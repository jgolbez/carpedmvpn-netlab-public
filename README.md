# Vendor-Neutral OSPF Training Labs

> **Free sample labs** demonstrating our professional vendor-neutral network training curriculum.  
> Full OSPF course with 24+ comprehensive labs available for purchase.

A complete containerized OSPF lab environment featuring zero-installation deployment via GitHub Codespaces, hands-on learning with industry-standard open-source tools, and curriculum designed for enterprise network training.

---

## What Makes This Different

**Vendor-Neutral Approach:**
- Learn OSPF concepts, not vendor syntax
- Uses FRRouting (open-source) - skills transfer to Cisco, Juniper, Arista
- Focus on protocol behavior, not CLI memorization
- Industry-standard tools used in production networks

**Zero Installation:**
- No local setup required
- Runs entirely in GitHub Codespaces
- Students need only a web browser
- Deploy labs in under 60 seconds

**Professional Curriculum:**
- Based on CCNP ENARSI exam topics
- Type A labs (build from scratch) and Type B labs (observe and modify)
- Hands-on configuration, not just reading
- Designed for monetizable training courses

---

## Available Sample Labs

These are 3 of 24 labs from our complete OSPF training curriculum.

### Lab 1: OSPF Fundamentals
**Path:** `~/labs/ospf/lab1-ospf-basics/`

**What you'll learn:**
- OSPF neighbor formation and adjacencies
- Router ID selection and configuration
- OSPF areas and area design
- Cost metrics and SPF algorithm
- Network convergence behavior

**Details:**
- **Topology:** 3 FRR routers in triangle topology
- **Type:** Type B (pre-configured, observe and modify)
- **Time:** 45-60 minutes
- **Level:** Beginner

**Deploy:**
```bash
cd ~/labs/ospf/lab1-ospf-basics
sudo containerlab deploy -t topology.yml
docker exec -it clab-ospf-fundamentals-r1 vtysh
```

---

### Lab 2: OSPF Network Types
**Path:** `~/labs/ospf/lab2-ospf-network-types/`

**What you'll learn:**
- Broadcast network type and DR/BDR election
- Priority manipulation and election control
- Point-to-point network configuration
- Point-to-multipoint for hub-spoke topologies
- LSA differences between network types
- When to use each network type

**Details:**
- **Topology:** 4 FRR routers in hub-spoke design
- **Type:** Type A (build from scratch)
- **Time:** 75 minutes
- **Level:** Beginner to Intermediate

**Deploy:**
```bash
cd ~/labs/ospf/lab2-ospf-network-types
sudo containerlab deploy -t topology.yml
docker exec -it clab-ospf-lab2-network-types-r1 vtysh
```

---

### Lab 3: OSPF Metrics and Path Selection
**Path:** `~/labs/ospf/lab3-ospf-metrics/`

**What you'll learn:**
- OSPF cost calculation and formula
- Manual cost assignment and manipulation
- Reference bandwidth configuration
- Path selection based on cost
- Equal-Cost Multipath (ECMP) load balancing
- Path preference strategies

**Details:**
- **Topology:** 4 FRR routers with multiple paths between endpoints
- **Type:** Type B (pre-configured, observe and modify)
- **Time:** 60 minutes
- **Level:** Beginner to Intermediate

**Deploy:**
```bash
cd ~/labs/ospf/lab3-ospf-metrics
sudo containerlab deploy -t topology.yml
docker exec -it clab-ospf-lab3-metrics-r1 vtysh
```

---

## Quick Start for Students

### Option 1: GitHub Codespaces (Recommended)

1. **Launch the environment:**
   
   [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/jgolbez/carpedmvpn-netlab-public)

2. **Wait ~60 seconds** for initialization

3. **Navigate to a lab:**
   ```bash
   cd ~/labs/ospf/lab1-ospf-basics
   ```

4. **Deploy the lab:**
   ```bash
   sudo containerlab deploy -t topology.yml
   ```

5. **Access routers:**
   ```bash
   docker exec -it clab-ospf-fundamentals-r1 vtysh
   ```

6. **Follow the lab guide:**
   ```bash
   cat lab-guide.md
   # Or open in VS Code
   ```

That's it! No installation, no configuration, just learning.

