#!/bin/bash

# OSPF Lab Setup Script
# This script configures the lab after deployment

echo "=== OSPF Lab Setup Script ==="
echo ""

# Enable OSPFD on all routers
echo "Step 1: Enabling OSPFD on all routers..."
for i in 1 2 3; do
  echo "  Configuring r$i..."
  docker exec clab-ospf-fundamentals-r$i sed -i 's/ospfd=no/ospfd=yes/g' /etc/frr/daemons 2>/dev/null || echo "    Warning: Could not modify daemons file"
  docker exec clab-ospf-fundamentals-r$i /usr/lib/frr/frrinit.sh restart 2>/dev/null || echo "    Warning: FRR restart had issues (this is often ok)"
done

echo ""
echo "Step 2: Configuring IP addresses..."

# Configure R1
echo "  Configuring R1 IPs..."
docker exec clab-ospf-fundamentals-r1 ip addr add 10.0.12.1/30 dev eth1 2>/dev/null || echo "    eth1 IP may already be configured"
docker exec clab-ospf-fundamentals-r1 ip addr add 10.0.13.1/30 dev eth2 2>/dev/null || echo "    eth2 IP may already be configured"
docker exec clab-ospf-fundamentals-r1 ip addr add 1.1.1.1/32 dev lo 2>/dev/null || echo "    lo IP may already be configured"
docker exec clab-ospf-fundamentals-r1 ip link set eth1 up
docker exec clab-ospf-fundamentals-r1 ip link set eth2 up

# Configure R2
echo "  Configuring R2 IPs..."
docker exec clab-ospf-fundamentals-r2 ip addr add 10.0.12.2/30 dev eth1 2>/dev/null || echo "    eth1 IP may already be configured"
docker exec clab-ospf-fundamentals-r2 ip addr add 10.0.23.1/30 dev eth2 2>/dev/null || echo "    eth2 IP may already be configured"
docker exec clab-ospf-fundamentals-r2 ip addr add 2.2.2.2/32 dev lo 2>/dev/null || echo "    lo IP may already be configured"
docker exec clab-ospf-fundamentals-r2 ip link set eth1 up
docker exec clab-ospf-fundamentals-r2 ip link set eth2 up

# Configure R3
echo "  Configuring R3 IPs..."
docker exec clab-ospf-fundamentals-r3 ip addr add 10.0.23.2/30 dev eth1 2>/dev/null || echo "    eth1 IP may already be configured"
docker exec clab-ospf-fundamentals-r3 ip addr add 10.0.13.2/30 dev eth2 2>/dev/null || echo "    eth2 IP may already be configured"
docker exec clab-ospf-fundamentals-r3 ip addr add 3.3.3.3/32 dev lo 2>/dev/null || echo "    lo IP may already be configured"
docker exec clab-ospf-fundamentals-r3 ip link set eth1 up
docker exec clab-ospf-fundamentals-r3 ip link set eth2 up

echo ""
echo "Step 3: Testing connectivity..."
echo "  Testing R1 -> R2..."
docker exec clab-ospf-fundamentals-r1 ping -c 1 10.0.12.2 > /dev/null 2>&1 && echo "    ✓ R1 can reach R2" || echo "    ✗ R1 cannot reach R2"
echo "  Testing R1 -> R3..."
docker exec clab-ospf-fundamentals-r1 ping -c 1 10.0.13.2 > /dev/null 2>&1 && echo "    ✓ R1 can reach R3" || echo "    ✗ R1 cannot reach R3"
echo "  Testing R2 -> R3..."
docker exec clab-ospf-fundamentals-r2 ping -c 1 10.0.23.2 > /dev/null 2>&1 && echo "    ✓ R2 can reach R3" || echo "    ✗ R2 cannot reach R3"

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "You can now configure OSPF on each router:"
echo "  docker exec -it clab-ospf-fundamentals-r1 vtysh"
echo "  docker exec -it clab-ospf-fundamentals-r2 vtysh"
echo "  docker exec -it clab-ospf-fundamentals-r3 vtysh"
echo ""
echo "In vtysh, configure OSPF with:"
echo "  configure terminal"
echo "  router ospf"
echo "  ospf router-id X.X.X.X"
echo "  network 10.0.0.0/8 area 0"
echo "  network X.X.X.X/32 area 0"
echo ""
