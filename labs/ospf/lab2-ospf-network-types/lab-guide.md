# Lab 2 Theory Section - OSPF Network Types

Objective:

Learn how OSPF behaves on different network types (broadcast, point-to-point, point-to-multipoint) by configuring and observing DR/BDR election and LSA generation.

---

## The Problem: Not All Networks Are Created Equal

In the early days of OSPF deployment (late 1980s, early 1990s), networks came in fundamentally different physical forms:

**Ethernet LANs:**
- Multiple routers on a shared broadcast medium (hub/switch)
- Any router can communicate with any other router
- "Broadcast" nature - one packet reaches everyone

**Frame Relay WANs:**
- Hub-spoke or partial mesh topologies
- Not all routers can directly reach each other
- "Non-broadcast multi-access" (NBMA)
- Connection-oriented, not truly broadcast

**Point-to-Point Serial Links:**
- Dedicated line between exactly two routers
- T1, DS3, SONET connections
- Simple, predictable topology

**The challenge:** OSPF needed to work efficiently on all these different physical network types, each with its own characteristics and constraints.

---

## Why Network Types Matter: The Flooding Problem

### The Core Issue: LSA Flooding

OSPF routers exchange link-state advertisements (LSAs) to build their topology database. On a multi-access network (like Ethernet with 5 routers), naive flooding would be catastrophic:

**Without optimization:**
```
Router A sends LSA update
Router B receives it, floods to C, D, E
Router C receives from B, floods to A, D, E (duplicate to D, E!)
Router D receives from B and C, floods to A, B, E (more duplicates!)
Router E receives from B, C, D, floods to A, B, C, D (even more!)
```

**Result:** Each LSA gets transmitted 20 times on a 5-router network. On a 10-router network: 90 transmissions. On a 20-router network: 380 transmissions. This doesn't scale!

### The Solution: Designated Router (DR)

RFC 2328 introduced the concept of a Designated Router for broadcast networks:

> "On broadcast networks, the Designated Router (DR) has two main functions:
> - The Designated Router generates a network-LSA on behalf of the network
> - The Designated Router becomes adjacent to all other routers on the network"

**With DR optimization:**
```
Router A sends LSA update to DR (224.0.0.6)
DR receives it
DR floods to all routers (224.0.0.5)
Done - 2 transmissions instead of 20!
```

**Backup DR (BDR):** A second router is elected as backup, ready to take over if DR fails. This provides redundancy without the overhead of full mesh adjacencies.

---

## Network Type Design Rationale

### Broadcast Network Type

**When to use:** Ethernet LANs where all routers can reach each other

**Characteristics from RFC 2328:**
> "On broadcast networks, each router advertises itself by periodically multicasting Hello packets. This multicast allows neighbors to be discovered dynamically."

**Design decisions:**
- **DR/BDR election:** Required (reduces flooding)
- **Hello interval:** 10 seconds (fast detection)
- **Dead interval:** 40 seconds (4x hello)
- **Neighbor discovery:** Automatic via multicast (224.0.0.5)
- **LSA flooding:** Optimized through DR

**Why these decisions?**
- DR election prevents N² flooding problem
- Fast hello timers appropriate for reliable LAN
- Multicast discovery works because it's a broadcast medium
- One router (DR) generates network-LSA for entire segment

**Historical context:** Originally designed for Ethernet hubs (true broadcast), works equally well with modern switches

---

### Point-to-Point Network Type

**When to use:** Direct connection between exactly two routers

**Characteristics from RFC 2328:**
> "On point-to-point networks there can be only two routers attached. As a consequence, no Designated Router is required."

**Design decisions:**
- **DR/BDR election:** None (only 2 routers)
- **Hello interval:** 10 seconds
- **Dead interval:** 40 seconds
- **Neighbor discovery:** Automatic
- **LSA flooding:** Direct between the two routers

**Why these decisions?**
- No DR needed - only one possible path anyway
- Faster convergence without DR election overhead
- Simpler - fewer things to go wrong
- Most common in WANs (T1, Metro Ethernet, etc.)

**Modern relevance:** Most common type in today's networks:
- Metro Ethernet handoffs
- MPLS connections
- Direct fiber links
- Routed subnets (not shared Layer 2)

---

### Point-to-Multipoint Network Type

**When to use:** Hub-spoke where not all spokes can reach each other

**The problem it solves:**

