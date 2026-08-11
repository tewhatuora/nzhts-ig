Profile: NzImmunisationReactionEvent
Parent: Observation
Id: nz-immunisation-reaction-event
Title: "New Zealand Immunisation Reaction Event"
Description: """
An Observation recording an adverse reaction event following a COVID-19 immunisation, where the
reaction is coded from a reference set that exists only in the SNOMED CT **New Zealand edition**.

The profile adds one meaningful constraint: a **required binding** of `Observation.code` to a SNOMED
CT [implicit ValueSet](http://hl7.org/fhir/R4/snomedct.html#implicit) - the members of the *New
Zealand COVID-19 adverse reaction event from immunisation reference set*. There is no locally
defined ValueSet resource; the binding points straight at the implicit URL:

    http://snomed.info/sct/21000210109?fhir_vs=refset/61231000210108

Reading that URL left to right:

* `http://snomed.info/sct` - the SNOMED CT code system. This is unchanged whatever edition is in
  play; there is no separate "NZ SNOMED" code system URI. The edition is named in `Coding.version`
  (see *Naming the edition in instances* below), not in `Coding.system`.
* `/21000210109` - the **module id of the SNOMED CT New Zealand edition**. This is what scopes
  resolution to NZ edition content, and it is the reason the URL resolves at all: the reference set
  is NZ edition content and is not present in the international edition.
* `?fhir_vs=refset/61231000210108` - expand to the members of this reference set.

A terminology server holding the NZ edition (such as NZHTS) expands this URL directly, so the
reference set does not have to be copied into this IG as an extensional ValueSet - contrast
[NZSmokingStatus](ValueSet-nz-smoking-status.html), which enumerates its concepts and must be
maintained by hand as the underlying content changes.

The binding is what makes the reference set *enforceable*: a validator configured against a server
holding the NZ edition will expand the implicit URL and reject any code that is not a member.

### Naming the edition in instances

Conforming instances must set `Coding.version` to the SNOMED CT NZ **edition URI**:

    http://snomed.info/sct/21000210109

This is not decoration. It is what lets a validator - or any consumer - determine *which terminology
server can answer questions about the code*. The
[terminology server registry](https://github.com/FHIR/ig-registry/blob/master/hl7-nz-tx-servers.json)
declares NZHTS authoritative for the pattern:

    http://snomed.info/sct|http://snomed.info/sct/21000210109*

which matches on system **and version**. A coding that gives only `system = http://snomed.info/sct`
is unqualified SNOMED CT: it will be routed to a general-purpose terminology server, which does not
hold the NZ edition, cannot expand this reference set, and will fail to validate the code. Omitting
the version is the single most common reason NZ edition content fails validation in an IG build.

### Version pinning

Both the implicit ValueSet URL above and `Coding.version` use the bare edition URI, with no release
appended, meaning "the current release of the NZ edition". Reference set membership therefore shifts
as the edition is updated. Where a reproducible expansion is needed - a published conformance test,
or a frozen release of a downstream IG - either may be pinned to a specific release:

    http://snomed.info/sct/21000210109/version/20260401?fhir_vs=refset/61231000210108
    http://snomed.info/sct/21000210109/version/20260401

Pinning trades currency for reproducibility: a pinned URI stops resolving once that release is no
longer served. This profile and its examples use the unpinned edition URI so that they track the
current NZ edition.

### Use in context

In R4 an immunisation reaction is referenced from
[`Immunization.reaction.detail`](http://hl7.org/fhir/R4/immunization-definitions.html#Immunization.reaction.detail),
a `Reference(Observation)`. See [ImmunisationReactionEventExample](Observation-immunisation-reaction-event-example.html)
and the [Immunization](Immunization-covid-immunisation-example.html) that refers to it.
"""
* code from http://snomed.info/sct/21000210109?fhir_vs=refset/61231000210108 (required)
* code ^short = "The adverse reaction event, from the NZ COVID-19 immunisation reaction refset"
* subject 1..1
* subject only Reference(Patient)
