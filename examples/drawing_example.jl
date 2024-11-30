using OmniParserIconDetectors
using OmniParserIconDetectors: load_image, save_image
using Colors, ImageIO, FileIO
using Colors: RGB, N0f8
using ImageDraw

# Create a blank white image
img = fill(RGB{N0f8}(1, 1, 1), 300, 1200)  # Height: 300px, Width: 1200px (3x larger)

# Draw numbers 0-9 horizontally with some spacing
for i in 0:9
    draw_number!(img, i, 60 + i * 105, 120, 3.0, RGB{N0f8}(0, 0, 0))
end

# Create two example detections with bounding boxes
detections = [
    DetectedItem(id = 1, confidence = 99.0, bbox = (50.0, 50.0, 200.0, 200.0)),
    DetectedItem(id = 22, confidence = 1.0, bbox = (250.0, 100.0, 400.0, 250.0))
]

# Draw the bounding boxes with confidence indicators
img = draw_detections(img, detections)

# Save the result
save_image("examples/drawing_example.png", img)
