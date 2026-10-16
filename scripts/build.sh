#!/usr/bin/env bash
set -u

IMAGE_NAME="devops-tool"

echo "======================================"
echo "      Docker Build & Smoke Tests      "
echo "======================================"

if ! command -v docker >/dev/null 2>&1; then
  echo "WARNING: Docker CLI unavailable. Skipping Docker image build and smoke tests."
  exit 0
fi

echo "Building Docker image '$IMAGE_NAME'..."
if docker build -t "$IMAGE_NAME" . ; then
  echo "PASS: Docker image built successfully."
else
  echo "FAIL: Docker image build failed."
  exit 1
fi

echo "--------------------------------------"
echo "Running Docker smoke tests..."

# Smoke test 1: help
if docker run --rm "$IMAGE_NAME" help >/dev/null 2>&1; then
  echo "PASS: Docker smoke test (help) passed."
else
  echo "FAIL: Docker smoke test (help) failed."
  exit 1
fi

# Smoke test 2: system-info
if docker run --rm "$IMAGE_NAME" system-info >/dev/null 2>&1; then
  echo "PASS: Docker smoke test (system-info) passed."
else
  echo "FAIL: Docker smoke test (system-info) failed."
  exit 1
fi

# Smoke test 3: invalid command must fail (non-zero return)
docker run --rm "$IMAGE_NAME" invalid-command >/dev/null 2>&1
rc=$?
if [ $rc -ne 0 ]; then
  echo "PASS: Docker smoke test (invalid-command returned non-zero exit code $rc)."
else
  echo "FAIL: Docker smoke test (invalid-command should have returned non-zero exit code)."
  exit 1
fi

echo "======================================"
echo "All Docker Build & Smoke Tests Passed!"
exit 0
