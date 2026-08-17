## NZHTS integration pattern usage

NZHTS is the national service for mastering, authoring and distributing authoritative health terminology. It is the source from which terminology is discovered and obtained; it is not intended to be a shared runtime terminology backend for New Zealand's clinical applications.

### Appropriate uses of NZHTS

NZHTS is currently intended to be used for:

* authoring and maintaining nationally managed terminology artifacts;
* discovering CodeSystems, ValueSets, ConceptMaps, NamingSystems etc. and updates to these terminology artifacts;
* sourcing authoritative reference material for implementation, testing or distribution;
* design-time terminology operations, including validating and expanding terminology during a [FHIR IG publication workflow](tx-ecosystem.html); and
* obtaining versioned terminology content through the [NZHTS syndication feed](https://nzhts.digital.health.nz/synd/syndication.xml) for loading into downstream terminology services.

These are human-in-the-loop, authoring, build-time or content-distribution activities. They are normally tolerant of network access, authentication and the operational characteristics of a shared national service.

### Do not make NZHTS a clinical runtime dependency

Clinical applications should not call NZHTS synchronously for routine user-facing or clinical workflows such as type-ahead search, code lookup, code validation or ValueSet expansion. NZHTS is not designed to meet an application's runtime latency, throughput, availability or support requirements. A direct dependency would also expose clinical workflows to internet connectivity, authentication and national-service maintenance events.

Direct access by the IG Publisher and other design-time tools is appropriate; direct access on every clinical transaction is not.

### Production application pattern

The expected production pattern is:

`NZHTS national master -> syndication feed -> integrator-managed terminology service -> clinical applications`

An integrator should use the syndication feed to discover and retrieve the required versioned releases, test them, and promote them into its own environment on a controlled schedule. The downstream service may be a high-performance in-memory terminology service for a small, well-defined set of operations, or a separate local FHIR terminology server where richer functions such as `$expand`, `$validate-code`, `$lookup`, subsumption, version history or locally managed terminology are required.


