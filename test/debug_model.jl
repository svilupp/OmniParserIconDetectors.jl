using OmniParserIconDetectors
using Images
using FileIO

# Create a test image
test_img = fill(RGB(1,1,1), 200, 200)  # White background
test_img[50:100, 50:100] .= RGB(0,0,0)  # Black square
save("test/images/test_icon.png", test_img)

# Try to detect icons
try
    println("Starting icon detection...")
    results = detect_icons("test/images/test_icon.png")
    println("Detection results: ", results)
catch e
    println("Error during detection: ", e)
    for (exc, bt) in Base.catch_stack()
        showerror(stdout, exc, bt)
        println()
    end
end
