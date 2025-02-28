#!/bin/bash
set -e

# Ensure scripts are executable
chmod +x /app/scripts/process-images.sh

# Run the image processor
exec /app/scripts/process-images.sh