module OmniParserIconDetectors

using ONNXRunTime
const ORT = ONNXRunTime
using DataDeps
using ImageBase
using ImageTransformations
using ImageIO
using Colors: RGB, N0f8, ColorTypes
using FileIO
using Statistics
using ImageDraw

export DetectedItem, IconDetectionModel
include("types.jl")

export load_detection_model
include("model.jl")

# export load_image, preprocess_image
include("image_processing.jl")

export draw_detections
# export draw_digit!, draw_number!, path_to_points, DIGIT_PATHS
include("drawing.jl")

export detect_icons
include("detection.jl")

# Register the ONNX model as a DataDep
function __init__()
    register(DataDep(
        "OmniParserIconDetector",
        """
        OmniParser Icon Detection Model

        Original source: https://github.com/microsoft/OmniParser
        Model: https://huggingface.co/microsoft/OmniParser
        """,
        "https://huggingface.co/onnx-community/OmniParser-icon_detect/resolve/main/onnx/model.onnx",
        "199626646b896fc40be49f30185f8c03a7ad066c24cb9ab73c17d0c6f3521f2c"
    ))
end

end # module
