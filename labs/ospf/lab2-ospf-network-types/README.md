# Lab 2: OSPF Network Types

This lab teaches OSPF network type configuration including broadcast, point-to-point, and point-to-multipoint.

## Quick Start

```bash
# Deploy the lab
sudo containerlab deploy -t topology.yml

# Verify infrastructure is ready
./test-infrastructure.sh

# Connect to a router
docker exec -it clab-ospf-lab2-network-types-r1 vtysh

# Follow lab-guide.md to configure OSPF

# Destroy the lab when done
sudo containerlab destroy -t topology.yml --cleanup
```

## Directory Structure

```
02-network-types/
├── topology.yml          # Containerlab topology definition
├── configs/
│   ├── daemons           # FRR daemon configuration
│   ├── vtysh.conf        # vtysh configuration
│   ├── r1-frr.conf       # R1 minimal config (students add OSPF)
│   ├── r2-frr.conf       # R2 minimal config
│   ├── r3-frr.conf       # R3 minimal config
│   └── r4-frr.conf       # R4 minimal config
├── lab-guide.md          # Detailed student instructions
├── test-infrastructure.sh # Infrastructure validation script
└── README.md             # This file
```

## Topology Overview

```
         10.0.1.0/24 (Broadcast Segment)
              |
    +------[br1]------+
    |         |       |
  [R1]      [R2]    [R3]
    |
    | 10.0.2.0/30 (Point-to-Point)
    |
  [R4]
```

- **Broadcast Segment:** R1, R2, R3 via bridge
- **Point-to-Point:** R1 ↔ R4 direct link

## Learning Objectives

- Configure OSPF broadcast network type
- Manipulate DR/BDR election
- Configure OSPF point-to-point network type
- Configure OSPF point-to-multipoint network type
- Understand when to use each network type

## Estimated Time

75 minutes

## Prerequisites

- Lab 1: OSPF Neighbor Formation (recommended)
- Basic Linux command line knowledge
- Understanding of IP addressing

## Resource Requirements

- **Memory:** ~400MB
- **CPU:** Minimal
- **Codespaces:** 2-core, 4GB (free tier) ✅

## Network Type Coverage

| Type | Default On | DR/BDR | Use Case |
|------|------------|--------|----------|
| Broadcast | Ethernet | Yes | LANs |
| Point-to-Point | Serial | No | WAN links |
| Point-to-Multipoint | Manual | No | Hub-spoke |

## Common Commands Reference

### Deployment
```bash
# Deploy
sudo containerlab deploy -t topology.yml

# Check status
sudo containerlab inspect -t topology.yml

# Destroy
sudo containerlab destroy -t topology.yml --cleanup
```

### OSPF Configuration
```bash
# Enter router
docker exec -it clab-ospf-lab2-network-types-r1 vtysh

# Configure OSPF
configure terminal
router ospf
 ospf router-id 1.1.1.1
 network 10.0.1.0/24 area 0
 exit

# Set network type
interface eth1
 ip ospf network broadcast
 # or
 ip ospf network point-to-point
 # or
 ip ospf network point-to-multipoint
 exit
```

### Verification
```bash
show ip ospf neighbor
show ip ospf interface
show ip ospf database
show ip route ospf
```

## Troubleshooting

### Lab won't deploy
```bash
# Check if containers are already running
sudo containerlab inspect

# Clean up previous deployment
sudo containerlab destroy -a --cleanup

# Try deploying again
sudo containerlab deploy -t topology.yml
```

### Can't connect to router
```bash
# List running containers
docker ps

# Check if container is running
docker ps | grep ospf-lab2

# Check container logs
docker logs clab-ospf-lab2-network-types-r1
```

### OSPF neighbors not forming
```bash
# Check interface is up
show interface brief

# Check OSPF is running
show ip ospf

# Check network statements
show running-config | section router ospf

# Check firewall (shouldn't be issue in containers)
# Verify timers match
show ip ospf interface eth1
```

## Notes

- This is a Type A lab (build from scratch)
- Students configure all OSPF from empty configs
- Configs have commented examples for reference
- All routers use FRRouting 10.1.1
- IPv6 is disabled to focus on IPv4 OSPF

## Files Needed for Repository

When adding to your repository, ensure you have:
- ✅ topology.yml
- ✅ configs/daemons
- ✅ configs/vtysh.conf
- ✅ configs/r1-frr.conf through r4-frr.conf
- ✅ lab-guide.md
- ✅ test-infrastructure.sh (optional - for verifying deployment)
- ✅ README.md

## Testing Checklist

Before committing to repository:

- [ ] Lab deploys successfully (`sudo containerlab deploy -t topology.yml`)
- [ ] All 4 routers start correctly
- [ ] Infrastructure test passes (`./test-infrastructure.sh`)
- [ ] Students can access routers via vtysh
- [ ] Lab guide instructions are accurate
- [ ] Lab destroys cleanly (`sudo containerlab destroy -t topology.yml --cleanup`)

**Note:** The infrastructure test only validates deployment - it does not configure OSPF. Students complete the OSPF configuration by following lab-guide.md.

## Version

- **Lab Version:** 1.1
- **FRR Version:** 10.1.1
- **Containerlab:** 0.48.6+
- **Last Updated:** January 2026

## License

© 2026 Carpe DMVPN, LLC. All Rights Reserved.

This is sample training material. Full course materials available for purchase.
