#!/bin/bash
set -e

# Configuration
INPUT_DIR="${INPUT_DIR:-/data/input}"
OUTPUT_DIR="${OUTPUT_DIR:-/data/output}"
CONFIG_FILE="${CONFIG_FILE:-/app/config/settings.yaml}"
SLEEP_INTERVAL="${SLEEP_INTERVAL:-10}"

# Function to read YAML configuration
parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s=\"%s\"\n", "'$prefix'",vn$2, $3);
      }
   }'
}

# Load configuration
echo "Loading configuration from $CONFIG_FILE"
eval $(parse_yaml "$CONFIG_FILE")

echo "Using format: $image_format"
echo "Using width: $image_width"
echo "Using height: $image_height"
echo "Using quality: $image_quality"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Process new files function
process_files() {
  echo "Checking for new files in $INPUT_DIR"
  
  # Find files in the input directory with image extensions
  find "$INPUT_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) -print0 | while IFS= read -r -d $'\0' file; do
    
    # Get the base filename
    filename=$(basename "$file")
    
    # Check if the file has already been processed by looking for a marker file
    if [ ! -f "$OUTPUT_DIR/.processed_$(basename "$file")" ]; then
      echo "Processing $filename"
      
      # Find the first available number
      counter=1
      while true; do
        padded_counter=$(printf "%02d" $counter)
        current_datetime=$(date +"%Y%m%d-%H%M%S")
        new_filename="foto-${padded_counter}-${current_datetime}.${image_format}"
        
        # Check if a file with this number (regardless of timestamp) already exists
        if ! ls "$OUTPUT_DIR"/foto-${padded_counter}-*.${image_format} 1> /dev/null 2>&1; then
          # No matching file found, this number is available
          break
        fi
        
        # Increment counter and try again
        ((counter++))
        
        # Safety check to prevent infinite loops (unlikely but good practice)
        if [ $counter -gt 999 ]; then
          echo "Warning: Unable to find available number under 1000. Using timestamp only."
          new_filename="foto-${current_datetime}.${image_format}"
          break
        fi
      done
      
      # Process the image with ImageMagick (using modern syntax)
      # Try the magick command first, fall back to convert if magick is not available
      if command -v magick &> /dev/null; then
        magick "$file" -resize "${image_width}x${image_height}" -quality "$image_quality" "$OUTPUT_DIR/$new_filename"
      else
        # Fall back to convert for older ImageMagick versions
        convert "$file" -resize "${image_width}x${image_height}" -quality "$image_quality" "$OUTPUT_DIR/$new_filename"
      fi
      
      # Create a marker file to avoid reprocessing
      touch "$OUTPUT_DIR/.processed_$(basename "$file")"
      
      echo "Converted $filename to $new_filename"
    fi
  done
}

# Main loop
echo "Starting image monitoring on $INPUT_DIR"
while true; do
  process_files
  echo "Sleeping for $SLEEP_INTERVAL seconds..."
  sleep "$SLEEP_INTERVAL"
done