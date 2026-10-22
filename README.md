<div align="center">

<img src="secureprobe.png" width="110" alt="SecureProbe app icon">

# SecureProbe

**Desktop security assessments for Windows and Linux**

Version **1.0.0** · Native desktop application · Local scan history and evidence

### Download the app

**Windows installer:** the native build is being validated. Its download button will appear when the file is ready.

[![Download for Kali, Debian and Ubuntu](https://img.shields.io/badge/Download-Kali%20%2F%20Debian%20%2F%20Ubuntu-0891B2?style=for-the-badge&logo=linux&logoColor=white)](https://github.com/Sa3d-99/secureprobe_app/releases/latest/download/SecureProbe.deb)

[![Download Linux RPM](https://img.shields.io/badge/Download-Fedora%20%2F%20RPM-2563EB?style=for-the-badge&logo=linux&logoColor=white)](https://github.com/Sa3d-99/secureprobe_app/releases/latest/download/SecureProbe.rpm)

[![Download Linux AppImage](https://img.shields.io/badge/Download-Linux%20AppImage-0891B2?style=for-the-badge&logo=linux&logoColor=white)](https://github.com/Sa3d-99/secureprobe_app/releases/latest/download/SecureProbe.AppImage)

**x86_64 / 64-bit PCs.** These buttons download built applications. Python, Node.js, Rust, and development tools are not required.

**Linux release 1.0.0 is available.** The initial packages target Kali rolling and Debian 12+; the Ubuntu 22.04 build is still being validated.

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

The installer is also available directly as [install.sh](install.sh) in this repository. Run it with **sudo bash install.sh**. It returns to your desktop account for the app files, so they remain owned by you.

This installer puts the AppImage, bundled Python engine, tools, and resources in SecureProbe’s own folder for your user. It verifies the signed checksum manifest and the selected download before installation. System package installation may request your administrator password. The script installs the built desktop application; it does not run the app from source.

[![Download automatic Linux installer](https://img.shields.io/badge/Download-Automatic%20Linux%20Installer-475569?style=for-the-badge&logo=linux&logoColor=white)](https://github.com/Sa3d-99/secureprobe_app/releases/latest/download/install.sh)

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

## Uninstall and clean storage

Close SecureProbe, then run the downloaded **uninstall.sh** as your desktop user for an automatic Linux installation. It removes the app and SecureProbe’s scan history, evidence, settings, cache, and bundled tools. Shared system libraries and other applications are retained. Native packages can also be removed with your system’s software manager.

[![Download Linux uninstaller](https://img.shields.io/badge/Download-Linux%20Uninstaller-DC2626?style=for-the-badge&logo=linux&logoColor=white)](https://github.com/Sa3d-99/secureprobe_app/releases/latest/download/uninstall.sh)

The uninstaller is also available directly as [uninstall.sh](uninstall.sh) in this repository.

Windows uses its registered uninstaller in **Settings → Apps**. Choose **Delete application data** to clean its stored scans and settings too.

## Updates and privacy

Open **Update Center** to check for a new app version and approve installation. Executable updates require a valid signature. Vulnerability catalog synchronization is separate, under **Vulnerability Intelligence**.

Scans, findings, evidence, and settings remain on your computer. Upgrades preserve the workspace outside the app installation folder.

The app icon is the cyber shield image supplied by the project owner.
