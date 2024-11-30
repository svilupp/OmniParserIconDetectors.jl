# These are actual character outlines from a common sans-serif font
# Each digit is defined as a series of commands:
# M = moveto, L = lineto, C = curveto (cubic bezier), Z = closepath
const DIGIT_PATHS = Dict(
    '0' => [
        ('M', 4.0, 1.5),  # Move to start
        ('C', 2.0, 1.5, 0.5, 3.5, 0.5, 7.0),  # Left curve
        ('C', 0.5, 10.5, 2.0, 12.5, 4.0, 12.5),  # Bottom curve
        ('C', 6.0, 12.5, 7.5, 10.5, 7.5, 7.0),  # Right curve
        ('C', 7.5, 3.5, 6.0, 1.5, 4.0, 1.5),  # Top curve
        ('Z',)  # Close path
    ],
    '1' => [
        ('M', 1.5, 8.0),   # Move start point more left and lower (was 2.5, 10.0)
        ('L', 4.0, 1.5),   # Keep top point the same
        ('L', 4.0, 12.5),  # Vertical line stays the same
        ('Z',)
    ],
    '2' => [
        ('M', 1.0, 3.5),
        ('C', 1.0, 2.0, 2.0, 1.5, 3.5, 1.5),
        ('C', 5.0, 1.5, 7.0, 2.0, 7.0, 4.0),
        ('C', 7.0, 8.0, 1.0, 9.0, 1.0, 12.5),
        ('L', 7.0, 12.5),
        ('Z',)
    ],
    '3' => [
        ('M', 1.0, 3.0),
        ('C', 1.0, 2.0, 2.0, 1.5, 3.5, 1.5),
        ('C', 5.0, 1.5, 7.0, 2.5, 7.0, 4.0),
        ('C', 7.0, 5.5, 6.0, 6.5, 4.5, 7.0),
        ('C', 6.0, 7.5, 7.0, 8.5, 7.0, 10.0),
        ('C', 7.0, 11.5, 5.0, 12.5, 3.5, 12.5),
        ('C', 2.0, 12.5, 1.0, 12.0, 1.0, 11.0),
        ('Z',)
    ],
    '4' => [
        ('M', 5.5, 1.5),
        ('L', 1.0, 8.5),
        ('L', 7.5, 8.5),
        ('M', 5.5, 1.5),
        ('L', 5.5, 12.5),
        ('Z',)
    ],
    '5' => [
        ('M', 6.5, 1.5),
        ('L', 2.0, 1.5),
        ('L', 1.5, 7.0),
        ('C', 2.0, 6.5, 3.0, 6.0, 4.0, 6.0),
        ('C', 5.5, 6.0, 7.0, 7.0, 7.0, 9.5),
        ('C', 7.0, 11.5, 5.5, 12.5, 3.5, 12.5),
        ('C', 2.0, 12.5, 1.0, 12.0, 1.0, 11.0),
        ('Z',)
    ],
    '6' => [
        ('M', 6.5, 2.0),
        ('C', 5.5, 1.5, 4.5, 1.5, 3.5, 1.5),
        ('C', 2.0, 1.5, 0.5, 3.0, 0.5, 7.0),
        ('C', 0.5, 11.0, 2.0, 12.5, 4.0, 12.5),
        ('C', 5.5, 12.5, 7.0, 11.5, 7.0, 9.5),
        ('C', 7.0, 7.5, 5.5, 6.5, 4.0, 6.5),
        ('C', 3.0, 6.5, 2.0, 7.0, 1.5, 7.5),
        ('Z',)
    ],
    '7' => [
        ('M', 1.0, 1.5),
        ('L', 7.0, 1.5),
        ('L', 3.5, 12.5),
        ('M', 2.0, 5.5),
        ('L', 5.5, 5.5),
        ('Z',)
    ],
    '8' => [
        ('M', 4.0, 1.5),
        ('C', 2.0, 1.5, 0.5, 2.5, 0.5, 4.0),
        ('C', 0.5, 5.5, 2.0, 6.5, 4.0, 7.0),
        ('C', 6.0, 7.5, 7.5, 8.5, 7.5, 10.0),
        ('C', 7.5, 11.5, 6.0, 12.5, 4.0, 12.5),
        ('C', 2.0, 12.5, 0.5, 11.5, 0.5, 10.0),
        ('C', 0.5, 8.5, 2.0, 7.5, 4.0, 7.0),
        ('C', 6.0, 6.5, 7.5, 5.5, 7.5, 4.0),
        ('C', 7.5, 2.5, 6.0, 1.5, 4.0, 1.5),
        ('Z',)
    ],
    '9' => [
        ('M', 1.5, 12.0),
        ('C', 2.5, 12.5, 3.5, 12.5, 4.5, 12.5),
        ('C', 6.0, 12.5, 7.5, 11.0, 7.5, 7.0),
        ('C', 7.5, 3.0, 6.0, 1.5, 4.0, 1.5),
        ('C', 2.5, 1.5, 1.0, 2.5, 1.0, 4.5),
        ('C', 1.0, 6.5, 2.5, 7.5, 4.0, 7.5),
        ('C', 5.0, 7.5, 6.0, 7.0, 6.5, 6.5),
        ('Z',)
    ]
)

