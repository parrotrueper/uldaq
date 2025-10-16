#!/usr/bin/env bash

# Script to install the uldaq Debian package

set -e  # Exit on any error

DEB_FILE="${1:-uldaq_1.2.1-1_amd64.deb}"

if [[ ! -f "${DEB_FILE}" ]]; then
    echo "Error: Debian package '${DEB_FILE}' not found."
    exit 1
fi

echo "Installing Debian package: ${DEB_FILE}"

# Install the package
sudo dpkg -i "${DEB_FILE}"

# Fix any missing dependencies
sudo apt-get install -f -y

echo "Installation completed successfully!"
