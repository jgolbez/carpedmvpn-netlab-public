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

## Starting the Lab

1. Deploy the lab:
   ```bash
   containerlab deploy -t topology.yml
   # Or with sudo if needed:
   sudo containerlab deploy -t topology.yml
   ```

2. Access each router and enable OSPFD:
   ```bash
   # For each router (r1, r2, r3):
   docker exec -it clab-ospf-fundamentals-r1 bash
   
   # Enable OSPFD in the FRR daemons file:
   sed -i 's/ospfd=no/ospfd=yes/g' /etc/frr/daemons
   
   # Restart FRR:
   /usr/lib/frr/frrinit.sh restart
   
   # Now enter vtysh:
   vtysh
   ```

## Lab Tasks

### Task 1: Configure IP Addresses

**For GitHub Codespaces**: You need to configure IPs at the Linux level first:

On R1 (in bash, before entering vtysh):
```bash
ip addr add 10.0.12.1/30 dev eth1
ip addr add 10.0.13.1/30 dev eth2
ip addr add 1.1.1.1/32 dev lo
ip link set eth1 up
ip link set eth2 up
```

On R2 (in bash):
```bash
ip addr add 10.0.12.2/30 dev eth1
ip addr add 10.0.23.1/30 dev eth2
ip addr add 2.2.2.2/32 dev lo
ip link set eth1 up
ip link set eth2 up
```

On R3 (in bash):
```bash
ip addr add 10.0.23.2/30 dev eth1
ip addr add 10.0.13.2/30 dev eth2
ip addr add 3.3.3.3/32 dev lo
ip link set eth1 up
ip link set eth2 up
```

**For Local Linux**: You can configure IPs directly in vtysh:
```
configure terminal
interface eth1
 ip address 10.0.12.1/30
interface eth2
 ip address 10.0.13.1/30
interface lo
 ip address 1.1.1.1/32
exit
```

### Task 2: Configure OSPF

In vtysh on each router:

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

1. **Test convergence** - Shut down a link and observe rerouting
2. **Adjust OSPF costs** to influence path selection
3. **Monitor OSPF events** with `debug ospf events`

## Quick Setup Script (Optional)

If you want to automate the initial setup, create this script:

```bash
#!/bin/bash
# setup-ospf-lab.sh

for i in 1 2 3; do
  echo "Setting up r$i..."
  docker exec clab-ospf-fundamentals-r$i sed -i 's/ospfd=no/ospfd=yes/g' /etc/frr/daemons
  docker exec clab-ospf-fundamentals-r$i /usr/lib/frr/frrinit.sh restart
done

# Add IPs for R1
docker exec clab-ospf-fundamentals-r1 ip addr add 10.0.12.1/30 dev eth1
docker exec clab-ospf-fundamentals-r1 ip addr add 10.0.13.1/30 dev eth2
docker exec clab-ospf-fundamentals-r1 ip addr add 1.1.1.1/32 dev lo
docker exec clab-ospf-fundamentals-r1 ip link set eth1 up
docker exec clab-ospf-fundamentals-r1 ip link set eth2 up

# Add IPs for R2
docker exec clab-ospf-fundamentals-r2 ip addr add 10.0.12.2/30 dev eth1
docker exec clab-ospf-fundamentals-r2 ip addr add 10.0.23.1/30 dev eth2
docker exec clab-ospf-fundamentals-r2 ip addr add 2.2.2.2/32 dev lo
docker exec clab-ospf-fundamentals-r2 ip link set eth1 up
docker exec clab-ospf-fundamentals-r2 ip link set eth2 up

# Add IPs for R3
docker exec clab-ospf-fundamentals-r3 ip addr add 10.0.23.2/30 dev eth1
docker exec clab-ospf-fundamentals-r3 ip addr add 10.0.13.2/30 dev eth2
docker exec clab-ospf-fundamentals-r3 ip addr add 3.3.3.3/32 dev lo
docker exec clab-ospf-fundamentals-r3 ip link set eth1 up
docker exec clab-ospf-fundamentals-r3 ip link set eth2 up

echo "Lab setup complete! Now configure OSPF in vtysh."
```

## FRR vs Cisco Command Differences

| Cisco IOS | FRR |
|-----------|-----|
| `router ospf 1` | `router ospf` |
| `network 10.0.12.0 0.0.0.3 area 0` | `network 10.0.12.0/30 area 0` |

## Cleanup

When finished:
```bash
containerlab destroy -t topology.yml --cleanup
# Or with sudo:
sudo containerlab destroy -t topology.yml --cleanup
```
