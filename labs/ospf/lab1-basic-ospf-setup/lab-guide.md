# OSPF Fundamentals Lab

## Objective
Learn OSPF basics by observing and modifying a pre-configured OSPF topology with 3 routers.

## Topology
```
     r1                     r2
  1.1.1.1/32            2.2.2.2/32
     eth1: .1---------.2 :eth1
         10.0.12.0/30
     eth2: .1     eth2: .1
           |            |
    10.0.13.0/30  10.0.23.0/30
           |            |
     eth2: .2     eth1: .2
            \    r3     /
             3.3.3.3/32
```

## Pre-configured Setup

This lab comes with:
- IP addresses configured on all interfaces
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
   docker exec -it clab-ospf-fundamentals-r1 vtysh
   docker exec -it clab-ospf-fundamentals-r2 vtysh
   docker exec -it clab-ospf-fundamentals-r3 vtysh
   ```

## Lab Tasks

### Task 1: Explore the Working OSPF Network
#### After deploying OSPF to all routers and including Loopback interfaces:

1. Check OSPF neighbors (should see 2 on each router):
   ```
   show ip ospf neighbor
   ```

2. View the OSPF database:
   ```
   show ip ospf database
   ```

3. Check the routing table:
   ```
   show ip route ospf
   ```
   You should see routes to other loopback addresses learned via OSPF.

4. Test end-to-end connectivity:
   ```
   ping 2.2.2.2 source 1.1.1.1
   ping 3.3.3.3 source 1.1.1.1
   traceroute 3.3.3.3 source 1.1.1.1
   ```

5. View the running configuration:
   ```
   show running-config
   ```

### Task 2: Experiment with OSPF

1. **Change OSPF Cost**
   ```
   configure terminal
   interface eth1
    ip ospf cost 100
   exit
   ```
   Then check how routing changed:
   ```
   show ip route ospf
   traceroute 3.3.3.3 source 1.1.1.1
   ```

2. **Disable a Link**
   ```
   configure terminal
   interface eth2
    shutdown
   exit
   ```
   Watch OSPF reconverge:
   ```
   show ip ospf neighbor
   show ip route ospf
   ```

3. **Add a New Network**
   ```
   configure terminal
   interface lo1
    ip address 10.10.10.1/32
   exit
   router ospf
    network 10.10.10.1/32 area 0
   exit
   ```
   Verify it's advertised:
   ```
   show ip ospf database router
   ```

4. **Create a New Area**
   ```
   configure terminal
   router ospf
    network 10.10.10.1/32 area 1
   exit
   ```
   Check the multi-area setup:
   ```
   show ip ospf
   show ip ospf database
   ```

### Task 3: OSPF Troubleshooting

1. **Monitor OSPF Events**
   ```
   debug ospf events
   # Make changes to see events
   undebug all
   ```

2. **Check OSPF Timers**
   ```
   show ip ospf interface eth1
   ```

3. **View OSPF Statistics**
   ```
   show ip ospf
   show ip ospf route
   ```

### Task 4: Break and Fix OSPF

1. **Remove a Network from OSPF**
   ```
   configure terminal
   router ospf
    no network 10.0.12.0/30 area 0
   exit
   ```
   What happens to the neighbor on that link?

2. **Change Router ID**
   ```
   configure terminal
   router ospf
    ospf router-id 9.9.9.9
   exit
   ```
   You may need to restart OSPF to see the effect:
   ```
   clear ip ospf process
   ```

3. **Mismatched Area**
   ```
   configure terminal
   router ospf
    no network 10.0.12.0/30 area 0
    network 10.0.12.0/30 area 1
   exit
   ```
   Check if the neighbor comes up (it shouldn't!)

## Useful Commands Reference

| Purpose | Command |
|---------|---------|
| Show OSPF neighbors | `show ip ospf neighbor` |
| Show OSPF routes | `show ip route ospf` |
| Show OSPF database | `show ip ospf database` |
| Show OSPF interface details | `show ip ospf interface` |
| Clear OSPF process | `clear ip ospf process` |
| Save configuration | `write memory` |

## Understanding the Configuration

Each router's configuration includes:
- Interface IP addresses
- OSPF process with router-id
- Networks advertised in area 0

Example (R1):
```
router ospf
 ospf router-id 1.1.1.1
 network 10.0.12.0/30 area 0    # Link to R2
 network 10.0.13.0/30 area 0    # Link to R3
 network 1.1.1.1/32 area 0      # Loopback
```

## FRR vs Cisco Command Differences

| Cisco IOS | FRR |
|-----------|-----|
| `router ospf 1` | `router ospf` |
| `network 10.0.12.0 0.0.0.3 area 0` | `network 10.0.12.0/30 area 0` |
| `show ip protocols` | `show ip ospf` |

## Cleanup

When finished:
```bash
containerlab destroy -t topology.yml --cleanup
# Or with sudo:
sudo containerlab destroy -t topology.yml --cleanup
```

## Challenge Questions

1. Why does OSPF use router-id?
2. What happens if two routers have the same router-id?
3. How does OSPF determine the best path when multiple exist?
4. What is the purpose of areas in OSPF?
5. How long does it take OSPF to detect a dead neighbor?

## Next Steps

- Try implementing OSPF authentication
- Create a hub-and-spoke topology
- Experiment with stub areas
- Add redistribution from static routes
