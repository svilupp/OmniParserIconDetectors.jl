using Images, FileIO, Luxor
using OmniParserIconDetectors

# Load and process image
img_path = joinpath(@__DIR__, "images", "test.png")
detections = detect_icons(img_path)

# Create a new drawing with the same dimensions as the input image
img = load(img_path)
height, width = size(img)
Drawing(width, height, joinpath(@__DIR__, "output", "detections.png"))

# Set up the drawing
background("white")
# Draw the background image
img_matrix = convert(Matrix{RGB{N0f8}}, img)
placeimage(img_matrix, O, :centered)

# Draw boxes with different colors based on confidence
for detection in detections
    (x1, y1, x2, y2) = detection.bbox
    conf = detection.confidence * 100  # Convert to percentage

    # Color gradient from red (low confidence) to green (high confidence)
    # Clamp confidence to 0-100 range
    conf_clamped = clamp(conf, 0, 100)
    r = (100 - conf_clamped)/100
    g = conf_clamped/100
    b = 0
    sethue(r, g, b)

    # Draw rectangle with thicker lines
    setline(3)
    rect(Point(x1, y1), x2-x1, y2-y1, :stroke)

    # Add confidence score text with better visibility
    fontsize(14)
    text("$(round(Int, conf_clamped))%", Point(x1, y1-10))
end

# Finish the drawing
finish()

println("Visualization saved to test/output/detections.png")
