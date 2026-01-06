# Lab 2: OSPF Network Types

**Estimated Time:** 75 minutes  
**Difficulty:** Beginner  
**Prerequisites:** Lab 1 (OSPF Neighbor Formation)

---

## Learning Objectives

By the end of this lab, you will be able to:
- Configure OSPF on broadcast network types
- Understand and manipulate DR/BDR election
- Configure OSPF on point-to-point network types
- Configure OSPF on point-to-multipoint network types
- Explain when to use each network type
- Observe LSA differences between network types

---

## Lab Topology

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

Loopbacks:
- R1: 1.1.1.1/32
- R2: 2.2.2.2/32
- R3: 3.3.3.3/32
- R4: 4.4.4.4/32
```

**Network Details:**
- **Broadcast Segment:** R1, R2, R3 connected via bridge (10.0.1.0/24)
- **Point-to-Point:** R1 ↔ R4 (10.0.2.0/30)

---

## Part 1: Deploy the Lab (5 minutes)

### Step 1: Deploy the topology

```bash
cd ~/labs/ospf/02-network-types
sudo containerlab deploy -t topology.yml
```

**Expected output:**
```
+---+------------------------+--------------+-------------+
| # |          Name          | Container ID |    State    |
+---+------------------------+--------------+-------------+
| 1 | clab-ospf-lab2-r1      | <id>         | running     |
| 2 | clab-ospf-lab2-r2      | <id>         | running     |
| 3 | clab-ospf-lab2-r3      | <id>         | running     |
| 4 | clab-ospf-lab2-r4      | <id>         | running     |
+---+------------------------+--------------+-------------+
```

### Step 2: Verify connectivity

```bash
# Connect to R1
docker exec -it clab-ospf-lab2-network-types-r1 vtysh

# Check interfaces
show interface brief
show ip interface brief

# Should see:
# lo: 1.1.1.1/32
# eth1: 10.0.1.1/24 (to broadcast segment)
# eth2: 10.0.2.1/30 (to R4)
```

---

## Part 2: Broadcast Network Type with DR/BDR Election (25 minutes)

### Concept Review

**Broadcast networks:**
- Default on Ethernet interfaces
- Requires DR (Designated Router) and BDR (Backup DR)
- Reduces LSA flooding on multi-access segments
- All routers send LSAs to DR (224.0.0.6)
- DR floods to all routers (224.0.0.5)

**DR/BDR Election:**
1. Highest OSPF priority wins (default = 1)
2. Tie-breaker: Highest Router ID
3. Priority 0 = never become DR/BDR

---

### Step 1: Configure OSPF on all routers (Broadcast Segment)

**On R1:**
```bash
docker exec -it clab-ospf-lab2-network-types-r1 vtysh

configure terminal
router ospf
 ospf router-id 1.1.1.1
 network 1.1.1.1/32 area 0
 network 10.0.1.0/24 area 0
 exit
exit
write memory
```

**On R2:**
```bash
docker exec -it clab-ospf-lab2-network-types-r2 vtysh

configure terminal
router ospf
 ospf router-id 2.2.2.2
 network 2.2.2.2/32 area 0
 network 10.0.1.0/24 area 0
 exit
exit
write memory
```

**On R3:**
```bash
docker exec -it clab-ospf-lab2-network-types-r3 vtysh

configure terminal
router ospf
 ospf router-id 3.3.3.3
 network 3.3.3.3/32 area 0
 network 10.0.1.0/24 area 0
 exit
exit
write memory
```

---

### Step 2: Verify DR/BDR election

Wait ~10 seconds for OSPF to converge, then check:

**On R1:**
```bash
show ip ospf neighbor
```

**Expected output:**
```
Neighbor ID     Pri State           Dead Time Address         Interface
2.2.2.2           1 Full/Backup     00:00:35  10.0.1.2        eth1:10.0.1.1
3.3.3.3           1 Full/DR         00:00:36  10.0.1.3        eth1:10.0.1.1
```

**Analysis:**
- R3 (3.3.3.3) became DR (highest router ID)
- R2 (2.2.2.2) became BDR (second highest)
- R1 is DROther (neither DR nor BDR)
- State "Full/DR" means full adjacency with the DR
- State "Full/Backup" means full adjacency with BDR

---

### Step 3: View OSPF interface details

**On R1:**
```bash
show ip ospf interface eth1
```

**Expected output (key fields):**
```
eth1 is up
  Internet Address 10.0.1.1/24, Broadcast 10.0.1.255, Area 0.0.0.0
  MTU mismatch detection: enabled
  Router ID 1.1.1.1, Network Type BROADCAST, Cost: 10
  Transmit Delay is 1 sec, State DROther, Priority 1
  Designated Router (ID) 3.3.3.3, Interface Address 10.0.1.3
  Backup Designated Router (ID) 2.2.2.2, Interface Address 10.0.1.2
  Timer intervals configured, Hello 10s, Dead 40s, Wait 40s, Retransmit 5
