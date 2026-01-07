#!/bin/bash
# Infrastructure Test for Lab 2: OSPF Network Types
# This validates the lab environment deploys correctly
# Students complete the actual OSPF configuration themselves

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

LAB_NAME="ospf-lab2-network-types"

echo "========================================="
echo "Lab 2: Infrastructure Test"
echo "========================================="
echo

check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ PASS${NC}: $1"
    else
        echo -e "${RED}✗ FAIL${NC}: $1"
        exit 1
    fi
}

# Test 1: Deploy the lab
echo "Test 1: Deploying lab..."
sudo containerlab deploy -t topology.yml --reconfigure > /dev/null 2>&1
check_status "Lab deployment"

sleep 3

# Test 2: Verify containers running
echo "Test 2: Checking containers..."
for router in r1 r2 r3 r4; do
    docker inspect clab-${LAB_NAME}-${router} > /dev/null 2>&1
    check_status "Container ${router} is running"
done

# Test 3: Verify IP addresses configured from FRR
echo "Test 3: Verifying FRR applied IP addresses..."
docker exec clab-${LAB_NAME}-r1 ip addr show eth1 | grep "10.0.12.1/30" > /dev/null
check_status "R1 eth1 has IP (FRR applied it)"

docker exec clab-${LAB_NAME}-r1 ip addr show eth2 | grep "10.0.13.1/30" > /dev/null
check_status "R1 eth2 has IP (FRR applied it)"

docker exec clab-${LAB_NAME}-r2 ip addr show eth1 | grep "10.0.12.2/30" > /dev/null
check_status "R2 eth1 has IP (FRR applied it)"

docker exec clab-${LAB_NAME}-r3 ip addr show eth1 | grep "10.0.13.2/30" > /dev/null
check_status "R3 eth1 has IP (FRR applied it)"

docker exec clab-${LAB_NAME}-r4 ip addr show eth1 | grep "10.0.14.2/30" > /dev/null
check_status "R4 eth1 has IP (FRR applied it)"

# Test 4: Verify FRR is running
echo "Test 4: Checking FRR daemons..."
for router in r1 r2 r3 r4; do
    docker exec clab-${LAB_NAME}-${router} vtysh -c "show version" | grep "FRRouting" > /dev/null
    check_status "FRR running on ${router}"
done

# Test 5: Verify interfaces are up
echo "Test 5: Checking interfaces are up..."
docker exec clab-${LAB_NAME}-r1 vtysh -c "show interface brief" | grep "eth1.*up" > /dev/null
check_status "R1 interfaces are up"

# Test 6: Verify connectivity
echo "Test 6: Checking link connectivity..."
docker exec clab-${LAB_NAME}-r1 ping -c 2 10.0.12.2 > /dev/null 2>&1
check_status "R1 can ping R2 (link working)"

docker exec clab-${LAB_NAME}-r1 ping -c 2 10.0.13.2 > /dev/null 2>&1
check_status "R1 can ping R3 (link working)"

# Test 7: Verify point-to-point link
echo "Test 7: Checking point-to-point link..."
docker exec clab-${LAB_NAME}-r1 ping -c 2 10.0.14.2 > /dev/null 2>&1
check_status "R1 can ping R4 (point-to-point link working)"

echo
echo "========================================="
echo -e "${GREEN}Infrastructure ready!${NC}"
echo "========================================="
echo
echo "Students can now proceed with lab-guide.md"
echo "to configure OSPF themselves."
echo
echo "To destroy lab: sudo containerlab destroy -t topology.yml --cleanup"
echo
