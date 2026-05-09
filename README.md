# dirty-frag-mitigation
# Dirty Frag Mitigation Script

A simple Bash utility to enable, disable, and verify mitigations for the Linux kernel local privilege escalation vulnerabilities collectively known as **Dirty Frag**.

The script automates Canonical's recommended temporary mitigation by blocking the affected kernel modules:

- `esp4`
- `esp6`
- `rxrpc`

until patched kernel packages are installed.

---

# Vulnerabilities

- CVE-2026-43284
- Pending/related Dirty Frag CVE affecting RxRPC

These vulnerabilities may allow:

- Local privilege escalation (LPE)
- Potential container escape scenarios
- Root access from unprivileged users

---

# Affected Systems

All currently supported Ubuntu releases are affected, including:

- Ubuntu 14.04 LTS
- Ubuntu 16.04 LTS
- Ubuntu 18.04 LTS
- Ubuntu 20.04 LTS
- Ubuntu 22.04 LTS
- Ubuntu 24.04 LTS
- Ubuntu 25.10
- Ubuntu 26.04 LTS

Other Linux distributions may also be vulnerable depending on kernel configuration.

---

# What the Script Does

## Enable Mitigation

When enabled, the script:

1. Creates:

```bash
/etc/modprobe.d/dirty-frag.conf
```

2. Blocks loading of vulnerable modules:

```bash
esp4
esp6
rxrpc
```

3. Regenerates initramfs:

```bash
update-initramfs -u -k all
```

4. Attempts to unload the vulnerable modules immediately.

---

## Disable Mitigation

When disabled, the script:

- Removes the mitigation configuration
- Regenerates initramfs
- Restores normal module loading after reboot

---

# Installation

Clone the repository:

```bash
git clone https://github.com/yzaraoui/dirty-frag-mitigation.git
cd dirty-frag-mitigation
```

Make the script executable:

```bash
chmod +x dirty-frag-mitigation.sh
```

---

# Usage

## Enable Mitigation

```bash
sudo ./dirty-frag-mitigation.sh enable
```

---

## Disable Mitigation

```bash
sudo ./dirty-frag-mitigation.sh disable
```

---

## Check Status

```bash
sudo ./dirty-frag-mitigation.sh status
```

---

# Example Output

```text
[*] Enabling Dirty Frag mitigation...
[*] Regenerating initramfs...
[*] Attempting to unload affected modules...
  [+] Unloaded: esp4
  [+] Unloaded: esp6
  [-] Not loaded: rxrpc

[RESULT] Mitigation ACTIVE
```

---

# Important Notes

## VPN / IPsec Impact

This mitigation disables:

- IPsec ESP support
- RxRPC support

Applications relying on these modules may stop functioning, including:

- StrongSwan
- IPsec VPNs
- AFS (Andrew File System)

---

## Reboot May Be Required

If the modules are actively in use, they cannot be unloaded immediately.

In this case, reboot the system:

```bash
sudo reboot
```

---

# Removing the Mitigation

Once your system receives patched kernel updates:

```bash
sudo ./dirty-frag-mitigation.sh disable
```

Then reboot if needed.

---

# Security References

## Canonical Advisory

https://ubuntu.com/blog/dirty-frag-linux-vulnerability-fixes-available

## Ubuntu CVE Tracker

https://ubuntu.com/security/CVE-2026-43284

---

# Disclaimer

This script provides a temporary mitigation only.

You should still install official kernel security updates as soon as they become available.

Use at your own risk.

---

# License

MIT License
