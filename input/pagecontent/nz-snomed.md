## NZ Edition SNOMED CT

### Treating http://snomed.info/sct as the NZ Edition of SNOMED

FHIR uses `http://snomed.info/sct` as the code system URI for every SNOMED CT edition. The New Zealand edition is not a separate code system; it is identified by the edition URI `http://snomed.info/sct/21000210109`, where `21000210109` is the identifying module for the [New Zealand Edition](https://docs.snomed.org/snomed-ct-practical-guides/snomed-ct-extension-guide/4-logical-design/4.4-editions/4.4.2-edition-uri-examples). The standard code system URI uses `http`, not `https`; FHIR URIs are identifiers, so the two forms are not interchangeable.

When an IG contains only the unversioned system URI, the IG Publisher cannot infer that the NZ edition is intended. This can make NZ extension concepts and NZ reference sets appear unknown, and can produce incorrect ValueSet expansions or terminology validation failures.

An IG can supply a build-wide default with a FHIR `Parameters` resource. Its `system-version` parameter tells the terminology service which edition to use whenever a ValueSet refers to `http://snomed.info/sct` without specifying a version. This follows the definition of the [`system-version` input to ValueSet `$expand`](http://hl7.org/fhir/R4/valueset-operation-expand.html).

### Parameters resource

For a standard SUSHI project, save the following complete resource as `input/_resources/exp-params.json`:

```json
{
  "resourceType": "Parameters",
  "id": "exp-params",
  "parameter": [
    {
      "name": "system-version",
      "valueUri": "http://snomed.info/sct|http://snomed.info/sct/21000210109"
    }
  ]
}
```

The value has the canonical `system|version` form. To the left of `|` is the unversioned code system to which the default applies; to the right is the NZ edition URI. Using the bare edition URI selects the latest NZ edition release available to the terminology server. For a reproducible build, the right-hand side can instead be pinned to a release, for example `http://snomed.info/sct/21000210109/version/20260401`. A pinned release must be updated deliberately and must be available on the terminology server used by the build.

### SUSHI configuration

Add `path-expansion-params` under the existing `parameters` block in `sushi-config.yaml`:

```yaml
parameters:
  path-expansion-params: ../../input/_resources/exp-params.json
```

Do not add a second `parameters` block if the file already has one; merge this entry into it. The path contains `../../` because the generated `ImplementationGuide` resource is written under `fsh-generated/resources`, and the IG Publisher resolves this setting relative to that resource. The [IG Publisher parameter definition](https://build.fhir.org/ig/FHIR/fhir-tools-ig/CodeSystem-ig-parameters.html) describes `path-expansion-params` as the path to a `Parameters` resource used for ValueSet expansion.

### When to use it

This configuration is appropriate for an NZ IG that uses SNOMED CT and expects unversioned references to be evaluated against the NZ edition, especially when it uses NZ extension concepts, NZ reference sets, or intensional ValueSets. It is also useful when existing FHIR artifacts use the shared SNOMED CT system URI and cannot conveniently add a version to every reference.

`system-version` is a default: it does not replace a version explicitly stated in `ValueSet.compose.include.version`, an implicit SNOMED ValueSet URL, or `Coding.version`. It also does not rewrite the resources published by the IG. Continue to put an explicit NZ edition or release URI in exchanged artifacts when edition selection must remain clear outside the IG build. Finally, the setting cannot add terminology content to a server; the selected terminology server must actually host the requested NZ edition.
