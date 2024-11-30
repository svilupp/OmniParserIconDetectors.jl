
@testset "types.jl" begin

    # Mock ONNX session for testing
    root_path = DataDeps.datadep"OmniParserIconDetector"
    path = joinpath(root_path, "model.onnx")
    mock_session = ORT.load_inference(path)
    model = IconDetectionModel(mock_session)
    @test model.session === mock_session

    # Test string constructor
    @test IconDetectionModel(path) isa IconDetectionModel

    # Test show method
    io = IOBuffer()
    show(io, model)
    @test !isempty(String(take!(io)))

    # Test DetectedItem constructor and defaults
    @test DetectedItem isa Type

    # Test default constructor
    item = DetectedItem()
    @test item.id == 0
    @test item.label == ""
    @test item.confidence == 0.0
    @test item.bbox == (0.0, 0.0, 0.0, 0.0)

    # Test kwarg constructor with custom values
    custom_item = DetectedItem(
        id = 1,
        label = "button",
        confidence = 95.5,
        bbox = (10.0, 20.0, 30.0, 40.0)
    )
    @test custom_item.id == 1
    @test custom_item.label == "button"
    @test custom_item.confidence == 95.5
    @test custom_item.bbox == (10.0, 20.0, 30.0, 40.0)

    # Test show method for DetectedItem
    io = IOBuffer()
    show(io, custom_item)
    output = String(take!(io))
    @test occursin("DetectedItem", output)
    @test occursin("id=1", output)
    @test occursin("confidence=95.5", output)
    @test occursin("bbox=(10.0, 20.0, 30.0, 40.0)", output)
end
