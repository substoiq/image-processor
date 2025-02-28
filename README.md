# Image Processing Pipeline

A containerized solution for automatically processing images from a shared folder using ImageMagick. The system monitors an input directory for new images, processes them according to specified settings, and saves them to an output directory with standardized naming.

## Features

- **Automatic Processing**: Continuously monitors an input directory for new images
- **Configurable Settings**: Image format, dimensions, and quality controlled via YAML configuration
- **Smart Naming**: Output files include sequential numbering and timestamps
- **Duplicate Prevention**: Checks for existing files to avoid overwriting
- **Containerized**: Runs in a Docker container for easy deployment
- **Kubernetes Ready**: Includes manifests for deployment on Kubernetes clusters
- **Shared Storage Support**: Works with NFS or other network storage solutions

## Prerequisites

- Docker (for containerized deployment)
- Kubernetes cluster (for Kubernetes deployment)
- ImageMagick (for local testing)
- Bash shell

## Installation

### Docker Deployment

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/image-processing-pipeline.git
   cd image-processing-pipeline
   ```

2. Build the Docker image:

   ```bash
   docker build -t image-processor:latest .
   ```

3. Run the container with volume mounts for input and output directories:

   ```bash
   docker run -d \
     -v /path/to/input:/data/input \
     -v /path/to/output:/data/output \
     -v /path/to/config:/app/config \
     --name image-processor \
     image-processor:latest
   ```

### Kubernetes Deployment

1. Update the PersistentVolumeClaim configurations in `kubernetes/pvc-input.yaml` and `kubernetes/pvc-output.yaml` to match your storage class and requirements.

2. Apply the Kubernetes manifests:

   ```bash
   kubectl apply -f kubernetes/pvc-input.yaml
   kubectl apply -f kubernetes/pvc-output.yaml
   kubectl apply -f kubernetes/configmap.yaml
   kubectl apply -f kubernetes/deployment.yaml
   ```

3. Verify the deployment:

   ```bash
   kubectl get pods -l app=image-processor
   ```

## Local Testing Setup

### Quick Setup

Run the provided setup script to create a local testing environment:

```bash
# Download the setup script
curl -O https://raw.githubusercontent.com/yourusername/image-processing-pipeline/main/setup-image-test.sh

# Make it executable
chmod +x setup-image-test.sh

# Run the setup script
./setup-image-test.sh
```

This will create a directory structure for testing in your current directory.

### Manual Setup

1. Install dependencies:
   ```bash
   # On Debian/Ubuntu
   sudo apt-get update
   sudo apt-get install imagemagick

   # On macOS
   brew install imagemagick

   # On CentOS/RHEL
   sudo yum install imagemagick
   ```

2. Create the directory structure:
   ```bash
   mkdir -p ~/image-test/{input,output,config,scripts}
   ```

3. Create a configuration file:

   ```bash
   cat > ~/image-test/config/settings.yaml << EOL
   # Image Processing Configuration
   image:
     format: "jpg"
     width: 800
     height: 600
     quality: 85
   EOL
   ```

4. Copy the processing script:

   ```bash
   # Download the script
   curl -o ~/image-test/scripts/process-images.sh https://raw.githubusercontent.com/yourusername/image-processing-pipeline/main/scripts/process-images.sh
   
   # Make it executable
   chmod +x ~/image-test/scripts/process-images.sh
   ```

5. Create a runner script:

   ```bash
   cat > ~/image-test/run-processor.sh << EOL
   #!/bin/bash
   INPUT_DIR=~/image-test/input \
   OUTPUT_DIR=~/image-test/output \
   CONFIG_FILE=~/image-test/config/settings.yaml \
   SLEEP_INTERVAL=5 \
   ~/image-test/scripts/process-images.sh
   EOL

   chmod +x ~/image-test/run-processor.sh
   ```

### Running the Test Environment

1. Start the image processor:

   ```bash
   ~/image-test/run-processor.sh
   ```

2. In another terminal, copy or move some test images to the input directory:
   ```bash
   cp /path/to/your/images/*.jpg ~/image-test/input/
   ```

3. Monitor the output directory to see the processed images:
   ```bash
   ls -la ~/image-test/output/
   ```

4. Press Ctrl+C in the terminal running the processor when done.

## Configuration

You can customize the image processing by editing the `settings.yaml` file:

```yaml
# Image Processing Configuration
image:
  format: "jpg"  # Output format (jpg, png, etc.)
  width: 800     # Output width in pixels
  height: 600    # Output height in pixels
  quality: 85    # Output quality (1-100, higher is better)
```

## File Naming Convention

Processed images follow this naming pattern:

```shell
foto-XX-YYYYMMDD-HHMMSS.ext
```

Where:

- `XX` is a sequential number (01, 02, etc.)
- `YYYYMMDD-HHMMSS` is the date and time of processing
- `ext` is the file extension from the configuration

## License

[Insert your license information here]
