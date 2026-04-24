#!/usr/bin/env bash
set -euo pipefail

FLUTTER_ROOT_DEFAULT="${HOME}/flutter"
FLUTTER_ROOT="${FLUTTER_ROOT:-$FLUTTER_ROOT_DEFAULT}"

if ! command -v flutter >/dev/null 2>&1; then
  if [ ! -d "${FLUTTER_ROOT}" ]; then
    echo "Flutter not found. Cloning stable Flutter SDK to ${FLUTTER_ROOT}..."
    git clone https://github.com/flutter/flutter.git --branch stable --depth 1 "${FLUTTER_ROOT}"
  fi
  export PATH="${FLUTTER_ROOT}/bin:${PATH}"
fi

flutter config --no-analytics
flutter pub get
flutter build web --release
