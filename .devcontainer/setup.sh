#!/bin/bash
set -e

echo "=== Setting up Network Lab Environment ==="

# Install containerlab
echo "Installing Containerlab..."
bash -c "$(curl -sL https://get.containerlab.dev)" -- -v 0.48.6

# Install netlab
echo "Installing Netlab..."
pip3 install networklab

# Add user's pip bin directory to PATH for this session
export PATH="$HOME/.local/bin:$PATH"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# Install additional Python packages for automation
pip3 install --user ansible netmiko napalm

# Pull commonly used container images to speed up first lab deployment
echo "Pre-pulling container images..."
docker pull quay.io/frrouting/frr:10.1.0
docker pull nginx:alpine
docker pull haproxy:2.9-alpine

# Create workspace directories
mkdir -p ~/labs/{ospf,bgp,loadbalancer}

# Set permissions for containerlab
sudo chown -R $(whoami):$(whoami) /etc/containerlab 2>/dev/null || true

# Configure containerlab for rootless operation in Codespaces if needed
if [ -n "$CODESPACES" ]; then
    # Allow containerlab to run without sudo in Codespaces
    sudo chmod 666 /var/run/docker.sock 2>/dev/null || true
fi

# Install useful networking tools
sudo apt-get update
sudo apt-get install -y net-tools iputils-ping traceroute tcpdump wireshark-cli jq

# Configure git for lab development
git config --global init.defaultBranch main
git config --global user.name "Lab Developer"
git config --global user.email "developer@netlab.local"

echo "=== Setup Complete! ==="
echo ""
echo "Quick Start Commands:"
echo "  cd ~/labs/ospf"
echo "  sudo containerlab deploy -t topology.yml"
echo ""
echo "Or use netlab:"
echo "  cd ~/labs/bgp"
echo "  netlab up"
echo ""
