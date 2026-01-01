# OSPF Fundamentals Lab

## Objective
Learn OSPF basics by configuring and observing OSPF neighbor relationships and route propagation in a 3-router topology.

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

## Pre-configured IP Addresses

The lab automatically configures these IPs when deployed:

| Router | Interface | IP Address |
|--------|-----------|------------|
| R1 | lo | 1.1.1.1/32 |
| R1 | eth1 | 10.0.12.1/30 |
| R1 | eth2 | 10.0.13.1/30 |
| R2 | lo | 2.2.2.2/32 |
| R2 | eth1 | 10.0.12.2/30 |
| R2 | eth2 | 10.0.23.1/30 |
| R3 | lo | 3.3.3.3/32 |
| R3 | eth1 | 10.0.23.2/30 |
| R3 | eth2 | 10.0.13.2/30 |

## Starting the Lab

1. Deploy the lab:
   ```bash
   containerlab deploy -t topology.yml
   # Or with sudo if needed:
   sudo containerlab deploy -t topology.yml
   ```

2. Wait about 30-60 seconds for containers to fully start

3. Access routers using vtysh:
   ```bash
   docker exec -it clab-ospf-fundamentals-r1 vtysh
   docker exec -it clab-ospf-fundamentals-r2 vtysh
   docker exec -it clab-ospf-fundamentals-r3 vtysh
   ```

## Lab Tasks

### Task 1: Verify Pre-configured IP Addresses

Check that IPs are configured correctly:
```
show interface brief
show interface eth1
show interface eth2
```

Test basic connectivity between directly connected routers:
```
ping 10.0.12.2   # From R1 to R2
ping 10.0.13.2   # From R1 to R3
```

### Task 2: Configure OSPF

**Important:** FRR uses `router ospf` (not `router ospf 1` like Cisco)

On R1:
```
configure terminal
router ospf
 ospf router-id 1.1.1.1
 network 10.0.12.0/30 area 0
 network 10.0.13.0/30 area 0
 network 1.1.1.1/32 area 0
exit
write memory
```

On R2:
```
configure terminal
router ospf
 ospf router-id 2.2.2.2
 network 10.0.12.0/30 area 0
 network 10.0.23.0/30 area 0
 network 2.2.2.2/32 area 0
exit
write memory
```

On R3:
```
configure terminal
router ospf
 ospf router-id 3.3.3.3
 network 10.0.23.0/30 area 0
 network 10.0.13.0/30 area 0
 network 3.3.3.3/32 area 0
exit
write memory
```

### Task 3: Verify OSPF Operations

1. Check OSPF neighbors (should see 2 neighbors on each router):
   ```
   show ip ospf neighbor
   ```

2. View OSPF database:
   ```
   show ip ospf database
   ```

3. Check routing table (should see OSPF routes to other loopbacks):
   ```
   show ip route ospf
   ```

4. Test end-to-end connectivity:
   ```
   ping 2.2.2.2 source 1.1.1.1
   ping 3.3.3.3 source 1.1.1.1
   ```

### Task 4: Experiment with OSPF

1. **Test convergence** - Shut down a link and observe rerouting:
   ```bash
   # From Linux shell on R2 (exit vtysh first):
   exit
   ip link set eth2 down
   vtysh
   
   # Back in vtysh, check OSPF:
   show ip ospf neighbor
   show ip route ospf
   ```

2. **Adjust OSPF costs** to influence path selection:
   ```
   configure terminal
   interface eth1
    ip ospf cost 100
   exit
   ```

3. **Monitor OSPF events**:
   ```
   debug ospf events
   # Make a change, observe logs
   undebug all
   ```

## Useful Commands Reference

| Purpose | Command |
|---------|---------|
| Show interfaces with IPs | `show interface brief` |
| Show OSPF neighbors | `show ip ospf neighbor` |
| Show OSPF routes | `show ip route ospf` |
| Show OSPF database | `show ip ospf database` |
| Show OSPF interface details | `show ip ospf interface` |
| Save configuration | `write memory` |

## FRR vs Cisco Command Differences

| Cisco IOS | FRR |
|-----------|-----|
| `router ospf 1` | `router ospf` |
| `network 10.0.12.0 0.0.0.3 area 0` | `network 10.0.12.0/30 area 0` |
| `show ip ospf` | `show ip ospf` (same) |

## Cleanup

When finished:
```bash
containerlab destroy -t topology.yml --cleanup
# Or with sudo:
sudo containerlab destroy -t topology.yml --cleanup
```

## Questions to Consider

1. How long does OSPF take to detect a failed neighbor?
2. What happens to the routing table when a link fails?
3. How does OSPF choose the best path when multiple paths exist?
4. What is the purpose of the OSPF router-id?

## Next Steps

- Try adding a fourth router to the topology
- Experiment with multiple OSPF areas
- Configure OSPF authentication
- Test OSPF stub areas
