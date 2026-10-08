#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "DevOps Application Tool v1.0"
  echo "Usage: ./app.sh <command> [arguments]"
  echo
  echo "Commands:"
  echo "  system-info               Display system information"
  echo "  check-host <host>         Resolve and check host reachability"
  echo "  check-port <host> <port>  Validate port and check TCP connection"
  echo "  help                      Display usage information"
}

cmd_system_info() {
  echo "=========================================="
  echo "          SYSTEM INFORMATION              "
  echo "=========================================="
  echo "Hostname:                 $(hostname 2>/dev/null || echo "${HOSTNAME:-localhost}")"
  echo "Current User:             $(whoami 2>/dev/null || echo "${USER:-unknown}")"
  echo "Date / Time:              $(date '+%Y-%m-%d %H:%M:%S %Z' 2>/dev/null || echo "Unknown")"
  echo "Operating System:         $(uname -o 2>/dev/null || uname -s 2>/dev/null || echo "Linux")"
  echo "Kernel Version:           $(uname -r 2>/dev/null || echo "Unknown")"
  echo "Uptime:                   $(uptime 2>/dev/null || echo "Active")"
  echo "Working Directory:        $(pwd)"
  echo "=========================================="
  exit 0
}

cmd_check_host() {
  local host="${1:-}"
  if [ -z "$host" ]; then
    echo "Error: Host argument is required." >&2
    echo "Usage: ./app.sh check-host <host>" >&2
    exit 2
  fi

  echo "Checking host: $host"
  local resolved_ip=""
  if command -v getent >/dev/null 2>&1; then
    resolved_ip=$(getent hosts "$host" 2>/dev/null | awk '{print $1}' | head -n 1 || true)
  fi
  if [ -z "$resolved_ip" ] && command -v nslookup >/dev/null 2>&1; then
    resolved_ip=$(nslookup "$host" 2>/dev/null | awk '/Address:/ {print $2}' | tail -n 1 || true)
  fi
  if [ -z "$resolved_ip" ]; then
    resolved_ip="$host"
  fi

  echo "Resolved IP: ${resolved_ip:-Unknown}"

  if command -v ping >/dev/null 2>&1; then
    if ping -c 1 -W 2 "$host" >/dev/null 2>&1 || ping -n 1 -w 2000 "$host" >/dev/null 2>&1; then
      echo "Host $host is REACHABLE."
      exit 0
    else
      echo "Host $host is UNREACHABLE."
      exit 1
    fi
  else
    echo "Host $host checked."
    exit 0
  fi
}

cmd_check_port() {
  local host="${1:-}"
  local port="${2:-}"

  if [ -z "$host" ] || [ -z "$port" ]; then
    echo "Error: Host and port arguments are required." >&2
    echo "Usage: ./app.sh check-port <host> <port>" >&2
    exit 2
  fi

  if ! [[ "$port" =~ ^[0-9]+$ ]]; then
    echo "Error: Port must be a numeric integer." >&2
    exit 2
  fi

  if [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
    echo "Error: Port must be an integer between 1 and 65535." >&2
    exit 2
  fi

  echo "Checking TCP port $port on host $host..."
  if command -v nc >/dev/null 2>&1; then
    if nc -z -w 2 "$host" "$port" 2>/dev/null; then
      echo "Port $port on $host is OPEN."
      exit 0
    else
      echo "Port $port on $host is CLOSED or TIMED OUT."
      exit 1
    fi
  else
    if (echo > "/dev/tcp/$host/$port") 2>/dev/null; then
      echo "Port $port on $host is OPEN."
      exit 0
    else
      echo "Port $port on $host is CLOSED or TIMED OUT."
      exit 1
    fi
  fi
}

if [ $# -lt 1 ]; then
  echo "Error: Command argument missing." >&2
  usage >&2
  exit 2
fi

COMMAND="$1"
shift || true

case "$COMMAND" in
  system-info)
    cmd_system_info
    ;;
  check-host)
    cmd_check_host "$@"
    ;;
  check-port)
    cmd_check_port "$@"
    ;;
  help|--help|-h)
    usage
    exit 0
    ;;
  *)
    echo "Error: Unknown command '$COMMAND'." >&2
    usage >&2
    exit 2
    ;;
esac
