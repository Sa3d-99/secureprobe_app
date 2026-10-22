#!/usr/bin/env bash
# Remove only SecureProbe and its own workspace. Shared OS libraries are retained.
set -euo pipefail
fail() { printf 'SecureProbe: %s\n' "$*" >&2; exit 1; }
keep_data=false
check=false
for option in "$@"; do
    case $option in
        --keep-data) keep_data=true ;;
        --check) check=true ;;
        -h|--help) printf 'Usage: bash uninstall.sh [--keep-data] [--check]\nDefault: remove SecureProbe and its scan history, evidence, cache and settings.\n'; exit 0 ;;
        *) fail "Unknown option: $option" ;;
    esac
done
[[ $(uname -s) == Linux ]] || fail 'This uninstaller supports Linux only.'
(( EUID != 0 )) || fail 'Run this as your desktop user, without sudo. System-package removal requests elevation when needed.'
data_dir=${XDG_DATA_HOME:-$HOME/.local/share}
[[ $data_dir == /* && $data_dir != *$'\n'* && $data_dir != *'"'* && $data_dir != *'%'* ]] || fail 'Unsupported XDG_DATA_HOME path.'
workspace="$data_dir/SecureProbe"
install_dir="$workspace/app"
webview_dir="$data_dir/com.sa3d.secureprobe"
if [[ -e $webview_dir || -L $webview_dir ]]; then
    [[ $(stat -c %u -- "$webview_dir") == "$EUID" ]] || fail 'Browser storage is owned by a different user.'
fi
[[ ! -L $workspace ]] || fail 'SecureProbe workspace is a symbolic link; inspect its destination before removal.'
if [[ -d $workspace ]]; then
    [[ $(stat -c %u -- "$workspace") == "$EUID" ]] || fail 'Workspace is owned by a different user.'
    if ! $keep_data; then
        managed=false
        if [[ -f $workspace/.secureprobe-workspace ]] && [[ $(cat "$workspace/.secureprobe-workspace") == com.sa3d.secureprobe:v1 ]]; then
            managed=true
        elif [[ -f $workspace/secureprobe.sqlite3 && ! -L $workspace/secureprobe.sqlite3 ]] \
            && grep -aq 'CREATE TABLE assessments' "$workspace/secureprobe.sqlite3" \
            && grep -aq 'CREATE TABLE finding_reviews' "$workspace/secureprobe.sqlite3"; then
            managed=true # Legacy SecureProbe workspace predating the ownership marker.
        fi
        $managed || fail 'Workspace is not recognized as SecureProbe-owned; no files were removed.'
    fi
fi

# Do not kill unrelated processes or remove live scan evidence.
for executable in /proc/[0-9]*/exe; do
    current=$(readlink -- "$executable" 2>/dev/null || true)
    if [[ $current == /usr/bin/secureprobe-desktop || $current == /usr/bin/secureprobe-backend ]]; then
        fail 'Close SecureProbe before uninstalling it.'
    fi
    environment="${executable%/exe}/environ"
    if [[ -r $environment ]]; then
        while IFS= read -r -d '' entry; do
            [[ $entry != "APPIMAGE=$install_dir/SecureProbe.AppImage" ]] || fail 'Close SecureProbe before uninstalling it.'
        done < <(cat "$environment" 2>/dev/null)
    fi
done
if $check; then
    printf 'App folder: %s\nWorkspace cleanup: %s\nShared system dependencies will be retained.\n' "$install_dir" "$workspace"
    exit 0
fi
privileged() {
    command -v sudo >/dev/null 2>&1 || fail 'sudo is required to remove the native system package.'
    sudo -- "$@"
}
if command -v dpkg-query >/dev/null 2>&1 && [[ $(dpkg-query -W -f='${Status}' secure-probe 2>/dev/null || true) == 'install ok installed' ]]; then
    privileged apt-get remove -y secure-probe
elif command -v rpm >/dev/null 2>&1 && rpm -q secure-probe >/dev/null 2>&1; then
    if command -v dnf >/dev/null 2>&1; then
        privileged dnf --setopt=clean_requirements_on_remove=False remove -y secure-probe
    elif command -v zypper >/dev/null 2>&1; then
        privileged zypper --non-interactive remove secure-probe
    else
        fail 'Remove the secure-probe RPM with your package manager, then rerun this uninstaller.'
    fi
fi
launcher="$HOME/.local/bin/secureprobe"
desktop="$data_dir/applications/secureprobe.desktop"
uninstall_entry="$data_dir/applications/secureprobe-uninstall.desktop"
if [[ -f $launcher ]] && grep -Fqx -- "# SecureProbe managed launcher: $install_dir" "$launcher"; then
    rm -f -- "$launcher"
fi
for entry in "$desktop" "$uninstall_entry"; do
    if [[ -f $entry ]] && grep -Fqx -- "X-SecureProbe-Install=$install_dir" "$entry"; then rm -f -- "$entry"; fi
done
icon="$data_dir/icons/hicolor/256x256/apps/secureprobe.png"
if [[ -f $install_dir/icon.sha256 && -f $icon ]]; then
    expected=$(cat "$install_dir/icon.sha256")
    actual=$(sha256sum -- "$icon"); actual=${actual%% *}
    if [[ $expected == "$actual" ]]; then rm -f -- "$icon"; fi
fi
rm -rf -- "$webview_dir"
if $keep_data; then
    rm -f -- "$install_dir/SecureProbe.AppImage" "$install_dir/icon.sha256" "$install_dir/uninstall.sh"
    rmdir -- "$install_dir" 2>/dev/null || true
    printf 'SecureProbe removed. Scan history and evidence were kept in %s.\n' "$workspace"
else
    # Exact app-owned directory only; never remove the parent data directory.
    rm -rf -- "$workspace"
    printf 'SecureProbe and its stored scans, evidence, cache and settings were removed.\n'
fi
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$data_dir/applications" 2>/dev/null || true
fi
