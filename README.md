# SecureProbe 1.0.0

A native desktop security workbench for Windows and Linux. Run authorized website assessments, inspect collected evidence, review module coverage, and keep scan history locally.

[Download the latest release](https://github.com/Sa3d-99/secureprobe_app/releases/latest) · [Source code](https://github.com/Sa3d-99/secureprobe) · [Report a problem](https://github.com/Sa3d-99/secureprobe/issues)

Installers appear in **Releases** after both platform builds and startup checks pass. If there is no published release yet, the first build is still being validated.

## Install

**Windows x64:** download the `-setup.exe` installer. It installs for your user and includes the Python engine and WebView2 installer. Python, Node.js, Rust, and Java are not required to run the included assessments. Update signatures authenticate app updates; they do not constitute a Microsoft Authenticode certificate.

**Kali Linux / Debian / Ubuntu x86_64:** download the `.deb`, then install it with:

```bash
sudo apt install ./SecureProbe_1.0.0_amd64.deb
```

Use the exact filename from the release. Launch SecureProbe from the applications menu. Installing through `apt` resolves declared desktop-library dependencies.

**Fedora / compatible RPM distributions x86_64:** download the `.rpm` and install it using your distribution’s package manager, for example `sudo dnf install ./SecureProbe-1.0.0-1.x86_64.rpm`. Use the filename from the release.

**Other desktop Linux distributions:** download the `.AppImage`:

```bash
chmod +x SecureProbe_1.0.0_amd64.AppImage
./SecureProbe_1.0.0_amd64.AppImage
```

If FUSE is unavailable, try `./SecureProbe_1.0.0_amd64.AppImage --appimage-extract-and-run`. Updates to an AppImage require a writable location. Native `.deb`/`.rpm` installations can be upgraded by installing the newer package when automatic installation is unavailable.

The initial architecture target is **x86_64 GNU/Linux with a graphical desktop**. AppImage improves portability but is not a guarantee for every distribution. Alpine/musl, ARM, very old distributions, and headless systems are not validated targets. See the release notes for actual test coverage.

## First assessment

1. Open **New Scan** and enter an HTTP or HTTPS URL you are authorized to test.
2. Select a profile, modules, request rate, and request budget. Private network targets require explicit opt-in.
3. Acknowledge authorization and start the assessment. Progress, pause, resume, and cancellation are available in the window.
4. Open **Findings** to inspect evidence, confidence, verification status, and remediation. **Reports** exports JSON through a native save dialog.

A completed scan does not certify that a website is secure. Failed, skipped, inconclusive, and untested checks remain unknown. Potential exposure is distinct from verified impact.

## Included functionality and limits

- The existing Python engine performs sixteen HTTP/TLS security checks. CLI and desktop share that engine.
- Scan history, evidence, settings, and a transactional CISA KEV catalog cache stay on your computer.
- The Tools page checks bundled file hashes and executable versions. Seven tool payloads are pinned for packaging: Nuclei, ProjectDiscovery httpx, Katana, ffuf, Trivy, Grype, and Gitleaks. **An available binary is not an integrated detection adapter.** These tools are not yet additional selectable desktop scan modules.
- Nmap, testssl.sh, standalone OpenSSL, and ZAP are not bundled in this initial build. The inventory records the unresolved licensing, packaging, or runtime requirements. Python’s native TLS checks remain available.
- CVE research currently uses CISA KEV. EPSS, automatic affected-version matching, and detection-rule updates are not available. Catalog membership never establishes target vulnerability.
- Native report export currently supports JSON. The Python scanner retains HTML, JSON, and text reporting. PDF export is not implemented.

## Updates

Open **Update Center** to check for new versions and approve installation. The app verifies update signatures before installing executable code. New source pushes trigger the release build workflow; a failed build does not become a public update. The first release is **1.0.0**, followed by increasing patch versions.

Vulnerability catalog synchronization is separate and explicitly requested in **Vulnerability Intelligence**. Bundled tool executables change only with an authenticated app release. User data is stored outside the installation folder: `~/.local/share/SecureProbe` on Linux and `%LOCALAPPDATA%\SecureProbe` on Windows.

## Project repositories

This repository contains downloads, release notes, and end-user documentation. Application source, tests, packaging scripts, tool manifests, and build workflows live in [Sa3d-99/secureprobe](https://github.com/Sa3d-99/secureprobe). Generated binaries and private scan reports are excluded from the source repository.

Only assess systems you own or have explicit authorization to test.

## Automatic Linux installer

Download the Bash installer, optionally inspect it, then run it as your normal user:

```bash
curl -fL https://raw.githubusercontent.com/Sa3d-99/secureprobe_app/main/install.sh -o install-secureprobe.sh
bash install-secureprobe.sh
```

It selects `.deb` on Kali/Debian/Ubuntu, `.rpm` on dnf/zypper systems, and a per-user AppImage otherwise. It installs missing `curl`/`minisign` packages through the distribution package manager, verifies a signed checksum manifest against the embedded release public key, verifies the selected payload, then installs. System package installation may ask for your sudo password. It never runs the graphical app as root.

Use `bash install-secureprobe.sh --appimage` for a per-user installation, or `--check` to inspect platform/dependency availability without changing anything. AppImage launch uses extraction mode so FUSE is not required. No Python, Node, Rust, Java, jq, or scanner-development toolchain is needed by this installer. A public release must exist before installation can complete.

The app icon is the cyber shield image supplied by the project owner.
