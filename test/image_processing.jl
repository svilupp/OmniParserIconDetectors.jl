using OmniParserIconDetectors: load_image, save_image, prepare_image_tensor,
                               normalize_image_tensor, preprocess_image, resize_to_square

@testset "Image Processing" begin
    # Basic image loading/saving
    @test_throws ArgumentError load_image("nonexistent.jpg")
    test_img = load(joinpath(@__DIR__, "images", "test1.png"))
    @test test_img isa AbstractArray{<:ColorTypes.Color}

    # Test resize_to_square - progressing from simple to complex cases
    # Case 1: Square image stays square
    square_img = fill(RGB{N0f8}(1, 1, 1), 100, 100)
    resized_square, scale = resize_to_square(square_img, 640)
    @test size(resized_square) == (640, 640)
    @test scale ≈ 6.4

    # Case 2: Landscape image gets padded vertically
    landscape = fill(RGB{N0f8}(1, 1, 1), 300, 400)
    resized_landscape, scale = resize_to_square(landscape, 640)
    @test size(resized_landscape) == (640, 640)
    @test scale ≈ 1.6
    @test all(resized_landscape[481:end, :] .== RGB{N0f8}(0, 0, 0))  # Check padding

    # Case 3: Portrait image gets padded horizontally
    portrait = fill(RGB{N0f8}(1, 1, 1), 400, 300)
    resized_portrait, scale = resize_to_square(portrait, 640)
    @test size(resized_portrait) == (640, 640)
    @test scale ≈ 1.6
    @test all(resized_portrait[:, 481:end] .== RGB{N0f8}(0, 0, 0))  # Check padding

    # Test prepare_image_tensor with increasing complexity
    # Case 1: Basic RGB image conversion
    small_rgb = fill(RGB{N0f8}(1, 0, 0), 10, 10)  # Pure red image
    tensor = prepare_image_tensor(small_rgb)
    @test size(tensor) == (1, 3, 10, 10)
    @test tensor[1, 1, :, :] ≈ ones(Float32, 10, 10)  # Red channel
    @test all(tensor[1, 2:3, :, :] .≈ 0.0f0)  # Green and Blue channels

    # Test normalize_image_tensor
    # Case 1: Basic normalization check
    test_tensor = reshape(Float32.(collect(1:12)), 1, 3, 2, 2)
    normalized = normalize_image_tensor(copy(test_tensor))
    @test size(normalized) == size(test_tensor)
    @test eltype(normalized) == Float32

    # Case 2: Invalid channel count
    wrong_tensor = reshape(Float32.(collect(1:8)), 1, 2, 2, 2)
    @test_throws AssertionError normalize_image_tensor(wrong_tensor)

    # Test full preprocess_image pipeline
    # Case 1: Standard image processing
    processed, scale = preprocess_image(test_img)
    @test size(processed)[1:2] == (1, 3)  # Batch and channel dimensions
    @test size(processed)[3] == size(processed)[4] == 640  # Square output
    @test eltype(processed) == Float32

    # Case 2: Small image processing
    small_img = imresize(test_img, ratio = 0.1)
    processed_small, scale_small = preprocess_image(small_img)
    @test size(processed_small)[3] == size(processed_small)[4] == 640
    @test scale_small > 1.0  # Image was upscaled
end