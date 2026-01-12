# OSPF Metrics and Path Selection Lab

## Objective
Learn how OSPF calculates costs and selects paths by observing multiple routes, manipulating costs, and implementing path preferences.

## Topology

```
        R2
       /  \
      /    \
    R1 ---- R4
      \    /
       \  /
        R3
```

**R1:** 1.1.1.1/32
- eth1: 10.0.12.1/30 (to R2)
- eth2: 10.0.13.1/30 (to R3)
- eth3: 10.0.14.1/30 (to R4 direct)

**R2:** 2.2.2.2/32
- eth1: 10.0.12.2/30 (to R1)
- eth2: 10.0.24.1/30 (to R4)

**R3:** 3.3.3.3/32
- eth1: 10.0.13.2/30 (to R1)
- eth2: 10.0.34.1/30 (to R4)

**R4:** 4.4.4.4/32
- eth1: 10.0.24.2/30 (to R2)
- eth2: 10.0.34.2/30 (to R3)
- eth3: 10.0.14.2/30 (to R1 direct)

**Three paths from R1 to R4:**
- Path 1: R1 -> R2 -> R4 (2 hops)
- Path 2: R1 -> R3 -> R4 (2 hops)
- Path 3: R1 -> R4 (1 hop, direct)

## Pre-configured Setup

This lab comes with:
- IP addresses configured on all interfaces
- OSPF fully configured in area 0
- Full connectivity between all routers

## Starting the Lab

1. Deploy the lab:
   ```bash
   containerlab deploy -t topology.yml
   # Or with sudo if needed:
   sudo containerlab deploy -t topology.yml
   ```

2. Wait about 30 seconds for OSPF to converge

3. Access the routers:
   ```bash
   docker exec -it clab-ospf-lab3-metrics-r1 vtysh
   docker exec -it clab-ospf-lab3-metrics-r2 vtysh
   docker exec -it clab-ospf-lab3-metrics-r3 vtysh
   docker exec -it clab-ospf-lab3-metrics-r4 vtysh
   ```

## Lab Tasks

### Task 1: Observe Default Costs and Path Selection

1. **On R1, check the routing table to R4's loopback:**
   ```
   show ip route 4.4.4.4
   ```
   
   You should see the route via the direct path (10.0.14.2) because it has the lowest cost.

2. **Check all OSPF routes from R1:**
   ```
   show ip route ospf
   ```
   
   Notice which paths OSPF selected.

3. **View detailed cost information for R4's loopback:**
   ```
   show ip ospf route 4.4.4.4
   ```
   
   This shows the cost calculation and next-hop.

4. **Check interface costs:**
   ```
   show ip ospf interface
   ```
   
   Look for the "Cost:" field on each interface. Default cost is 10 for Ethernet interfaces.

### Task 2: Calculate OSPF Costs

1. **Understand the cost formula:**
   ```
   OSPF Cost = Reference Bandwidth / Interface Bandwidth
   ```
   
   Default reference bandwidth = 100 Mbps
   
   For 10 Mbps interface: 100/10 = 10 (default)

2. **On R1, check the current reference bandwidth:**
   ```
   show ip ospf
   ```
   
   Look for "Reference bandwidth" in the output.

3. **Calculate costs for paths from R1 to R4:**
   
   **Path 1 (via R2):**
   - R1 -> R2: Cost 10 (eth1)
   - R2 -> R4: Cost 10 (eth2)
   - **Total: 20**
   
   **Path 2 (via R3):**
   - R1 -> R3: Cost 10 (eth2)
   - R3 -> R4: Cost 10 (eth2)
   - **Total: 20**
   
   **Path 3 (direct):**
   - R1 -> R4: Cost 10 (eth3)
   - **Total: 10** <- Best path!

4. **Verify your calculations:**
   ```
   show ip ospf route 4.4.4.4
   ```

### Task 3: Modify Interface Costs

1. **Make the direct path less preferred by increasing its cost:**
   
   On R1:
   ```
   configure terminal
   interface eth3
    ip ospf cost 30
   exit
   exit
   ```

2. **Check the routing table change:**
   ```
   show ip route 4.4.4.4
   ```
   
   Now R1 should use BOTH paths via R2 and R3 (ECMP - Equal Cost Multipath).
   You'll see two next-hops!

