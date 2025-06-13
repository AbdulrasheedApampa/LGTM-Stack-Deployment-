#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Create the Argo CD namespace
kubectl create namespace argocd || echo "Namespace 'argocd' already exists."

# Apply Argo CD installation manifests
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.0.6/manifests/install.yaml


# Get the initial admin password
echo "Fetching Argo CD initial admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d; echo
