#!/usr/bin/env bash
# no4nn.sh — Android analysis toolchain installer
# Entry point estable; uso ofensivo exclusivamente autorizado.

set -Eeuo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=src/android_toolchain/core.sh
source "$ROOT_DIR/src/android_toolchain/core.sh"
android_toolchain_main "$@"
