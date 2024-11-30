using OmniParserIconDetectors: calculate_iou, yolo_to_xxyy, DetectedItem,
                               load_detection_model, detect_icons

@testset "calculate_iou" begin
    # Test 1: Complete overlap (identical boxes)
    box = (0.0, 0.0, 1.0, 1.0)
    @test calculate_iou(box, box) ≈ 1.0

    # Test 2: No overlap
    box1 = (0.0, 0.0, 1.0, 1.0)
    box2 = (2.0, 2.0, 3.0, 3.0)
    @test calculate_iou(box1, box2) == 0.0

    # Test 3: Partial overlap
    box1 = (0.0, 0.0, 2.0, 2.0)
    box2 = (1.0, 1.0, 3.0, 3.0)
    # Area of intersection is 1x1=1, areas are 4 each, union is 7
    @test calculate_iou(box1, box2) ≈ 1 / 7

    # Test 4: One box inside another
    box1 = (0.0, 0.0, 4.0, 4.0)
    box2 = (1.0, 1.0, 2.0, 2.0)
    # Area of inner box is 1, outer is 16, intersection is 1
    @test calculate_iou(box1, box2) ≈ 1 / 16

    # Test 5: Edge touching boxes (should be 0)
    box1 = (0.0, 0.0, 1.0, 1.0)
    box2 = (1.0, 0.0, 2.0, 1.0)
    @test calculate_iou(box1, box2) == 0.0

    # Test 6: Thin overlap (testing precision)
    box1 = (0.0, 0.0, 2.0, 2.0)
    box2 = (1.99, 0.0, 4.0, 2.0)
    # Very small overlap area testing numerical stability
    @test calculate_iou(box1, box2) > 0.0

    # Test 7: Non-square boxes with partial overlap
    box1 = (0.0, 0.0, 4.0, 1.0)  # wide rectangle
    box2 = (3.0, 0.0, 5.0, 2.0)  # overlapping taller rectangle
    # Intersection: 1x1=1, box1 area: 4, box2 area: 4, union: 7
    @test calculate_iou(box1, box2) ≈ 1 / 7

    # Test 8: Negative coordinates
    box1 = (-2.0, -2.0, 0.0, 0.0)
    box2 = (-1.0, -1.0, 1.0, 1.0)
    # Intersection: 1x1=1, box1 area: 4, box2 area: 4, union: 7
    @test calculate_iou(box1, box2) ≈ 1 / 7

    # Test 9: Zero-area box (invalid case)
    box1 = (0.0, 0.0, 0.0, 1.0)
    box2 = (0.0, 0.0, 1.0, 1.0)
    @test calculate_iou(box1, box2) == 0.0
end

@testset "yolo_to_xxyy" begin
    # Case 1: Simple centered box
    @test yolo_to_xxyy((0.5, 0.5, 0.2, 0.2)) == (0.4, 0.4, 0.6, 0.6)

    # Case 2: Box at origin
    @test yolo_to_xxyy((0.0, 0.0, 0.1, 0.1)) == (-0.05, -0.05, 0.05, 0.05)
end

@testset "detect_icons" begin
    # Load test model
    model = load_detection_model()

    # Test basic detection
    test_img_path = joinpath(@__DIR__, "images", "test1.png")
    detections = detect_icons(model, test_img_path)
    @test detections isa Vector{DetectedItem}
    @test length(detections) > 1

    detections = model(test_img_path)
    @test detections isa Vector{DetectedItem}
    @test length(detections) > 1

    # Test detection with different thresholds
    detections_strict = detect_icons(model, test_img_path,
        iou_threshold = 0.05,  # stricter IoU
        box_threshold = 0.2,   # higher confidence
        min_scaled_confidence = 50)  # higher min confidence
    @test length(detections_strict) <= length(detections)  # Should detect fewer items

    # Test verbose output
    # Capture logging output to test verbose mode
    detected_with_logging = detect_icons(model, test_img_path, verbose = true)
    @test detected_with_logging isa Vector{DetectedItem}

    # Test invalid image path
    @test_throws ArgumentError detect_icons(model, "nonexistent.png")
end
