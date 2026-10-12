# Data provenance and reuse

Original local records have been retained. Local paths and private conversation identifiers are redacted in the distributed files. Recorded model labels, modes, timestamps, field vectors, observed errors and missing values are preserved. Evaluation tools use relative paths.

`export_manifest.json` records the hashes of original and distributed files. Historical hash records refer to the local originals; `SHA256SUMS.json` verifies the distributed package. Extracted generated code and evaluation code are unchanged.

Capture-transport tools and duplicate rendering artifacts are omitted, as listed in the export manifest. Scientific plots and GUI screenshots are retained as individual frames; they do not establish animation.

No package-wide reuse license has been assigned. Generated responses and third-party materials retain their respective provenance.
