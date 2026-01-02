# Network Training Lab Environment - Sample Labs

> **This is a free sample** demonstrating our professional network training platform. 
> Full course materials with comprehensive workbooks and solutions are available for purchase.

A complete containerized networking lab environment for education, featuring automated setup, pre-configured labs, and zero-installation deployment via GitHub Codespaces.

## Quick Start for Students

1. Click the button below to launch the lab environment:
   
   [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/YOUR_USERNAME/network-labs)

2. Wait ~60 seconds for the environment to initialize

3. Choose a lab and start learning:
   ```bash
   cd ~/labs/ospf
   sudo containerlab deploy -t topology.yml
   ```

That's it! No local installation required. Everything runs in the cloud.

## Available Labs

### 1. OSPF Fundamentals (`~/labs/ospf`)
- **Topics**: OSPF neighbors, areas, cost metrics, convergence
- **Devices**: 3 FRR routers in triangle topology
- **Time**: 45-60 minutes
- **Level**: Beginner
- **Requirements**: Containerlab only

### 2. BGP Multi-AS (`~/labs/bgp`)  
- **Topics**: iBGP, eBGP, route reflection, AS path manipulation
- **Devices**: 5 FRR routers across 3 autonomous systems
- **Time**: 60-90 minutes
- **Level**: Intermediate
- **Special**: Auto-configured with netlab (optional - can run manually if netlab unavailable)

### 3. Load Balancing (`~/labs/loadbalancer`)
- **Topics**: HAProxy, nginx caching, health checks, algorithms
- **Devices**: HAProxy, nginx, 3 web servers, Redis
- **Time**: 90-120 minutes
- **Level**: Intermediate
- **Requirements**: Containerlab only

### System Requirements

**GitHub Codespaces** (Recommended):
- No local requirements
- 2-core machine type (default)
- 120 free core-hours/month per user

**Local Development**:
- Ubuntu 22.04+ (or WSL2 on Windows)
- Docker installed
- 8GB RAM minimum
- 20GB free disk space


### Lab Management Commands

```bash
# Deploy a lab
sudo containerlab deploy -t topology.yml

# Connect to a node
docker exec -it clab-[lab-name]-[node-name] vtysh

# Destroy a lab
sudo containerlab destroy -t topology.yml --cleanup

# With netlab (auto-configured)
netlab up        # Deploy with configurations
netlab connect r1  # Connect to router
netlab down      # Destroy lab
```

## 🔧 What's Included

### Software Stack
- **Containerlab 0.48.6**: Network topology orchestration
- **Netlab**: Automated device configuration
- **FRRouting 10.1**: Full routing protocol suite
- **HAProxy 2.9**: Load balancing
- **nginx**: Web server and caching proxy
- **Docker**: Container runtime

### Pre-Installed Tools
- `vtysh`: FRR CLI interface
- `tcpdump`: Packet capture
- `wireshark-cli`: Protocol analysis  
- `traceroute`: Path discovery
- `ansible`: Automation
- `netmiko`: Network automation library

### Directory Structure
```
/home/vscode/
├── .devcontainer/
│   ├── devcontainer.json    # Codespaces configuration
│   └── setup.sh             # Environment setup script
├── labs/
│   ├── ospf/
│   │   ├── topology.yml    # Containerlab topology with bind mounts
│   │   ├── daemons         # FRR daemon configuration
│   │   ├── vtysh.conf      # VTY shell configuration
│   │   ├── r1-frr.conf     # Router 1 configuration
│   │   ├── r2-frr.conf     # Router 2 configuration
│   │   ├── r3-frr.conf     # Router 3 configuration
│   │   └── lab-guide.md    # Student instructions
│   ├── bgp/
│   │   ├── topology.yml    # Netlab topology
│   │   ├── lab.yml         # Netlab configuration
│   │   └── lab-guide.md    
│   └── loadbalancer/
│       ├── topology.yml
│       ├── haproxy.cfg
│       ├── nginx.conf
│       └── lab-guide.md
└── README.md
```

