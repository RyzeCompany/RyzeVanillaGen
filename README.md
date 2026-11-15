# RyzeVanillaGen

**RyzeCompany's independently distributed native vanilla-world generator for RyzeMP.**

This repository contains the real Go terrain/carver and decoration core previously maintained under `RyzeMP/native/vanillagen`. It is **not** a replacement server or a separate world data download. RyzeMP keeps its PHP worldgen, its native IPC client and its PHP fallback. The Egg installs this Go executable outside `RyzeMP.phar`.

## Compatibility contract

- **Native IPC protocol:** `7`
- **Worldgen algorithm:** `4`
- **Executable output:** `vanillagen v0.1.0 protocol 7 algorithm 4` from `-version`
- **Runtime:** standalone binary; invoked by RyzeMP via `RYZEMP_VANILLAGEN_BINARY`; private loopback communication only (no extra public port)
- **Important:** Go FMA auto-fusion changes terrain rounding. All official builds use `-d=fmahash=n` and check the resulting object code.

## Download and verification

The [releases](https://github.com/RyzeCompany/RyzeVanillaGen/releases) contain `vanillagen-linux-amd64`, `vanillagen-linux-arm64`, Windows/Darwin builds, individual `.sha256` files and `SHA256SUMS`.

Use an explicit version and verify the SHA-256 before executing. RyzeMP's Egg should install **a version it explicitly supports**, not an unverified `latest`. The official Egg puts the binary in `bin/ryzemp/vanillagen/` and refuses protocol/algorithm mismatches.

## Developer build

Go 1.24+:

```sh
go test ./...
go vet ./...
bash scripts/build.sh v0.1.0 linux/amd64
./dist/vanillagen-linux-amd64 -version
(cd dist && sha256sum -c SHA256SUMS)
```

The workflow runs Go tests, builds the external native binaries, verifies protocol 7 / algorithm 4 and publishes `v0.1.0` after successful validation on `main`. Use **Actions → RyzeVanillaGen → Run workflow** with a fresh tag (e.g. `v0.1.1`) for a later immutable release. Production publishing never requires merging an RyzeMP PR.

## Provenance and legal

Source originally integrated in RyzeMP's VanillaMine-based development branch at commit `df4ba29c27a144946a9ced96c859bbf0e257a688`, based on VanillaMine and PocketMine-MP work. Its licensing and attribution are retained; see [LICENSE](LICENSE) and [THIRD_PARTY.md](THIRD_PARTY.md). Minecraft worldgen data and game assets are **not** bundled in these releases.

Do not replace the PHP fallback or delete RyzeMP's source until the official binary, version lock and real-world terrain equivalence tests have passed.
