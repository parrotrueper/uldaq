#!/usr/bin/env bash

echo "Build the debian package"
./build_deb.sh

echo "Build the tester"
docker build -f Dockerfile.test -t uldaq-test .

echo "Test installation"
docker run --rm uldaq-test sh -c "ldconfig && pkg-config --exists libuldaq && echo 'libuldaq installed successfully' || echo 'libuldaq not found'"
