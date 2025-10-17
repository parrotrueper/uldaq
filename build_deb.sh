#!/usr/bin/env bash

# Script to automate building the uldaq Debian package using Docker

set -e  # Exit on any error

IMAGE_NAME="uldaq-build"
CONTAINER_NAME="uldaq-container"
DEB_FILE="uldaq-ubuntu2204_1.2.1-1_amd64.deb"

echo "Building Docker image..."
docker build -t "${IMAGE_NAME}" .

echo "Cleaning up any existing container..."
docker rm -f "${CONTAINER_NAME}" || true

echo "Running Docker container..."
#shellcheck disable=2312
docker run -d --name "${CONTAINER_NAME}" -v "$(pwd)":/app "${IMAGE_NAME}" bash -c "while true; do sleep 30; done"

echo "Configuring and building the project..."
docker exec "${CONTAINER_NAME}" bash -c "cd /app && make distclean || make clean || true"
docker exec "${CONTAINER_NAME}" bash -c "cd /app && ./configure"
docker exec "${CONTAINER_NAME}" bash -c "cd /app && make"

echo "Fixing libtool issue for static library..."
docker exec "${CONTAINER_NAME}" bash -c "cd /app && sed -i 's/old_library=.*/old_library=\"\"/' src/libuldaq.la"
docker exec "${CONTAINER_NAME}" bash -c "cd /app && cp src/.libs/libuldaq.a /usr/local/lib/libuldaq.a"

echo "Creating necessary directories..."
docker exec "${CONTAINER_NAME}" mkdir -p /usr/local/share/doc

echo "Creating Debian package with checkinstall..."
docker exec "${CONTAINER_NAME}" bash -c "cd /app && checkinstall --pkgname=uldaq-ubuntu2204 --pkgversion=1.2.1 --default --nodoc"

echo "Copying .deb file out of container..."
docker cp "${CONTAINER_NAME}":/app/"${DEB_FILE}" .

echo "Cleaning up build artifacts..."
docker exec "${CONTAINER_NAME}" bash -c "cd /app && make clean"

echo "Verifying .deb package contents..."
dpkg -c "${DEB_FILE}"

echo "Cleaning up container..."
docker stop "${CONTAINER_NAME}"
docker rm "${CONTAINER_NAME}"
rm -rf backup-*

echo "Debian package ${DEB_FILE} created successfully!"
