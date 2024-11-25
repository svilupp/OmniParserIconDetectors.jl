# OmniParserIconDetectors.jl

A lightweight Julia wrapper for the OmniParser icon detection model using ONNXRuntime.jl.

## Installation

```julia
using Pkg
# Install the package
Pkg.add(url="https://github.com/svilupp/OmniParserIconDetectors.jl")

# Important: This package requires a specific version of ONNXRunTime.jl
Pkg.add(url="https://github.com/svilupp/ONNXRunTime.jl#mac120")
```

## Usage

```julia
using OmniParserIconDetectors
using FileIO

# Detect icons in an image
detections = detect_icons("path/to/your/image.png")

# Visualize detections (optional)
img = load("path/to/your/image.png")
img_with_boxes = draw_detections(img, detections)
save("output.png", img_with_boxes)

# Each detection contains:
# - bbox: Tuple of (x1, y1, x2, y2) coordinates in original image space
# - confidence: Detection confidence score (0-100)
```

## Features

- Automatic model download using DataDeps.jl
- Image preprocessing and scaling to 640px on the longest side
- Strict detection filtering:
  - Minimum confidence threshold: 15%
  - Minimum detection size: 15x15 pixels
  - Maximum aspect ratio: 5.0
  - Non-Maximum Suppression (NMS) with IoU threshold of 0.2
- Coordinate translation back to original image space
- Visualization tools:
  - Color-coded confidence scores (red to green)
  - 3-pixel thick bounding boxes
  - Proportional confidence indicators
  - White background for better visibility

## Model Information

This package uses the OmniParser icon detection model from Microsoft, available at:
https://huggingface.co/onnx-community/OmniParser-icon_detect

The model is licensed under AGPL.

## Dependencies

- ONNXRunTime.jl (specific version from https://github.com/svilupp/ONNXRunTime.jl#mac120)
- DataDeps.jl
- ImageBase.jl
- ImageTransformations.jl
- Images.jl
- FileIO.jl
