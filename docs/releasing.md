# Releasing Remote View Favorites

GitHub Actions builds the Mod Portal ZIP. You do not need to run `scripts/package_mod.sh` locally.

## Steps

1. Bump `info.json` version and add notes in `CHANGELOG.md`.
2. Commit and push.
3. Tag matching `info.json`: `git tag v0.1.0` then `git push origin v0.1.0`.
4. The **Release** workflow packages the zip, checks it has no executables/scripts, and attaches it to a GitHub Release.
5. Download that zip from the GitHub Release and upload it on the Factorio Mod Portal.
6. If the portal description changed, paste from [mod-portal.md](mod-portal.md).

CI on `main` / `public` / pull requests smoke-tests the same zip rules without creating a release.

## Package rules

- Zip name: `remote-view-favorites_<version>.zip`
- One top-level folder: `remote-view-favorites_<version>/`
- Tag `vX.Y.Z` must match `info.json` version `X.Y.Z`
- No `.sh` / `.py` / binaries in the zip; execute bits stripped
- `docs/`, `scripts/`, and `CHANGELOG.md` stay in git only; Factorio gets generated `changelog.txt`
