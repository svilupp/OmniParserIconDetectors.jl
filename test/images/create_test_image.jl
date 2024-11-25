using Images, FileIO, Luxor

# Create a drawing surface
Drawing(640, 640, "test.png")
background("white")

# Draw several icon-like shapes
# App icon (square with rounded corners)
sethue("royalblue")
box(Point(150, 150), 100, 100, :fill)

# Notification icon (circle)
sethue("red")
circle(Point(300, 150), 20, :fill)

# Menu icon (three horizontal lines)
sethue("gray30")
for y in [350, 400, 450]
    line(Point(100, y), Point(200, y), :stroke)
end

# Save the drawing
finish()
mv("test.png", joinpath(@__DIR__, "test.png"), force=true)
println("Test image created at: ", joinpath(@__DIR__, "test.png"))