```

**Key observations:**
- Network Type: BROADCAST
- State: DROther (not DR or BDR)
- Priority: 1 (default)
- DR: 3.3.3.3
- BDR: 2.2.2.2

---

### Step 4: Manipulate DR/BDR election with priority

Let's make R1 the DR by increasing its priority.

**On R1:**
```bash
configure terminal
interface eth1
 ip ospf priority 255
 exit
exit
```

**Clear OSPF process to re-elect (DO NOT DO THIS IN PRODUCTION):**
```bash
clear ip ospf process
yes
```

Wait 10 seconds, then verify:

```bash
show ip ospf neighbor
```

**Expected output:**
```
Neighbor ID     Pri State           Dead Time Address         Interface
2.2.2.2           1 Full/DROther    00:00:36  10.0.1.2        eth1:10.0.1.1
3.3.3.3           1 Full/Backup     00:00:38  10.0.1.3        eth1:10.0.1.1
```

**On R2, check:**
```bash
show ip ospf neighbor
```

```
Neighbor ID     Pri State           Dead Time Address         Interface
1.1.1.1         255 Full/DR         00:00:37  10.0.1.1        eth1:10.0.1.2
3.3.3.3           1 Full/Backup     00:00:39  10.0.1.3        eth1:10.0.1.2
```

**Analysis:**
- R1 (priority 255) is now DR
- R3 (highest router ID among remaining) is now BDR
- R2 is DROther

---

### Step 5: Prevent a router from becoming DR/BDR

Set R2's priority to 0 (never DR/BDR):

**On R2:**
```bash
configure terminal
interface eth1
 ip ospf priority 0
 exit
exit

clear ip ospf process
yes
```

**Verify:**
```bash
show ip ospf interface eth1
```

Look for: `Priority 0` - this router will never participate in DR/BDR election.

---

### Step 6: Examine OSPF database (LSA Type 2)

**On R1 (the DR):**
```bash
show ip ospf database
```

**Expected output:**
```
       OSPF Router with ID (1.1.1.1)

                Router Link States (Area 0.0.0.0)

Link ID         ADV Router      Age  Seq#       CkSum  Link count
1.1.1.1         1.1.1.1          234 0x80000004 0xabcd 3
2.2.2.2         2.2.2.2          156 0x80000003 0x1234 2
3.3.3.3         3.3.3.3          189 0x80000003 0x5678 2

                Net Link States (Area 0.0.0.0)

Link ID         ADV Router      Age  Seq#       CkSum
10.0.1.1        1.1.1.1          234 0x80000002 0x9abc
```

**Key observation:**
- **Type 1 LSA:** One per router (Router Link States)
- **Type 2 LSA:** One for the broadcast segment (Net Link States)
  - Generated by DR (1.1.1.1 in this case)
  - Link ID = DR's interface IP (10.0.1.1)

**Compare with point-to-point:**
- Point-to-point links DO NOT generate Type 2 LSAs
- Only Type 1 LSAs exist for point-to-point

---

## Part 3: Point-to-Point Network Type (15 minutes)

### Concept Review

**Point-to-point networks:**
- Direct connection between two routers
- No DR/BDR election (not needed)
- Faster neighbor formation
- Common on WAN links, direct connections
- Uses 224.0.0.5 (AllSPFRouters) for hellos

---

### Step 1: Configure OSPF on point-to-point link (R1-R4)

**On R1:**
```bash
configure terminal
router ospf
 network 10.0.2.0/30 area 0
 exit
interface eth2
 ip ospf network point-to-point
 exit
exit
write memory
```

**On R4:**
```bash
docker exec -it clab-ospf-lab2-network-types-r4 vtysh

configure terminal
router ospf
 ospf router-id 4.4.4.4
 network 4.4.4.4/32 area 0
 network 10.0.2.0/30 area 0
 exit
interface eth1
 ip ospf network point-to-point
 exit
