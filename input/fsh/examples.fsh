Instance: immunisation-reaction-event-example
InstanceOf: NzImmunisationReactionEvent
Usage: #example
Title: "Immunisation Reaction Event Example"
Description: """
An adverse reaction event following a COVID-19 immunisation. `Observation.code` carries a SNOMED CT
concept that is a member of the New Zealand COVID-19 adverse reaction event from immunisation
reference set (`61231000210108`), enforced by the required binding on
[NzImmunisationReactionEvent](StructureDefinition-nz-immunisation-reaction-event.html).

`Coding.system` is the plain SNOMED CT URI - there is no separate "NZ SNOMED" code system. The NZ
edition is named in `Coding.version`, which carries the **edition URI**:

    http://snomed.info/sct/21000210109

Setting the version is not merely documentation. It is what allows a validator, or any consumer, to
work out *which terminology server can answer questions about this code*. The
[terminology server registry](https://github.com/FHIR/ig-registry/blob/master/hl7-nz-tx-servers.json)
declares NZHTS authoritative for `http://snomed.info/sct|http://snomed.info/sct/21000210109*` - a
match on system **and version**. A coding that omits the version is just unqualified SNOMED CT, and
will be routed to a general-purpose server that does not hold the NZ edition and cannot resolve NZ
edition content.

The version here is the edition URI, with no release appended, meaning "the current release of the
NZ edition". It could be pinned to a specific release - `http://snomed.info/sct/21000210109/version/20260401` -
which buys reproducibility at the cost of going stale when that release is no longer served.
"""
* contained[0] = ExamplePatient
* status = #final
* code.coding.system = "http://snomed.info/sct"
* code.coding.version = "http://snomed.info/sct/21000210109"
* code.coding.code = #50920009
* code.coding.display = "Myocarditis"
* subject.reference = "#patient"
* effectiveDateTime = "2026-07-02"


Instance: covid-immunisation-example
InstanceOf: Immunization
Usage: #example
Title: "COVID-19 Immunisation Example"
Description: """
The COVID-19 immunisation that the adverse reaction event followed. `Immunization.reaction.detail`
references the [Observation](Observation-immunisation-reaction-event-example.html) carrying the
NZ-edition-coded reaction.

As with the reaction, `vaccineCode.version` names the SNOMED CT New Zealand edition, so that the
coding resolves against a server holding that edition.
"""
* contained[0] = ExamplePatient
* status = #completed
* vaccineCode.coding.system = "http://snomed.info/sct"
* vaccineCode.coding.version = "http://snomed.info/sct/21000210109"
* vaccineCode.coding.code = #1119349007
* vaccineCode.coding.display = "COVID-19 vaccine"
* patient.reference = "#patient"
* occurrenceDateTime = "2026-07-01"
* reaction.date = "2026-07-02"
* reaction.detail = Reference(immunisation-reaction-event-example)


// Contained subject, shared by the two examples above. Matches the pattern already used by
// Observation/smoking-status-example.
Instance: ExamplePatient
InstanceOf: Patient
Usage: #inline
* id = "patient"
* meta.profile = "http://hl7.org.nz/fhir/StructureDefinition/NzPatient"
* identifier.use = #official
* identifier.system = "https://standards.digital.health.nz/ns/nhi-id"
* identifier.value = "ZZZ0039"