3. **Verify the cost change:**
   ```
   show ip ospf interface eth3
   ```
   
   Look for "Cost: 30"

4. **Check OSPF route details:**
   ```
   show ip ospf route 4.4.4.4
   ```
   
   You should see both R2 and R3 as next-hops with cost 20 each.

### Task 4: Equal-Cost Multipath (ECMP)

1. **Test connectivity with both paths active:**
   ```
   ping 4.4.4.4 -c 10 source 1.1.1.1
   ```
   
   All pings should succeed.

2. **Use traceroute to see path selection:**
   ```
   traceroute 4.4.4.4 -s 1.1.1.1
   ```
   
   Run it multiple times - you might see it use different paths (R2 or R3).

3. **On R1, check how many paths are installed:**
   ```
   show ip route 4.4.4.4
   ```
   
   Look for multiple "via" entries - this is ECMP in action.

4. **View OSPF's perspective:**
   ```
   show ip ospf route
   ```
   
   Look for routes with multiple paths listed.

### Task 5: Prefer a Specific Path

1. **Force R1 to prefer the path through R2:**
   
   On R1:
   ```
   configure terminal
   interface eth2
    ip ospf cost 30
   exit
   exit
   ```
   
   This makes the R3 path more expensive (10+30 = 40).

2. **Verify R1 now prefers R2:**
   ```
   show ip route 4.4.4.4
   ```
   
   Should now show only one path via R2 (10.0.12.2).

3. **Check the costs:**
   ```
   show ip ospf route 4.4.4.4
   ```
   
   - Path via R2: Cost 20
   - Path via R3: Cost 40
   - Direct: Cost 30

4. **Test with traceroute:**
   ```
   traceroute 4.4.4.4 -s 1.1.1.1
   ```
   
   Should go: R1 -> R2 -> R4

### Task 6: Adjust Reference Bandwidth

1. **Simulate higher-speed interfaces by changing reference bandwidth:**
   
   On R1:
   ```
   configure terminal
   router ospf
    auto-cost reference-bandwidth 1000
   exit
   exit
   ```
   
   This changes the reference from 100 Mbps to 1000 Mbps (1 Gbps).

2. **Check the new reference bandwidth:**
   ```
   show ip ospf
   ```

3. **See how interface costs changed:**
   ```
   show ip ospf interface brief
   ```
   
   The default cost is now 100 (1000/10 = 100) instead of 10.

4. **Important:** For accurate costs, configure the same reference bandwidth on ALL routers:
   
   On R2, R3, and R4:
   ```
   configure terminal
   router ospf
    auto-cost reference-bandwidth 1000
   exit
   exit
   ```

5. **Verify routing converged with new costs:**
   ```
   show ip route ospf
   ```

### Task 7: Cost Calculation with Different Interface Types

1. **View all interface costs:**
   ```
   show ip ospf interface brief
   ```

2. **Calculate what the cost would be for different interface types:**
   
   With reference-bandwidth 1000:
   - 10 Mbps: 1000/10 = 100
   - 100 Mbps: 1000/100 = 10
   - 1 Gbps: 1000/1000 = 1
   - 10 Gbps: 1000/10000 = 0.1 (rounds to 1, minimum)

3. **Manually set a cost to simulate a faster link:**
   
   On R1:
   ```
   configure terminal
   interface eth3
    ip ospf cost 1
   exit
   exit
   ```
   
   This simulates a 1 Gbps link.

4. **Check routing preference:**
   ```
   show ip route 4.4.4.4
   ```
   
   Direct path should be preferred again (lowest cost).

## Useful Commands Reference

| Purpose | Command |
|---------|---------|
| Show OSPF routes with costs | `show ip ospf route` |
| Show routing table entry | `show ip route 4.4.4.4` |
| Show all OSPF routes | `show ip route ospf` |
| Show interface costs | `show ip ospf interface` |
| Show brief interface info | `show ip ospf interface brief` |
| Show OSPF process info | `show ip ospf` |
| Set interface cost | `ip ospf cost <1-65535>` |
| Set reference bandwidth | `auto-cost reference-bandwidth <1-4294967>` |
| Traceroute from source | `traceroute <dest> -s <source>` |
| Save configuration | `write memory` |