"""
    path_to_points(path, scale::Real = 1.0, steps::Int = 30)

Convert a path of drawing commands into a sequence of points.

# Arguments
- `path`: Vector of tuples containing drawing commands ('M'=moveto, 'L'=lineto, 'C'=curveto)
- `scale::Real`: Scaling factor for the points (default: 1.0)
- `steps::Int`: Number of interpolation steps for curves and lines (default: 30)

# Returns
- Vector of (x,y) coordinate tuples representing the path
"""
function path_to_points(path, scale::Real = 1.0, steps::Int = 30)
    points = Tuple{Float64, Float64}[]
    current_pos = (0.0, 0.0)

    for cmd in path
        if cmd[1] == 'M'  # Move to
            current_pos = (cmd[2] * scale, cmd[3] * scale)
            push!(points, current_pos)
        elseif cmd[1] == 'L'  # Line to
            new_pos = (cmd[2] * scale, cmd[3] * scale)
            for t in range(0, 1, length = steps)
                x = current_pos[1] + t * (new_pos[1] - current_pos[1])
                y = current_pos[2] + t * (new_pos[2] - current_pos[2])
                push!(points, (x, y))
            end
            current_pos = new_pos
        elseif cmd[1] == 'C'  # Cubic Bezier
            p1 = current_pos
            p2 = (cmd[2] * scale, cmd[3] * scale)
            p3 = (cmd[4] * scale, cmd[5] * scale)
            p4 = (cmd[6] * scale, cmd[7] * scale)

            for t in range(0, 1, length = steps)
                # Cubic Bezier formula
                x = (1 - t)^3 * p1[1] +
                    3 * (1 - t)^2 * t * p2[1] +
                    3 * (1 - t) * t^2 * p3[1] +
                    t^3 * p4[1]
                y = (1 - t)^3 * p1[2] +
                    3 * (1 - t)^2 * t * p2[2] +
                    3 * (1 - t) * t^2 * p3[2] +
                    t^3 * p4[2]
                push!(points, (x, y))
            end
            current_pos = p4
        end
    end
    points
end

"""
    draw_digit!(img::AbstractMatrix, digit::Char, x::Int, y::Int,
                scale::Float64 = 1.0, color::ColorTypes.Color = RGB{N0f8}(1,1,1))

Draw a single digit character onto an image matrix.

# Arguments
- `img`: Target image matrix to draw on
- `digit`: Character ('0'-'9') to draw
- `x`: X-coordinate for digit placement
- `y`: Y-coordinate for digit placement  
- `scale`: Size scaling factor (default: 1.0)
- `color`: Color of the digit (default: white)
"""
function draw_digit!(img::AbstractMatrix, digit::Char, x::Int, y::Int,
        scale::Float64 = 1.0, color::ColorTypes.Color = RGB{N0f8}(1, 1, 1))
    if !haskey(DIGIT_PATHS, digit)
        return
    end

    points = path_to_points(DIGIT_PATHS[digit], scale)
    height, width = size(img)

    # Draw with multiple passes for thickness
    thickness = 1.5  # Adjust this value to control line thickness
    for offset_x in (-thickness):0.5:thickness
        for offset_y in (-thickness):0.5:thickness
            for (px, py) in points
                ix = round(Int, px + x + offset_x)
                iy = round(Int, py + y + offset_y)
                if 1 <= ix <= width && 1 <= iy <= height
                    # Anti-aliasing with smoother falloff
                    dx = (px + x + offset_x - ix)
                    dy = (py + y + offset_y - iy)
                    dist = sqrt(dx^2 + dy^2)
                    intensity = max(0.0, min(1.0, (1.5 - dist / sqrt(2))))
                    # Blend colors using intensity
                    img[iy, ix] = RGB{N0f8}(
                        (1 - intensity) * convert(Float64, img[iy, ix].r) +
                        intensity * color.r,
                        (1 - intensity) * convert(Float64, img[iy, ix].g) +
                        intensity * color.g,
                        (1 - intensity) * convert(Float64, img[iy, ix].b) +
                        intensity * color.b
                    )
                end
            end
        end
    end
