using Test
using OmniParserIconDetectors
using Images
using FileIO

@testset "OmniParserIconDetectors.jl" begin
    @testset "Image Processing" begin
        test_img = load(joinpath(@__DIR__, "images", "test.png"))
        scaled_img, ratio = scale_image_max_640(test_img)
        @test maximum(size(scaled_img)) <= 640

        # Test aspect ratio preservation
        orig_ratio = size(test_img)[2] / size(test_img)[1]
        scaled_ratio = size(scaled_img)[2] / size(scaled_img)[1]
        @test isapprox(orig_ratio, scaled_ratio, rtol=0.01)
    end

    @testset "Icon Detection" begin
        test_img_path = joinpath(@__DIR__, "images", "test.png")
        detections = detect_icons(test_img_path)
        @test isa(detections, Vector{IconDetection})

        if !isempty(detections)
            detection = first(detections)
            @test isa(detection.bbox, NTuple{4,Float64})
            @test 0 ≤ detection.confidence ≤ 100

            # Test detection thresholds
            @test detection.confidence >= 15.0  # Minimum confidence threshold

            # Test box dimensions
            width = detection.bbox[3] - detection.bbox[1]
            height = detection.bbox[4] - detection.bbox[2]
            @test width >= 15 && height >= 15  # Minimum size check
            @test max(width, height) / min(width, height) <= 5.0  # Aspect ratio check
        end
    end

    @testset "Visualization" begin
        test_img = load(joinpath(@__DIR__, "images", "test.png"))
        detections = detect_icons(joinpath(@__DIR__, "images", "test.png"))
        img_with_boxes = draw_detections(test_img, detections)
        @test size(img_with_boxes) == size(test_img)
        @test eltype(img_with_boxes) == eltype(test_img)
    end
end
