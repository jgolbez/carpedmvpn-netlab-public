# OSPF Metrics and Path Selection Lab

## Objective
Learn how OSPF calculates costs and selects paths by observing multiple routes, manipulating costs, and implementing path preferences.

# Lab 3 Theory Section - OSPF Metrics and Path Selection

---

## The Problem: Hop Count Isn't Enough

### RIP's Metric Limitation

In the 1980s, RIP (Routing Information Protocol) used a simple metric: **hop count**. Every link = 1 hop, regardless of speed or quality.

**This created absurd scenarios:**

**Scenario 1: The Slow "Short" Path**
```
        [1 Mbps]
    A -------------- B     (1 hop, preferred by RIP)

    A -- [10 Mbps] -- C -- [10 Mbps] -- B     (2 hops, ignored by RIP)
```
RIP would choose the 10 Mbps direct path over the 1 Gbps path through C, even though the faster path could transfer data 100x faster.

**Scenario 2: The Congested Link**
```
    A ---------- B     (1 hop, 99% utilized)
    
    A -- C -- D -- B   (3 hops, 10% utilized)
```
RIP would send all traffic over the congested link, ignoring the available capacity on the longer path.

**The fundamental flaw:** Hop count treats all links as equal. A satellite link with 500ms latency = a fiber link with 1ms latency = a congested link = a pristine link. All are "1 hop."

---

## The Solution: Cost-Based Metrics

OSPF introduced a revolutionary concept: **administrators define what "cost" means**.

RFC 2328 deliberately made this flexible:

> "A cost is associated with the output side of each router interface. This cost is configurable by the system administrator. The lower the cost, the more likely the interface is to be used to forward data traffic."

**The genius of this design:**
- Cost can represent bandwidth
- Cost can represent monetary expense
- Cost can represent latency
- Cost can represent administrative policy
- **Cost can represent whatever matters to YOU**

---

## The Cisco Standard: Bandwidth-Based Cost

While RFC 2328 left cost calculation open, Cisco established a de facto standard:

```
Cost = Reference Bandwidth / Interface Bandwidth
```

**Default reference bandwidth:** 100 Mbps

**Example calculations:**
- 10 Mbps Ethernet: 100/10 = **10**
- 100 Mbps FastEthernet: 100/100 = **1**
- 1 Gbps GigabitEthernet: 100/1000 = 0.1 → **1** (minimum)
- 10 Gbps 10GigE: 100/10000 = 0.01 → **1** (minimum)

**Why this formula?**
- Higher bandwidth = lower cost (more desirable)
- Automatically adapts to interface speed
- Intuitive: faster links are preferred
- Predictable: same interface types get same cost

---

## The Modern Problem: Fast Interfaces

The default reference bandwidth (100 Mbps) was fine in 1998 when FastEthernet was cutting-edge. In 2026, it's obsolete.

**The issue:**

With default settings, these all get cost 1:
- 100 Mbps FastEthernet
- 1 Gbps GigabitEthernet  
- 10 Gbps 10GigE
- 100 Gbps 100GigE
- 400 Gbps 400GigE

**OSPF can't differentiate between them!**

### Real-World Impact

**Scenario: Datacenter with mixed speeds**
```
           [1 Gbps, Cost 1]
    R1 ----------------------- R2
           
    R1 -- [100 Gbps, Cost 1] -- R3 -- [100 Gbps, Cost 1] -- R2
```

OSPF sees:
- Direct path: Cost 1
- Via R3: Cost 2

**Result:** OSPF chooses the 1 Gbps link, ignoring the 100 Gbps path, because it can't tell them apart!

---

## The Solution: Increase Reference Bandwidth

RFC 2328 anticipated this:

> "The TOS 0 metric must be set to a value greater than 0. A cost of 1 is appropriate for most networks."

Modern networks need modern reference bandwidth:

```
router ospf
 auto-cost reference-bandwidth 100000
```

