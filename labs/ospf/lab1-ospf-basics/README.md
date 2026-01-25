# OSPF Fundamentals Lab

## Overview

OSPF (Open Shortest Path First) revolutionized enterprise routing when it was introduced in 1989. This lab explores the fundamental concepts of link-state routing by observing and configuring a working OSPF network. You'll understand not just *how* OSPF works, but *why* it was designed the way it was.

**Duration:** 60-90 minutes  
**Difficulty:** Beginner  
**Prerequisites:** Basic TCP/IP networking, familiarity with router CLI

---

## The Problem: Why OSPF Exists

### The Limitations of Distance-Vector Routing

In the 1980s, networks used **RIP (Routing Information Protocol)**, a distance-vector protocol. RIP had critical limitations:

1. **Hop count metric** - Only the number of hops mattered, not the speed of the links in aggregate
2. **Slow convergence** - Could take minutes to detect and route around failures
3. **Counting to infinity** - Networks with more than 15 hops were consifdered unreachable
4. **Limited scalability** - Maximum 15 hops meant RIP couldn't scale to large networks
5. **No load balancing** - Single best path only

As networks grew larger and more complex, these limitations became unacceptable.

### The Link-State Solution

RFC 2328 (OSPF Version 2, later updated by several other RFCs) introduced a fundamentally different approach:

> "OSPF is a link state routing protocol. It is designed to be run internal to a single Autonomous System. Each OSPF router maintains an identical database describing the Autonomous System's topology. From this database, a routing table is calculated by constructing a shortest-path tree."

This was a fundamental shift in dynamic routing because OSPF aimed to have each router be completely aware of its connectivity to other routers in the same area, and the dynamically routed networks would be expressed as points in a graph.

**Distance-vector (RIP):** "I know the distance to destinations"
- Routers share their routing tables with neighbors, but not a path by which to arrive
- Lacks a complete view of the netwirk topology
- "Routing by rumor" was how distance-vector routing is referred

**Link-state (OSPF):** "I know the complete network topology"
- Routers share information about their directly connected links
- All routers build identical topology database
- Each router independently calculates best paths based on knowledge of the graph and the metric of the links

---

## Why Dijkstra's Algorithm?

OSPF uses **Dijkstra's Shortest Path First (SPF) algorithm** to calculate routes. RFC 2328 describes this:

> "The shortest-path tree is calculated by using a form of Dijkstra's algorithm. The algorithm builds a tree from the root (the calculating router itself) to all destinations in the OSPF area."

**Why Dijkstra specifically?**

1. **Optimal paths** - Mathematically guarantees the shortest path to every destination
2. **Efficient computation** - O(n²) or O(n log n) with priority queue - fast even for large networks
3. **Cost-based metric** - Can use any metric (bandwidth, delay, monetary cost), not just hop count
4. **Loop-free** - Tree structure inherently prevents routing loops
5. **Proven algorithm** - Well-understood since 1959, reliable and predictable

If every router has the same map (link-state database) and runs the same algorithm (Dijkstra), they'll all agree on the best paths. Calculating the same view of the network is critical.

---

## OSPF Design Principles

### 1. Link-State Advertisements (LSAs)

RFC 2328 defines LSAs as the fundamental building blocks:

> "Each separate type of LSA has a separate function. Router-LSAs and network-LSAs describe how an area's routers and networks are interconnected.  Summary-LSAs provide a way of condensing an area's routing information.  AS-external-LSAs provide a way of transparently advertising externally-derived routing information throughout the Autonomous System."

**Why LSAs instead of route updates?**
- LSAs describe links, not routes
- Smaller, more efficient to flood
- Each router computes its own routes
- Changes propagate quickly (only affected LSAs update, not entire tables)

### 2. Areas and Hierarchical Design

OSPF divides networks into areas to improve scalability:

