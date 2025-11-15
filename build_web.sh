#!/bin/bash
# Build Flutter web app for GitHub Pages deployment
# This script builds the web version locally for testing

echo "Building Flutter web app for GitHub Pages..."
echo

# Get the repository name
REPO_NAME="json_stream_parser_demo"

echo "Building with base-href: /$REPO_NAME/"
flutter build web --release --base-href /$REPO_NAME/

if [ $? -eq 0 ]; then
    echo
    echo "============================================"
    echo "Build successful!"
    echo
    echo "Output directory: build/web"
    echo
    echo "To test locally, you can serve the build folder:"
    echo "  cd build/web"
    echo "  python -m http.server 8000"
    echo
    echo "Then visit: http://localhost:8000"
    echo "============================================"
else
    echo
    echo "Build failed!"
fi
