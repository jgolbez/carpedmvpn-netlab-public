#!/bin/bash
# Setup script for Network Lab Environment
# The containerlab devcontainer image already includes Docker, containerlab, and most tools

echo "=== Setting up OSPF Training Lab Environment ==="
echo ""

# Note: The containerlab devcontainer image already includes:
# - Docker and Docker-in-Docker
# - Containerlab
# - Common networking tools (tcpdump, traceroute, etc.)

# Pre-pull the FRR container image for faster lab startup
echo "Pre-pulling FRR container image..."
docker pull frrouting/frr:v10.1.1

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Available Labs:"
echo "  • OSPF Fundamentals (Lab 1)"
echo "  • OSPF Network Types (Lab 2)"
echo ""
echo "To start Lab 1:"
echo "  cd labs/ospf/lab1-ospf-basics"
echo "  sudo containerlab deploy -t topology.yml"
echo ""
echo "To start Lab 2:"
echo "  cd labs/ospf/lab2-ospf-network-types"
echo "  sudo containerlab deploy -t topology.yml"
echo ""
echo "To access a router:"
echo "  docker exec -it <container-name> vtysh"
echo ""
echo "Example:"
echo "  docker exec -it clab-ospf-fundamentals-r1 vtysh"
echo ""
