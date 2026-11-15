#!/usr/bin/env bash
# Build stable cross-platform native worldgen binaries without rounding-changing FMA.
# The PHP terrain generator requires bit-identical multiplication/addition on every target.
set -euo pipefail
cd "$(dirname "$0")/.."
VERSION="${1:?Release version required (for example v0.1.0)}"
shift
TARGETS=("$@")
if (( ${#TARGETS[@]} == 0 )); then
  TARGETS=(linux/amd64 linux/arm64 windows/amd64 darwin/amd64 darwin/arm64)
fi
export CGO_ENABLED=0
export GOFLAGS=-trimpath
GCFLAGS='github.com/RyzeCompany/RyzeVanillaGen/...=-d=fmahash=n'
mkdir -p dist
for target in "${TARGETS[@]}"; do
  os="${target%/*}"
  arch="${target#*/}"
  suffix=''
  if [[ "$os" == windows ]]; then suffix='.exe'; fi
  name="vanillagen-${os}-${arch}${suffix}"
  echo "Building ${name} (release ${VERSION})"
  GOOS="$os" GOARCH="$arch" go build -gcflags "$GCFLAGS" \
    -ldflags "-s -w -X main.version=${VERSION}" -o "dist/${name}" . 2> >(grep -Ev '^(fmahash triggered|\[DISABLED\]|# github.com/)' >&2 || true)
  test -s "dist/${name}"
  # Reject fused instructions in our code: they silently change terrain
  # rounding between the Go and PHP implementations.
  if go tool objdump -s 'github.com/RyzeCompany/RyzeVanillaGen' "dist/${name}" 2>/dev/null | \
    grep -Eq '\b(FMADD|FMSUB|FNMADD|FNMSUB|VFMADD|VFMSUB|VFNMADD|VFNMSUB)[A-Z0-9]*\b'; then
    echo "Forbidden fused multiply-add detected in ${name}" >&2
    exit 1
  fi
  if [[ "$os" == linux && "$arch" == amd64 ]]; then
    actual="$(./dist/"$name" -version)"
    expected="vanillagen ${VERSION} protocol 7 algorithm 4"
    [[ "$actual" == "$expected" ]] || { echo "Wrong native API: ${actual}" >&2; exit 1; }
  fi
  (cd dist && sha256sum "$name" > "$name.sha256")
done
(cd dist && sha256sum vanillagen-* | grep -v -E '\.sha256:' | grep -v '\.sha256  ' > SHA256SUMS)
