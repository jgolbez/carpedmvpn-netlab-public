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
        R1 (Hub)
       / | \
   eth1 eth2 eth3
     /   |    \
   R2   R3    R4

Networks:
- 10.0.12.0/30: R1 ↔ R2
- 10.0.13.0/30: R1 ↔ R3
- 10.0.14.0/30: R1 ↔ R4

Loopbacks:
- R1: 1.1.1.1/32
- R2: 2.2.2.2/32
- R3: 3.3.3.3/32
- R4: 4.4.4.4/32
```

**Network Details:**
- **R1-R2, R1-R3:** Point-to-point links (will configure as broadcast)
- **R1-R4:** Point-to-point link (will keep as point-to-point)

