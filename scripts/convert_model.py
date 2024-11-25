import onnx
from pathlib import Path

# Load the model
model_path = Path.home() / ".julia" / "scratchspaces" / "124859b0-ceae-595e-8997-d05f6a7a8dfe" / "datadeps" / "OmniParserIconDetector" / "model.onnx"
model = onnx.load(str(model_path))

# Downgrade IR version to 8 and opset to 15
model.ir_version = 8
for opset in model.opset_import:
    if opset.domain == "" or opset.domain == "ai.onnx":
        opset.version = 15

# Save with older versions
onnx.save(model, str(model_path), save_as_external_data=False)

print(f"Model IR version: {model.ir_version}")
print(f"Model opset version: {model.opset_import[0].version}")
