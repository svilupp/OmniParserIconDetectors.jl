using OmniParserIconDetectors: path_to_points, draw_digit!, draw_number!, draw_label!,
                               draw_bbox!, draw_detections

# Test path_to_points function
@testset "path_to_points" begin
    # Test simple move command
    simple_path = [('M', 1.0, 1.0)]
    points = path_to_points(simple_path)
    @test length(points) == 1
    @test points[1] == (1.0, 1.0)

    # Test line command with scaling
    line_path = [('M', 0.0, 0.0), ('L', 1.0, 1.0)]
    points = path_to_points(line_path, 2.0, 3)
    @test length(points) == 4  # start point + 3 interpolated points
    @test points[1] == (0.0, 0.0)
    @test points[end] == (2.0, 2.0)  # scaled by 2.0

    # Test cubic bezier curve
    curve_path = [('M', 0.0, 0.0), ('C', 1.0, 0.0, 1.0, 1.0, 0.0, 1.0)]
    points = path_to_points(curve_path, 1.0, 3)
    @test length(points) > 2  # Should have multiple interpolated points
end

# Test draw_digit! function
@testset "draw_digit!" begin
    # Create test image
    img = zeros(RGB{N0f8}, 20, 20)

    # Test drawing digit '1'
    draw_digit!(img, '1', 5, 5)
    @test any(x -> x != RGB{N0f8}(0, 0, 0), img)  # Should have modified some pixels

    # Test invalid digit
    img_before = copy(img)
    draw_digit!(img, 'A', 5, 5)  # Invalid digit
    @test all(img .== img_before)  # Should not modify image

    # Test scaling
    img_scaled = zeros(RGB{N0f8}, 40, 40)
    draw_digit!(img_scaled, '1', 10, 10, 2.0)
    @test any(x -> x != RGB{N0f8}(0, 0, 0), img_scaled)
end

# Test draw_number! function
@testset "draw_number!" begin
    # Test positive number
    img = zeros(RGB{N0f8}, 30, 50)
    draw_number!(img, 42, 5, 5)
    @test any(x -> x != RGB{N0f8}(0, 0, 0), img)

    # Test negative number
    img_neg = zeros(RGB{N0f8}, 30, 50)
    draw_number!(img_neg, -7, 5, 5)
    @test any(x -> x != RGB{N0f8}(0, 0, 0), img_neg)

    # Test zero
    img_zero = zeros(RGB{N0f8}, 30, 50)
    draw_number!(img_zero, 0, 5, 5)
    @test any(x -> x != RGB{N0f8}(0, 0, 0), img_zero)
end

# Test draw_label! function
@testset "draw_label!" begin
    img = zeros(RGB{N0f8}, 50, 50)
    color = RGB{N0f8}(1, 0, 0)  # Red color

    # Test basic label drawing
    draw_label!(img, 10, 20, 1, 50.0, color)
    @test any(x -> x == color, img)

    # Test label at image boundary
    img_boundary = zeros(RGB{N0f8}, 50, 50)
    draw_label!(img_boundary, 45, 5, 2, 75.0, color)
    @test any(x -> x == color, img_boundary)

    # Test with different confidence values
    img_conf = zeros(RGB{N0f8}, 50, 50)
    draw_label!(img_conf, 10, 20, 3, 100.0, color)
    @test any(x -> x == color, img_conf)
end

# Test draw_bbox! function
@testset "draw_bbox!" begin
    img = zeros(RGB{N0f8}, 100, 100)
    color = RGB{N0f8}(1, 0, 0)

    # Test basic bbox drawing
    draw_bbox!(img, 20, 20, 40, 40, color)
    @test any(x -> x == color, img)

    # Test bbox at image boundary
    img_boundary = zeros(RGB{N0f8}, 100, 100)
    draw_bbox!(img_boundary, 1, 1, 99, 99, color)
    @test any(x -> x == color, img_boundary)

    # Test with different thickness
    img_thick = zeros(RGB{N0f8}, 100, 100)
    draw_bbox!(img_thick, 20, 20, 40, 40, color, thickness = 3)
    @test any(x -> x == color, img_thick)
end

# Test draw_detections function
@testset "draw_detections" begin
    # Create test image and detection
    img = zeros(RGB{N0f8}, 100, 100)
    detection = DetectedItem(; id = 1, bbox = (20, 20, 40, 40), confidence = 95.0)

    # Test single detection
    result = draw_detections(img, [detection])
    @test result != img  # Should have modified the image

    # Test multiple detections
    detections = [
        DetectedItem(; id = 1, bbox = (20, 20, 40, 40), confidence = 95.0),
        DetectedItem(; id = 2, bbox = (60, 60, 80, 80), confidence = 85.0)
    ]
    result_multi = draw_detections(img, detections)
    @test result_multi != img

    # Test with out-of-bounds detection
    invalid_detection = DetectedItem(; id = 3, bbox = (-10, -10, 10, 10), confidence = 90.0)
    result_invalid = draw_detections(img, [invalid_detection])
    @test all(result_invalid .== img)  # Should not modify image
end
