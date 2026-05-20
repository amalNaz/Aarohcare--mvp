#!/bin/bash

# Build script for Vercel Flutter web deployment

echo "Starting Flutter web build for Vercel..."

# Check if Flutter SDK is available
if ! command -v flutter &> /dev/null; then
    echo "Flutter not found. Installing Flutter SDK..."
    
    # Create directory for Flutter SDK
    mkdir -p /tmp/flutter
    cd /tmp/flutter
    
    # Download Flutter SDK for Linux (Vercel runs on Linux)
    curl -o flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.0-stable.tar.xz
    
    # Extract
    tar xf flutter.tar.xz
    
    # Add to PATH
    export PATH="/tmp/flutter/flutter/bin:$PATH"
    
    # Disable analytics
    flutter config --no-analytics
    
    cd -
fi

# Install dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Clean previous builds
echo "Cleaning previous builds..."
flutter clean

# Build web app
echo "Building Flutter web app..."
flutter build web --release

# Check if build was successful
if [ -d "build/web" ]; then
    echo "Build successful! Output directory: build/web"
    exit 0
else
    echo "Build failed!"
    exit 1
fi
