using OmniParserIconDetectors
using FileIO

# Load and process image
img_path = joinpath(@__DIR__, "images", "test.png")
img = load(img_path)

# Detect icons
detections = detect_icons(img_path)

# Draw detections on image
img_with_boxes = draw_detections(img, detections)

# Save the result
output_path = joinpath(@__DIR__, "images", "test_with_detections.png")
save(output_path, img_with_boxes)

println("Detection visualization saved to: $output_path")