---

### Option 2: Local Deployment

**Requirements:**
- Ubuntu 22.04+ (or WSL2 on Windows)
- Docker installed
- 8GB RAM minimum
- 20GB free disk space

**Setup:**
```bash
# Install Docker (if not installed)
curl -fsSL https://get.docker.com | sh

# Install Containerlab
bash -c "$(curl -sL https://get.containerlab.dev)"

# Clone repository
git clone https://github.com/jgolbez/carpedmvpn-netlab-public
cd carpedmvpn-netlab-public

# Navigate to lab
cd labs/ospf/lab1-ospf-basics

# Deploy
sudo containerlab deploy -t topology.yml
```

---

## System Requirements

### GitHub Codespaces (Recommended)
- **Local Requirements:** None (just a web browser)
- **Machine Type:** 2-core, 8GB RAM (default)
- **Free Tier:** 120 core-hours/month per user
- **Cost:** Free for typical educational use (~60 lab sessions/month)
- **Overage:** $0.18/hour for 2-core machine

### Local Development
- **OS:** Ubuntu 22.04+, macOS, or Windows with WSL2
- **RAM:** 8GB minimum (16GB recommended for multiple labs)
- **Storage:** 20GB free
- **CPU:** Dual-core minimum (quad-core recommended)
- **Docker:** Version 20.10 or newer

---

## Lab Management Commands

### Deploying Labs
```bash
# Navigate to lab directory
cd ~/labs/ospf/lab1-ospf-basics

# Deploy the lab
sudo containerlab deploy -t topology.yml

# Check lab status
sudo containerlab inspect -t topology.yml
```

### Accessing Routers
```bash
# Connect to router (replace with your lab and router name)
docker exec -it clab-ospf-fundamentals-r1 vtysh

# Example: Access R2 in Lab 1
docker exec -it clab-ospf-fundamentals-r2 vtysh

# Example: Access R1 in Lab 2
docker exec -it clab-ospf-lab2-network-types-r1 vtysh
```

### Inside Router CLI
```bash
# View running configuration
show running-config

# View OSPF neighbors
show ip ospf neighbor

# View routing table
show ip route

# View OSPF database
show ip ospf database

# Enter configuration mode
configure terminal
```

### Destroying Labs
```bash
# Destroy current lab
sudo containerlab destroy -t topology.yml --cleanup

# Destroy all running labs
sudo containerlab destroy -a --cleanup
```

---

## Technology Stack

**Orchestration:**
- **Containerlab 0.48.6+** - Network topology management
- **Docker** - Container runtime

**Networking:**
- **FRRouting 10.1.1** - Full routing protocol suite (OSPF, BGP, IS-IS, etc.)
- **Linux networking** - Real IP forwarding, not simulation

**Development:**
- **VS Code** - Integrated in Codespaces
- **GitHub Codespaces** - Cloud-based development environment

**Why FRRouting?**
- Open-source, production-grade routing stack
- Used by major cloud providers and ISPs
- Same protocol implementations as commercial routers
- Skills transfer directly to Cisco IOS, Juniper Junos, Arista EOS

---

## Repository Structure

```
carpedmvpn-netlab-public/
├── .devcontainer/
│   ├── devcontainer.json      # Codespaces configuration
│   └── setup.sh               # Environment initialization
├── labs/
│   └── ospf/
│       ├── lab1-ospf-basics/
│       │   ├── configs/       # FRR router configurations
│       │   ├── lab-guide.md   # Student instructions
│       │   └── topology.yml   # Containerlab topology
│       └── lab2-ospf-network-types/
│           ├── configs/       # FRR router configurations
│           ├── lab-guide.md   # Student instructions
│           └── topology.yml   # Containerlab topology
└── README.md                  # This file
```

**Each lab folder contains:**
- `topology.yml` - Defines the network topology for containerlab
- `configs/` - FRR configuration files for each router
- `lab-guide.md` - Complete student instructions with learning objectives

---

## Cost Analysis

### GitHub Codespaces
- **Free Tier:** 120 core-hours/month
- **Typical Lab:** 1-2 hours per session
- **Monthly Capacity:** 60-120 lab sessions free
- **Cost per lab:** $0 (within free tier)
- **Overage pricing:** $0.18/hour for 2-core machine

