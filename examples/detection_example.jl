# Set DataDeps to always accept downloads
ENV["DATADEPS_ALWAYS_ACCEPT"] = "true"

using OmniParserIconDetectors
using OmniParserIconDetectors: load_image, preprocess_image, draw_detections

model = load_detection_model()

img = joinpath(@__DIR__, "..", "test", "images", "test1.png")
detections = detect_icons(model, img)
out = draw_detections(img, detections; save_path = "examples/detection_example.png")

# Or use the model directly as a functor
detections = model(img)
out = draw_detections(img, detections; save_path = "examples/detection_example.png")

# Set verbose=true to get more information about the detection process
detections = model(img; verbose = true)