## Cost Analysis

### GitHub Codespaces (Recommended)
- **Free Tier**: 120 core-hours/month
- **Lab Usage**: ~2 core-hours per lab session
- **Monthly Capacity**: ~60 lab sessions free
- **Overage**: $0.18/hour for 2-core machine

### Local Deployment
- **Software**: $0 (all open-source)
- **Hardware**: Existing laptops/desktops work
- **Minimum**: 8GB RAM, dual-core CPU

### Comparison to Alternatives
| Platform | Monthly Cost | Setup Time | Features |
|----------|-------------|------------|----------|
| This Solution | $0 | 1 minute | Full labs in browser |
| EVE-NG Pro | €12.50 | 2-4 hours | Web UI, limited free |
| GNS3 Cloud | $50+ | 1-2 hours | Full features |
| Physical Lab | $1000s | Days | Hardware |


## Additional Resources

- [Containerlab Documentation](https://containerlab.dev)
- [Netlab Documentation](https://netlab.tools)
- [BGP Labs (bgplabs.net)](https://bgplabs.net)
- [FRRouting Docs](https://docs.frrouting.org)

## Troubleshooting

### Common Issues in GitHub Codespaces


**"containerlab deploy fails"**
```bash
# In Codespaces, try without sudo first:
containerlab deploy -t topology.yml

# If permission denied, fix Docker socket:
sudo chmod 666 /var/run/docker.sock

# Then try again without sudo:
containerlab deploy -t topology.yml
```


### Common Issues

**"Permission denied" errors**
```bash
# Always use sudo with containerlab
sudo containerlab deploy -t topology.yml
```

**Container won't start**
```bash
# Check Docker status
docker ps -a
docker logs [container-name]
```

**Out of resources**
```bash
# Clean up old labs
docker system prune -a
sudo containerlab destroy -a --cleanup
```

**Codespaces timeout**
- Free tier: 30 minutes idle timeout
- Save work frequently
- Use `netlab down` or `containerlab destroy` before closing

## 📄 Copyright Notice

© 2026 [Carpe DMVPN, LLC]. All Rights Reserved.

This repository contains sample training materials. The complete course materials, including 
comprehensive lab workbooks and solutions, are available for purchase.

The underlying open-source software tools used in these labs (Containerlab, FRR, nginx, HAProxy, etc.) 
remain under their respective open-source licenses. We claim no ownership of these tools.

## 💼 Premium Training Courses

These sample labs demonstrate the quality of our training materials. 

**Available for Purchase:**
- **Networking Fundamentals Course** - 15 progressive labs with detailed workbooks
- **Advanced Routing & Switching** - 20 labs covering OSPF, BGP, MPLS, and more
- **Load Balancing & High Availability** - 12 labs with real-world scenarios
- **Network Automation with Python** - Hands-on automation labs

Each course includes:
- ✅ Complete lab workbooks with theory and practice
- ✅ Step-by-step solutions guides
- ✅ Troubleshooting scenarios
- ✅ Assessment materials
- ✅ Lifetime access to updates

**[Contact for Pricing]** | **[Enterprise Licensing Available]**

## 👥 Support

- **Sample Lab Issues**: [GitHub Issues](https://github.com/YOUR_USERNAME/network-labs/issues)
- **Course Purchases**: [Your contact/sales email]
- **Enterprise Training**: [Your business email]

## 🎯 Key Features for Education

✅ **Zero Installation** - Students need only a web browser  
✅ **Fast Deployment** - Labs start in under 60 seconds  
✅ **Auto-Configuration** - Netlab configures routing protocols automatically  
✅ **Cost-Effective** - Completely free for typical educational use  
✅ **Industry Tools** - Real FRR, HAProxy, nginx - not simulations  
✅ **Reproducible** - Git-based labs ensure consistency  
✅ **Scalable** - Support 30+ students simultaneously  

---
