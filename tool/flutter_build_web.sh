#!/usr/bin/env bash
# Builds Flutter web on Vercel (Linux) or any CI. Clones stable SDK into .flutter-sdk.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FLUTTER_DIR="${ROOT}/.flutter-sdk"
if [[ ! -x "${FLUTTER_DIR}/bin/flutter" ]]; then
  rm -rf "${FLUTTER_DIR}"
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"
export FLUTTER_ROOT="${FLUTTER_DIR}"

flutter config --enable-web --no-analytics
flutter precache --web
flutter pub get

if [[ -n "${BASE_HREF:-}" ]]; then
  flutter build web --release --base-href "${BASE_HREF}"
else
  flutter build web --release
fi
