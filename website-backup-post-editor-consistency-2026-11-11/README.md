# Post-editor-consistency website backup

Created November 11, 2026, after the Home page consistency review and publication.

This recovery package preserves both current website outputs:

- `live-snapshot/`: the published website at `https://www.cloudarchitectresearch.com`
- `preview-snapshot/`: the Articulation preview at `https://01a074aa-13f1-7147-bd99-53f3c5be23c2.preview.articulationsites.com`

Each snapshot contains seven routes, referenced assets, and a manifest containing SHA-256 checksums. The included `backup-site.ps1` script can create another snapshot later.

The earlier pre-change recovery point remains available separately in `website-backup-pre-native-rebuild-2026-11-11/`.