## Understanding OSPF Cost

### Cost Calculation Formula

```
OSPF Cost = Reference Bandwidth / Interface Bandwidth
```

**Default reference bandwidth:** 100 Mbps (100,000 Kbps)

### Default Costs by Interface Type

| Interface Type | Bandwidth | Default Cost (ref 100) | Cost (ref 1000) |
|----------------|-----------|------------------------|-----------------|
| 10 Mbps Ethernet | 10 Mbps | 10 | 100 |
| 100 Mbps FastEthernet | 100 Mbps | 1 | 10 |
| 1 Gbps GigabitEthernet | 1000 Mbps | 1 | 1 |
| 10 Gbps 10GigE | 10000 Mbps | 1 | 1 |

**Problem with default:** 100 Mbps, 1 Gbps, and 10 Gbps all get cost 1!

**Solution:** Increase reference bandwidth:
```
router ospf
 auto-cost reference-bandwidth 10000
```
This accommodates up to 10 Gbps links with meaningful cost differences.

### Path Selection Rules

1. **Lowest cost wins**
2. **Equal costs = ECMP** (load balancing across multiple paths)
3. **Manual costs override calculations**
4. **Minimum cost is 1** (even if calculation gives less)

### When to Manually Set Costs

**Use auto-cost reference-bandwidth when:**
- You have consistent interface types
- Network-wide cost policy
- Simpler management

**Use manual `ip ospf cost` when:**
- Want to prefer specific paths
- Need per-interface tuning
- Overriding bandwidth-based calculation

## ECMP (Equal-Cost Multipath)

### How ECMP Works

When multiple paths have the same cost:
1. OSPF installs all equal-cost paths
2. Router load-balances traffic across paths
3. Per-flow load balancing (same flow = same path)

### Benefits

- Better bandwidth utilization
- Automatic failover if one path fails
- No configuration needed (automatic)

### Verifying ECMP

```
show ip route 4.4.4.4
```

Look for multiple "via" entries:
```
O   4.4.4.4/32 [110/20] via 10.0.12.2, eth1, 00:01:23
                        via 10.0.13.2, eth2, 00:01:23
```

## FRR vs Cisco Command Differences

| Cisco IOS | FRR |
|-----------|-----|
| `show ip ospf interface brief` | `show ip ospf interface brief` (same!) |
| `show ip ospf` | `show ip ospf` (same!) |
| `ip ospf cost 100` | `ip ospf cost 100` (same!) |
| `auto-cost reference-bandwidth 1000` | `auto-cost reference-bandwidth 1000` (same!) |
| `show ip cef <ip>` | No direct equivalent (CEF is Cisco-specific) |

Most OSPF cost commands are identical between FRR and Cisco!

## Cleanup

When finished:
```bash
containerlab destroy -t topology.yml --cleanup
# Or with sudo:
sudo containerlab destroy -t topology.yml --cleanup
```

## Challenge Questions

1. Why does OSPF use cost instead of hop count?
2. What happens if you set different reference bandwidths on different routers?
3. How many equal-cost paths can OSPF use simultaneously?
4. What's the minimum OSPF cost value? Why?
5. If R1-R4 direct link is 1 Gbps but R1-R2-R4 path is 10 Gbps, how would you make OSPF prefer the faster path?
6. What happens to existing OSPF neighbors when you change the reference bandwidth?
7. Why is it recommended to set reference bandwidth network-wide?

### Answers

1. Cost allows considering link speed/quality, not just number of hops (a 10 Gbps 3-hop path may be better than 10 Mbps 1-hop)
2. Routing inconsistencies - routers calculate costs differently, may create suboptimal paths or loops
3. FRR defaults to 64, configurable with `maximum-paths`
4. Minimum is 1 - ensures all links have at least some cost
5. Set manual costs: direct link `ip ospf cost 100`, 10G path links `ip ospf cost 10` each
6. Nothing - cost change doesn't affect neighbor relationships, only routing decisions
7. Ensures consistent cost calculation across network, prevents routing anomalies

## Next Steps

- Explore multi-area OSPF with inter-area cost calculations
- Implement traffic engineering with cost manipulation
- Study OSPF convergence time with different costs
- Try asymmetric routing scenarios
