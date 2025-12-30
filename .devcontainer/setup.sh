#!/bin/bash
set -e

echo "=== Setting up Network Lab Environment ==="

# Detect if we're in GitHub Codespaces
if [ -n "$CODESPACES" ]; then
    echo "Detected GitHub Codespaces environment"
fi

# Install containerlab
echo "Installing Containerlab..."
bash -c "$(curl -sL https://get.containerlab.dev)" -- -v 0.48.6

# Fix PATH for this session AND future sessions BEFORE installing netlab
export PATH="$HOME/.local/bin:$PATH"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# Install netlab (now the PATH is ready)
echo "Installing Netlab..."
pip3 install networklab

# Verify netlab is accessible
if command -v netlab &> /dev/null; then
    echo "✓ Netlab installed successfully"
else
    echo "⚠ Warning: netlab not found in PATH, trying alternative install"
    pip3 install --force-reinstall networklab
fi

# Install additional Python packages for automation
pip3 install ansible netmiko napalm

# Fix Docker permissions for Codespaces (before pulling images)
if [ -n "$CODESPACES" ]; then
    echo "Configuring Docker permissions for Codespaces..."
    sudo chmod 666 /var/run/docker.sock 2>/dev/null || true
fi

# Pull commonly used container images to speed up first lab deployment
echo "Pre-pulling container images..."
docker pull quay.io/frrouting/frr:10.1.0
docker pull nginx:alpine
docker pull haproxy:2.9-alpine

# Create workspace directories
mkdir -p ~/labs/{ospf,bgp,loadbalancer}

# Set permissions for containerlab (handle both vscode and other users)
echo "Setting containerlab permissions..."
sudo mkdir -p /etc/containerlab
sudo chown -R $(whoami):$(whoami) /etc/containerlab 2>/dev/null || true

# Install useful networking tools
echo "Installing networking tools..."
sudo apt-get update
sudo apt-get install -y net-tools iputils-ping traceroute tcpdump wireshark-cli jq

# Configure git for lab development
git config --global init.defaultBranch main
git config --global user.name "Lab Developer"
git config --global user.email "developer@netlab.local"

# Final PATH verification for the user
echo ""
echo "=== Verifying Installation ==="
echo -n "Containerlab: "
containerlab version 2>/dev/null | head -1 || echo "Not found"
echo -n "Netlab: "
netlab --version 2>/dev/null || python3 -m netlab --version 2>/dev/null || echo "Not found - may need to restart terminal"
echo -n "Docker: "
docker --version || echo "Not found"

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Quick Start Commands:"
echo "  cd ~/labs/ospf"
if [ -n "$CODESPACES" ]; then
    echo "  containerlab deploy -t topology.yml  # No sudo needed in Codespaces"
else
    echo "  sudo containerlab deploy -t topology.yml"
fi
echo ""
echo "Or use netlab:"
echo "  cd ~/labs/bgp"
echo "  netlab up"
echo ""
if ! command -v netlab &> /dev/null; then
    echo "⚠ Note: If netlab is not found, restart your terminal or run:"
    echo "  source ~/.bashrc"
fi
