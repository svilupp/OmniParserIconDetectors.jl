"""
    calculate_iou(box1::NTuple{4,Float64}, box2::NTuple{4,Float64})

Calculate Intersection over Union (IoU) between two bounding boxes.
Each box is represented as (x1, y1, x2, y2).
"""
function calculate_iou(box1::NTuple{4, Float64}, box2::NTuple{4, Float64})
    x1_1, y1_1, x2_1, y2_1 = box1
    x1_2, y1_2, x2_2, y2_2 = box2

    # Calculate intersection coordinates
    x1_i = max(x1_1, x1_2)
    y1_i = max(y1_1, y1_2)
    x2_i = min(x2_1, x2_2)
    y2_i = min(y2_1, y2_2)

    # Check if boxes overlap
    if x2_i <= x1_i || y2_i <= y1_i
        return 0.0
    end

    # Calculate areas
    intersection = (x2_i - x1_i) * (y2_i - y1_i)
    area1 = (x2_1 - x1_1) * (y2_1 - y1_1)
    area2 = (x2_2 - x1_2) * (y2_2 - y1_2)
    union = area1 + area2 - intersection

    return intersection / union
end

"""
    detect_icons(model::IconDetectionModel, image_path::String;
        verbose::Bool = false, iou_threshold::Real = 0.1, box_threshold::Real = 0.15,
        min_scaled_confidence::Integer = 25)

Detect icons in the given image and return their coordinates and confidence scores.

Arguments:
- model: The IconDetectionModel to use for detection
- image_path: Path to the image file to analyze
- verbose: Whether to print detection statistics (default: false)
- iou_threshold: Minimum Intersection over Union threshold for merging overlapping boxes (default: 0.1, smaller is more strict)
- box_threshold: Minimum confidence threshold for keeping a detection box (default: 0.15, ranges from 0 to 1)
- min_scaled_confidence: Minimum scaled confidence score (0-100) as a percentage of the highest confidence found (default: 25)

Returns: Vector of DetectedItem objects, where each item contains:
- id: Unique identifier for the detection
- label: Class label (currently unused)
- confidence: Detection confidence score (0-100)
- bbox: Bounding box coordinates as (x1,y1,x2,y2) tuple
"""
function detect_icons(model::IconDetectionModel, image_path::String;
        verbose::Bool = false, iou_threshold::Real = 0.1, box_threshold::Real = 0.15,
        min_scaled_confidence::Integer = 25)
    # Load and preprocess image
    img = load_image(image_path)
    input_tensor, scale = preprocess_image(img)

    # Prepare input tensor
    input_dict = Dict("images" => input_tensor)

    # Run inference and get raw detections
    outputs = model.session(input_dict)
    raw_detections = outputs["output0"]

    # Get confidence scores (last channel)
    confidence_scores = @view raw_detections[1, 5, :]
    conf_min, conf_max = minimum(confidence_scores), maximum(confidence_scores)

    if verbose
        # Sort for top 10 scores
        sorted_conf = sort(vec(confidence_scores), rev = true)
        top_10_conf = join([string(round(c, digits = 4)) for c in sorted_conf[1:10]], ", ")

        @info """
        Detection Statistics:
        Confidence scores:
          Min: $(conf_min)
          Max: $(conf_max)
          Mean: $(mean(confidence_scores))
          Std: $(std(confidence_scores))

        Top 10 raw confidence scores: $top_10_conf
        """
    end

    # Reshape to get (5, 8400) - first remove the batch dimension, then transpose correctly
    detections = dropdims(raw_detections, dims = 1)  # Now (5, 8400)

    # Process detections
    results = DetectedItem[]
    raw_results = []

    # Process all detections
    n_total = size(detections, 2)  # Changed from size(..., 1)
    n_above_threshold = 0

    for i in axes(detections, 2)  # Changed from axes(..., 1)
        cx, cy, w, h, conf = detections[:, i]  # Changed from detections[i, :]
        x1, y1, x2, y2 = yolo_to_xxyy((cx, cy, w, h))

        ## Check confidence threshold, skip if below
        conf < box_threshold && continue

        # Convert confidence to relative percentage (0-100)
        conf_percent = 100.0 * (conf / conf_max)

        # More strict threshold for initial detection
        if conf_percent >= min_scaled_confidence
            n_above_threshold += 1

            # Scale coordinates back to original image size and ensure correct ordering
            x1, x2 = minmax(x1 / scale, x2 / scale)
            y1, y2 = minmax(y1 / scale, y2 / scale)

            # Calculate box dimensions
            width = x2 - x1
            height = y2 - y1

            # Filter out unreasonable boxes (too small, too thin, or too large)
            min_dimension = min(width, height)
            aspect_ratio = max(width, height) / min_dimension
            if width > 15 && height > 15 &&  # Increased minimum size
               aspect_ratio < 5.0 &&        # Added aspect ratio check
               width < 0.7 * size(img, 2) &&
               height < 0.7 * size(img, 1)
                push!(raw_results, (bbox = (x1, y1, x2, y2), conf = conf_percent))
            end
        end
    end

    if verbose
        @info """
        Detection Results:
          Total boxes processed: $n_total
          Boxes above threshold: $n_above_threshold
          Boxes after size filtering: $(length(raw_results))
        """
    end

    # Sort by confidence and apply stricter NMS
    sort!(raw_results, by = x -> x.conf, rev = true)

    # Apply NMS with stricter threshold
    counter = 1
    while !isempty(raw_results)
        best_detection = popfirst!(raw_results)
        push!(results,
            DetectedItem(; id = counter, bbox = best_detection.bbox,
                confidence = round(best_detection.conf, digits = 2)))
        counter += 1

        # Filter out overlapping detections with stricter IoU threshold
        filter!(
            r -> calculate_iou(r.bbox, best_detection.bbox) <= iou_threshold, raw_results)
    end

    return results
end

"""
    yolo_to_xxyy(cxcywh::NTuple{4,Real})

Convert bounding box from YOLO format (cx, cy, w, h) to (x1, y1, x2, y2).
"""
function yolo_to_xxyy(cxcywh::NTuple{4, Real})
    cx, cy, w, h = cxcywh
    x1 = cx - w / 2
    y1 = cy - h / 2
    x2 = cx + w / 2
    y2 = cy + h / 2
    return (x1, y1, x2, y2)
end