### Local Deployment
- **Software:** $0 (all open-source)
- **Hardware:** Use existing computer
- **Minimum:** 8GB RAM, dual-core CPU
- **Ongoing costs:** $0

### Alternative Solutions
| Platform | Monthly Cost | Setup Time | Notes |
|----------|-------------|------------|-------|
| **This Solution** | **$0** | **1 minute** | Browser-based, no installation |
| Cisco CML | $199+ | 2-4 hours | Official Cisco, expensive |
| EVE-NG Pro | ~$100/year | 2-4 hours | Popular choice, setup required |
| GNS3 Cloud | $50+ | 1-2 hours | Good features, still costs money |
| Physical Lab | $1000s+ | Days | Real hardware, very expensive |

---

## Full OSPF Training Curriculum

These sample labs are part of our **complete 24-lab OSPF curriculum** designed for network engineers seeking vendor-neutral OSPF expertise. Based on CCNP ENARSI exam topics.

**What's included in the full course:**
- ✅ 24 progressive OSPF labs (Type A and Type B)
- ✅ Complete lab workbooks with theory and practice
- ✅ Step-by-step solution guides
- ✅ Troubleshooting scenarios
- ✅ Assessment materials
- ✅ Coverage of all ENARSI OSPF topics
- ✅ Lifetime access to updates

**Topics covered in full curriculum:**
- OSPF fundamentals and neighbor formation
- Network types (broadcast, point-to-point, point-to-multipoint, NBMA)
- Multi-area OSPF design
- Route summarization and filtering
- Stub areas (stub, totally stubby, NSSA)
- Authentication (MD5, SHA)
- Virtual links
- LSA types and flooding
- Path selection and metrics
- OSPF over Frame Relay (legacy)
- Advanced troubleshooting

**Curriculum coverage:** 98% of vendor exam OSPF topics

---

## Copyright & Licensing

© 2026 Carpe DMVPN, LLC. All Rights Reserved.

**Sample Labs:**
This repository contains sample training materials demonstrating our curriculum quality. The complete OSPF course with all 24 labs and comprehensive workbooks is available for purchase.

**Open Source Software:**
The underlying tools used in these labs (Containerlab, FRRouting, Docker) are open-source and remain under their respective licenses. We claim no ownership of these tools.

**For Purchase:**
- Individual Course License

**Contact:** [Your contact information]

---

## Troubleshooting

### Containerlab won't deploy

```bash
# Check Docker is running
docker ps

# If permission error, try with sudo
sudo containerlab deploy -t topology.yml

# Check if containers are already running
sudo containerlab inspect
```

### Can't connect to router

```bash
# List running containers
docker ps

# Check container logs
docker logs clab-ospf-fundamentals-r1

# Verify lab deployed successfully
sudo containerlab inspect -t topology.yml
```

### Out of resources

```bash
# Clean up old labs
docker system prune -a

# Destroy all labs
sudo containerlab destroy -a --cleanup

# In Codespaces, rebuild container if needed
```

### Codespaces issues

- **Timeout:** Free tier has 30-minute idle timeout
- **Save work:** Always use `containerlab destroy` before closing
- **Rebuild:** Use "Codespaces: Rebuild Container" if environment breaks

---

## Additional Resources

**Learning OSPF:**
- [FRRouting OSPF Documentation](https://docs.frrouting.org/en/latest/ospf.html)
- [RFC 2328 - OSPF Version 2](https://datatracker.ietf.org/doc/html/rfc2328)

**Tools:**
- [Containerlab Documentation](https://containerlab.dev)
- [FRRouting Documentation](https://docs.frrouting.org)
- [Docker Documentation](https://docs.docker.com)

**Community:**
- [GitHub Issues](https://github.com/jgolbez/carpedmvpn-netlab-public/issues) - Report problems with sample labs
- [Discussions](https://github.com/jgolbez/carpedmvpn-netlab-public/discussions) - Ask questions

---

**Ready to explore advanced routing concepts? Start with Lab 1!**

```bash
cd ~/labs/ospf/lab1-ospf-basics
sudo containerlab deploy -t topology.yml
```
