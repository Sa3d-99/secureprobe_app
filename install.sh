#!/usr/bin/env bash
# Install an authenticated SecureProbe release. No Python, Node or Rust required.
set -euo pipefail

readonly RELEASE_URL='https://github.com/Sa3d-99/secureprobe_app/releases/latest/download'
readonly SIGNING_KEY='RWSpaNRqhEnJuFRHG9RyLD01MbfTlC32R/kK4wcmfbIDuuFh2Okqz6X6' # gitleaks:allow -- public verification key

fail() { printf 'SecureProbe: %s\n' "$*" >&2; exit 1; }
usage() {
    printf 'Usage: bash install.sh [--appimage | --deb | --rpm | --check]\n'
    printf 'Default: self-contained AppImage installation for your user.\n'
    printf 'Also supports sudo bash install.sh from your desktop account.\n'
}
privileged() {
    if (( EUID == 0 )); then "$@";
    elif command -v sudo >/dev/null 2>&1; then sudo -- "$@";
    else fail 'Installing system packages requires root or sudo. Try --appimage after installing curl and minisign.';
    fi
}

mode=auto
case "${1:-}" in
    '') ;;
    --appimage) mode=appimage ;;
    --deb) mode=deb ;;
    --rpm) mode=rpm ;;
    --check) mode=check ;;
    -h|--help) usage; exit 0 ;;
    *) usage; exit 2 ;;
esac
(( $# <= 1 )) || { usage; exit 2; }
[[ $(uname -s) == Linux ]] || fail 'This installer supports Linux only.'
case "$(uname -m)" in x86_64|amd64) ;; *) fail 'This release supports x86_64 only; ARM packages are not available.' ;; esac
command -v apt-get >/dev/null 2>&1 && package_manager=apt || package_manager=unknown
if [[ $package_manager == unknown ]]; then
    for candidate in dnf zypper pacman; do
        if command -v "$candidate" >/dev/null 2>&1; then package_manager=$candidate; break; fi
    done
fi
if [[ $mode == auto ]]; then
    mode=appimage
fi
if [[ $mode == check ]]; then
    printf 'Linux x86_64 detected; package manager: %s\n' "$package_manager"
    for dependency in curl sha256sum base64 tar; do
        command -v "$dependency" >/dev/null 2>&1 || printf 'Required dependency missing: %s\n' "$dependency"
    done
    exit 0
fi
[[ $mode != deb || $package_manager == apt ]] || fail '--deb requires apt-get.'
[[ $mode != rpm || $package_manager == dnf || $package_manager == zypper ]] || fail '--rpm requires dnf or zypper.'

if [[ $mode == appimage ]]; then
    if (( EUID == 0 )); then
        [[ -n ${SUDO_USER:-} && ${SUDO_UID:-} =~ ^[0-9]+$ && ${SUDO_UID:-0} != 0 ]] \
            || fail 'Use sudo bash install.sh from your desktop account, or select --deb / --rpm for a system package.'
        [[ $(id -u -- "$SUDO_USER") == "$SUDO_UID" ]] || fail 'Cannot identify the desktop user who invoked sudo.'
        printf 'Installing SecureProbe for desktop user %s.\n' "$SUDO_USER"
        # Never create a root-owned workspace or use root's HOME/XDG paths.
        exec sudo -H -u "$SUDO_USER" -- env -u XDG_DATA_HOME -u XDG_CONFIG_HOME -u XDG_CACHE_HOME \
            bash "$(readlink -f -- "${BASH_SOURCE[0]}")" "$@"
    fi
fi
missing=()
if ! command -v curl >/dev/null 2>&1; then missing+=(curl); fi
if (( ${#missing[@]} )); then
    printf 'Installing required download tools: %s\n' "${missing[*]}"
    case $package_manager in
        apt) privileged apt-get update; privileged apt-get install -y "${missing[@]}" ;;
        dnf) privileged dnf install -y "${missing[@]}" ;;
        zypper) privileged zypper --non-interactive install "${missing[@]}" ;;
        pacman) privileged pacman -S --needed --noconfirm "${missing[@]}" ;;
        *) fail 'Install curl and minisign using your distribution package manager, then rerun this installer.' ;;
    esac
fi
for dependency in sha256sum base64; do command -v "$dependency" >/dev/null 2>&1 || fail "Missing $dependency (GNU coreutils)."; done