> "OSPF allows networks to be separated into areas. This enables a significant reduction in routing traffic. Areas are identified by a 32-bit Area ID."

**The scalability problem:**
- In a flat network, every change floods to every router
- Link flapping can cause network-wide route recalculations
- Routing tables grow linearly with network size

**The area solution:**
- Area 0 (backbone) connects all other areas
- Internal routes stay within areas (reduced flooding)
- Area Border Routers (ABRs) summarize routes between areas
- SPF calculations limited to area scope

**Real-world impact:** A 1000-router flat OSPF network requires every router to know about every link. With 10 areas of 100 routers each, most routers only need to know their area's 100 routers plus summaries from other areas - massive reduction in overhead.

### 3. Router ID - A Unique Identity

OSPF requires every router to have a unique identifier:

> "Each router in an OSPF routing domain is assigned a Router ID. This Router ID uniquely identifies the router, and is represented as a 32-bit number."

**Why not just use an IP address?**
- IP addresses can change (interface renumbering, DHCP)
- Routers may have many interfaces with many IPs
- Router ID provides stable identity for LSA origination
- Simplifies SPF calculation (nodes in the graph need stable IDs)

**Best practice:** Use a loopback interface IP as router-id - loopbacks never go down, providing stable identity.

---

## How OSPF Works: The Lifecycle

### Phase 1: Neighbor Discovery

Routers send **Hello packets** (multicast 224.0.0.5) every 10 seconds on broadcast networks:
- Discover neighbors on directly connected links
- Verify bidirectional communication
- Negotiate parameters (area, timers, authentication)

### Phase 2: Database Synchronization

Once neighbors are discovered, routers synchronize their link-state databases:
- Exchange Database Description (DBD) packets listing all LSAs
- Request missing LSAs using Link State Requests
- Receive LSAs via Link State Updates
- Acknowledge with Link State Acknowledgments

**Result:** All routers in an area have identical link-state databases.

### Phase 3: Route Calculation

Each router independently runs Dijkstra's SPF algorithm:
- Root of the tree is the router itself
- Each link has a cost (default: 100 Mbps / interface bandwidth)
- Algorithm finds lowest-cost path to each destination
- Results populate the routing table

### Phase 4: Maintaining Synchronization

OSPF continuously maintains accuracy:
- LSAs are **aged** - each has a sequence number and age
- Every 30 minutes, routers **refresh** their LSAs (preventing expiration)
- **Incremental updates** when topology changes (only affected LSAs flood)
- **Triggered updates** when links fail (immediate convergence)

---

## Understanding OSPF Costs

RFC 2328 deliberately left cost calculation flexible:

> "A cost is associated with the output side of each router interface. This cost is configurable by the system administrator. The lower the cost, the more likely the interface is to be used to forward data traffic."

**The cost formula (Cisco standard):**
```
Cost = Reference Bandwidth / Interface Bandwidth
```