end

"""
    draw_number!(img::AbstractMatrix, number::Number, x::Int, y::Int,
                scale::Float64 = 1.0, color::ColorTypes.Color = RGB{N0f8}(1,1,1))

Draw a number (including negative numbers) onto an image matrix.

# Arguments
- `img`: Target image matrix to draw on
- `number`: Number to draw (can be negative)
- `x`: X-coordinate for number placement
- `y`: Y-coordinate for number placement
- `scale`: Size scaling factor (default: 1.0)
- `color`: Color of the number (default: white)
"""
function draw_number!(img::AbstractMatrix, number::Number, x::Int, y::Int,
        scale::Float64 = 1.0, color::ColorTypes.Color = RGB{N0f8}(1, 1, 1))
    num_str = string(abs(number))
    offset = 0

    # Handle negative sign
    if number < 0
        for i in 1:round(Int, 4 * scale)
            ix = x + i + offset
            iy = y + round(Int, 7 * scale)
            if 1 <= ix <= size(img, 2) && 1 <= iy <= size(img, 1)
                img[iy, ix] = RGB{N0f8}(color.r, color.g, color.b)
            end
        end
        offset += round(Int, 8 * scale)
    end

    # Draw each digit
    for digit in num_str
        draw_digit!(img, digit, x + offset, y, scale, color)
        offset += round(Int, 8 * scale)  # Less spacing than previous version
    end
end

"""
    draw_label!(img::AbstractMatrix{C}, x1::Int, y1::Int,
                detection_id::Int, confidence::Float64, color::C; thickness::Int = 2)

Draw a detection label box with ID and confidence score.

# Arguments
- `img`: Target image matrix to draw on
- `x1`: X-coordinate for label placement
- `y1`: Y-coordinate for label placement
- `detection_id`: Detection ID number to display
- `confidence`: Confidence score (0-100) affecting label color
- `color`: Base color for the label box
- `thickness`: Line thickness for the box (default: 2)
"""
function draw_label!(img::AbstractMatrix{C}, x1::Int, y1::Int,
        detection_id::Int, confidence::Float64, color::C; thickness::Int = 2) where {C <:
                                                                                     ColorTypes.Color}
    height, width = size(img)

    # Calculate indicator dimensions based only on digits (30% smaller)
    indicator_height = 34  # Was 48
    digits = detection_id > 0 ? length(string(detection_id)) : 1
    indicator_width = round(Int, 17 * digits)  # Was 24 * digits

    # Add padding (scaled down)
    indicator_width += 8 + thickness  # Was 12 + thickness

    # Adjust position if label would go outside image bounds
    label_x = x1 - thickness  # Shift left by thickness to align with bbox
    label_y = y1

    if label_x + indicator_width > width
        label_x = width - indicator_width
    end

    if label_y - indicator_height < 1
        label_y = y1 + indicator_height
    end

    y_range = (label_y - indicator_height):label_y
    x_range = label_x:min(width, label_x + indicator_width)
    img[y_range, x_range] .= color

    # Calculate perceived brightness for text color
    t = min(1.0, confidence / 100.0)
    brightness = 0.299 * (1.0 - t) + 0.587 * t + 0.114 * 0.0
    text_color = brightness > 0.5 ? C(RGB(0.1, 0.1, 0.1)) : C(RGB(0.9, 0.9, 0.9))

    if detection_id > 0
        text_x = label_x + 4  # Was 6
        text_y = label_y - indicator_height + 3  # Was 4
        draw_number!(img, detection_id, text_x, text_y, 2.1, text_color)  # Scale was 3.0
    end
end

