from flask import Flask, request, jsonify
import torch
import torch.nn as nn
from torchvision import models, transforms
from PIL import Image
from scipy.spatial.distance import cosine
import numpy as np
import io

# Define Siamese Network
class SiameseNetwork(nn.Module):
    def __init__(self):
        super(SiameseNetwork, self).__init__()
        self.resnet = models.resnet18(pretrained=True)
        self.resnet.fc = nn.Linear(self.resnet.fc.in_features, 256)

    def forward(self, x):
        return self.resnet(x)

# Load model
model = SiameseNetwork()
model.eval()

# Transform
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406],
                         std=[0.229, 0.224, 0.225])
])

# Compare logic
def get_image_embedding(image):
    image = transform(image).unsqueeze(0)
    with torch.no_grad():
        features = model(image)
    return features

def compare_images(image1, image2):
    emb1 = get_image_embedding(image1).squeeze().cpu().numpy()
    emb2 = get_image_embedding(image2).squeeze().cpu().numpy()
    similarity = 1 - cosine(emb1, emb2)
    return similarity

# Flask API App
app = Flask(__name__)

@app.route("/compare", methods=["POST"])
def compare_endpoint():
    file1 = request.files.get("signature1")
    file2 = request.files.get("signature2")

    if not file1 or not file2:
        return jsonify({"error": "Both signature1 and signature2 files are required"}), 400

    try:
        image1 = Image.open(io.BytesIO(file1.read())).convert("RGB")
        image2 = Image.open(io.BytesIO(file2.read())).convert("RGB")

        similarity_score = compare_images(image1, image2)

        result = "similar" if similarity_score > 0.90 else "different"

        return jsonify({
            "similarity_score": round(float(similarity_score), 4),
            "result": result
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