**Why this approach?**
- Prefers higher-bandwidth paths (10 Gbps better than 1 Gbps)
- Allows administrative policy (manually set costs)
- Vendor-neutral (RFC doesn't mandate specific calculation)
- Scalable (works from dial-up to 400 Gbps)

**Example calculations (reference bandwidth = 100 Mbps):**
- 10 Mbps Ethernet: 100/10 = 10
- 100 Mbps FastEthernet: 100/100 = 1
- 1 Gbps GigabitEthernet: 100/1000 = 0.1 → rounds to 1 (minimum cost)

**The modern problem:** With the default reference bandwidth, all interfaces 100 Mbps and faster get cost 1. No differentiation between FastEthernet and 100 Gbps!

**The solution:** Increase reference bandwidth to match your fastest links:
```
auto-cost reference-bandwidth 100000  # For 100 Gbps networks
```

---

## Why These Design Decisions Matter

### Dijkstra = Loop-Free Routing

Distance-vector protocols can loop during convergence:
```
A tells B: "I can reach X via C, distance 2"
B tells C: "I can reach X via A, distance 3"
C tells A: "I can reach X via B, distance 4"
← Routing loop during convergence!
```

With Dijkstra, this can't happen:
```
All routers have identical topology map
All routers run same algorithm from their perspective
All routers agree on the tree structure
No loops possible - it's a tree!
```

### Areas = Scalability Without Sacrifice

**The scalability trilemma:**
- Want fast convergence → Need small SPF domains
- Want simple management → Want single routing domain
- Want optimal paths → Need full topology view

**OSPF's solution - hierarchical areas:**
- Fast convergence ✅ (SPF limited to area scope)
- Manageable ✅ (summarization at area boundaries)
- Optimal paths ✅ (within areas; inter-area is good enough)

### Router-ID = Stability

**Why not use interface IPs as identity?**

Consider this scenario:
```
R1 has interfaces: 10.0.1.1, 10.0.2.1, 10.0.3.1
Which one identifies this router?
What if we renumber 10.0.1.1 → 172.16.1.1?
Do we need to update the entire OSPF database?
```

**With router-id:**
```
R1 has router-id: 1.1.1.1 (on loopback)
All LSAs originated by 1.1.1.1
IP addresses can change without affecting OSPF identity
Loopback never goes down = stable identity
```

---

## What You'll Learn in This Lab

Now that you understand the theory, this lab will let you:

1. **Observe** a working OSPF network with full topology visibility
2. **Verify** that all routers have identical link-state databases
3. **Manipulate** costs to see Dijkstra's algorithm choose different paths
4. **Break** OSPF in controlled ways to understand failure modes
5. **Experiment** with areas, router-IDs, and network statements

**The goal:** Move from theoretical understanding to practical mastery.

---

## Topology

```
      R2
     /  \
   R1----R3
```

**R1:** 1.1.1.1/32
- eth1: 10.0.12.1/30 (to R2)
- eth2: 10.0.13.1/30 (to R3)

**R2:** 2.2.2.2/32
- eth1: 10.0.12.2/30 (to R1)
- eth2: 10.0.23.1/30 (to R3)

**R3:** 3.3.3.3/32
- eth1: 10.0.23.2/30 (to R2)
- eth2: 10.0.13.2/30 (to R1)

**Why this topology?**
- Triangle creates **redundant paths** (R1 can reach R3 directly or via R2)
- Equal-cost paths demonstrate **load balancing**
- Simple enough to understand, complex enough to be interesting
- Each router has exactly 2 neighbors (typical in production)

---

## Pre-configured Setup

This lab comes with:
- IP addresses configured on all interfaces
- OSPF fully configured in area 0
- All loopback interfaces advertised
- Full connectivity between all routers

**Why pre-configured?**
This is a **Type B lab** - you'll focus on observing how OSPF works and manipulating it, not typing configuration commands. This lets you focus on understanding the protocol behavior rather than syntax.

---

## Starting the Lab

1. Deploy the lab:
   ```bash
   containerlab deploy -t topology.yml
   # Or with sudo if needed:
   sudo containerlab deploy -t topology.yml
   ```

2. Wait about 30 seconds for OSPF to converge

3. Access the routers:
   
   **Option A: VSCode Containerlab Extension (Recommended)**
   - Right-click on a router node in the topology view
   - Click "SSH"
   - You'll automatically be in the router CLI (vtysh)
   
   **Option B: SSH Directly**
   ```bash
   ssh admin@clab-ospf-fundamentals-r1
   # Password: admin
   # Type: vtysh or v
   ```
   
   **Option C: Docker Exec**
   ```bash
   docker exec -it clab-ospf-fundamentals-r1 vtysh
   ```

---

## Lab Tasks

### Task 1: Verify Identical Topology Databases

**Theory recap:** All OSPF routers in an area should have identical link-state databases. Let's verify this fundamental principle.

1. **On R1, view the OSPF database:**
   ```
   show ip ospf database
   ```
   
   You'll see:
   - **Router LSAs (Type 1):** One from each router (R1, R2, R3)
   - **Network LSAs (Type 2):** Generated by DR for each broadcast segment
   
   Note the **Link State ID** and **Advertising Router** for each LSA.

2. **On R2 and R3, view their databases:**
   ```
   show ip ospf database
   ```
   
   **Key observation:** All three routers show **identical** LSAs. This is the foundation of OSPF - synchronized topology knowledge.

3. **Examine a specific Router LSA:**
   ```
   show ip ospf database router 1.1.1.1
   ```
   
   This shows R1's Router LSA containing:
   - Links R1 knows about (to R2, to R3)
   - Cost of each link
   - Link types
   
   **RFC 2328 explains:** "Each router in the area originates a router-LSA. The LSA describes the state and cost of the router's links (i.e., interfaces) to the area."

4. **Check OSPF neighbors:**
   ```
   show ip ospf neighbor
   ```
   
   You should see neighbors in **Full** state. RFC 2328 defines this:
   > "Full: In this state, the neighboring routers are fully adjacent. The adjacency will now appear in router-LSAs and network-LSAs."

**Why this matters:** The "Full" state means databases are synchronized. This is what enables the identical database you just verified.

---

### Task 2: Observe Dijkstra's Algorithm in Action

**Theory recap:** Each router independently runs SPF to calculate its routing table from the shared database.

1. **On R1, check the routing table to R3's loopback:**
   ```
   show ip route 3.3.3.3
   ```
   
   You'll see the route is via **10.0.13.2** (direct path) with cost **10**.

2. **View OSPF's SPF calculation for this route:**
   ```
   show ip ospf route 3.3.3.3
   ```
   
   This shows:
   - **Cost:** 10 (one hop at default cost)
   - **Path type:** Intra-area
   - **Next-hop:** Direct to R3

3. **Now check the alternate path (via R2):**
   
   R1 could also reach R3 via R2: R1 → R2 → R3
   - R1 to R2: Cost 10
   - R2 to R3: Cost 10
   - **Total:** 20
   
   Dijkstra chose the direct path (cost 10) over this path (cost 20). ✓

4. **View all OSPF routes:**
   ```
   show ip route ospf
   ```
   
   Each route shows the **lowest-cost path** calculated by SPF.

**Why Dijkstra works:** It evaluates ALL possible paths and mathematically proves it found the shortest. Distance-vector protocols only know what neighbors tell them.

---

### Task 3: Manipulate Costs and Watch SPF Recalculate

**Now let's see Dijkstra adapt to changing conditions.**

1. **Make the direct R1-R3 path more expensive:**
   ```
   configure terminal
   interface eth2
    ip ospf cost 100
   exit
   exit
   ```

2. **Check how the routing changed:**
   ```
   show ip route 3.3.3.3
   ```
   
   Now the route goes via R2! 
   - Direct path: Cost 100
   - Via R2: Cost 20 (10 + 10)
   - Dijkstra chose the new shortest path ✓

3. **Watch the SPF recalculation:**
   ```
   show ip ospf route 3.3.3.3
   ```
   
   OSPF recalculated the entire shortest-path tree when you changed the cost.

4. **Use traceroute to verify the path:**
   ```
   traceroute 3.3.3.3 source 1.1.1.1
   ```
   
   You'll see: R1 → R2 → R3 (taking the longer but lower-cost path)

**The lesson:** Cost is the only metric that matters. A 100-hop path with total cost 50 beats a 1-hop path with cost 100.

---

### Task 4: Understand Router-ID Significance

**Theory recap:** Router-ID is OSPF's stable identity for a router, independent of interface IPs.

1. **Check R1's current router-ID:**
   ```
   show ip ospf
   ```
   
   Look for: `OSPF Routing Process, Router ID: 1.1.1.1`

2. **See how it's used in the database:**
   ```
   show ip ospf database router
   ```
   
   Every Router LSA is **identified by its router-id**. This is what makes LSAs uniquely attributable to their originator.

3. **Try changing the router-ID:**
   ```
   configure terminal
   router ospf
    ospf router-id 9.9.9.9
   exit
   exit
   ```

4. **The change requires OSPF restart to take effect:**
   ```
   clear ip ospf process
   yes
   ```

5. **Verify the new router-ID:**
   ```
   show ip ospf
   show ip ospf database router
   ```
   
   Now R1's LSA is originated by 9.9.9.9 instead of 1.1.1.1.

**Why this matters:** 
- LSAs are tracked by originating router-ID
- Changing router-ID creates "new" LSAs from SPF perspective
- Stable router-ID prevents unnecessary SPF recalculations
- **Production rule:** Set router-id explicitly, don't rely on automatic selection

**RFC 2328 warning:** 
> "The router-id must be unique within the entire Autonomous System."

Duplicate router-IDs cause severe problems - routers can't distinguish LSAs, leading to routing instability.

---

### Task 5: Explore Area Boundaries

**Theory recap:** Areas create hierarchy. Let's see what happens when we introduce a second area.

1. **Create a new loopback and place it in Area 1:**
   ```
   configure terminal
   interface lo1
    ip address 10.10.10.1/32
   exit
   router ospf
    network 10.10.10.1/32 area 1
   exit
   exit
   ```

2. **Check OSPF's view of areas:**
   ```
   show ip ospf
   ```
   
   You'll now see:
   - **Area 0** (backbone)
   - **Area 1** (the new area)
   
   R1 is now an **Area Border Router (ABR)**.

3. **Examine the database with multiple areas:**
   ```
   show ip ospf database
   ```
   
   Notice new LSA types:
   - **Summary LSAs (Type 3):** R1 advertises Area 1's 10.10.10.1/32 into Area 0
   
   **RFC 2328:**
   > "Summary-LSAs are the Type 3 and 4 LSAs. These LSAs are originated by area border routers. A summary-LSA describes a route to a destination outside the LSA's area, yet still inside the AS."

4. **On R2, check if it learned the Area 1 route:**
   ```
   show ip route 10.10.10.1
   ```
   
   R2 sees it as an **inter-area route** (O IA) - it's in Area 0 but the destination is in Area 1.

**Why areas matter:**
- Without areas: R2 would have R1's Router LSA showing the lo1 link
- With areas: R2 has a Summary LSA (smaller, abstracted)
- **Benefit:** Changes to lo1 don't trigger SPF in Area 0, only in Area 1

---

### Task 6: Break and Fix OSPF (Learning from Failure)

**The best way to understand how something works is to break it.**

1. **Remove a network from OSPF:**
   ```
   configure terminal
   router ospf
    no network 10.0.12.0/30 area 0
   exit
   exit
   ```
   
   Immediately check neighbors:
   ```
   show ip ospf neighbor
   ```
   
   **R2 is gone!** Why?
   - R1 no longer advertises 10.0.12.0/30 in OSPF
   - No Hello packets sent on eth1
   - R2's dead timer expires (40 seconds)
   - Neighbor relationship torn down

2. **Watch the ripple effect:**
   ```
   show ip route ospf
   ```
   
   R2's loopback (2.2.2.2) is now unreachable from R1.
   But R3's loopback (3.3.3.3) is still reachable - OSPF adapted!

3. **Fix it:**
   ```
   configure terminal
   router ospf
    network 10.0.12.0/30 area 0
   exit
   exit
   ```
   
   Within 10 seconds (hello interval), the neighbor comes back up.

4. **Try area mismatch:**
   ```
   configure terminal
   router ospf
    no network 10.0.12.0/30 area 0
    network 10.0.12.0/30 area 1
   exit
   exit
   ```
   
   Check neighbors:
   ```
   show ip ospf neighbor
   ```
   
   **R2 won't appear!** 
   
   **RFC 2328 requirement:**
   > "All routers belonging to an area must agree on the area's configuration. To be more precise, all routers attached to a common network must agree on that network's Area ID."
   
   R1 thinks the link is in Area 1, R2 thinks it's in Area 0. No agreement = no adjacency.

**Key lesson:** OSPF has strict consistency requirements. This prevents routing loops and database corruption.

---

### Task 7: Equal-Cost Multipath (ECMP)

**Theory:** When multiple paths have equal cost, OSPF can use all of them.

1. **Reset eth2 cost to default:**
   ```
   configure terminal
   interface eth2
    no ip ospf cost
   exit
   router ospf
    network 10.0.12.0/30 area 0
    no network 10.0.12.0/30 area 1
   exit
   exit
   ```

2. **Make both paths to R3 equal cost:**
   
   Currently:
   - Direct (R1 → R3): Cost 10
   - Via R2 (R1 → R2 → R3): Cost 20
   
   Increase direct path cost:
   ```
   configure terminal
   interface eth2
    ip ospf cost 20
   exit
   exit
   ```

3. **Check for ECMP:**
   ```
   show ip route 3.3.3.3
   ```
   
   You should see **two** next-hops:
   - via 10.0.13.2 (direct)
   - via 10.0.12.2 (through R2)
   
   Both paths have cost 20 - OSPF installs both!

4. **Verify with traceroute:**
   ```
   traceroute 3.3.3.3 source 1.1.1.1
   ```
   
   Run it multiple times. You might see it use different paths (per-flow load balancing).

**Why ECMP matters:**
- Utilizes all available bandwidth
- Automatic redundancy (if one path fails, traffic continues on the other)
- No configuration needed (automatic when costs are equal)
- **Production impact:** 10 Gbps + 10 Gbps = 20 Gbps effective throughput

---

## Useful Commands Reference

| Purpose | Command |
|---------|---------|
| Show OSPF neighbors | `show ip ospf neighbor` |
| Show OSPF routes | `show ip route ospf` |
| Show OSPF database | `show ip ospf database` |
| Show OSPF interface details | `show ip ospf interface` |
| Show SPF calculation | `show ip ospf route` |
| Show OSPF process info | `show ip ospf` |
| Clear OSPF process | `clear ip ospf process` |
| Save configuration | `write memory` |

---

## Understanding the Configuration

Each router's OSPF configuration follows this pattern:

```
router ospf
 ospf router-id 1.1.1.1
 network 10.0.12.0/30 area 0    # Link to R2
 network 10.0.13.0/30 area 0    # Link to R3
 network 1.1.1.1/32 area 0      # Loopback
```

**Breaking it down:**

**`router ospf`** - Enters OSPF configuration mode
- Note: FRR doesn't use process ID (unlike Cisco's `router ospf 1`)
- RFC allows multiple OSPF instances; FRR simplifies to one