"""
    draw_bbox!(img::AbstractMatrix, x1::Int, y1::Int, x2::Int, y2::Int,
               color::ColorTypes.Color; thickness::Int = 2)

Draw a bounding box on an image with specified thickness.

# Arguments
- `img`: Target image matrix to draw on
- `x1`: Left X-coordinate of box
- `y1`: Top Y-coordinate of box
- `x2`: Right X-coordinate of box
- `y2`: Bottom Y-coordinate of box
- `color`: Color of the bounding box
- `thickness`: Line thickness (default: 2)
"""
function draw_bbox!(img::AbstractMatrix, x1::Int, y1::Int, x2::Int, y2::Int,
        color::ColorTypes.Color; thickness::Int = 2)
    height, width = size(img)

    # Draw thicker bounding box
    for offset in (-thickness):thickness
        # Top line - extend slightly beyond corners
        draw!(img,
            LineSegment(
                Point(clamp(x1 - thickness, 1, width), clamp(y1 + offset, 1, height)),
                Point(clamp(x2 + thickness, 1, width), clamp(y1 + offset, 1, height))),
            color)

        # Right line - extend slightly beyond corners
        draw!(img,
            LineSegment(
                Point(clamp(x2 + offset, 1, width), clamp(y1 - thickness, 1, height)),
                Point(clamp(x2 + offset, 1, width), clamp(y2 + thickness, 1, height))),
            color)

        # Bottom line - extend slightly beyond corners
        draw!(img,
            LineSegment(
                Point(clamp(x2 + thickness, 1, width), clamp(y2 + offset, 1, height)),
                Point(clamp(x1 - thickness, 1, width), clamp(y2 + offset, 1, height))),
            color)

        # Left line - extend slightly beyond corners
        draw!(img,
            LineSegment(
                Point(clamp(x1 + offset, 1, width), clamp(y2 + thickness, 1, height)),
                Point(clamp(x1 + offset, 1, width), clamp(y1 - thickness, 1, height))),
            color)
    end
end

"""
    draw_detections(img::AbstractMatrix{C},
        detections::AbstractVector{DetectedItem}; thickness::Int = 2,
        save_path::String = "", verbose::Bool = false) where {C <:
                                                              ColorTypes.Color}

Draw detection boxes on image `img` using the coordinates and confidence scores from `detections`.

Returns the annotated image.

# Arguments
- `img`: Input image matrix
- `detections`: Vector of DetectedItem objects containing detection information
- `thickness`: Line thickness for drawing boxes (default: 2)
- `save_path`: Optional path to save the annotated image (default: "")
- `verbose`: Whether to print information about the detection process (default: false)
"""
function draw_detections(img::AbstractMatrix{C},
        detections::AbstractVector{DetectedItem}; thickness::Int = 2,
        save_path::String = "", verbose::Bool = false) where {C <:
                                                              ColorTypes.Color}
    img_with_boxes = copy(img)
    height, width = size(img)

    for detection in detections
        # Skip if any bbox coordinates are outside image bounds
        x1, y1, x2, y2 = detection.bbox
        if x1 < 1 || y1 < 1 || x2 > width || y2 > height
            continue
        end

        # Calculate color based on confidence
        t = min(1.0, detection.confidence / 100.0)
        color = C(RGB(1.0 - t, t, 0.0))

        # Round coordinates
        (x1, y1, x2, y2) = map(x -> round(Int, x), detection.bbox)

        # Draw bounding box using new function
        draw_bbox!(img_with_boxes, x1, y1, x2, y2, color; thickness)

        # Draw label
        draw_label!(img_with_boxes, x1, y1, detection.id, detection.confidence, color;
            thickness)
    end

    if !isempty(save_path)
        save_image(save_path, img_with_boxes)
        verbose && @info "Saved annotated image to $save_path"
    end
    return img_with_boxes
end

"""
    draw_detections(image_path::String, detections::AbstractVector{DetectedItem}; 
                   thickness::Int=2, save_path::String="") 

Draw detection boxes on an image loaded from `image_path`. Returns the annotated image.

# Arguments
- `image_path`: Path to the input image
- `detections`: Vector of DetectedItem objects to draw
- `thickness`: Line thickness for drawing boxes (default: 2)
- `save_path`: Optional path to save the annotated image (default: "")

# Returns
- The annotated image with detection boxes drawn
"""
function draw_detections(image_path::String, detections::AbstractVector{DetectedItem};
        thickness::Int = 2, save_path::String = "")
    img = load_image(image_path)
    return draw_detections(img, detections; thickness = thickness, save_path = save_path)
end
