
## IG Testing

<p class="dragon">Important note: This implementation guide is not for general use yet - it is being used to test the approach of creating a FHIR IG/Package for the NZHTS service.</p>

## NZHTS Content 

This FHIR IG contains terminology artefacts from the [New Zealand Health Terminology service](https://www.tewhatuora.govt.nz/health-services-and-programmes/digital-health/terminology-service/) that are used in FHIR NZ FHIR implementation guides, so the terminology can be included as a package dependency in IGs that use NZHTS mastered terminology. 

The IG will be generated from a snapshot downloaded from the NZHTS FHIR API. The intention would be to release a new version of the IG/package with each NZHTS release (currently monthly).  

## Version

{% include cross-version-analysis.xhtml %}

## Dependencies

{% include dependency-table.xhtml %}

## Intellectual property

{% include ip-statements.xhtml %}