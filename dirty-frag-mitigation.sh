#!/usr/bin/env bash
#
# dirty-frag-mitigation.sh
#
# Enable or disable the Dirty Frag mitigation for Ubuntu/Linux systems.
#
# Usage:
#   sudo ./dirty-frag-mitigation.sh enable
#   sudo ./dirty-frag-mitigation.sh disable
#   sudo ./dirty-frag-mitigation.sh status
#

set -euo pipefail

CONF_FILE="/etc/modprobe.d/dirty-frag.conf"

MODULES=(
  esp4
  esp6
  rxrpc
)

require_root() {
  if [[ "$EUID" -ne 0 ]]; then
    echo "[ERROR] Please run as root or with sudo."
    exit 1
  fi
}

enable_mitigation() {
  echo "[*] Enabling Dirty Frag mitigation..."

  cat > "$CONF_FILE" <<EOF
install esp4 /bin/false
install esp6 /bin/false
install rxrpc /bin/false
EOF

  echo "[*] Regenerating initramfs..."
  update-initramfs -u -k all

  echo "[*] Attempting to unload affected modules..."
  for mod in "${MODULES[@]}"; do
    if lsmod | grep -q "^${mod}\b"; then
      if rmmod "$mod" 2>/dev/null; then
        echo "  [+] Unloaded: $mod"
      else
        echo "  [!] Could not unload: $mod (possibly in use)"
      fi
    else
      echo "  [-] Not loaded: $mod"
    fi
  done

  echo
  check_status

  echo
  echo "[*] Mitigation enabled."
  echo "[*] If any modules are still loaded, reboot the system:"
  echo "    sudo reboot"
}

disable_mitigation() {
  echo "[*] Disabling Dirty Frag mitigation..."

  if [[ -f "$CONF_FILE" ]]; then
    rm -f "$CONF_FILE"
    echo "  [+] Removed $CONF_FILE"
  else
    echo "  [-] Mitigation file not present"
  fi

  echo "[*] Regenerating initramfs..."
  update-initramfs -u -k all

  echo
  echo "[*] Mitigation disabled."
  echo "[*] Reboot recommended to restore normal module loading:"
  echo "    sudo reboot"
}

check_status() {
  echo "[*] Checking module status..."

  local loaded=0

  for mod in "${MODULES[@]}"; do
    if grep -q "^${mod} " /proc/modules; then
      echo "  [VULNERABLE] Module loaded: $mod"
      loaded=1
    else
      echo "  [OK] Module not loaded: $mod"
    fi
  done

  echo

  if [[ -f "$CONF_FILE" ]]; then
    echo "[*] Mitigation config present: $CONF_FILE"
  else
    echo "[*] Mitigation config NOT present"
  fi

  echo

  if [[ "$loaded" -eq 0 ]]; then
    echo "[RESULT] Mitigation ACTIVE"
  else
    echo "[RESULT] System may still be vulnerable until reboot"
  fi
}

main() {
  require_root

  case "${1:-}" in
    enable)
      enable_mitigation
      ;;
    disable)
      disable_mitigation
      ;;
    status)
      check_status
      ;;
    *)
      echo "Usage:"
      echo "  sudo $0 enable"
      echo "  sudo $0 disable"
      echo "  sudo $0 status"
      exit 1
      ;;
  esac
}

main "$@"
