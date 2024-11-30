
abstract type AbstractDetectionModel end

"""
    IconDetectionModel

OmniParser model for icon detection, including the ONNX session for inference.

Returns a functor `model(img)` that returns a vector of `DetectedItem`.
"""
struct IconDetectionModel <: AbstractDetectionModel
    session::ORT.InferenceSession
end
function Base.show(io::IO, result::AbstractDetectionModel)
    dump(io, result; maxdepth = 1)
end
function IconDetectionModel(path::String)
    return IconDetectionModel(ORT.load_inference(path))
end
"""
    (model::IconDetectionModel)(img; kwargs...)

Run inference on `img` using the IconDetectionModel and function `detect_icons`.
"""
function (model::IconDetectionModel)(img; kwargs...)
    return detect_icons(model, img; kwargs...)
end

"""
    DetectedItem

A struct to hold the icon detection `bbox` together with its confidence and ID.
"""
@kwdef struct DetectedItem
    id::Int = 0
    label::String = ""
    confidence::Float64 = 0.0
    bbox::NTuple{4, Float64} = (0.0, 0.0, 0.0, 0.0)
end
"""
    Base.show(io::IO, detection::IconDetection)

Custom display for IconDetection objects.
"""
function Base.show(io::IO, detection::DetectedItem)
    print(
        io, "DetectedItem(id=$(detection.id), bbox=$(detection.bbox), confidence=$(detection.confidence)%)")
end
