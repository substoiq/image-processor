FROM alpine:3.17

# Install required packages
RUN apk add --no-cache \
    bash \
    imagemagick \
    findutils \
    yaml-cpp \
    curl

# Create app directories
RUN mkdir -p /app/scripts /app/config /data/input /data/output

# Copy scripts and config
COPY scripts/ /app/scripts/
COPY config/ /app/config/

# Make scripts executable
RUN chmod +x /app/scripts/*.sh

# Set environment variables
ENV INPUT_DIR=/data/input \
    OUTPUT_DIR=/data/output \
    CONFIG_FILE=/app/config/settings.yaml \
    SLEEP_INTERVAL=10

# Set working directory
WORKDIR /app

# Set entrypoint
ENTRYPOINT ["/app/scripts/entrypoint.sh"]