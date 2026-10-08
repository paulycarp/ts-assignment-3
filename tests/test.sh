#!/usr/bin/env bash
set -u

PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS+1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }

echo "======================================"
echo "    Student Test Suite - App CLI     "
echo "======================================"

APP="./app/app.sh"

if [ ! -f "$APP" ]; then
  echo "ERROR: Application binary $APP not found!"
  exit 1
fi

# Test 1: Help command
"$APP" help >/dev/null 2>&1
[[ $? -eq 0 ]] && pass "Test 1: help command returns exit code 0" || fail "Test 1: help command failed"

# Test 2: System-info command
"$APP" system-info >/dev/null 2>&1
[[ $? -eq 0 ]] && pass "Test 2: system-info command returns exit code 0" || fail "Test 2: system-info command failed"

# Test 3: Invalid command
"$APP" invalid-cmd >/dev/null 2>&1
[[ $? -eq 2 ]] && pass "Test 3: invalid command returns exit code 2" || fail "Test 3: invalid command should return exit code 2"

# Test 4: Check-host missing host
"$APP" check-host >/dev/null 2>&1
[[ $? -eq 2 ]] && pass "Test 4: check-host rejects missing host with exit code 2" || fail "Test 4: check-host should reject missing host with exit code 2"

# Test 5: Check-host valid host (localhost)
"$APP" check-host localhost >/dev/null 2>&1
rc=$?
[[ $rc -eq 0 || $rc -eq 1 ]] && pass "Test 5: check-host accepts valid host (localhost)" || fail "Test 5: check-host failed valid host unexpectedly"

# Test 6: Check-port missing port
"$APP" check-port localhost >/dev/null 2>&1
[[ $? -eq 2 ]] && pass "Test 6: check-port rejects missing port with exit code 2" || fail "Test 6: check-port should reject missing port with exit code 2"

# Test 7: Check-port non-numeric port
"$APP" check-port localhost abc >/dev/null 2>&1
[[ $? -eq 2 ]] && pass "Test 7: check-port rejects non-numeric port with exit code 2" || fail "Test 7: check-port should reject non-numeric port with exit code 2"

# Test 8: Check-port out-of-range port 0
"$APP" check-port localhost 0 >/dev/null 2>&1
[[ $? -eq 2 ]] && pass "Test 8: check-port rejects port 0 with exit code 2" || fail "Test 8: check-port should reject port 0 with exit code 2"

# Test 9: Check-port out-of-range port 65536
"$APP" check-port localhost 65536 >/dev/null 2>&1
[[ $? -eq 2 ]] && pass "Test 9: check-port rejects port 65536 with exit code 2" || fail "Test 9: check-port should reject port 65536 with exit code 2"

echo "======================================"
echo "Passed: $PASS | Failed: $FAIL"
echo "======================================"

[[ $FAIL -eq 0 ]]
