# OSPF Fundamentals Lab

## Objective
Learn OSPF basics by configuring and observing OSPF neighbor relationships and route propagation in a 3-router topology.

## Topology
```
     r1
    /  \
   /    \
  r2----r3
```

## Starting the Lab

1. Deploy the lab:
   ```bash
   sudo containerlab deploy -t topology.yml
   ```

2. Wait about 30 seconds for containers to fully start

3. Access routers:
   ```bash
   docker exec -it clab-ospf-fundamentals-r1 vtysh
   docker exec -it clab-ospf-fundamentals-r2 vtysh
   docker exec -it clab-ospf-fundamentals-r3 vtysh
   ```

## Lab Tasks

### Task 1: Configure IP Addresses

On R1:
```
configure terminal
interface eth1
 ip address 10.0.12.1/30
 no shutdown
interface eth2  
 ip address 10.0.13.1/30
 no shutdown
interface lo0
 ip address 1.1.1.1/32
exit
```

On R2:
```
configure terminal
interface eth1
 ip address 10.0.12.2/30
 no shutdown
interface eth2
 ip address 10.0.23.1/30
 no shutdown
interface lo0
 ip address 2.2.2.2/32
exit
```

On R3:
```
configure terminal
interface eth1
 ip address 10.0.23.2/30
 no shutdown
interface eth2
 ip address 10.0.13.2/30
 no shutdown
interface lo0
 ip address 3.3.3.3/32
exit
```

### Task 2: Configure OSPF

On each router, configure OSPF:

```
configure terminal
router ospf
 ospf router-id [X.X.X.X]  # Use loopback IP
 network 10.0.0.0/8 area 0
 network [X.X.X.X]/32 area 0  # Advertise loopback
exit
```

### Task 3: Verify OSPF Operations

1. Check OSPF neighbors:
   ```
   show ip ospf neighbor
   ```

2. View OSPF database:
   ```
   show ip ospf database
   ```

3. Check routing table:
   ```
   show ip route ospf
   ```

4. Test connectivity:
   ```
   ping 2.2.2.2 source 1.1.1.1
   ping 3.3.3.3 source 1.1.1.1
   ```

### Task 4: Experiment with OSPF

1. Shut down the link between R2 and R3:
   - On R2: `configure terminal`, `interface eth2`, `shutdown`
   - Observe how OSPF reconverges
   - Check the new path with `traceroute 3.3.3.3 source 2.2.2.2`

2. Change OSPF cost on a link:
   - On R1: `configure terminal`, `interface eth1`, `ip ospf cost 100`
   - Observe how traffic patterns change

3. Monitor OSPF events:
   - `debug ospf events` (use carefully, `undebug all` to stop)

## Cleanup

When finished:
```bash
sudo containerlab destroy -t topology.yml --cleanup
```

## Questions to Consider

1. How long does OSPF take to detect a failed neighbor?
2. What happens to the routing table when a link fails?
3. How does OSPF choose the best path when multiple paths exist?
4. What is the purpose of the OSPF router-id?

## Next Steps

Try modifying the topology to add a fourth router or create multiple OSPF areas!