Consider a hub-spoke VPN:
```
        HUB
       / | \
   Spoke1 Spoke2 Spoke3
```

Spokes cannot directly communicate with each other - all traffic must go through hub.

**If you used broadcast type:**
- DR election might choose a spoke as DR
- Spokes can't reach each other = broken adjacencies
- Network won't converge properly

**If you used point-to-point type:**
- Can't - point-to-point is for exactly 2 routers
- Would need separate OSPF configuration per spoke

**Point-to-multipoint solution:**

RFC 2328 explains:
> "Point-to-MultiPoint networks are treated as a collection of point-to-point links."

**Design decisions:**
- **DR/BDR election:** None (treated as multiple point-to-point)
- **Hello interval:** 30 seconds (longer - typical for slower links)
- **Dead interval:** 120 seconds (4x hello)
- **Neighbor discovery:** Automatic, but neighbors treated independently
- **Host routes:** Creates /32 routes for each neighbor interface

**Why these decisions?**
- No DR because it's conceptually multiple point-to-point links
- Longer timers appropriate for WAN/VPN scenarios
- Host routes allow spoke-to-spoke traffic to route through hub
- Each spoke-to-hub connection is independent

**Modern use cases:**
- Hub-spoke VPNs (DMVPN, FlexVPN)
- MPLS Layer 3 VPNs
- Metro Ethernet E-LAN services
- Any partial-mesh topology

---

## NBMA (Non-Broadcast Multi-Access)

**Historical artifact:** Designed for Frame Relay

