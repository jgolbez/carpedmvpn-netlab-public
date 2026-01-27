# Vendor-Neutral OSPF Training Labs

> **Free sample labs** demonstrating our professional vendor-neutral network training curriculum.  
> Full OSPF course with 24+ comprehensive labs available soon.

A complete containerized OSPF lab environment featuring zero-installation deployment via GitHub Codespaces, visual topology interface with one-click router access, and curriculum designed for enterprise network training.

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

**Visual Interactive Interface:**
- VSCode Containerlab extension provides graphical topology view
- Right-click any router to instantly SSH in
- No memorizing container names or complex commands
- Automatic router CLI (vtysh) on login

**Professional Curriculum:**
- Type A labs (build from scratch) and Type B labs (observe and modify)
- Hands-on configuration, not just reading
- Theory-first approach with RFC references
- Designed for monetizable training courses

---

## Available Sample Labs

These are 3 of 24 labs from our complete OSPF training curriculum.

### Lab 1: OSPF Fundamentals
**Path:** `~/labs/ospf/lab1-ospf-basics/`

**What you'll learn:**
- Why OSPF was created (RIP's limitations)
- Link-state vs distance-vector routing
- Dijkstra's SPF algorithm and why OSPF uses it
- Router ID selection and significance
- OSPF neighbor formation and adjacencies
- OSPF areas and hierarchical design
- Cost metrics and path selection
- Network convergence behavior

**Details:**
- **Topology:** 3 FRR routers in triangle topology
- **Type:** Type B (pre-configured, observe and modify)
- **Time:** 60-90 minutes (includes theory reading)
- **Level:** Beginner
- **Theory:** Comprehensive with RFC 2328 quotations
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
- Production multi-access segment design

**Details:**
- **Topology:** 4 FRR routers in hub-spoke design
- **Type:** Type A (build from scratch)
- **Time:** 75 minutes
- **Level:** Beginner to Intermediate
---

### Lab 3: OSPF Metrics and Path Selection
**Path:** `~/labs/ospf/lab3-ospf-metrics/`

**What you'll learn:**
- OSPF cost calculation formula
- Why cost instead of hop count
- Manual cost assignment and manipulation
- Reference bandwidth configuration and scaling
- Path selection based on cost
- Equal-Cost Multipath (ECMP) load balancing
- Path preference strategies and traffic engineering

**Details:**
- **Topology:** 4 FRR routers with multiple paths between endpoints
- **Type:** Type B (pre-configured, observe and modify)
- **Time:** 60 minutes
- **Level:** Beginner to Intermediate
---

## Quick Start for Students

### Option 1: GitHub Codespaces (Recommended)

1. **Launch the environment:**
   
   [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/jgolbez/carpedmvpn-netlab-public)

2. **Wait ~60 seconds** for initialization

3. **Navigate to a lab:**
   ```bash
   cd labs/ospf/lab1-ospf-basics
   ```

4. **Deploy the lab:**
   ```bash
   sudo containerlab deploy -t topology.yml
   ```

5. **Access routers using VSCode:**
   - Open the **Containerlab** panel in VSCode (left sidebar)
   - You'll see your deployed topology with router nodes
   - Right-click on a router (e.g., R1) → Select "SSH"
   - Login with username: `admin`, password: `admin`
   - You'll automatically be in the router CLI (vtysh)

   **Alternative - Command Line:**
   ```bash
   # SSH directly
   ssh admin@clab-ospf-fundamentals-r1
   # Password: admin
   
   # Or use docker exec
   docker exec -it clab-ospf-fundamentals-r1 vtysh
   ```

6. **Follow the lab guide:**
   ```bash
   cat lab-guide.md
   # Or open in VS Code for better formatting
   ```

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
cd labs/ospf/lab1-ospf-basics

# Deploy the lab
sudo containerlab deploy -t topology.yml

# Check lab status
sudo containerlab inspect -t topology.yml
```

### Accessing Routers

**Option 1: VSCode Containerlab Extension (Recommended)**
1. Open the **Containerlab** panel in VSCode (left sidebar icon)
2. View your deployed topology visually
3. Right-click on any router node
4. Select "SSH"
5. Enter credentials:
   - Username: `admin`
   - Password: `admin`
6. You're automatically in vtysh (router CLI)

**Option 2: Direct SSH**
```bash
# SSH to a router by name
ssh admin@clab-ospf-fundamentals-r1
# Password: admin

# You'll be automatically placed in vtysh
```

**Option 3: Docker Exec (Fallback)**
```bash
# Connect directly to router CLI
docker exec -it clab-ospf-fundamentals-r1 vtysh

# Examples for different labs:
docker exec -it clab-ospf-fundamentals-r2 vtysh       # Lab 1, R2
docker exec -it clab-ospf-lab2-network-types-r1 vtysh # Lab 2, R1
docker exec -it clab-ospf-lab3-metrics-r1 vtysh       # Lab 3, R1
```

**Inside Router CLI:**
```bash
# You're now in vtysh - the router CLI
r1# show ip ospf neighbor
r1# show ip route
r1# configure terminal
r1(config)# 
```

**To exit vtysh and return to bash:**
```
r1# exit
admin@r1:~$
```

### Destroying Labs
```bash
# Destroy current lab
sudo containerlab destroy -t topology.yml --cleanup

# Destroy all running labs
sudo containerlab destroy -a --cleanup
```

---

## VSCode Containerlab Extension

The Containerlab extension provides a visual, interactive way to work with your lab topologies.

**Features:**
- **Visual Topology:** See your network diagram in VSCode
- **One-Click SSH:** Right-click any router to instantly connect
- **Automatic Login:** Pre-configured SSH access (admin/admin)
- **Direct to CLI:** SSH sessions automatically start in router CLI (vtysh)
- **Multiple Sessions:** Easy to open connections to multiple routers simultaneously
- **No Commands to Remember:** Intuitive right-click interface

**How to Use:**
1. Deploy a lab using `sudo containerlab deploy -t topology.yml`
2. Wait 30 seconds for SSH to initialize
3. Open the Containerlab panel in VSCode (left sidebar)
4. Your topology appears with all router nodes
5. Right-click any router → Select "SSH"
6. Enter password: `admin` (username auto-filled)
7. You're immediately in the router CLI

**Why This Matters:**
- No need to remember long `docker exec` commands
- Visual representation helps understand topology
- Faster workflow for multi-router configurations
- More intuitive for students new to containerized labs
- Works the same in Codespaces and local VSCode

**Alternative Access Methods:**
- **SSH directly:** `ssh admin@<container-name>`
- **Docker exec:** `docker exec -it <container-name> vtysh`

The extension is pre-installed in GitHub Codespaces and provides the easiest way to interact with your labs.

---

## Technology Stack

**Orchestration:**
- **Containerlab 0.48.6+** - Network topology management
- **Docker** - Container runtime

**Networking:**
- **FRRouting 10.1.0** - Full routing protocol suite (OSPF, BGP, IS-IS, etc.)
- **Linux networking** - Real IP forwarding, not simulation

**Development:**
- **VS Code** - Integrated in Codespaces
- **Containerlab VSCode Extension** - Visual topology with one-click SSH access
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
│       │   │   ├── daemons
│       │   │   ├── vtysh.conf
│       │   │   ├── ssh-setup.sh
│       │   │   └── r*.conf
│       │   ├── lab-guide.md   # Student instructions
│       │   └── topology.yml   # Containerlab topology
│       ├── lab2-ospf-network-types/
│       │   ├── configs/
│       │   ├── lab-guide.md
│       │   └── topology.yml
│       └── lab3-ospf-metrics/
│           ├── configs/
│           ├── lab-guide.md
│           └── topology.yml
└── README.md                  # This file
```

**Each lab folder contains:**
- `topology.yml` - Defines the network topology for containerlab
- `configs/` - FRR configuration files and SSH setup script
- `lab-guide.md` - Complete student instructions with theory and practice

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

These sample labs are part of our **complete 24-lab OSPF curriculum** designed for network engineers seeking vendor-neutral OSPF expertise.

**What's included in the full course:**
- ✅ 24 progressive OSPF labs (Type A and Type B)
- ✅ Theory-first approach with RFC quotations
- ✅ Complete lab workbooks with comprehensive explanations
- ✅ Step-by-step solution guides
- ✅ Troubleshooting scenarios
- ✅ Assessment materials with learning checklists
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

**Curriculum coverage:** Based on CCNP ENARSI exam topics

---

## Copyright & Licensing

© 2026 Carpe DMVPN, LLC. All Rights Reserved.

**Sample Labs:**
This repository contains sample training materials demonstrating our curriculum quality. The complete OSPF course with all 24 labs and comprehensive workbooks is available for purchase.

**Open Source Software:**
The underlying tools used in these labs (Containerlab, FRRouting, Docker) are open-source and remain under their respective licenses. We claim no ownership of these tools.

**For Purchase:**
- Individual Course License

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

### Can't SSH to router

```bash
# Wait 30 seconds after deployment
# SSH setup script needs time to run

# Check if SSH is running in container
docker exec clab-ospf-fundamentals-r1 ps aux | grep sshd
# Should see: /usr/sbin/sshd -D

# Verify container is running
docker ps | grep ospf-fundamentals

# Test direct access (bypass SSH)
docker exec -it clab-ospf-fundamentals-r1 vtysh
```

### VSCode Extension not showing topology

```bash
# Reload VSCode window
# Ctrl+Shift+P → "Developer: Reload Window"

# Verify lab is deployed
sudo containerlab inspect

# Check extension is installed
# Extensions panel → Search "containerlab"
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
- [RFC 2328 - OSPF Version 2](https://datatracker.ietf.org/doc/html/rfc2328) - The definitive specification
- [FRRouting OSPF Documentation](https://docs.frrouting.org/en/latest/ospf.html)

**Tools:**
- [Containerlab Documentation](https://containerlab.dev)
- [Containerlab VSCode Extension](https://marketplace.visualstudio.com/items?itemName=containerlab.containerlab)
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
# Then right-click R1 in the Containerlab panel to SSH in
```
