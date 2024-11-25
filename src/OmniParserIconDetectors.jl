module OmniParserIconDetectors

# Set DataDeps to always accept downloads
ENV["DATADEPS_ALWAYS_ACCEPT"] = "true"

using ONNX
using ONNXRunTime
using DataDeps
using ImageBase
using ImageTransformations
using Images
using FileIO
using Statistics
using ImageDraw

include("image_processing.jl")
include("visualization.jl")

export IconDetection, detect_icons, calculate_iou, draw_detections, scale_image_max_640

"""
    IconDetection

Represents a detected icon in an image.

# Fields
- `bbox::NTuple{4,Float64}`: Bounding box coordinates (x1, y1, x2, y2) in pixels
- `confidence::Float64`: Detection confidence score (0-100)
"""
struct IconDetection
    bbox::NTuple{4,Float64}
    confidence::Float64
end

"""
    Base.show(io::IO, detection::IconDetection)

Custom display for IconDetection objects.
"""
function Base.show(io::IO, detection::IconDetection)
    print(io, "IconDetection(bbox=($(detection.bbox)), confidence=$(detection.confidence)%)")
end

"""
    calculate_iou(box1::NTuple{4,Float64}, box2::NTuple{4,Float64})

Calculate Intersection over Union (IoU) between two bounding boxes.
Each box is represented as (x1, y1, x2, y2).
"""
function calculate_iou(box1::NTuple{4,Float64}, box2::NTuple{4,Float64})
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

# Register the ONNX model as a DataDep
function __init__()
    register(DataDep(
        "OmniParserIconDetector",
        """
        OmniParser Icon Detection Model

        Original source: https://github.com/microsoft/OmniParser
        Model: https://huggingface.co/onnx-community/OmniParser-icon_detect
        """,
        "https://huggingface.co/onnx-community/OmniParser-icon_detect/resolve/main/onnx/model.onnx",
    ))
end

"""
    preprocess_image(img)

Preprocess the image for the ONNX model:
1. Scale to 640px on the longest side
2. Convert to RGB array
3. Normalize pixel values
"""
function preprocess_image(img)
    # Scale image using the dedicated function
    scaled_img, scale = scale_image_max_640(img)

    # Convert to RGB array and normalize to [0,1]
    rgb_array = Float32.(channelview(RGB.(scaled_img)))

    # Normalize to mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]
    means = reshape(Float32[0.485, 0.456, 0.406], (3,1,1))
    stds = reshape(Float32[0.229, 0.224, 0.225], (3,1,1))
    rgb_array = (rgb_array .- means) ./ stds

    # Get dimensions of scaled image
    scaled_h, scaled_w = size(rgb_array)[2:3]

    # Pad to 640x640 if needed
    padded = zeros(Float32, 3, 640, 640)
    padded[:, 1:scaled_h, 1:scaled_w] = rgb_array

    # Add batch dimension (NCHW)
    input_tensor = reshape(padded, (1, 3, 640, 640))
    return input_tensor, scale
end

"""
    detect_icons(image_path::String)

Detect icons in the given image and return their coordinates and confidence scores.
Returns: Array of IconDetection objects
"""
function detect_icons(image_path::String)
    # Load and preprocess image
    img = load(image_path)
    input_tensor, scale = preprocess_image(img)

    # Get model path
    model_path = joinpath(datadep"OmniParserIconDetector", "model.onnx")

    # Create inference session
    session = ONNXRunTime.load_inference(model_path)

    # Prepare input tensor
    input_dict = Dict("images" => input_tensor)

    # Run inference and get raw detections
    outputs = session(input_dict)
    raw_detections = outputs["output0"]

    # Get confidence scores (last channel)
    confidence_scores = @view raw_detections[1, 5, :]
    conf_min, conf_max = minimum(confidence_scores), maximum(confidence_scores)

    println("\nConfidence score statistics:")
    println("  Min: ", conf_min)
    println("  Max: ", conf_max)
    println("  Mean: ", mean(confidence_scores))
    println("  Std: ", std(confidence_scores))

    # Print top 10 raw confidence scores
    sorted_conf = sort(vec(confidence_scores), rev=true)
    println("\nTop 10 raw confidence scores:")
    for (i, conf) in enumerate(sorted_conf[1:10])
        println("  $i: $conf")
    end

    # Reshape to get (8400, 5) - first remove the batch dimension, then transpose
    detections = permutedims(dropdims(raw_detections, dims=1), (2, 1))

    # Process detections
    results = IconDetection[]
    raw_results = []

    # Process all detections
    n_total = size(detections, 1)
    n_above_threshold = 0

    # Find global max confidence for relative scaling
    max_conf = maximum(view(detections, :, 5))

    for i in 1:n_total
        x1, y1, x2, y2, conf = detections[i, :]

        # Convert confidence to relative percentage (0-100)
        conf_raw = Float64(conf)
        conf_percent = 100.0 * (conf_raw / max_conf)

        # More strict threshold for initial detection
        if conf_percent > 15.0  # Increased from 10.0 to 15.0 for better quality detections
            n_above_threshold += 1

            # Scale coordinates back to original image size and ensure correct ordering
            x1, x2 = minmax(x1/scale, x2/scale)
            y1, y2 = minmax(y1/scale, y2/scale)

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
                push!(raw_results, (bbox=(x1, y1, x2, y2), conf=conf_percent))
            end
        end
    end

    println("\nDetection statistics:")
    println("  Total boxes processed: $n_total")
    println("  Boxes above threshold: $n_above_threshold")
    println("  Boxes after size filtering: $(length(raw_results))")

    # Sort by confidence and apply stricter NMS
    sort!(raw_results, by=x->x.conf, rev=true)

    # Apply NMS with stricter threshold
    while !isempty(raw_results)
        best_detection = popfirst!(raw_results)
        push!(results, IconDetection(best_detection.bbox, round(best_detection.conf, digits=2)))

        # Filter out overlapping detections with stricter IoU threshold
        filter!(r -> calculate_iou(r.bbox, best_detection.bbox) < 0.2, raw_results)
    end

    return results
end

end # module
