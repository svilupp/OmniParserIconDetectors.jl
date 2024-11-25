using ImageTransformations, FileIO, ImageIO

"""
    scale_image_max_640(img)

Scale the input image so its largest dimension is at most 640 pixels while maintaining
aspect ratio. If the image is already smaller than 640px in both dimensions, it is
returned unchanged.

Returns the resized image and the calculated ratio.
"""
function scale_image_max_640(img)
    height, width = size(img)
    max_dimension = max(height, width)

    if max_dimension <= 640
        return img, 1.0
    end

    height_ratio = height > 640 ? 640 / height : 1.0
    width_ratio = width > 640 ? 640 / width : 1.0
    scale_ratio = min(height_ratio, width_ratio)

    return imresize(img, ratio=scale_ratio), scale_ratio
end

"""
    prepare_image_input(img)

Transform the image to the input format expected by the model. 3-dimensional array with
dimensions (1, 3, H, W).
"""
function prepare_image_input(img)
    # Preallocate output array with desired dimensions
    # Assuming input needs to be (1, 3, H, W) for the model
    img_data = channelview(img)
    h, w = size(img_data)[2:3]
    output = Array{Float32}(undef, 1, 3, h, w)

    # Take only first 3 channels and reshape
    @views output[1, 1:3, :, :] = Float32.(img_data[1:3, :, :])

    return output
end

"""
    load_image(path::String)

Load an image from the specified file path using ImageBase.
Returns the loaded image or throws an error if the file cannot be loaded.
"""
function load_image(path::String)
    if !isfile(path)
        throw(ArgumentError("File not found: $path"))
    end

    return load(path)
end