**`ospf router-id 1.1.1.1`** - Explicit router-ID configuration
- Uses loopback IP for stability
- Best practice: Always configure explicitly

**`network 10.0.12.0/30 area 0`** - Advertise this network in Area 0
- FRR uses **prefix/length** notation
- Cisco uses **wildcard mask** notation
- Functionally equivalent

**Why loopback in OSPF?**
- Reachable management address (can SSH to router from anywhere in network)
- Router-ID source
- Stable endpoint for BGP, tunnels, etc.

---

## FRR vs Cisco Command Differences

| Cisco IOS | FRR |
|-----------|-----|
| `router ospf 1` | `router ospf` |
| `network 10.0.12.0 0.0.0.3 area 0` | `network 10.0.12.0/30 area 0` |
| `show ip protocols` | `show ip ospf` |

**Why the difference?**
- FRR uses CIDR notation (modern, more intuitive)
- Cisco uses wildcard masks (legacy, but powerful)
- Both accomplish the same goal

**Fun fact:** FRR syntax often matches Juniper's more closely than Cisco's. This is intentional - FRR aims to be vendor-neutral while borrowing best practices from multiple vendors.

---

## Cleanup

When finished:
```bash
containerlab destroy -t topology.yml --cleanup
# Or with sudo:
sudo containerlab destroy -t topology.yml --cleanup
```