temporary_dir=$(mktemp -d -t secureprobe-install.XXXXXXXX)
trap 'rm -rf -- "$temporary_dir"' EXIT
fetch() {
    curl --fail --silent --show-error --location --proto '=https' --proto-redir '=https' \
        --retry 3 --connect-timeout 15 --max-time 900 "$RELEASE_URL/$1" --output "$temporary_dir/$1" \
        || fail "Cannot download $1. Check connectivity and whether a public release exists."
}
# Ubuntu 22.04 has no minisign package. Use an upstream static verifier temporarily.
# The pinned hash authenticates these fixed bytes before they can be executed.
verifier=minisign
if ! command -v minisign >/dev/null 2>&1; then
    command -v tar >/dev/null 2>&1 || fail 'GNU tar is required to prepare the signature verifier.'
    verifier_archive="$temporary_dir/minisign.tar.gz"
    curl --fail --silent --show-error --location --proto '=https' --proto-redir '=https' \
        --retry 3 --connect-timeout 15 --max-time 90 \
        https://github.com/jedisct1/minisign/releases/download/0.12/minisign-0.12-linux.tar.gz \
        --output "$verifier_archive" || fail 'Cannot download the pinned signature verifier.'
    printf '%s  %s\n' '9a599b48ba6eb7b1e80f12f36b94ceca7c00b7a5173c95c3efc88d9822957e73' "$verifier_archive" \
        | sha256sum --check --status || fail 'Signature verifier integrity check failed.'
    verifier="$temporary_dir/minisign"
    tar -xOzf "$verifier_archive" minisign-linux/x86_64/minisign > "$verifier" \
        || fail 'Cannot prepare the signature verifier.'
    chmod 700 "$verifier"
fi
fetch SHA256SUMS
fetch SHA256SUMS.sig
base64 --decode < "$temporary_dir/SHA256SUMS.sig" > "$temporary_dir/checksums.minisig" || fail 'Invalid checksum signature encoding.'
"$verifier" -Vm "$temporary_dir/SHA256SUMS" -P "$SIGNING_KEY" -x "$temporary_dir/checksums.minisig" \
    || fail 'Release signature verification failed. Nothing was installed.'
verified_download() {
    local asset=$1 checksum
    checksum=$(grep -E "^[a-f0-9]{64}  ${asset//./\\.}$" "$temporary_dir/SHA256SUMS") || fail "No signed checksum for $asset."
    [[ $(printf '%s\n' "$checksum" | wc -l) -eq 1 ]] || fail "Duplicate checksum for $asset."
    fetch "$asset"
    (cd "$temporary_dir" && printf '%s\n' "$checksum" | sha256sum --check --status) || fail "Checksum mismatch for $asset."
}

case $mode in
    deb)
        asset=SecureProbe.deb
        verified_download "$asset"
        privileged apt-get install -y "$temporary_dir/$asset"
        ;;
    rpm)
        asset=SecureProbe.rpm
        verified_download "$asset"
        if [[ $package_manager == dnf ]]; then privileged dnf install -y "$temporary_dir/$asset";
        else privileged zypper --non-interactive install "$temporary_dir/$asset"; fi
        ;;
    appimage)
        verified_download SecureProbe.AppImage
        verified_download secureprobe.png
        verified_download uninstall.sh
        data_dir=${XDG_DATA_HOME:-$HOME/.local/share}
        [[ $data_dir == /* && $data_dir != *$'\n'* && $data_dir != *'"'* && $data_dir != *'%'* ]] || fail 'Unsupported XDG_DATA_HOME path.'
        install_dir="$data_dir/SecureProbe/app"
        mkdir -p -- "$install_dir" "$data_dir/applications" "$data_dir/icons/hicolor/256x256/apps" "$HOME/.local/bin"
        printf 'com.sa3d.secureprobe:v1\n' > "$data_dir/SecureProbe/.secureprobe-workspace"
        install -m 755 "$temporary_dir/SecureProbe.AppImage" "$install_dir/SecureProbe.AppImage.new"
        mv -f -- "$install_dir/SecureProbe.AppImage.new" "$install_dir/SecureProbe.AppImage"
        install -m 755 "$temporary_dir/uninstall.sh" "$install_dir/uninstall.sh"
        icon_digest=$(sha256sum "$temporary_dir/secureprobe.png"); icon_digest=${icon_digest%% *}
        printf '%s\n' "$icon_digest" > "$install_dir/icon.sha256"
        install -m 644 "$temporary_dir/secureprobe.png" "$data_dir/icons/hicolor/256x256/apps/secureprobe.png"
        {
            printf '#!/usr/bin/env bash\n'
            printf '# SecureProbe managed launcher: %s\n' "$install_dir"
            printf 'exec %q --appimage-extract-and-run "$@"\n' "$install_dir/SecureProbe.AppImage"
        } > "$HOME/.local/bin/secureprobe"
        chmod 755 "$HOME/.local/bin/secureprobe"
        cat > "$data_dir/applications/secureprobe.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=SecureProbe
Comment=Local security assessment workbench
Exec="$HOME/.local/bin/secureprobe"
Icon=$data_dir/icons/hicolor/256x256/apps/secureprobe.png
Terminal=false
Categories=Development;Security;
X-SecureProbe-Install=$install_dir
DESKTOP
        # Remove the old menu shortcut on upgrades, preserving unrelated entries.
        legacy_uninstaller="$data_dir/applications/secureprobe-uninstall.desktop"
        if [[ -f $legacy_uninstaller ]] && grep -Fqx -- "X-SecureProbe-Install=$install_dir" "$legacy_uninstaller"; then
            rm -f -- "$legacy_uninstaller"
        fi
        if command -v update-desktop-database >/dev/null 2>&1; then
            update-desktop-database "$data_dir/applications" || true
        fi
        ;;
esac
printf 'SecureProbe installed. Open it from your applications menu. Scan data is preserved during upgrades.\n'
