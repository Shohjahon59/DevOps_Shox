#!/bin/bash

set -e

echo "🧪 Testing CI/CD Pipeline Components..."
echo ""

# Test 1: Check Dockerfile
echo "1️⃣ Checking Dockerfile..."
if [ -f "foodapi/Dockerfile" ]; then
    echo "✅ Dockerfile exists"
    echo "📄 Dockerfile content:"
    head -5 foodapi/Dockerfile
else
    echo "❌ Dockerfile not found at foodapi/Dockerfile"
    exit 1
fi
echo ""

# Test 2: Build .NET application
echo "2️⃣ Testing .NET build..."
if command -v dotnet &> /dev/null; then
    cd foodapi/FoodApi
    dotnet restore
    dotnet build --configuration Release
    cd ../..
    echo "✅ .NET build successful"
else
    echo "⚠️  .NET SDK not found, skipping build test"
fi
echo ""

# Test 3: Validate Helm chart
echo "3️⃣ Validating Helm chart..."
if command -v helm &> /dev/null; then
    helm lint foodapi-chart/
    echo "✅ Helm chart is valid"
    
    echo ""
    echo "📊 Helm template preview:"
    helm template foodapi foodapi-chart/ --set image.tag=test123 | head -50
else
    echo "❌ Helm not found"
    exit 1
fi
echo ""

# Test 4: Check ArgoCD application manifest
echo "4️⃣ Checking ArgoCD application..."
if [ -f "argocd/foodapi-application.yaml" ]; then
    echo "✅ ArgoCD application manifest exists"
    echo "📄 Application config:"
    cat argocd/foodapi-application.yaml | grep -A 5 "source:"
else
    echo "❌ ArgoCD application manifest not found"
    exit 1
fi
echo ""

# Test 5: Check GitHub Actions workflow
echo "5️⃣ Checking GitHub Actions workflow..."
if [ -f ".github/workflows/ci-cd.yaml" ]; then
    echo "✅ CI/CD workflow exists"
    echo "📄 Workflow jobs:"
    grep "^  [a-z-]*:" .github/workflows/ci-cd.yaml
else
    echo "❌ CI/CD workflow not found"
    exit 1
fi
echo ""

# Test 6: Docker build test
echo "6️⃣ Testing Docker build..."
if command -v docker &> /dev/null; then
    echo "Building Docker image..."
    docker build -t foodapi:test -f foodapi/Dockerfile foodapi/
    echo "✅ Docker build successful"
    
    echo ""
    echo "🔍 Image details:"
    docker images foodapi:test
    
    # Cleanup
    docker rmi foodapi:test
else
    echo "⚠️  Docker not found, skipping Docker build test"
fi
echo ""

# Test 7: Check Kubernetes resources
echo "7️⃣ Checking Kubernetes cluster..."
if command -v kubectl &> /dev/null; then
    if kubectl cluster-info &> /dev/null; then
        echo "✅ Kubernetes cluster is accessible"
        
        # Check if ArgoCD is installed
        if kubectl get namespace argocd &> /dev/null; then
            echo "✅ ArgoCD namespace exists"
            kubectl get pods -n argocd | head -5
        else
            echo "⚠️  ArgoCD not installed"
        fi
        
        # Check monitoring namespace
        if kubectl get namespace monitoring &> /dev/null; then
            echo "✅ Monitoring namespace exists"
        fi
    else
        echo "⚠️  Kubernetes cluster not accessible"
    fi
else
    echo "⚠️  kubectl not found"
fi
echo ""

echo "✨ CI/CD Pipeline Test Complete!"
echo ""
echo "📋 Summary:"
echo "- Dockerfile: ✅"
echo "- Helm Chart: ✅"
echo "- ArgoCD Config: ✅"
echo "- GitHub Actions: ✅"
echo ""
echo "🚀 Ready to push to GitHub!"