---

## What You Should Have Learned

After completing this lab, you should be able to:

**Fundamental Concepts:**
- [ ] Explain why OSPF was needed (RIP's limitations)
- [ ] Describe the difference between distance-vector and link-state routing
- [ ] Explain why OSPF uses Dijkstra's algorithm
- [ ] Understand what a link-state database is and why all routers must have identical copies

**OSPF Mechanics:**
- [ ] Explain the OSPF neighbor discovery and database synchronization process
- [ ] Describe what LSAs are and why OSPF floods links instead of routes
- [ ] Understand how OSPF calculates routes using the SPF algorithm
- [ ] Explain the purpose and importance of router-ID

**Cost and Path Selection:**
- [ ] Calculate OSPF cost using the formula: Reference Bandwidth / Interface Bandwidth
- [ ] Explain why OSPF uses cost instead of hop count
- [ ] Predict which path OSPF will choose given multiple routes with different costs
- [ ] Understand how equal-cost multipath (ECMP) works

**Areas and Scalability:**
- [ ] Explain why OSPF uses areas
- [ ] Describe the role of Area 0 (backbone)
- [ ] Understand how areas reduce SPF calculation scope
- [ ] Explain what an Area Border Router (ABR) does

**Practical Skills:**
- [ ] Verify OSPF neighbors are in Full state
- [ ] Interpret the output of `show ip ospf database`
- [ ] Troubleshoot OSPF adjacency problems
- [ ] Manipulate OSPF costs to influence path selection
- [ ] Identify why an OSPF adjacency might fail to form

**Design Understanding:**
- [ ] Explain why router-ID uses a stable identifier instead of an interface IP
- [ ] Understand the consequences of duplicate router-IDs
- [ ] Describe the trade-offs between flat OSPF and multi-area OSPF
- [ ] Explain how OSPF prevents routing loops

---

## Deep Dive: RFC 2328 Key Concepts

**If you want to understand OSPF deeply, these RFC sections are essential:**

- **Section 4.3 (Link State Advertisements):** Explains LSA types and flooding
- **Section 11 (The Routing Table Structure):** How SPF results become routes
- **Section 16 (Calculation of the Shortest-Path Tree):** Dijkstra implementation
- **Appendix C (Architectural Constants):** Default timers and limits

**Read the RFC at:** https://datatracker.ietf.org/doc/html/rfc2328

---

## Next Steps

Now that you understand OSPF fundamentals, you can explore:

- **Lab 2:** OSPF network types (broadcast, point-to-point, point-to-multipoint) and DR/BDR election
- **Lab 3:** OSPF metrics and path selection in depth
- **Advanced topics:** OSPF authentication, stub areas, route redistribution, summarization

**Additional reading:**
- RFC 2328 (OSPF v2) - The definitive specification
- RFC 5340 (OSPF v3 for IPv6) - IPv6 adaptation
- "OSPF: Anatomy of an Internet Routing Protocol" by John Moy (OSPF creator)

---

## Reflection Questions

After completing this lab, consider:

1. How would OSPF handle a network with 1000 routers in a single area? What would be the limitations?
2. Why might an organization choose RIP over OSPF despite RIP's limitations?
3. How does OSPF's design reflect the state of networking in 1989 vs today?
4. What trade-offs did the OSPF designers make when choosing Dijkstra's algorithm?

**The goal isn't just to configure OSPF - it's to understand why it works the way it does.**
