# kubectl deployment commands

# Navigate to the directory containing the Dockerfile
cd image-processor

# Build the Docker image
docker build -t image-processor:latest .

# Push to your container registry (if needed)
# docker tag image-processor:latest your-registry/image-processor:latest
# docker push your-registry/image-processor:latest

```bash
# Apply the Kubernetes manifests
kubectl apply -f kubernetes/pvc-input.yaml
kubectl apply -f kubernetes/pvc-output.yaml
kubectl apply -f kubernetes/configmap.yaml
kubectl apply -f kubernetes/deployment.yaml

# Verify deployment
kubectl get pods -l app=image-processor
```