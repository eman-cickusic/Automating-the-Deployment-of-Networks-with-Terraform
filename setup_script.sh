#!/bin/bash

# Terraform GCP Networks Setup Script
# This script helps you set up the Terraform configuration for GCP networks

set -e

echo "🚀 Setting up Terraform GCP Networks project..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required tools
echo "📋 Checking prerequisites..."

if ! command_exists terraform; then
    echo "❌ Terraform is not installed. Please install Terraform first."
    echo "   Visit: https://www.terraform.io/downloads.html"
    exit 1
fi

if ! command_exists gcloud; then
    echo "❌ Google Cloud CLI is not installed. Please install gcloud first."
    echo "   Visit: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

echo "✅ Prerequisites check complete"

# Get project ID
if [ -z "$GOOGLE_PROJECT" ]; then
    echo "🔧 Setting up GCP project..."
    
    # Try to get current project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "")
    
    if [ -n "$CURRENT_PROJECT" ]; then
        echo "Current GCP project: $CURRENT_PROJECT"
        read -p "Use this project? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            export GOOGLE_PROJECT=$CURRENT_PROJECT
        fi
    fi
    
    if [ -z "$GOOGLE_PROJECT" ]; then
        read -p "Enter your GCP Project ID: " GOOGLE_PROJECT
        export GOOGLE_PROJECT
    fi
else
    echo "Using project from environment: $GOOGLE_PROJECT"
fi

# Set up terraform.tfvars
echo "📝 Creating terraform.tfvars file..."
if [ ! -f terraform.tfvars ]; then
    cp terraform.tfvars.example terraform.tfvars
    sed -i.bak "s/your-project-id-here/$GOOGLE_PROJECT/" terraform.tfvars
    rm terraform.tfvars.bak 2>/dev/null || true
    echo "✅ Created terraform.tfvars with your project ID"
else
    echo "⚠️  terraform.tfvars already exists, skipping creation"
fi

# Enable required APIs
echo "🔌 Enabling required GCP APIs..."
gcloud services enable compute.googleapis.com --project=$GOOGLE_PROJECT
echo "✅ Compute Engine API enabled"

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

# Format Terraform files
echo "📐 Formatting Terraform files..."
terraform fmt

# Validate configuration
echo "✅ Validating Terraform configuration..."
terraform validate

echo ""
echo "🎉 Setup complete! Next steps:"
echo ""
echo "1. Review your configuration:"
echo "   terraform plan"
echo ""
echo "2. Apply the configuration:"
echo "   terraform apply"
echo ""
echo "3. To clean up later:"
echo "   terraform destroy"
echo ""
echo "💡 Tip: You can customize regions and zones in terraform.tfvars"