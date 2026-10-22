<div align="center">

# SecureProbe

**Desktop security assessments for Windows and Linux**

Version **1.0.0** · Native desktop application · Local scan history and evidence

### Download the app

[![Download Windows installer](https://img.shields.io/badge/Download-Windows%20Installer-2563EB?style=for-the-badge&logo=windows&logoColor=white)](https://github.com/Sa3d-99/secureprobe_app/releases/latest/download/SecureProbe-Setup.exe)

[![Download for Kali, Debian and Ubuntu](https://img.shields.io/badge/Download-Kali%20%2F%20Debian%20%2F%20Ubuntu-0891B2?style=for-the-badge&logo=linux&logoColor=white)](https://github.com/Sa3d-99/secureprobe_app/releases/latest/download/SecureProbe.deb)

[![Download Linux RPM](https://img.shields.io/badge/Download-Fedora%20%2F%20RPM-2563EB?style=for-the-badge&logo=linux&logoColor=white)](https://github.com/Sa3d-99/secureprobe_app/releases/latest/download/SecureProbe.rpm)

[![Download Linux AppImage](https://img.shields.io/badge/Download-Linux%20AppImage-0891B2?style=for-the-badge&logo=linux&logoColor=white)](https://github.com/Sa3d-99/secureprobe_app/releases/latest/download/SecureProbe.AppImage)

**x86_64 / 64-bit PCs.** These buttons download built applications. Python, Node.js, Rust, and development tools are not required.

*Downloads become available after the first release passes its Windows and Linux build checks. Until then, a download button may report that the file is not available yet.*

</div>

## Install and open

| Your computer | What to download | Installation |
| --- | --- | --- |
| Windows | Windows Installer | Open **SecureProbe-Setup.exe**, follow the installer, then open **SecureProbe** from the Start menu. |
| Kali, Debian, Ubuntu | Debian package | Open **SecureProbe.deb** with your system’s package installer. Allow it to install required desktop libraries. |
| Compatible RPM Linux | RPM package | Open **SecureProbe.rpm** with your system’s software installer. |
| Other desktop GNU/Linux | AppImage | Save **SecureProbe.AppImage**, enable execution in its file properties, then open it. |

The app name stays **SecureProbe**. Its version appears inside the app. Download filenames do not contain the version number.

Linux support targets x86_64 GNU/Linux desktops. Compatibility with every distribution, Alpine/musl, ARM, or very old systems is not guaranteed. AppImage needs a writable location for automatic replacement; native packages can be upgraded with a newer package.

<details>
<summary><strong>Optional: automatic Linux installer</strong></summary>

This installer selects a native package or installs an AppImage for your user. It verifies the signed checksum manifest and the selected download before installation. System package installation may request your administrator password. The script installs the built desktop application; it does not run the app from source.

[![Download automatic Linux installer](https://img.shields.io/badge/Download-Automatic%20Linux%20Installer-475569?style=for-the-badge&logo=linux&logoColor=white)](https://github.com/Sa3d-99/secureprobe_app/releases/latest/download/install-secureprobe.sh)

</details>

## Start an assessment

1. Open **New Scan** and enter a website you own or are authorized to assess.
2. Choose the profile, scanner modules, request rate, and request budget.
3. Confirm authorization, then select **Start assessment**.
4. Watch progress in the window. Pause, resume, or cancel when needed.
5. Open **Findings** to review evidence and remediation, or **Reports** to save the results.

## What the app includes

- Sixteen HTTP/TLS security checks using the shared scanning engine.
- Local scan history, findings, evidence, coverage, comparisons, and JSON export.
- Scope validation, private-network opt-in, request pacing and budgets.
- A tool inventory with hash verification and executable health checks.
- A local CISA KEV catalog for vulnerability research and offline search after synchronization.
- Signed application updates through **Update Center**.

A completed scan is not a security certification. Failed, skipped, inconclusive, and untested checks remain unknown. Potential exposure is distinct from confirmed impact.

<details>
<summary><strong>Current feature coverage</strong></summary>

Seven tool binaries are prepared for packaging: Nuclei, ProjectDiscovery httpx, Katana, ffuf, Trivy, Grype, and Gitleaks. Their inventory and health checks are available; they do not yet provide additional selectable desktop detection adapters.

Nmap, testssl.sh, standalone OpenSSL, and ZAP are not bundled in this initial build. EPSS, automatic affected-version matching, detection-rule synchronization, and PDF export are not available. CVE catalog membership never proves that a target is vulnerable.

</details>

## Updates and privacy

Open **Update Center** to check for a new app version and approve installation. Executable updates require a valid signature. Vulnerability catalog synchronization is separate, under **Vulnerability Intelligence**.

Scans, findings, evidence, and settings remain on your computer. Upgrades preserve the workspace outside the app installation folder.

The app icon is the cyber shield image supplied by the project owner.
