#!/usr/bin/env bash
set -u

ERRORS=0

echo "======================================"
echo "      Lint & Syntax Validator        "
echo "======================================"

# Check required project files
for file in README.md app/app.sh Dockerfile compose.yaml .dockerignore .github/workflows/ci.yml; do
  if [ -f "$file" ]; then
    echo "PASS: File exists: $file"
  else
    echo "FAIL: File missing: $file"
    ERRORS=$((ERRORS + 1))
  fi
done

# Run bash -n syntax check on shell scripts
echo "--------------------------------------"
echo "Checking Bash syntax..."
for script in app/*.sh scripts/*.sh tests/*.sh; do
  [ -f "$script" ] || continue
  if bash -n "$script" >/dev/null 2>&1; then
    echo "PASS: Syntax OK: $script"
  else
    echo "FAIL: Syntax error in $script"
    ERRORS=$((ERRORS + 1))
  fi
done

# Optional ShellCheck integration
if command -v shellcheck >/dev/null 2>&1; then
  echo "--------------------------------------"
  echo "Running ShellCheck analysis..."
  for script in app/*.sh scripts/*.sh tests/*.sh; do
    [ -f "$script" ] || continue
    shellcheck -e SC2015 "$script" || true
  done
fi

echo "======================================"
if [ "$ERRORS" -eq 0 ]; then
  echo "Linting Passed Successfully (0 errors)"
  exit 0
else
  echo "Linting Failed ($ERRORS error(s) detected)"
  exit 1
fi
