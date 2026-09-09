# 🚗 Multi-Class Segmentation for Autonomous Vehicles

📘 This project is also available in [French 🇫🇷](./README.fr.md)

**Source of truth** : [Forgejo](https://git.gregoiremureau.com/openclassroom-ai/oc-p08-street-vision) (self-hosted).

```bash
git clone https://git.gregoiremureau.com/openclassroom-ai/oc-p08-street-vision.git
git clone https://git.gregoiremureau.com/openclassroom-ai/oc-p08-street-vision.git
```

Prod: https://api.gregoiremureau.com/ml/street-vision/

Full dataset: `./fetch-data.sh` (Cityscapes **not** in git; a small sample is already in `notebooks/content/data/`).

## 📋 Project Description

This project develops a semantic segmentation system for street images intended for autonomous vehicles. It enables the automatic identification and segmentation of various urban elements: vehicles, pedestrians, street furniture, road infrastructure, etc.

The system is part of a complete embedded computer vision pipeline for autonomous vehicles, processing images in real time to feed decision-making systems.

## 🗂️ Project Structure

```
├── notebooks/
│   ├── p8_notebook.ipynb       # Main model training notebook
│   └── content/
│       └── data/
│           ├── new_images_to_predict/     # Various images for inference tests
│           └── test_images_sample/        # Cityscapes sample with masks
├── utils/
│   └── utils.py                # Shared functions (preprocessing, loading, inference)
├── app/                        # API and Web Interface
│   ├── main.py                 # FastAPI API with segmentation routes
│   ├── streamlit_app.py        # Interactive web interface
│   └── requirements.txt        # Dependencies for the API and interface
├── cityscapes_config.json      # Cityscapes class configuration
├── .env.example                # Environment variables template
├── Dockerfile                  # Docker configuration
├── docker-compose.yml.example  # Docker Compose template
├── nginx.conf                  # Reverse proxy configuration
├── start.sh                    # Services startup script
├── .dockerignore              # Docker build optimization
└── README.md
```

> **Note**: Trained models are stored and versioned via **MLFlow** with artifacts on **MinIO**, not locally.

**Current development status:**
- ✅ **Model training**: Complete (notebook + MLFlow + MinIO)
- ✅ **Inference functions**: Developed and ready
- ✅ **FastAPI API**: Complete API with segmentation endpoints
- ✅ **Web Interface**: Streamlit interface for upload and visualization
- ✅ **Deployment**: Full Docker containerization + nginx reverse proxy

## 🏷️ Segmentation Classes

The model identifies **8 main categories**:

1. **Road** - Roadway and driving surfaces
2. **Sidewalk** - Pedestrian areas
3. **Buildings** - Architectural structures
4. **Vegetation** - Trees, bushes, green spaces
5. **Vehicles** - Cars, trucks, buses
6. **People** - Pedestrians, cyclists
7. **Signage** - Signs, traffic lights
8. **Street furniture** - Poles, barriers, bus shelters

## 🧠 Technical Architecture

### Implemented Models
Using the **[segmentation_models](https://github.com/qubvel/segmentation_models)** library by qubvel to implement the architectures.

**Main architectures:**
- **U-Net**: Classic encoder-decoder architecture
- **FPN** (Feature Pyramid Network): Feature pyramid network

**Tested backbones:**
```python
# Models with default backbones
('U-Net', None)     # Built-in U-Net backbone
('FPN', None)       # Default VGG16 backbone

# Models with pretrained backbones (frozen encoders)
('U-Net', 'mobilenetv2')
('U-Net', 'efficientnetb0') 
('FPN', 'mobilenetv2')
('FPN', 'efficientnetb0')
('FPN', 'resnet34')

# Selective fine-tuning (trainable encoders)
('U-Net', 'mobilenetv2')
('FPN', 'efficientnetb0') 
('FPN', 'resnet34')
```

**Training strategies:**
- **Frozen encoders**: Transfer learning with fixed pretrained features
- **Fine-tuning**: Fine adjustment of pretrained encoders
- **Training from scratch**: Without pretraining (default backbones)

### Technology Stack
- **Framework**: Keras/TensorFlow
- **Architectures**: [segmentation_models](https://github.com/qubvel/segmentation_models) (qubvel)
- **Experiment management**: MLFlow
- **Artifact storage**: MinIO (S3-compatible)
- **API**: FastAPI with Pydantic validation
- **Interface**: Streamlit for user interaction
- **Reverse Proxy**: nginx for API/Interface routing
- **Deployment**: Docker + personal NAS *(sovereign solutions)*

## 📊 Dataset

- **Source**: Cityscapes Dataset
- **Local organization**:
  - `notebooks/content/data/test_images_sample/`: Sample with ground truth masks for inference tests
  - `notebooks/content/data/new_images_to_predict/`: Various test images for validation

## 🚀 Installation and Configuration

### Option 1: Docker Deployment (Recommended)

#### Quick configuration
```bash
# Clone the project
git clone https://git.gregoiremureau.com/openclassroom-ai/oc-p08-street-vision.git
cd oc-p08-street-vision

# Copy and adapt the configuration
cp .env.example .env
cp docker-compose.yml.example docker-compose.yml

# Edit the environment variables
nano .env
```

#### Required environment variables
```bash
# Server configuration
NGINX_PORT=8080

# MLflow configuration
MLFLOW_TRACKING_URI=http://localhost:5000
MLFLOW_S3_ENDPOINT_URL=http://localhost:9000
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key

# API base URL (for Streamlit)
MULTISEG_API_BASE_URL=http://localhost:8080/api
```

#### Deployment
```bash
# Build and launch
docker-compose up --build

# Or in the background
docker-compose up -d --build

# Access the application
# Web interface: http://localhost:8080
# API docs: http://localhost:8080/api/docs
# Health check: http://localhost:8080/health
```

#### Local test without docker-compose
```bash
# Launch with a custom port
docker build -t multiseg-api .
docker run -p 3000:3000 \
  -e NGINX_PORT=3000 \
  -e MLFLOW_TRACKING_URI=http://host.docker.internal:5000 \
  -e MULTISEG_API_BASE_URL=http://localhost:3000/api \
  multiseg-api
```

### Option 2: Local Installation (Development)

#### For experimentation and training
```bash
cd notebooks
pip install -r requirements.txt
```

#### For the API only
```bash
cd app
pip install -r requirements.txt

# Manual service startup
# Terminal 1: FastAPI
uvicorn app.main:app --host 0.0.0.0 --port 8000

# Terminal 2: Streamlit  
streamlit run app/streamlit_app.py --server.port 8501
```

## 🌐 API Usage

### Main Endpoints

#### Image segmentation
```bash
# Upload and segmentation via curl
curl -X POST "http://localhost:8080/api/segment" \
  -F "file=@image.jpg" \
  -F "model_name=unet_mobilenetv2" \
  -F "confidence_threshold=0.5"
```

#### Model information
```bash
# List of available models
curl "http://localhost:8080/api/models"

# Details of a model
curl "http://localhost:8080/api/models/unet_mobilenetv2"
```

#### Monitoring
```bash
# Health check
curl "http://localhost:8080/health"

# API metrics
curl "http://localhost:8080/api/metrics"
```

### Web Interface

The Streamlit interface accessible at `http://localhost:8080` allows you to:
- **Upload images** by drag-and-drop or selection
- **Select the model** among the available models
- **Adjust parameters** (confidence threshold, etc.)
- **Visualize** results with segmentation overlay
- **Download** segmentation masks

## 🔧 Deployment Architecture

### Service Structure
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   nginx:8080    │────│  FastAPI:8000    │────│   MLFlow/MinIO  │
│  (Reverse Proxy)│    │  (API Backend)   │    │ (Model Storage) │
└─────────┬───────┘    └──────────────────┘    └─────────────────┘
          │
┌─────────▼───────┐
│  Streamlit:8501 │
│ (Web Interface) │
└─────────────────┘
```

### Volumes and Persistence
- **Models**: Downloaded from MLFlow/MinIO at startup
- **Temporary uploads**: In-memory storage (no persistence)
- **Logs**: Accessible via `docker-compose logs`

### Monitoring and Logs
```bash
# Real-time logs
docker-compose logs -f

# Logs for a specific service
docker-compose logs -f multiseg-api

# Performance metrics
curl http://localhost:8080/api/metrics
```

## 🔮 Future Improvements

### Models and Performance
- **Adaptive preprocessing**: Backbone-specific preprocessing instead of generic normalization
- **Real-time optimization**: Improved inference performance for embedded deployment
- **Improved training resolution**: The API accepts any image resolution, but training was performed on images resized to 224x224. Retraining at higher resolutions (512x512, 1024x1024) could improve accuracy by capturing more fine detail, at the cost of increased computational power requirements
- **Targeted transfer learning**: Using backbones pretrained on Mapillary Vistas

### Infrastructure and Deployment
- **Horizontal scaling**: Kubernetes support for multi-instance deployment
- **Smart caching**: Caching predictions for similar images
- **API Gateway**: Integrating a gateway for authentication and rate limiting
- **Advanced monitoring**: Prometheus/Grafana integration for detailed metrics

### Data and Generalization
- **Condition generalization**: Extending beyond Cityscapes' urban conditions
- **People segmentation**: Improving IoU via data augmentation (generative AI)
- **Additional datasets**: Integrating complementary datasets for robustness

---

*Project developed with a technological sovereignty approach, favoring open-source solutions and hosting on personal infrastructure.*