**This changes calculations:**
- 1 Gbps: 100000/1000 = **100**
- 10 Gbps: 100000/10000 = **10**
- 100 Gbps: 100000/100000 = **1**

**Now OSPF can differentiate!**

**Critical rule:** Configure the same reference bandwidth on **ALL routers** in the OSPF domain. Mismatched reference bandwidth causes routing inconsistencies.

---

## Manual Cost Assignment: Traffic Engineering

Sometimes you don't want automatic cost calculation. You want to **force** traffic to take a specific path.

**Use cases:**

### Use Case 1: Backup Link
```
    A -- [Primary, 1 Gbps] -- B
    A -- [Backup, 1 Gbps] -- B
```

Both are 1 Gbps, but you want primary for normal traffic and backup only for failover:

```
interface backup-link
 ip ospf cost 1000
```

Now backup is only used if primary fails.

### Use Case 2: Expensive Link

```
    A -- [Metro Fiber, cheap] -- B
    A -- [Satellite, $$$] -- B
```

Satellite might have higher bandwidth, but you pay per GB:

```
interface satellite-link
 ip ospf cost 10000
```

Use satellite only when fiber fails.

### Use Case 3: Administrative Preference

```
    A -- [Through secure datacenter] -- B
    A -- [Through public internet] -- B
```

Security policy requires traffic through datacenter:

```
interface internet-link
 ip ospf cost 5000
```

**The power:** Manual cost gives you complete control over path selection.

---

## Equal-Cost Multipath (ECMP)

What happens when multiple paths have the **same** cost?

**OSPF's answer:** Use them all!

RFC 2328:
> "When multiple equal-cost routes to a destination exist, traffic can be distributed equally among them."

### How ECMP Works

**Example:**
```
        [Cost 10]
    R1 ------------ R2
        [Cost 10]
    R1 ------------ R3
    
    Both paths to R2: Cost 10
```

**OSPF behavior:**
1. SPF algorithm finds both paths
2. Both paths installed in routing table
3. Router load-balances across both links
4. Per-flow load balancing (same flow = same path for consistency)

### ECMP Benefits

**Bandwidth multiplication:**
- 2x 10 Gbps links = 20 Gbps effective throughput
- Automatic without configuration

**Automatic failover:**
- If one path fails, traffic instantly moves to remaining path
- No reconvergence needed for the working path

**No configuration needed:**
- If costs are equal, ECMP happens automatically
- Works with up to 64 paths (FRR default)

### The Catch

**ECMP only works with EQUAL costs!**

```
Path A: Cost 20
Path B: Cost 21   ← Not used, even if it's 1 away!
```

OSPF doesn't do "good enough" routing - it's always optimal path(s) or nothing.

---

## Cost Calculation Deep Dive

### The Formula in Detail

```
OSPF Cost = Reference Bandwidth (Mbps) / Interface Bandwidth (Mbps)
```

**Important notes:**
- Result is rounded (no decimal costs)
- Minimum cost is 1
- Maximum cost is 65,535
- Calculated per interface
- Only affects outbound traffic (cost is on output interface)

### Example Network

```
    R1 [10G] -- [10G] R2 [1G] -- [1G] R3
```

**With reference bandwidth 10000 (10 Gbps):**

