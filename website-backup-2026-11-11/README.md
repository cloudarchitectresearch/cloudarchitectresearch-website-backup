# Cloud Architect and Research website backup

This folder contains a dated static snapshot of the public website at
`https://www.cloudarchitectresearch.com`, created on November 11, 2026.

Included routes:

- Home (`/`)
- Services (`/services`)
- Contact (`/contact`)
- CircleGlow Support (`/circleglow-support`)
- Apps & Services (`/apps-and-services`)
- SAP Learning (`/sap-learning`)
- Sajilo Circle (`/sajilo-circle`)

`snapshot/manifest.json` records the source URL, local path, file size, and
SHA-256 checksum for each saved page and asset. This is the recoverable archive
of the published site before the November 11 editor update.

`preview-snapshot/manifest.json` is a second archive captured from the verified
Articulation preview. It preserves the updated Home page and all other pages as
they appeared immediately before publishing. Articulation remains the editable
source of record for the live website.

To create a fresh snapshot later, run `backup-site.ps1` from PowerShell.

## Articulation editor page IDs

- Home: `01a0754b-ff7d-72d1-94b0-ddc9d5a5999f`
- Services: `01a0754b-ffc5-7091-810f-c9b361e607af`
- Contact: `01a0754b-ff69-70f1-8a60-fceae1fffcc5`
- CircleGlow Support: `01a129ea-c922-73dc-9c5a-8ae9b5065aae`
- Apps & Services: `01a14d7d-8047-70e8-8e7d-ed0749ca1325`
- SAP Learning: `01a1801a-0739-7088-b2bd-6f6e952000be`

