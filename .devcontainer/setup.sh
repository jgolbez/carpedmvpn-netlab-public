#!/bin/bash
# Minimal setup script - the containerlab devcontainer image already includes most tools

echo "=== Setting up Network Lab Environment ==="

# Install netlab (the only thing not included in the containerlab image)
echo "Installing netlab..."
pip3 install networklab

# Pre-pull the container images we'll use in labs
echo "Pre-pulling container images for faster lab startup..."
docker pull quay.io/frrouting/frr:10.1.0
docker pull nginx:alpine  
docker pull haproxy:2.9-alpine

# Create lab directories
echo "Creating lab directories..."
mkdir -p ~/labs/{ospf,bgp,loadbalancer}

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "To test the environment:"
echo "  bash test-environment.sh"
echo ""
echo "To start a lab:"
echo "  cd ~/labs/ospf"
echo "  containerlab deploy -t topology.yml"
echo ""
echo "For netlab (BGP lab):"
echo "  cd ~/labs/bgp"  
echo "  python3 -m netlab up"
echo ""
