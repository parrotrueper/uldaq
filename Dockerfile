# Use Ubuntu 24.04 as the base image
FROM ubuntu:24.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install build dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    make \
    libusb-1.0-0-dev \
    autotools-dev \
    libtool \
    pkg-config \
    bzip2 \
    checkinstall \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Define a volume for the project
VOLUME /app

# Default command
CMD ["bash"]
