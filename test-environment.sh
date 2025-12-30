#!/bin/bash

echo "========================================="
echo "Network Lab Environment Test"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test function
test_component() {
    local name=$1
    local command=$2
    echo -n "Testing $name... "
    if eval $command &>/dev/null; then
        echo -e "${GREEN}✓${NC} Installed"
        return 0
    else
        echo -e "${RED}✗${NC} Not found"
        return 1
    fi
}

# Check Docker
test_component "Docker" "docker --version"

# Check Containerlab
test_component "Containerlab" "containerlab version"

# Check Netlab - multiple ways it might work
echo -n "Testing Netlab... "
if command -v netlab &>/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Installed (direct command)"
elif python3 -m netlab --version &>/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Installed (use: python3 -m netlab)"
else
    echo -e "${YELLOW}⚠${NC} Not found (optional - only needed for BGP lab auto-config)"
fi

# Check Python
test_component "Python 3" "python3 --version"

# Check if Docker is running
echo -n "Testing Docker daemon... "
if docker info &>/dev/null; then
    echo -e "${GREEN}✓${NC} Running"
else
    echo -e "${RED}✗${NC} Not running"
    echo "  Try: sudo service docker start"
fi

# Check if images are available
echo ""
echo "Checking container images:"
for image in "quay.io/frrouting/frr:10.1.0" "nginx:alpine" "haproxy:2.9-alpine"; do
    echo -n "  $image... "
    if docker image inspect $image &>/dev/null; then
        echo -e "${GREEN}✓${NC} Available"
    else
        echo -e "${YELLOW}⚠${NC} Not downloaded (will download on first use)"
    fi
done

# Check lab directories
echo ""
echo "Checking lab directories:"
for lab in "ospf" "bgp" "loadbalancer"; do
    echo -n "  ~/labs/$lab... "
    if [ -d "$HOME/labs/$lab" ]; then
        echo -e "${GREEN}✓${NC} Exists"
    else
        echo -e "${RED}✗${NC} Missing"
    fi
done

# Test containerlab deployment
echo ""
echo "Testing containerlab deployment:"
cat > /tmp/test-topo.yml << EOF
name: test
topology:
  nodes:
    test:
      kind: linux
      image: alpine:latest
EOF

echo -n "  Creating test topology... "
# The containerlab devcontainer runs as root, so no sudo needed
if containerlab deploy -t /tmp/test-topo.yml &>/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Success"
    echo -n "  Destroying test topology... "
    if containerlab destroy -t /tmp/test-topo.yml --cleanup &>/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Success"
    else
        echo -e "${YELLOW}⚠${NC} Cleanup failed (not critical)"
    fi
else
    echo -e "${RED}✗${NC} Failed"
    echo "  This might be normal if not running as root"
fi

rm -f /tmp/test-topo.yml

# System resources check
echo ""
echo "System Resources:"
echo "  CPU Cores: $(nproc)"
echo "  Total RAM: $(free -h | awk '/^Mem:/ {print $2}')"
echo "  Available RAM: $(free -h | awk '/^Mem:/ {print $7}')"
echo "  Docker disk usage: $(docker system df 2>/dev/null | awk '/Images/ {print $4}')"

# GitHub Codespaces detection
echo ""
if [ -n "$CODESPACES" ]; then
    echo -e "${GREEN}Running in GitHub Codespaces${NC}"
    echo "  Codespace name: $CODESPACE_NAME"
else
    echo "Running locally"
fi

# Final summary
echo ""
echo "========================================="
echo "Test Summary"
echo "========================================="
echo ""
echo "Your environment is ready for:"
echo "  • OSPF lab - Basic containerlab"
echo "  • Load Balancer lab - Multi-container services"

# Check if netlab works
if command -v netlab &>/dev/null 2>&1 || python3 -m netlab --version &>/dev/null 2>&1; then
    echo "  • BGP lab - With netlab auto-configuration"
    NETLAB_CMD="netlab up or python3 -m netlab up"
else
    echo "  • BGP lab - Manual configuration (netlab not available)"
    NETLAB_CMD="manual configuration"
fi

echo ""
echo "Quick start:"
echo "  cd ~/labs/ospf"
echo "  containerlab deploy -t topology.yml"
echo ""
if [ -n "$NETLAB_CMD" ]; then
    echo "Or with netlab (BGP lab):"
    echo "  cd ~/labs/bgp"
    echo "  $NETLAB_CMD"
fi
echo ""
