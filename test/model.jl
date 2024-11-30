@testset "Model Loading" begin
    # Test loading from specific path
    test_model_path = joinpath(@__DIR__, "data", "test_model.onnx")
    @test_throws AssertionError load_detection_model("nonexistent_path.onnx")

    # Create a dummy ONNX file for testing
    mkpath(dirname(test_model_path))
    write(test_model_path, "dummy content")

    # Test loading from path (this might fail if the file isn't a valid ONNX model)
    @test_throws Exception load_detection_model(test_model_path)

    # Test loading from datadep
    # First ensure DATADEPS_ALWAYS_ACCEPT is set
    old_env = get(ENV, "DATADEPS_ALWAYS_ACCEPT", nothing)
    ENV["DATADEPS_ALWAYS_ACCEPT"] = "true"

    # Test the datadep model loading
    @test load_detection_model() isa IconDetectionModel

    path = DataDeps.datadep"OmniParserIconDetector"
    @test load_detection_model(joinpath(path, "model.onnx")) isa IconDetectionModel

    # Restore original ENV setting
    if isnothing(old_env)
        delete!(ENV, "DATADEPS_ALWAYS_ACCEPT")
    else
        ENV["DATADEPS_ALWAYS_ACCEPT"] = old_env
    end

    # Cleanup
    rm(dirname(test_model_path), recursive = true)
end