**R1's perspective (reaching R3):**
- R1 → R2: Cost 10000/10000 = **1** (local 10G interface)
- R2 → R3: Cost 10000/1000 = **10** (R2's 1G interface)
- **Total cost from R1 to R3: 11**

**Key insight:** Cost is calculated on the **outbound** interface. R1 doesn't care that R2 has a 1G interface until traffic is leaving R2 toward R3.

---

## Asymmetric Routing

Because cost is per-interface and per-direction, you can have different costs in each direction:

```
    R1 [Cost 10] --> R2
    R1 <-- [Cost 100] R2
```

**Result:**
- R1 → R2 traffic: Uses this link (cost 10)
- R2 → R1 traffic: Might use different path (this link costs 100 from R2's perspective)

**Use case:** Satellite link with asymmetric bandwidth:
- Downlink: 50 Mbps (low cost)
- Uplink: 5 Mbps (high cost)

Configure costs to match:
- Downlink interface: Low cost (encourage use)
- Uplink interface: High cost (discourage use)

---

## Cost vs. Other Metrics

### Why Not Use Latency?

**Latency changes dynamically:**
- Network congestion
- Processing delays
- Queuing delays

**OSPF cost is static (or administratively changed):**
- Prevents routing instability
- No flapping between paths
- Predictable behavior

**If you need dynamic latency-based routing:** Use traffic engineering (MPLS TE, Segment Routing)

### Why Not Use Utilization?

**Same reason - too dynamic:**
- Link goes from 10% to 90% utilization constantly
- Would cause continuous SPF recalculations
- Routing would never be stable

**Modern approach:**
- OSPF provides stable topology-based routing
- Traffic engineering overlay (MPLS, SD-WAN) handles dynamic optimization

---

## Historical Context: Why Cost Was Revolutionary

### Before OSPF (RIP era - 1980s)

**Metric:** Hop count only

**Problem:** Can't express link quality

**Result:** Suboptimal routing

**Example:**
```
    A -- [9.6 kbps modem] -- B     (1 hop, preferred)
    
    A -- [T1] -- C -- [T1] -- B    (2 hops, ignored)
```

RIP would send all traffic over the 9.6 kbps modem link because "1 hop < 2 hops."

### OSPF's Innovation (Late 1980s)

**Metric:** Flexible cost
**Capability:** Administrator defines what matters
**Result:** Optimal routing based on real network properties

**Same example with OSPF:**
```
    A -- [Cost 10000] -- B     (slow link)
    
    A -- [Cost 10] -- C -- [Cost 10] -- B  (fast links, total cost 20)
```

OSPF chooses the T1 path even though it's more hops, because total cost (20) beats direct cost (10000).

---

## Modern Challenge: Traffic Engineering

As networks grow more complex, even OSPF cost isn't enough:

**Requirements today:**
- Route based on bandwidth availability
- Route based on latency
- Route based on application requirements
- Route based on business policy
- Change routes dynamically based on conditions

**OSPF's role in modern networks:**
- Provides base topology and reachability
- Establishes shortest paths
- Ensures loop-free routing

**Overlay technologies handle advanced requirements:**
- MPLS Traffic Engineering
- Segment Routing
- SD-WAN overlays

**The lesson:** OSPF cost gets you 90% of the way there. For the remaining 10%, you need additional tools.

---

## What You'll Learn in This Lab

Now that you understand why OSPF uses cost and how it enables optimal path selection, this lab will let you:

1. **Observe** default cost calculations based on interface bandwidth
2. **Calculate** costs manually to predict OSPF behavior
3. **Manipulate** costs to influence path selection
4. **Experience** ECMP when multiple paths have equal cost
5. **Configure** reference bandwidth for modern networks
6. **Implement** traffic engineering with manual cost assignment

**The goal:** Master OSPF's most powerful feature - cost-based path selection.

---

## RFC 2328 Key Sections

If you want to dive deeper into the specification:

- **Section 2 (Key Concepts):** Defines cost and shortest path
- **Section 16.1 (Dijkstra's algorithm):** How SPF uses cost
- **Appendix C.3 (Cost):** Cost configuration details

**Read the RFC at:** https://datatracker.ietf.org/doc/html/rfc2328

---


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

### Step 1: Deploy the Lab

Navigate to the lab directory and deploy the topology:

```bash
cd ~/labs/ospf/lab3-ospf-metrics
sudo containerlab deploy -t topology.yml
```

The deployment will:
- Create and start all router containers (R1, R2, R3, R4)
- Configure the multi-path topology
- Set up management network connectivity
- Initialize SSH access (takes ~30 seconds)
- **Pre-configure OSPF** (this is a Type B lab)

### Step 2: Wait for Initialization

**Important:** Wait 30 seconds after deployment for:
- SSH to fully initialize
- OSPF to converge (neighbors to form)

### Step 3: Access the Routers

You have three options for accessing the routers:

#### Option A: VSCode Containerlab Extension (Recommended)

1. Open the **Containerlab** panel in VSCode (left sidebar)
2. You'll see R1, R2, R3, R4 with multiple interconnected paths
3. Right-click on any router → Select "SSH"
4. Enter password: `admin`
5. You're automatically in vtysh

**Tip:** The visual topology is especially helpful in this lab since you'll be comparing multiple paths between R1 and R4.

#### Option B: Direct SSH

```bash
ssh admin@clab-ospf-lab3-metrics-r1  # Password: admin
ssh admin@clab-ospf-lab3-metrics-r2
ssh admin@clab-ospf-lab3-metrics-r3
ssh admin@clab-ospf-lab3-metrics-r4
```

#### Option C: Docker Exec (Advanced)

```bash
docker exec -it clab-ospf-lab3-metrics-r1 vtysh
docker exec -it clab-ospf-lab3-metrics-r2 vtysh
docker exec -it clab-ospf-lab3-metrics-r3 vtysh
docker exec -it clab-ospf-lab3-metrics-r4 vtysh
```

### Working in the Router CLI

Once connected (via any method), you're in **vtysh** - the FRR router CLI.

**Basic navigation:**
```
r1# show ip ospf neighbor          # View OSPF neighbors
r1# show ip route                  # View routing table
r1# configure terminal             # Enter configuration mode
r1(config)# router ospf            # Enter OSPF configuration
r1(config-router)# exit            # Back to config mode
r1(config)# exit                   # Back to exec mode
r1# exit                           # Exit vtysh (back to bash)
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

## What You Should Have Learned

After completing this lab, you should be able to:

**Cost Fundamentals:**
- [ ] Explain why OSPF uses cost instead of hop count
- [ ] Describe the OSPF cost formula: Reference Bandwidth / Interface Bandwidth
- [ ] Calculate OSPF cost for different interface speeds
- [ ] Understand why the minimum cost is 1
- [ ] Explain the purpose of reference bandwidth

**Cost Calculation:**
- [ ] Calculate path cost across multiple hops
- [ ] Predict which path OSPF will choose given multiple options
- [ ] Identify why fast links (1G+) all get cost 1 with default settings
- [ ] Understand the impact of reference bandwidth on cost calculations
- [ ] Explain why reference bandwidth must be consistent across all routers

**Manual Cost Assignment:**
- [ ] Configure manual cost on an interface using `ip ospf cost`
- [ ] Override automatic cost calculation for traffic engineering
- [ ] Implement primary/backup link scenarios using cost
- [ ] Force traffic through specific paths using cost manipulation
- [ ] Understand when manual cost is appropriate vs. automatic

**Equal-Cost Multipath (ECMP):**
- [ ] Explain how OSPF handles multiple equal-cost paths
- [ ] Identify when ECMP will activate (exact cost match required)
- [ ] Understand per-flow vs per-packet load balancing
- [ ] Calculate effective bandwidth with ECMP
- [ ] Recognize ECMP in routing table output

**Reference Bandwidth:**
- [ ] Configure reference bandwidth using `auto-cost reference-bandwidth`
- [ ] Choose appropriate reference bandwidth for modern networks
- [ ] Understand the impact of mismatched reference bandwidth
- [ ] Explain why changing reference bandwidth doesn't break adjacencies
- [ ] Calculate costs with non-default reference bandwidth

**Path Selection:**
- [ ] Trace OSPF path selection through multiple routers
- [ ] Use `show ip ospf route` to see SPF calculation results
- [ ] Verify path selection with `traceroute`
- [ ] Understand outbound cost calculation
- [ ] Recognize when OSPF will not load-balance (unequal costs)

**Practical Skills:**
- [ ] Modify costs to influence path selection
- [ ] Implement traffic engineering using cost
- [ ] Troubleshoot unexpected path selection
- [ ] Verify cost configuration with `show ip ospf interface`
- [ ] Compare automatic vs manual cost assignment

**Design Understanding:**
- [ ] Explain why cost is per-interface, not per-path
- [ ] Understand asymmetric routing caused by different costs
- [ ] Recognize the limitations of static cost metrics
- [ ] Compare OSPF cost to other routing metrics (hop count, delay)
- [ ] Explain the trade-offs between automatic and manual cost

---

## Deep Dive: RFC 2328 Key Concepts

**If you want to understand OSPF metrics deeply, these RFC sections are essential:**

- **Section 2 (Key Concepts):** Definition of cost and its role in shortest path calculation
- **Section 16.1 (Calculating the shortest-path tree):** How Dijkstra's algorithm uses cost to build the SPF tree
- **Section 16.2 (The next hop calculation):** How multiple equal-cost paths are identified
- **Appendix C.3 (Configurable Constants):** Default cost values and recommendations

**Read the RFC at:** https://datatracker.ietf.org/doc/html/rfc2328

**Particularly relevant passages:**

**On cost definition (Section 2):**
> "A cost is associated with the output side of each router interface. This cost is configurable by the system administrator. The lower the cost, the more likely the interface is to be used to forward data traffic."

**On cost flexibility:**
> "OSPF allows separate metrics to be configured for different Types of Service (TOS). TOS-based routing has not been widely implemented, and this document describes only TOS 0 routing."

**On equal-cost paths (Section 11):**
> "When there are multiple paths of equal cost to a destination, traffic can be distributed equally among the multiple paths (called equal-cost multipath)."

**On cost calculation (Appendix C.3):**
> "The TOS 0 metric must be set to a value greater than 0. A cost of 1 is appropriate for most networks."

---

## Next Steps

Now that you understand OSPF metrics and path selection, you can explore:

- **Lab 4 (Future):** Multi-area OSPF - How costs work across area boundaries
- **Advanced topic:** OSPF traffic engineering - Complex cost manipulation for specific traffic flows
- **Advanced topic:** Fast reroute and convergence optimization
- **Advanced topic:** OSPF vs IS-IS metrics - Comparing link-state protocols

---

## Reflection Questions

After completing this lab, consider:

1. **100 Gbps datacenter problem:** You have a datacenter with 100 Gbps links between spine and leaf routers. With default OSPF settings, these links get cost 1 (same as 100 Mbps). What reference bandwidth would you set? What happens to existing costs on slower links when you make this change? Is it disruptive?

2. **Primary vs backup WAN links:** You have two links from your branch office to headquarters: a primary 1 Gbps metro Ethernet (flat rate) and a backup 1 Gbps cellular link ($10/GB). Both get the same automatic cost. How would you configure costs to use cellular only when metro Ethernet fails? What cost values would you choose and why?

3. **Asymmetric routing implications:** You configure R1→R2 with cost 10 and R2→R1 with cost 100. Traffic from R1 to R2 uses this link, but return traffic from R2 to R1 takes a different path. What problems might this cause? When would asymmetric routing be intentional and beneficial?

4. **ECMP limitations:** You have three paths: Path A (cost 10), Path B (cost 10), Path C (cost 11). OSPF uses A and B with ECMP, completely ignoring C. Path C is actually higher bandwidth than A or B. How would you modify costs to include all three paths? What are the implications of making this change?

5. **Dynamic vs static metrics:** OSPF cost is static (or administratively changed). Modern networks have dynamic conditions - congestion, failures, varying latency. Why doesn't OSPF automatically adjust costs based on current link utilization or latency? What technologies provide dynamic path selection?

6. **Consistency requirement:** Why does OSPF require the same reference bandwidth on all routers? What specific problems occur if Router A uses 100 and Router B uses 10000? Can you think of a scenario where intentionally inconsistent reference bandwidth might be useful (even if problematic)?

---
