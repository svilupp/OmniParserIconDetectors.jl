import onnxruntime as ort
import numpy as np
import json
import sys

def run_inference(model_path, input_tensor):
    # Convert to float32 and reshape to NCHW
    input_tensor = np.asarray(input_tensor, dtype=np.float32)
    print(f"Input tensor shape before reshape: {input_tensor.shape}", file=sys.stderr)

    # Ensure NCHW format (batch, channels, height, width)
    if input_tensor.shape != (1, 3, 640, 640):
        input_tensor = input_tensor.reshape(1, 3, 640, 640)

    print(f"Final input tensor shape: {input_tensor.shape}", file=sys.stderr)
    print(f"Final input tensor type: {input_tensor.dtype}", file=sys.stderr)

    # Load model
    session = ort.InferenceSession(model_path)

    # Run inference
    outputs = session.run(
        ["output0"],
        {"images": input_tensor}
    )

    return outputs[0].tolist()

if __name__ == "__main__":
    # Read input from stdin
    input_data = json.loads(sys.stdin.read())
    model_path = input_data["model_path"]
    input_tensor = np.array(input_data["input_tensor"])

    result = run_inference(model_path, input_tensor)
    print(json.dumps(result))
