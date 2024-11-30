"""
    load_detection_model(path::String)

Loads an onnx version of the `IconDetectionModel` from a local path (when pre-downloaded).
"""
function load_detection_model(path::String)
    @assert isfile(path) "File at path $path does not exist"
    session = ORT.load_inference(path)
    return IconDetectionModel(session)
end

"""
    load_detection_model()

Downloads the model weights from HuggingFace and returns an `IconDetectionModel`.

Requires `ENV["DATADEPS_ALWAYS_ACCEPT"] = "true"` to be set before calling this function.
"""
function load_detection_model()
    get(ENV, "DATADEPS_ALWAYS_ACCEPT", "false") != "true" &&
        @warn "DATADEPS_ALWAYS_ACCEPT is not set, download might fail!"
    root = datadep"OmniParserIconDetector"
    path = joinpath(root, "model.onnx")
    @assert isfile(path) "File at path $path does not exist"
    session = ORT.load_inference(path)
    return IconDetectionModel(session)
end
