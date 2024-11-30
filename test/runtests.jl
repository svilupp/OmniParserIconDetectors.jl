using Test
using OmniParserIconDetectors
using ONNXRunTime
const ORT = ONNXRunTime
using FileIO, ImageBase, ImageIO, ImageDraw
using ImageTransformations
using ImageBase
using Colors: ColorTypes, RGB, N0f8
using DataDeps
using Aqua

@testset "OmniParserIconDetectors.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(OmniParserIconDetectors; persistent_tasks = false)
    end
    include("types.jl")
    include("model.jl")
    include("image_processing.jl")
    include("detection.jl")
    # include("drawing.jl")
end
