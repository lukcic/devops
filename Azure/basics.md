# Azure structure

- `Tenant` - Azure login account? (AWS Root account)
  - `Management group` - (like AWS Organization OUs) includes other Management groups and subscriptions
    - `Subscription` - payment
      - `Resource group` - resources groupped together

# Availability

Default availability of single VM - 99,9% (with premium SSD).

Region pairs - each region has

## Availability zone

`Strefa dostępności - fizycznie rozdziel zasoby w regionie`
VMs are deployed in different AZ across the region. Upgrades SLA to 99,99%.

## Availability set

`Zestaw dostępności - automatycznie rozpraszam naszyny wirtualne na wiele domen błędów`

Not as good as Availability zone - VMs are in the same AZ, but in different fault and update domains. Upgrades SLA to 99,95%.

### Fault domain

Group of virtual machines that share the same switch and power (the same rack?).

### Update domain

Group of virtual machines that are updated in the same time (the same physical server?). Update domains are maintained
one after another (not at once).

##

`Zestaw skalowania maszyn wirtualnych - rozpraszaj maszyny wirtualne na wiele stref i domen błędów na duza skale.`

https://docs.microsoft.com/pl-pl/learn/certifications/azure-fundamentals/

https://learn.microsoft.com/pl-pl/credentials/certifications/azure-fundamentals/?practice-assessment-type=certification
