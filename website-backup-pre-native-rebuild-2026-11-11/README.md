# Pre-native-rebuild website backup

Created November 11, 2026, immediately before rebuilding the Home page as native Articulation content.

This backup preserves both current sources of truth:

- `live-snapshot/`: the published website at `https://www.cloudarchitectresearch.com`
- `preview-snapshot/`: the Articulation Preview at `https://01a074aa-13f1-7147-bd99-53f3c5be23c2.preview.articulationsites.com`

Each snapshot contains seven routes, referenced assets, and a manifest with SHA-256 checksums. The included `backup-site.ps1` script can create another snapshot later.

The backup was created before removing the Home-page runtime replacement script or changing the underlying Articulation blocks.
