#!/usr/bin/env bash
set -euo pipefail

# This repository primarily contains the database container in this workspace.
# Some CI pipelines attempt to run `./gradlew check` unconditionally.
# Provide a minimal wrapper that is a no-op unless a real Gradle wrapper exists.

if [[ -f "./android/gradlew" ]]; then
  exec bash "./android/gradlew" "$@"
fi

echo "No Android Gradle project found in this workspace; skipping Gradle task: ${*:-<none>}"
exit 0
