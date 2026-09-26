### Unit 2 Analysis: RideShare Database Schema Design

This document details the architectural reasoning, constraint patterns, and execution hierarchy implemented within the CreateDDL.sql script for the RideShare database. I have kept in mind to build tables in the order of their dependencies. I have also ran, and rerun the creating of tables and used DROP to test.

### 1. Table Creation and Destruction Ordering

Relational databases with referential integrity constraints enforce strict requirements on data definition sequences. Tables must be managed based on their network dependencies. 

### Creation Dependency Order

1. **riders**: Independent entity containing zero foreign keys. Must exist before any journey transactions can occur.
2. **drivers**: Independent entity holding operational profiling metrics. Must be established prior to scheduling work tasks.
3. **driver_badges**: Static catalog lookup structure containing reward classifications. Must predate relational assignment entries.
4. **trips**: Intermediary transaction record. Requires fully active primary identities from both riders and drivers to fulfill structural constraints.
5. **driver_badge_awards**: Many-to-many bridge junction. Evaluates intersections between drivers and driver_badges, making it entirely dependent on both catalogs being fully deployed first.

### Destructive Reset Policy

To enable stateless, repeatable test deployment cycles, the destruction routine explicitly mirrors the reverse sequence: 

[driver_badge_awards] ──> [trips] ──> [driver_badges] ──> [drivers] ──> [riders]

Removing leaf nodes first cleanly severs foreign keys without triggering relational constraint violations. The inclusion of the CASCADE parameter provides defensive structural fallback protection against lingering dependencies. 

### 2. Referential Integrity and Type Uniformity

Mismatched data types across relationship boundaries constitute a primary driver of deployment phase compilation failures. 

* **Type Symmetry**: All transactional consumer columns (trips.rider_id, driver_badge_awards.driver_id) utilize explicit INTEGER allocations matching the structural definitions of their target source attributes precisely. This configuration guarantees compatibility during index generation.
* **Storage Precision**: Financial values (fare_amount) are explicitly bound to DECIMAL(10, 2) instead of imprecise floating-point classifications (REAL, DOUBLE). This preserves numerical scaling properties up to 8 whole digits alongside exact 2-decimal fractional positions for transactional auditing.

### 3. Constraint Management and Naming Convention

Standardizing explicit, human-readable constraint labels isolates application failures instantly during integration testing. The tracking structure deployed across this project enforces the following schema: 

PrefixConstraint TypeTarget Application Strategy
****pk_****
Primary KeyGuarantees internal structural index boundaries for search indexing.
****fk_****
Foreign KeyControls cascading synchronization rules across records.
****uq_****
Unique ConstraintAsserts distinct values on business fields like communication addresses (email) and credential tokens (license_number).

### Cascade Mitigation Matrix

* **ON DELETE CASCADE**: Assigned to trips.rider_id and all driver_badge_awards relationships. If a profile domain is purged from the application stack, all relational reward allocations and profile history drop seamlessly to minimize unindexed orphan rows.
* **ON DELETE SET NULL**: Assigned to trips.driver_id. If a vendor profile changes status or leaves the system, the systemic record of the actual historical event remains mathematically secure. The relationship reference updates cleanly to a null footprint to retain aggregate cash flow records inside the table.
