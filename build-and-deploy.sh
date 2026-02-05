#!/bin/bash

set -e

# Get current git commit
SHORT_SHA=$(git rev-parse --short HEAD)
IMAGE_NAME="rashidov2005/foodapi"

echo "🚀 Building and deploying Food API..."
echo "📦 Tag: ${SHORT_SHA}"

# 1. Build .NET application
echo ""
echo "1️⃣ Building .NET application..."
dotnet restore foodapi/FoodApi/FoodApi.csproj
dotnet build foodapi/FoodApi/FoodApi.csproj --configuration Release --no-restore
echo "✅ .NET build successful"

# 2. Build Docker image
echo ""
echo "2️⃣ Building Docker image..."
docker build -t ${IMAGE_NAME}:${SHORT_SHA} -f foodapi/Dockerfile foodapi/
docker tag ${IMAGE_NAME}:${SHORT_SHA} ${IMAGE_NAME}:latest
echo "✅ Docker build successful"

# 3. Push to Docker Hub (optional)
read -p "Push to Docker Hub? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "3️⃣ Pushing to Docker Hub..."
    docker push ${IMAGE_NAME}:${SHORT_SHA}
    docker push ${IMAGE_NAME}:latest
    echo "✅ Docker push successful"
fi

# 4. Deploy to Kubernetes
echo ""
echo "4️⃣ Deploying to Kubernetes..."
./deploy.sh ${SHORT_SHA}

echo ""
echo "🎉 Build and deployment complete!"
echo "📦 Image: ${IMAGE_NAME}:${SHORT_SHA}"