exit
write memory
```

---

### Step 2: Verify point-to-point neighbor relationship

**On R1:**
```bash
show ip ospf neighbor
```

**Expected output:**
```
Neighbor ID     Pri State           Dead Time Address         Interface
4.4.4.4           0 Full/-          00:00:38  10.0.2.2        eth2:10.0.2.1
...other neighbors...
```

**Key observations:**
- Pri = 0 (priority doesn't matter on point-to-point)
- State = Full/- (the "-" means no DR/BDR on this link)
- Faster to reach Full state (no DR/BDR election)

---

### Step 3: Compare interface output

**On R1:**
```bash
show ip ospf interface eth2
```

**Expected output:**
```
eth2 is up
  Internet Address 10.0.2.1/30, Broadcast 10.0.2.3, Area 0.0.0.0
  Router ID 1.1.1.1, Network Type POINTOPOINT, Cost: 10
  Transmit Delay is 1 sec, State Point-To-Point, Priority 1
  No backup designated router on this network
  No designated router on this network
  Timer intervals configured, Hello 10s, Dead 40s
```

**Key differences from broadcast:**
- Network Type: POINTOPOINT
- State: Point-To-Point (not DR/BDR/DROther)
- No DR/BDR

---

### Step 4: Examine OSPF database - No Type 2 LSA

**On R1:**
```bash
show ip ospf database
```

**Notice:**
- Type 1 LSAs for all routers (including R4)
- No Type 2 LSA for the 10.0.2.0/30 link (point-to-point doesn't use Type 2)
- Type 2 LSA only exists for broadcast segment (10.0.1.0/24)

---

## Part 4: Point-to-Multipoint Network Type (25 minutes)

### Concept Review

**Point-to-multipoint:**
- Treats multi-access network as collection of point-to-point links
- No DR/BDR election (like point-to-point)
- Each neighbor gets a /32 host route
- Useful for hub-and-spoke topologies
- Better for partial mesh than broadcast
- Modern alternative to NBMA (Non-Broadcast Multi-Access)

**Use cases:**
- Hub-and-spoke VPN networks
- Partial mesh topologies
- When you want broadcast-like connectivity without DR/BDR overhead

---

### Step 1: Reconfigure broadcast segment as point-to-multipoint

We'll reconfigure the 10.0.1.0/24 segment to see the difference.

**On R1:**
```bash
configure terminal
interface eth1
 ip ospf network point-to-multipoint
 exit
exit
write memory
```

**On R2:**
```bash
docker exec -it clab-ospf-lab2-network-types-r2 vtysh

configure terminal
interface eth1
 ip ospf network point-to-multipoint
 exit
exit
write memory
```

**On R3:**
```bash
docker exec -it clab-ospf-lab2-network-types-r3 vtysh

configure terminal
interface eth1
 ip ospf network point-to-multipoint
 exit
exit
write memory
```

---

### Step 2: Verify neighbor relationships - No DR/BDR

Wait ~40 seconds for old adjacencies to timeout and new ones to form.

**On R1:**
```bash
show ip ospf neighbor
```

**Expected output:**
```
Neighbor ID     Pri State           Dead Time Address         Interface
2.2.2.2           0 Full/-          00:00:37  10.0.1.2        eth1:10.0.1.1
3.3.3.3           0 Full/-          00:00:38  10.0.1.3        eth1:10.0.1.1
4.4.4.4           0 Full/-          00:00:39  10.0.2.2        eth2:10.0.2.1
```

**Key observations:**
- All neighbors show Pri = 0 (no priority matters)
- All states show Full/- (no DR/BDR)
- All routers have direct adjacencies with each other

---

### Step 3: View interface details

**On R1:**
```bash
show ip ospf interface eth1
```

**Expected output:**
```
eth1 is up
  Internet Address 10.0.1.1/24, Broadcast 10.0.1.255, Area 0.0.0.0
  Router ID 1.1.1.1, Network Type POINTOMULTIPOINT, Cost: 10
  Transmit Delay is 1 sec, State Point-To-Multipoint, Priority 1
  No backup designated router on this network
  No designated router on this network
  Timer intervals configured, Hello 30s, Dead 120s
