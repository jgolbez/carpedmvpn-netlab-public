# Network Training Lab Environment - Sample Labs

> **This is a free sample** demonstrating a network training lab platform. 
> Full course materials with comprehensive workbooks and solutions are available for purchase.

A complete containerized networking lab environment for education, featuring automated setup, pre-configured labs, and zero-installation deployment via GitHub Codespaces.

## Quick Start

1. Click the button below to launch the lab environment:
   
   [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/YOUR_USERNAME/network-labs)

2. Wait ~60 seconds for the environment to initialize

3. Choose a lab and start learning:
   ```bash
   cd ~/labs/ospf
   sudo containerlab deploy -t topology.yml
   ```

That's it! No local installation required. Everything runs in the cloud.

## Sample Labs

### 1. OSPF Fundamentals (`~/labs/ospf`)
- **Topics**: OSPF neighbors, areas, cost metrics, convergence
- **Devices**: 3 FRR routers in triangle topology
- **Time**: 45-60 minutes
- **Level**: Beginner

### 2. BGP Multi-AS (`~/labs/bgp`)  
- **Topics**: iBGP, eBGP, route reflection, AS path manipulation
- **Devices**: 5 FRR routers across 3 autonomous systems
- **Time**: 60-90 minutes
- **Level**: Intermediate
- **Special**: Auto-configured with netlab!

### 3. Load Balancing (`~/labs/loadbalancer`)
- **Topics**: HAProxy, nginx caching, health checks, algorithms
- **Devices**: HAProxy, nginx, 3 web servers, Redis
- **Time**: 90-120 minutes
- **Level**: Intermediate

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

## Learning Path

### Suggested Progression
1. **Week 1-2**: OSPF Fundamentals
2. **Week 3-4**: BGP Basics  
3. **Week 5-6**: Load Balancing
4. **Week 7-8**: Combined scenarios

## Additional Resources

- [Containerlab Documentation](https://containerlab.dev)
- [Netlab Documentation](https://netlab.tools)
- [BGP Labs (bgplabs.net)](https://bgplabs.net)
- [FRRouting Docs](https://docs.frrouting.org)

## Troubleshooting

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

## Premium Training Courses

These sample labs demonstrate the quality of our training materials. 

**Available for Purchase:**
- **Networking Fundamentals Course** - XX progressive labs with detailed workbook and solutions
- **Advanced Routing & Switching** - XX labs covering OSPF, BGP, MPLS, and more
- **Load Balancing & High Availability** - XX labs with real-world scenarios

Each course includes:
- ✅ Complete lab workbooks with theory and practice
- ✅ Step-by-step solutions guides
- ✅ Troubleshooting scenarios
- ✅ Lifetime access to updates


## Support

- **Sample Lab Issues**: [GitHub Issues](https://github.com/jgolbez/carpedmvpn-netlab-public/issues)
- **Course Purchases**: [tim@carpedmvpn.com]

---
