using Images, ImageDraw

"""
    draw_detections(img, detections)

Draw bounding boxes around detected icons on the input image.
Returns a new image with colored boxes indicating detections and their confidence scores.
"""
function draw_detections(img, detections)
    img_with_boxes = copy(img)
    C = eltype(img)

    for detection in detections
        confidence = detection.confidence
        t = min(1.0, confidence / 100.0)

        # Make colors more visible with thicker lines
        color = C(RGB(1.0 - t, t, 0.0))
        (x1, y1, x2, y2) = map(x -> round(Int, x), detection.bbox)

        # Draw thicker rectangle
        for offset in -1:1
            draw!(img_with_boxes, LineSegment(Point(x1+offset, y1), Point(x2+offset, y1)), color)
            draw!(img_with_boxes, LineSegment(Point(x2, y1+offset), Point(x2, y2+offset)), color)
            draw!(img_with_boxes, LineSegment(Point(x2-offset, y2), Point(x1-offset, y2)), color)
            draw!(img_with_boxes, LineSegment(Point(x1, y2-offset), Point(x1, y1-offset)), color)
        end

        # Draw confidence indicator as a filled rectangle
        indicator_width = round(Int, 30 * (confidence / 100))
        indicator_height = 8
        rect_points = RectanglePoints(
            Point(x1, max(10, y1-15)),
            Point(x1 + indicator_width, max(10, y1-15) + indicator_height)
        )
        # Draw white background first
        draw!(img_with_boxes, rect_points, C(RGB(1,1,1)))
        # Draw colored confidence indicator
        draw!(img_with_boxes, rect_points, color)
    end

    return img_with_boxes
end

export draw_detections