```

**Key observations:**
- Network Type: POINTOMULTIPOINT
- State: Point-To-Multipoint
- No DR/BDR
- **Hello timer changed to 30s** (vs 10s on broadcast)
- **Dead timer changed to 120s** (vs 40s on broadcast)

---

### Step 4: Examine routing table - /32 host routes

**On R1:**
```bash
show ip route ospf
```

**Expected output:**
```
O   2.2.2.2/32 [110/10] via 10.0.1.2, eth1, 00:02:15
O   3.3.3.3/32 [110/10] via 10.0.1.3, eth1, 00:02:14
O   4.4.4.4/32 [110/10] via 10.0.2.2, eth2, 00:05:43
O   10.0.1.2/32 [110/10] is directly connected, eth1, 00:02:15
O   10.0.1.3/32 [110/10] is directly connected, eth1, 00:02:14
```

**Key observation:**
- **Point-to-multipoint creates /32 host routes** for each neighbor on the segment
- This is different from broadcast, which learns the entire 10.0.1.0/24 subnet
- Each router's interface IP is learned as a /32

---

### Step 5: Compare OSPF database

**On R1:**
```bash
show ip ospf database
```

**Observations:**
- Type 1 LSAs still present for all routers
- **No Type 2 LSA** for 10.0.1.0/24 (because point-to-multipoint doesn't elect DR)
- This is similar to point-to-point behavior

---

### Step 6: When to use point-to-multipoint

**Use point-to-multipoint when:**
1. Hub-and-spoke topology (hub is connected to many spokes)
2. Partial mesh network (not all routers connected to all)
3. Want to avoid DR/BDR election complexity
4. Need broadcast-like behavior without broadcast requirements
5. Replacing legacy NBMA networks

**Example scenario:**
```
        [Hub - R1]
       /    |     \
    [R2]  [R3]   [R4]  (Spokes)
```
- All spokes connect to hub
- Spokes may or may not connect to each other
- Point-to-multipoint: each spoke has adjacency with hub only
- Broadcast: would elect DR/BDR, all spokes try to peer

---

## Part 5: Network Type Comparison (5 minutes)

### Summary Table

| Feature | Broadcast | Point-to-Point | Point-to-Multipoint |
|---------|-----------|----------------|---------------------|
| **DR/BDR Election** | Yes | No | No |
| **Type 2 LSA** | Yes (from DR) | No | No |
| **Hello Timer** | 10s | 10s | 30s |
| **Dead Timer** | 40s | 40s | 120s |
| **Neighbor Discovery** | Automatic | Automatic | Automatic |
| **Host Routes (/32)** | No | No | Yes |
| **Best For** | LANs, Ethernet | WAN, direct links | Hub-spoke, partial mesh |
| **Multicast Address** | 224.0.0.5, 224.0.0.6 | 224.0.0.5 | 224.0.0.5 |

---

### Decision Tree: Which Network Type to Use?

```
Is this a LAN segment with 3+ routers?
  ├─ Yes → Use BROADCAST (default for Ethernet)
  └─ No → Continue

Is this a direct connection between 2 routers?
  ├─ Yes → Use POINT-TO-POINT
  └─ No → Continue

Is this a hub-and-spoke or partial mesh?
  ├─ Yes → Use POINT-TO-MULTIPOINT
  └─ No → Special case (NBMA, etc.)
```

---

## Lab Cleanup

### Save your configurations (if you want to reference later)

From each router:
```bash
write memory
show running-config
```

### Destroy the lab

```bash
sudo containerlab destroy -t topology.yml --cleanup
```

**Expected output:**
```
INFO[0000] Parsing & checking topology file: topology.yml
INFO[0000] Destroying lab: ospf-lab2-network-types
INFO[0001] Removed container: clab-ospf-lab2-network-types-r1
INFO[0001] Removed container: clab-ospf-lab2-network-types-r2
INFO[0001] Removed container: clab-ospf-lab2-network-types-r3
INFO[0001] Removed container: clab-ospf-lab2-network-types-r4
```

---

## Review Questions

Test your understanding:

1. What happens if all routers on a broadcast segment have the same priority?
2. Why don't point-to-point links need a DR/BDR?
3. When would you use point-to-multipoint instead of broadcast?
4. What LSA type is generated by the DR on a broadcast network?
5. How do hello timers differ between broadcast and point-to-multipoint?
6. What's the purpose of setting OSPF priority to 0?

### Answers

1. Router with highest router-ID becomes DR
2. Only 2 routers on the link - no need for a designated router to reduce flooding
3. Hub-spoke topologies, partial mesh, or when you want to avoid DR/BDR complexity
4. Type 2 LSA (Network LSA)
5. Broadcast = 10s, Point-to-Multipoint = 30s
6. Router will never become DR or BDR

---

## Key Takeaways

✅ Broadcast networks require DR/BDR election  
✅ DR/BDR election uses priority (then router-ID as tiebreaker)  
✅ Point-to-point networks are simpler (no DR/BDR)  
✅ Point-to-multipoint is useful for hub-spoke topologies  
✅ Point-to-multipoint creates /32 host routes for neighbors  
✅ Network type is configured per interface, not globally  
✅ Different network types generate different LSA patterns

---

**Lab Complete!** 🎉

You've successfully learned how to configure and compare OSPF network types. This knowledge is critical for designing and troubleshooting OSPF networks in production environments.

**Next Lab:** Lab 3 - OSPF Metrics and Path Selection
