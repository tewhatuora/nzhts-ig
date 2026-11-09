## NZHTS integration pattern usage

NZHTS is the national service for mastering, authoring and distributing authoritative health terminology. It is the source from which terminology is discovered and obtained; it is not intended to be a shared runtime terminology backend for New Zealand's clinical applications.

### Appropriate uses of NZHTS

NZHTS is currently intended to be used for:

* authoring and maintaining nationally managed terminology artifacts;
* discovering CodeSystems, ValueSets, ConceptMaps, NamingSystems etc. and updates to these terminology artifacts;
* sourcing authoritative reference material for implementation, testing or distribution;
* design-time terminology operations, including validating and expanding terminology during a [FHIR IG publication workflow](tx-ecosystem.html); and
* obtaining versioned terminology content through the APIs and [syndication feed](https://nzhts.digital.health.nz/synd/syndication.xml) for loading into downstream terminology services.

These are human-in-the-loop, authoring, build-time or content-distribution activities. They are normally tolerant of network access, authentication and the operational characteristics of a shared national service.

### NZHTS as a clinical runtime dependency

Clinical applications should not call NZHTS synchronously for routine user-facing or clinical workflows such as type-ahead search, code lookup, code validation or ValueSet expansion. NZHTS is not designed to meet an application's runtime latency, throughput, availability or support requirements. A direct dependency would also expose clinical workflows to internet connectivity, authentication and national-service maintenance events.

Direct access by the IG Publisher and other design-time tools is the intended use case; direct access by end user applications for every clinical transaction are better served by more local services.

### Production application pattern

The expected production pattern is:

`NZHTS national master -> syndication or scheduled retrieval -> integrator-managed terminology service or local cache -> clinical applications`

An integrator should use the APIs or syndication feed to discover and retrieve the required versioned releases. The downstream service may be a local cache, an  in-memory terminology service for a small, well-defined set of operations, or a separate local FHIR terminology server where richer functions such as `$expand`, `$validate-code`, `$lookup`, subsumption, version history are required.

