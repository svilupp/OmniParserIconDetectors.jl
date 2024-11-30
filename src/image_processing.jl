"""
    resize_to_square(img, target_size::Int=640)

Resize the input image to a square shape of target_size x target_size while maintaining aspect ratio.
Black (zero) padding is added to make it square. Image is aligned to top-left (0,0).
Returns the square image and resize information needed to map coordinates back to original image.
"""
function resize_to_square(img, target_size::Int = 640)
    height, width = size(img)

    # Calculate scaling to fit within target size
    scale_factor = target_size / max(height, width)
    new_height = round(Int, height * scale_factor)
    new_width = round(Int, width * scale_factor)

    # Create black square canvas
    img_square = zeros(eltype(img), target_size, target_size)

    # Resize original image and place it at (0,0)
    img_resized = imresize(img, (new_height, new_width))
    img_square[1:new_height, 1:new_width] = img_resized

    return img_square, scale_factor
end

"""
    prepare_image_tensor(img)

Transform the image to the input format expected by the model. 3-dimensional array with
dimensions (1, 3, H, W).
"""
function prepare_image_tensor(img)
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
    normalize_image_tensor(
        img, means::Vector{Float32} = Float32[0.485, 0.456, 0.406],
        stds::Vector{Float32} = Float32[0.229, 0.224, 0.225])

Normalize the image tensor using ImageNet mean and standard deviation values.
Input should be a Float32 array with values in [0,1] range.
"""
function normalize_image_tensor(
        img, means::Vector{Float32} = Float32[0.485, 0.456, 0.406],
        stds::Vector{Float32} = Float32[0.229, 0.224, 0.225])
    @assert size(img)[2]==3 "Expected 3 channels, got $(size(img)[2])"

    # Create views for each channel and normalize in-place
    for c in 1:3
        @views img[1, c, :, :] .= (img[1, c, :, :] .- means[c]) ./ stds[c]
    end

    return img
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

"""
    save_image(path::String, img::AbstractArray)

Save an image to the specified file path using FileIO.
Returns the path where the image was saved or throws an error if saving fails.
"""
function save_image(path::String, img::AbstractArray)
    try
        mkpath(dirname(path))
        save(path, img)
        return path
    catch e
        throw(ErrorException("Failed to save image to $path: $e"))
    end
end

"""
    preprocess_image(img::AbstractArray{<:T}) where {T <: ColorTypes.Color}

Preprocess the image for the ONNX model:
1. Scale to 640px on the longest side
2. Convert to RGB array
3. Normalize using ImageNet mean and standard deviation values

Returns the preprocessed image tensor and the scaling ratio.
"""
function preprocess_image(img::AbstractArray{<:T}) where {T <: ColorTypes.Color}
    # Scale image using the dedicated function
    scaled_img, scale = resize_to_square(img)

    # Prepare image tensor
    input_tensor = prepare_image_tensor(scaled_img)

    # Normalize image tensor
    normalized_img = normalize_image_tensor(input_tensor)

    return normalized_img, scale
end