**Why it exists:** Frame Relay was multi-access (multiple routers on same "network") but not broadcast (couldn't send to everyone at once)

**Characteristics:**
- Requires manual neighbor configuration
- Has DR/BDR election
- Hello interval: 30 seconds
- No automatic discovery

**Modern relevance:** Nearly obsolete
- Frame Relay is dead technology
- Use point-to-multipoint instead
- Included in curriculum for certification exams only

RFC 2328 even acknowledges the complexity:
> "Configuration information is required in order to send Hello packets to neighboring routers."

**Translation:** "This is complicated. Use point-to-multipoint if you can."

---

## Why Multiple Network Types?

### Design Philosophy: Match Protocol to Physical Reality

**The OSPF designers' insight:** One size does NOT fit all.

Rather than force all networks into the same model, OSPF provides different modes optimized for different physical topologies:

**Broadcast → Optimized for shared LANs**
- Uses DR to prevent flooding explosion
- Fast timers for fast detection
- Automatic discovery

**Point-to-Point → Optimized for simple links**
- No DR overhead
- Fastest convergence
- Simplest configuration

**Point-to-Multipoint → Optimized for hub-spoke**
- No DR election conflicts
- Independent adjacencies
- Handles partial connectivity

**The alternative:** Single rigid model would either:
- Waste resources on simple links (unnecessary DR election)
- Fail on complex topologies (can't handle partial mesh)
- Have slow convergence everywhere (conservative timers for worst case)

---

## Real-World Impact

### Scenario 1: Enterprise Campus

**Network:** 20 routers on same VLAN (Layer 2 domain)

**Wrong choice - Point-to-Point:**
- Can't use it - more than 2 routers
- Would need 190 separate subnets (one per router pair)
- Routing table explosion

**Right choice - Broadcast:**
- One DR election
- 19 adjacencies instead of 190
- Single network-LSA
- Efficient and scalable

---

### Scenario 2: MPLS Provider Network

**Network:** 100 customer sites, hub-spoke topology

**Wrong choice - Broadcast:**
- DR election might choose a spoke site
- If DR site goes down, all OSPF reconverges
- Spokes can't reach each other = broken adjacencies

**Right choice - Point-to-Multipoint:**
- Each spoke independent
- No DR election
- Spoke failure only affects that spoke
- Automatic spoke-to-spoke routing via hub

---

### Scenario 3: Metro Ethernet Handoff

**Network:** Direct fiber between two datacenter routers

**Wrong choice - Broadcast:**
- Unnecessary DR election (only 2 routers)
- Slower convergence (election takes time)
- Extra complexity

**Right choice - Point-to-Point:**
- No DR overhead
- Instant adjacency
- Clean and simple

---

## What You'll Learn in This Lab

Now that you understand why network types exist and what problems they solve, this lab will let you:

1. **Experience** DR/BDR election on broadcast networks
2. **Manipulate** priority to control which router becomes DR
3. **Observe** how point-to-point eliminates DR/BDR entirely
4. **Configure** point-to-multipoint for hub-spoke scenarios
5. **Compare** LSA behavior across different network types
6. **Understand** when to use each type in production

**The goal:** Move from theoretical understanding to practical mastery of OSPF network type selection.

---

## Important Note: Lab Topology Simplification

**In production:** Broadcast segments typically look like this:
```
     10.0.1.0/24 (single subnet)
            |
      [L2 Switch]
       /    |    \
     R1    R2    R3
```

**In this lab:** We use separate /30 links:
```
R1 -- R2 (10.0.12.0/30)
R1 -- R3 (10.0.13.0/30)
R2 -- R3 (10.0.23.0/30)
```

**Why the difference?**
- Containerlab limitation: Each link is a separate network namespace
- Simulating shared Layer 2 requires additional complexity
- Commands and concepts are **identical**
- You'll see DR/BDR election per link instead of per segment

**Important:** The behavior is the same, the topology is just simplified for lab portability. Everything you learn applies directly to production multi-access segments.

---

## RFC 2328 Key Sections

If you want to dive deeper into the specification:

- **Section 9 (The Interface Data Structure):** Defines network types
- **Section 9.1 (Interface states):** How interfaces transition
- **Section 9.4 (Designated Router election):** Election algorithm
- **Section 12.4 (Generating network-LSAs):** Why DR generates Type 2 LSAs

**Read the RFC at:** https://datatracker.ietf.org/doc/html/rfc2328

---

## Topology

```
        R1 (Hub)
       / | \
     R2  R3  R4
```

**R1:** 1.1.1.1/32
- eth1: 10.0.12.1/30 (to R2)
- eth2: 10.0.13.1/30 (to R3)
- eth3: 10.0.14.1/30 (to R4)

**R2:** 2.2.2.2/32
- eth1: 10.0.12.2/30 (to R1)

**R3:** 3.3.3.3/32
- eth1: 10.0.13.2/30 (to R1)

**R4:** 4.4.4.4/32
- eth1: 10.0.14.2/30 (to R1)

## Pre-configured Setup

This lab comes with:
- IP addresses configured on all interfaces
- FRR daemons running
- **No OSPF configured** - you'll configure this yourself

## Starting the Lab

### Step 1: Deploy the Lab

Navigate to the lab directory and deploy the topology:

```bash
cd ~/labs/ospf/lab2-ospf-network-types
sudo containerlab deploy -t topology.yml
```

The deployment will:
- Create and start all router containers (R1, R2, R3, R4)
- Configure the hub-spoke topology
- Set up management network connectivity
- Initialize SSH access (takes ~30 seconds)

### Step 2: Wait for Initialization

**Important:** Wait 30 seconds after deployment for SSH to fully initialize.

### Step 3: Access the Routers

You have three options for accessing the routers:

#### Option A: VSCode Containerlab Extension (Recommended)

1. Open the **Containerlab** panel in VSCode (left sidebar)
2. You'll see R1 (hub) connected to R2, R3, and R4 (spokes)
3. Right-click on any router → Select "SSH"
4. Enter password: `admin`
5. You're automatically in vtysh

**Tip:** Since this is a hub-spoke topology, you'll likely work primarily on R1 (the hub) and reference the spoke routers.

#### Option B: Direct SSH

```bash
ssh admin@clab-ospf-lab2-network-types-r1  # Password: admin
ssh admin@clab-ospf-lab2-network-types-r2
ssh admin@clab-ospf-lab2-network-types-r3
ssh admin@clab-ospf-lab2-network-types-r4
```

#### Option C: Docker Exec (Advanced)

```bash
docker exec -it clab-ospf-lab2-network-types-r1 vtysh
docker exec -it clab-ospf-lab2-network-types-r2 vtysh
docker exec -it clab-ospf-lab2-network-types-r3 vtysh
docker exec -it clab-ospf-lab2-network-types-r4 vtysh
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

### Task 1: Configure OSPF with Broadcast Network Type

#### On R1:
```
configure terminal
router ospf
 ospf router-id 1.1.1.1
 network 1.1.1.1/32 area 0
 network 10.0.12.0/30 area 0
 network 10.0.13.0/30 area 0
exit
interface eth1
 ip ospf network broadcast
exit
interface eth2
 ip ospf network broadcast
exit
exit
write memory
```

#### On R2:
```
configure terminal
router ospf
 ospf router-id 2.2.2.2
 network 2.2.2.2/32 area 0
 network 10.0.12.0/30 area 0
exit
interface eth1
 ip ospf network broadcast
exit
exit
write memory
```

#### On R3 (similar pattern):
```
configure terminal
router ospf
 ospf router-id 3.3.3.3
 network 3.3.3.3/32 area 0
 network 10.0.13.0/30 area 0
exit
interface eth1
 ip ospf network broadcast
exit
exit
write memory
```

Wait 10 seconds, then verify:
```
show ip ospf neighbor
```

You should see neighbors with state "Full/DR" or "Full/Backup".

### Task 2: Observe DR/BDR Election

1. **Check DR/BDR roles on R1:**
   ```
   show ip ospf interface eth1
   ```
   Look for:
   - "Network Type BROADCAST"
   - "State DR" or "State Backup"
   - "Designated Router (ID)" and IP
   - "Backup Designated Router (ID)" and IP

2. **Check the OSPF database for Type 2 LSAs:**
   ```
   show ip ospf database
   ```
   Under "Net Link States" you'll see Type 2 LSAs generated by the DR.

3. **Compare with production multi-access segments:**
   In production, you'd have all routers on the same subnet (e.g., 10.0.1.0/24) connected via a switch.
   Our lab uses separate /30 links, so each link has its own DR/BDR election.
   The commands and concepts are identical - just the topology differs.

### Task 3: Manipulate DR/BDR Election

1. **Change R1's priority to become DR:**
   ```
   configure terminal
   interface eth1
    ip ospf priority 255
   exit
   exit
   ```

2. **Force re-election (don't do this in production!):**
   ```
   clear ip ospf process
   yes
   ```

3. **Verify R1 is now DR:**
   ```
   show ip ospf neighbor
   show ip ospf interface eth1
   ```

4. **Prevent a router from becoming DR/BDR:**
   On R2, set priority to 0:
   ```
   configure terminal
   interface eth1
    ip ospf priority 0
   exit
   exit
   clear ip ospf process
   yes
   ```
   R2 will never be DR or BDR with priority 0.

### Task 4: Configure Point-to-Point Network Type

1. **On R1, add R4 with point-to-point:**
   ```
   configure terminal
   router ospf
    network 10.0.14.0/30 area 0
   exit
   interface eth3
    ip ospf network point-to-point
   exit
   exit
   write memory
   ```

2. **On R4:**
   ```
   configure terminal
   router ospf
    ospf router-id 4.4.4.4
    network 4.4.4.4/32 area 0
    network 10.0.14.0/30 area 0
   exit
   interface eth1
    ip ospf network point-to-point
   exit
   exit
   write memory
   ```

3. **Verify point-to-point neighbor:**
   ```
   show ip ospf neighbor
   ```
   Look for R4 with state "Full/-" (the dash means no DR/BDR).

4. **Compare interface details:**
   ```
   show ip ospf interface eth3
   ```
   You'll see:
   - "Network Type POINTOPOINT"
   - "No designated router on this network"

5. **Check OSPF database:**
   ```
   show ip ospf database
   ```
   Notice: No Type 2 LSA for the R1-R4 link (point-to-point doesn't need it).

### Task 5: Experiment with Point-to-Multipoint

1. **Change R1-R2 link to point-to-multipoint:**
   On R1:
   ```
   configure terminal
   interface eth1
    ip ospf network point-to-multipoint
   exit
   exit
   ```
   
   On R2:
   ```
   configure terminal
   interface eth1
    ip ospf network point-to-multipoint
   exit
   exit
   ```

2. **Wait 40 seconds for neighbors to reform, then check:**
   ```
   show ip ospf neighbor
   ```
   R2 should now show state "Full/-" (no DR/BDR).

3. **Check interface timers:**
   ```
   show ip ospf interface eth1
   ```
   Notice:
   - "Network Type POINTOMULTIPOINT"
   - "Hello 30s, Dead 120s" (different from broadcast's 10s/40s)

4. **Check routing table for host routes:**
   ```
   show ip route ospf
   ```
   You'll see a /32 host route for R2's interface IP (10.0.12.2/32).
   This is unique to point-to-multipoint.

### Task 6: Compare Network Types Side-by-Side

With R1-R2 as point-to-multipoint, R1-R3 as broadcast, and R1-R4 as point-to-point:

```
show ip ospf neighbor
```

Compare the "Pri" and "State" columns:
- **Broadcast (R3):** Priority matters, state shows DR/Backup
- **Point-to-Point (R4):** Pri=0, state is "Full/-"
- **Point-to-Multipoint (R2):** Pri=0, state is "Full/-"

```
show ip ospf database
```

Compare LSAs:
- Type 2 LSAs only for broadcast links
- No Type 2 LSAs for point-to-point or point-to-multipoint

## Useful Commands Reference

| Purpose | Command |
|---------|---------|
| Show OSPF neighbors | `show ip ospf neighbor` |
| Show interface details | `show ip ospf interface eth1` |
| Show OSPF database | `show ip ospf database` |
| Show OSPF routes | `show ip route ospf` |
| Configure network type | `ip ospf network <broadcast\|point-to-point\|point-to-multipoint>` |
| Configure OSPF priority | `ip ospf priority <0-255>` |
| Clear OSPF process | `clear ip ospf process` |
| Save configuration | `write memory` |

## Network Type Decision Guide

| Scenario | Network Type | Why? |
|----------|--------------|------|
| LAN with 3+ routers on same subnet | Broadcast | Default for Ethernet, reduces flooding |
| Direct WAN link between 2 routers | Point-to-Point | No DR/BDR needed, faster convergence |
| Hub-spoke VPN or MPLS | Point-to-Multipoint | No DR/BDR overhead, works with partial mesh |
| Legacy Frame Relay | NBMA | Obsolete, use point-to-multipoint instead |

## Understanding Network Types

### Broadcast
- **Default on:** Ethernet interfaces
- **DR/BDR:** Yes (reduces flooding)
- **Hello/Dead:** 10s/40s
- **Type 2 LSA:** Yes (generated by DR)
- **Best for:** LAN segments with multiple routers

### Point-to-Point
- **Default on:** Serial interfaces
- **DR/BDR:** No (only 2 routers)
- **Hello/Dead:** 10s/40s
- **Type 2 LSA:** No
- **Best for:** WAN links, direct connections

### Point-to-Multipoint
- **Default on:** None (must configure)
- **DR/BDR:** No
- **Hello/Dead:** 30s/120s
- **Type 2 LSA:** No
- **Host routes:** Creates /32 for each neighbor
- **Best for:** Hub-spoke topologies, partial mesh

## Production Multi-Access Segments

In production networks, broadcast segments typically look like this:

```
     10.0.1.0/24 (single subnet)
            |
      [L2 Switch]
       /    |    \
     R1    R2    R3
     .1    .2    .3
```

**Key differences from our lab:**
- All routers on **same subnet** (10.0.1.0/24)
- Connected via **Layer 2 switch**
- **One DR election** for entire segment
- You'd see **DROther** state (router that's neither DR nor BDR)

**In our lab:**
- Each link has **separate subnet** (/30)
- Direct router-to-router connections
- **Separate elections** per link
- Only 2 routers per link = always one DR, one BDR (or neither)

**Important:** All the commands, concepts, and verification steps are identical.
The topology is simplified for lab portability, but the OSPF behavior is the same.

## FRR vs Cisco Command Differences

| Cisco IOS | FRR |
|-----------|-----|
| `router ospf 1` | `router ospf` |
| `network 10.0.12.0 0.0.0.3 area 0` | `network 10.0.12.0/30 area 0` |
| `ip ospf network broadcast` | `ip ospf network broadcast` (same!) |
| `ip ospf priority 100` | `ip ospf priority 100` (same!) |

## Cleanup

When finished:
```bash
containerlab destroy -t topology.yml --cleanup
# Or with sudo:
sudo containerlab destroy -t topology.yml --cleanup
```

## What You Should Have Learned

After completing this lab, you should be able to:

**Network Type Fundamentals:**
- [ ] Explain why OSPF has different network types
- [ ] Describe the flooding problem on multi-access networks
- [ ] Understand why DR/BDR election is necessary on broadcast networks
- [ ] Explain when no DR/BDR is needed

**Broadcast Networks:**
- [ ] Configure broadcast network type on OSPF interfaces
- [ ] Trigger and observe DR/BDR election
- [ ] Manipulate priority to control which router becomes DR
- [ ] Identify DR and BDR from `show ip ospf neighbor` output
- [ ] Understand the role of DROther routers
- [ ] Explain why Type 2 LSAs exist on broadcast networks

**Point-to-Point Networks:**
- [ ] Configure point-to-point network type
- [ ] Understand why point-to-point doesn't need DR/BDR
- [ ] Recognize point-to-point neighbors in Full/- state
- [ ] Explain why no network-LSA is generated

**Point-to-Multipoint Networks:**
- [ ] Configure point-to-multipoint network type
- [ ] Understand when to use point-to-multipoint (hub-spoke topologies)
- [ ] Explain why point-to-multipoint has longer timers (30s/120s)
- [ ] Recognize host routes (/32) created by point-to-multipoint
- [ ] Describe how point-to-multipoint solves the hub-spoke problem

**Practical Skills:**
- [ ] Set OSPF priority on an interface
- [ ] Force OSPF DR re-election (and know why not to do it in production)
- [ ] Identify network type from `show ip ospf interface` output
- [ ] Compare LSA types generated by different network types
- [ ] Choose appropriate network type for a given topology

**Design Understanding:**
- [ ] Explain the trade-offs between broadcast and point-to-point
- [ ] Understand why NBMA is largely obsolete
- [ ] Recognize when point-to-multipoint is the best choice
- [ ] Compare hello/dead timers across network types

---

## Deep Dive: RFC 2328 Key Concepts

**If you want to understand OSPF network types deeply, these RFC sections are essential:**

- **Section 9 (The Interface Data Structure):** Complete definition of all network types and their properties
- **Section 9.3 (Interface state machine):** How interfaces transition through states based on network type
- **Section 9.4 (Electing the Designated Router):** The DR/BDR election algorithm in detail
- **Section 12.4 (Generating network-LSAs):** Why and how DRs generate Type 2 LSAs
- **Appendix C.3 (Configurable Constants):** Default timer values for each network type

**Read the RFC at:** https://datatracker.ietf.org/doc/html/rfc2328

**Particularly relevant passages:**

**On DR purpose (Section 7.3):**
> "The Designated Router originates a network-LSA on behalf of the network. This network-LSA lists all routers currently attached to the network. The network-LSA is required for the Designated Router to advertise the network itself."

**On point-to-point simplicity (Section 8.1):**
> "On point-to-point networks, no Designated Router election is performed. Each router forms an adjacency with the router at the other end of the link."

**On point-to-multipoint design (Section 8.2):**
> "Pt-MultiPt networks are treated as a collection of point-to-point links. OSPF packets are always sent as unicasts on these networks."

---

## Next Steps

Now that you understand OSPF network types, you can explore:

- **Lab 3:** OSPF metrics and path selection - How OSPF chooses between multiple paths
- **Advanced topic:** OSPF on Frame Relay (NBMA) - Historical but sometimes tested
- **Advanced topic:** Demand circuits - Reducing OSPF overhead on expensive links
- **Advanced topic:** OSPF over GRE tunnels - Network type considerations for VPNs

---

## Reflection Questions

After completing this lab, consider:

1. **Hub-spoke VPN with 50 spokes:** You're designing OSPF for a hub-spoke VPN where the hub is in your datacenter and 50 remote branch offices are spokes. Spokes cannot directly communicate with each other. What network type would you choose and why? What would happen if you chose broadcast instead?

2. **Datacenter spine-leaf architecture:** In a modern datacenter with spine-leaf topology, you have point-to-point links between each leaf and each spine router. Should you use broadcast or point-to-point network type? How does your choice affect convergence time and overhead?

3. **DR failure impact:** On a broadcast network with 20 routers, the DR fails. What happens during the failover? How long does it take? What traffic is affected? How does this compare to a point-to-point link failure?

4. **Evolution from Frame Relay:** Frame Relay is essentially dead. Why do we still teach NBMA network type? What modern technologies have similar characteristics (hub-spoke, non-broadcast) that might benefit from point-to-multipoint?

5. **Priority 0 use case:** You have a low-end router on a broadcast segment that shouldn't waste CPU on being DR. You set its priority to 0. Does this save significant resources? What are the trade-offs?

6. **Timer optimization:** Point-to-multipoint uses 30s/120s timers instead of 10s/40s. If you have a high-speed, reliable MPLS connection in hub-spoke topology, should you manually configure faster timers? What are the implications?

---

