#!/usr/bin/env bash

VERSION="2.6.0"
SCRIPT_NAME="${0##*/}"
SCRIPT_DIR="$(CDPATH= cd "$(dirname "$0")" && pwd -P)"
BLACKLIST_FILE="$SCRIPT_DIR/blacklist.txt"

# Color codes
if [[ -t 1 && "${TERM:-}" != "dumb" ]]; then
    RED=$'\033[31m'
    GREEN=$'\033[32m'
    YELLOW=$'\033[33m'
    BLUE=$'\033[34m'
    BOLD=$'\033[1m'
    RESET=$'\033[0m'
else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    RESET=""
fi

TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/s23-vulkan.XXXXXX") || {
    echo "Failed to create a temporary directory."
    exit 1
}
ALL_PACKAGES="$TEMP_DIR/all_packages.txt"
APP_TO_RESTART="$TEMP_DIR/app_to_restart.txt"
FORCE_STOP_ERRORS="$TEMP_DIR/force_stop_errors.log"
RUNNING_APPS="$TEMP_DIR/running_apps.log"
TEMP_PACKAGES="$TEMP_DIR/temp_packages.txt"
KEYBOARD_PACKAGES="$TEMP_DIR/keyboard_packages.txt"
FILTERED_PACKAGES="$TEMP_DIR/filtered_packages.txt"
EXCLUDED_PACKAGES="$TEMP_DIR/excluded_packages.txt"

INTERACTIVE=false
skip_clear=false

cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

pause_if_interactive() {
    if [ "$INTERACTIVE" = true ]; then
        read -n1 -s -r -p "Press any key to return to the menu..."
    fi
}

print_error() {
    printf '%b%s%b\n' "$RED" "[ERROR] $*" "$RESET"
}

print_success() {
    printf '%b%s%b\n' "$GREEN" "[OK] $*" "$RESET"
}

print_warning() {
    printf '%b%s%b\n' "$YELLOW" "[WARN] $*" "$RESET"
}

check_commands() {
    local missing=false
    local cmd

    for cmd in "$@"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            print_error "$cmd not found. Please install it."
            missing=true
        fi
    done

    if [ "$missing" = true ]; then
        return 1
    fi
    return 0
}

check_device() {
    check_commands adb awk grep sort sed cut paste tr || return 1

    if ! adb get-state >/dev/null 2>&1; then
        print_error "No device detected. Please connect your device and enable USB debugging."
        return 1
    fi

    return 0
}

capture_device_state() {
    auto_rotation=$(adb shell settings get system accelerometer_rotation)
    CURRENT_ACCESSIBILITY=$(adb shell settings get secure enabled_accessibility_services)
    CURRENT_WALLPAPER=$(adb shell dumpsys wallpaper | awk 'match($0, /ComponentInfo\{[^}][^}]*\}/) { print substr($0, RSTART + 14, RLENGTH - 15); exit }')
    WALLPAPER_PACKAGE=$(echo "$CURRENT_WALLPAPER" | cut -d'/' -f1)
    WALLPAPER_SERVICE=$(echo "$CURRENT_WALLPAPER" | cut -d'/' -f2)
    EDGE_ENABLE_ORIG=$(adb shell settings get secure edge_enable)
    EDGE_PANELS_ENABLED_ORIG=$(adb shell settings get secure edge_panels_enabled)
}

restore_device_state() {
    local attempts
    local restored_auto_rotation
    local restored_accessibility

    attempts=0
    adb shell settings put system accelerometer_rotation "$auto_rotation"
    restored_auto_rotation=$(adb shell settings get system accelerometer_rotation)
    while [[ "$auto_rotation" != "$restored_auto_rotation" ]]; do
        echo "Auto rotation was not restored. Trying again..."
        sleep 1
        adb shell settings put system accelerometer_rotation "$auto_rotation"
        restored_auto_rotation=$(adb shell settings get system accelerometer_rotation)
        attempts=$((attempts + 1))
        if [[ $attempts -gt 5 ]]; then
            print_warning "Failed to restore auto rotation after 5 attempts. Please restore it manually from Quick Settings."
            break
        fi
    done

    attempts=0
    adb shell settings put secure enabled_accessibility_services "$CURRENT_ACCESSIBILITY"
    restored_accessibility=$(adb shell settings get secure enabled_accessibility_services)
    while [[ "$CURRENT_ACCESSIBILITY" != "$restored_accessibility" ]]; do
        echo "Accessibility settings were not restored. Trying again..."
        sleep 1
        adb shell settings put secure enabled_accessibility_services "$CURRENT_ACCESSIBILITY"
        restored_accessibility=$(adb shell settings get secure enabled_accessibility_services)
        attempts=$((attempts + 1))
        if [[ $attempts -gt 5 ]]; then
            print_warning "Failed to restore accessibility settings after 5 attempts. Please restore them manually in Settings > Accessibility."
            break
        fi
    done

    adb shell settings put secure edge_enable "$EDGE_ENABLE_ORIG"
    adb shell settings put secure edge_panels_enabled "$EDGE_PANELS_ENABLED_ORIG"
}

extract_widget_packages() {
    adb shell dumpsys appwidget | awk '
        /^Widgets:/ { in_widgets = 1; next }
        /^Hosts:/ { in_widgets = 0 }
        in_widgets && /provider=/ {
            if (match($0, /ComponentInfo\{[^/}][^/}]*/)) {
                print substr($0, RSTART + 14, RLENGTH - 14)
            }
        }
    ' >> "$APP_TO_RESTART"

    adb shell dumpsys appwidget | awk '
        /^Hosts:/ { in_hosts = 1; next }
        /^Grants:/ { in_hosts = 0 }
        in_hosts && /hostId=HostId/ {
            if (match($0, /pkg:[^}][^}]*/)) {
                print substr($0, RSTART + 4, RLENGTH - 4)
            }
        }
    ' >> "$APP_TO_RESTART"
}

restart_widget_packages() {
    if [ -s "$APP_TO_RESTART" ]; then
        sort -u "$APP_TO_RESTART" -o "$APP_TO_RESTART"
        adb shell "while read pkg; do monkey -p \"\$pkg\" -c android.intent.category.LAUNCHER 1; done" < "$APP_TO_RESTART"
    fi
}

show_notice() {
    clear
    printf '%b\n' "${BOLD}${RED}==== NOTICE ====${RESET}"
    printf '%b\n' "${YELLOW}This tool is provided for your convenience and makes changes to system settings via ADB.${RESET}"
    echo "I have tested it extensively on my own device and have not seen issues, but use care."
    echo ""
    printf '%b\n' "${GREEN}Please use responsibly and do not use this tool for harmful or inappropriate purposes.${RESET}"
    echo "If you have any concerns, consider backing up your data first."
    echo ""
    printf '%b\n' "${YELLOW}Standard Disclaimer:${RESET}"
    echo "This script is provided \"as is,\" with no guarantees or warranties. Use at your own risk."
    echo "The script only changes a system rendering setting temporarily; it reverts on reboot."
    echo "The script does not modify or delete files on your device."
    echo "The author is not responsible for unexpected issues, data loss, or device instability."
    echo "This is not an official Samsung or Google product."
    echo ""
    echo "Problems are very unlikely, but always proceed with care."
    echo ""
    pause_if_interactive
}

show_warning() {
    clear
    echo "WARNING: Launching all apps may:"
    echo "- Wake sleeping or background apps"
    echo "- Increase battery consumption temporarily"
    echo ""
    echo "In rare cases, launching apps can help if something did not load after switching renderers."
    echo "Usually, it is better to launch only the app you need."
    echo ""
}

show_info() {
    clear
    printf '%b\n' "${BOLD}${BLUE}==== Info and Help ====${RESET}"
    echo ""
    echo "- This script forces Vulkan rendering on your Samsung S23 device."
    echo "- Forcing Vulkan can improve performance, reduce heat, improve battery life, and help with lag."
    echo "- To revert to OpenGL, restart your device."
    echo "- You must re-run this script after every device reboot to keep Vulkan active."
    printf '%b\n' "${GREEN}- Samsung auto optimization restarts will not reset Vulkan rendering. Only a full device reboot will revert to OpenGL.${RESET}"
    echo ""
    printf '%b\n' "${BOLD}Blacklist Management:${RESET}"
    echo "- To add apps to the blacklist, edit blacklist.txt and add one package name per line."
    echo "  Example package name: com.example.app"
    printf '%b\n' "- To find an app package name, use ${YELLOW}adb shell pm list packages | grep keyword${RESET} or search online."
    echo "- To remove apps from the blacklist, edit blacklist.txt and run the blacklist action again."
    echo "- To clear all blacklisted apps, run:"
    printf '%b\n' "  ${YELLOW}adb shell 'settings put global game_driver_blacklist \"\"'${RESET}"
    echo ""
    echo "If you experience issues, reboot your device."
    echo ""
    pause_if_interactive
}

show_help() {
    cat <<EOF
S23/S23+/S23U Vulkan Rendering Tool for macOS v$VERSION

Usage:
  ./$SCRIPT_NAME              Open the interactive menu
  ./$SCRIPT_NAME --full       Switch to Vulkan with the full app restart flow
  ./$SCRIPT_NAME --basic      Switch to Vulkan with the basic restart flow
  ./$SCRIPT_NAME --blacklist  Apply blacklist.txt to game_driver_blacklist
  ./$SCRIPT_NAME --reboot     Reboot the device to revert to OpenGL
  ./$SCRIPT_NAME --updates    Check GitHub for the latest release
  ./$SCRIPT_NAME --help       Show this help message

Notes:
  - Vulkan must be re-applied after each full device reboot.
  - The full Vulkan flow is the default recommended action.
  - Temporary files are created under macOS temp storage and removed on exit.
EOF
}

set_vulkan_renderer() {
    if adb shell setprop debug.hwui.renderer skiavk; then
        print_success "Vulkan renderer property set successfully."
        return 0
    fi

    print_error "Failed to set Vulkan renderer property."
    return 1
}

run_vulkan_basic() {
    : > "$APP_TO_RESTART"

    set_vulkan_renderer || return 1

    adb shell "am crash com.android.systemui; am force-stop com.android.settings; am force-stop com.sec.android.app.launcher" >/dev/null 2>&1
    adb shell am force-stop com.samsung.android.app.aodservice >/dev/null 2>&1
    adb shell am crash com.google.android.inputmethod.latin b >/dev/null 2>&1

    print_success "Vulkan forced."
    print_success "Key system apps have been restarted."

    extract_widget_packages
    restart_widget_packages
    print_warning "Widget providers and widget hosts have been restarted. Some widgets may require a tap."
}

add_exclusion() {
    if [ -n "$1" ] && [ "$1" != "null" ]; then
        echo "$1" >> "$EXCLUDED_PACKAGES"
    fi
}

run_vulkan_full() {
    : > "$ALL_PACKAGES"
    : > "$APP_TO_RESTART"
    : > "$TEMP_PACKAGES"
    : > "$KEYBOARD_PACKAGES"
    : > "$FORCE_STOP_ERRORS"
    : > "$RUNNING_APPS"
    : > "$FILTERED_PACKAGES"
    : > "$EXCLUDED_PACKAGES"

    adb shell pm list packages 2>/dev/null | sed 's/^package://' | grep -F -v "ia.mo" | grep -F -v "com.netflix.mediaclient" | sort > "$TEMP_PACKAGES"
    adb shell ime list -s | cut -d'/' -f1 > "$KEYBOARD_PACKAGES"
    grep -F -v -f "$KEYBOARD_PACKAGES" "$TEMP_PACKAGES" | sort -u > "$ALL_PACKAGES"
    adb shell dumpsys activity processes > "$RUNNING_APPS"

    while read -r pkg; do
        if grep -F -q "$pkg" "$RUNNING_APPS"; then
            echo "$pkg" >> "$APP_TO_RESTART"
        fi
    done < "$ALL_PACKAGES"

    set_vulkan_renderer || return 1

    add_exclusion "com.samsung.android.bluelightfilter"
    add_exclusion "com.samsung.android.wcmurlsnetworkstack"
    add_exclusion "com.sec.unifiedwfc"
    add_exclusion "com.samsung.android.net.wifi.wifiguider"
    add_exclusion "com.sec.imsservice"
    add_exclusion "com.samsung.ims.smk"
    add_exclusion "com.sec.epdg"
    add_exclusion "com.samsung.android.networkstack"
    add_exclusion "com.samsung.android.networkdiagnostic"
    add_exclusion "com.samsung.android.ConnectivityOverlay"
    add_exclusion "$WALLPAPER_PACKAGE"
    add_exclusion "$WALLPAPER_SERVICE"

    grep -F -v -f "$EXCLUDED_PACKAGES" "$ALL_PACKAGES" > "$FILTERED_PACKAGES"

    echo "Stopping apps. Please wait..."
    cmds=''
    while read -r pkg; do
        cmds="${cmds}am force-stop $pkg; "
    done < "$FILTERED_PACKAGES"

    adb shell "$cmds" 2> "$FORCE_STOP_ERRORS"
    echo ""

    print_success "Vulkan forced. Apps have been force stopped."

    extract_widget_packages

    adb shell am force-stop com.sec.android.app.launcher
    sleep 2
    adb shell monkey -p com.sec.android.app.launcher -c android.intent.category.LAUNCHER 1

    restart_widget_packages
    print_warning "Previously running apps, widget providers, and widget hosts have been restarted. Some widgets may require a tap."
}

run_vulkan() {
    local mode="$1"

    check_device || return 1
    capture_device_state

    if [ "$mode" = "basic" ]; then
        run_vulkan_basic
    else
        run_vulkan_full
    fi
    local result=$?

    restore_device_state
    echo "To revert to OpenGL, restart your device."
    return "$result"
}

run_blacklist() {
    check_device || return 1

    if [[ ! -f "$BLACKLIST_FILE" ]]; then
        print_error "blacklist.txt not found. Create it with one package name per line."
        return 1
    fi

    printf '%b\n' "${GREEN}Current Game Driver Blacklist:${RESET}"
    current_blacklist=$(adb shell settings get global game_driver_blacklist)
    if [[ -z "$current_blacklist" || "$current_blacklist" == "null" ]]; then
        printf '%b\n' "${YELLOW}No apps are currently blacklisted.${RESET}"
    else
        echo "$current_blacklist" | tr ',' '\n'
    fi

    echo ""
    blacklist=$(paste -s -d, "$BLACKLIST_FILE")
    adb shell settings put global game_driver_blacklist "$blacklist"

    print_warning "All apps in blacklist.txt have been added to game_driver_blacklist."
    echo "This step is based on a recommendation from a Reddit user:"
    printf '%b\n' "${BLUE}https://www.reddit.com/r/GalaxyS23Ultra/comments/1kgnzru/comment/mr0qdd4/${RESET}"
    echo "It may help prevent crashes for some apps, but results may vary."
    echo "To remove apps from the blacklist, edit blacklist.txt and run this action again."
    echo ""
    printf '%b\n' "${GREEN}Updated Game Driver Blacklist:${RESET}"

    current_blacklist=$(adb shell settings get global game_driver_blacklist)
    if [[ -z "$current_blacklist" || "$current_blacklist" == "null" ]]; then
        printf '%b\n' "${YELLOW}No apps are currently blacklisted.${RESET}"
    else
        echo "$current_blacklist" | tr ',' '\n'
    fi
}

run_reboot() {
    check_device || return 1

    printf '%b\n' "${YELLOW}Reboot your device to revert to OpenGL. Type YES to continue.${RESET}"
    read -p "Type 'YES' to continue: " confirm
    if [[ "$confirm" == "YES" ]]; then
        adb reboot
    else
        print_error "Reboot canceled."
    fi
}

run_launch_all_apps() {
    show_warning
    read -p "Type 'YES' to continue: " confirm
    if [[ "$confirm" != "YES" ]]; then
        print_error "Launch canceled."
        return 1
    fi

    check_device || return 1
    capture_device_state

    adb shell "for pkg in \$(pm list packages | cut -f2 -d:); do monkey -p \"\$pkg\" -c android.intent.category.LAUNCHER 1; done"
    print_warning "All apps launched. Close unused apps from Recents immediately."
    restore_device_state
}

run_gpuwatch_info() {
    printf '%b\n' "${BOLD}${YELLOW}GPUWatch cannot be enabled via ADB.${RESET}"
    echo ""
    printf '%b\n' "${GREEN}To enable GPUWatch, follow these steps on your device:${RESET}"
    echo "1. Go to Settings > Developer Options > GPU Watch"
    echo "2. Toggle ON"
    echo ""
    printf '%b\n' "${YELLOW}You will see a persistent notification that lets you control the overlay.${RESET}"
}

run_update_check() {
    check_commands curl sed || return 1

    printf '%b\n' "${BOLD}${YELLOW}Checking for updates...${RESET}"
    api_response=$(curl -s https://api.github.com/repos/Ameen-Sha-Cheerangan/s23-vulkan-support/releases/latest)
    latest_version=$(echo "$api_response" | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | sed -n '1p')
    latest_version_clean=$(echo "$latest_version" | sed 's/^v//')
    current_version_clean="$VERSION"

    if [ -z "$latest_version" ]; then
        print_error "Failed to check for updates. Please check your internet connection."
    elif [ "$current_version_clean" = "$latest_version_clean" ]; then
        print_success "You are using the latest version (v$VERSION)."
    else
        skip_clear=true
        printf '%b\n' "${RED}A new version ($latest_version) is available. You are using v$VERSION.${RESET}"
        printf '%b\n' "${YELLOW}If you want to update, exit this running program and run these commands:${RESET}"
        printf '%b\n' "${YELLOW}Commands:${RESET}"
        printf '%b\n' "${GREEN}cd .. && rm -rf s23-vulkan-support-$VERSION* $VERSION*.zip${RESET}"
        printf '%b\n' "${GREEN}curl -L -o $latest_version.zip https://github.com/Ameen-Sha-Cheerangan/s23-vulkan-support/archive/refs/tags/$latest_version.zip${RESET}"
        printf '%b\n' "${GREEN}unzip $latest_version.zip && cd s23-vulkan-support-$latest_version${RESET}"
        printf '%b\n' "${GREEN}chmod +x opengl-to-vulkan-macos.sh${RESET}"
        printf '%b\n' "${YELLOW}Then run the script:${RESET}"
        printf '%b\n' "${GREEN}./opengl-to-vulkan-macos.sh${RESET}"

        release_notes=$(echo "$api_response" | sed -n 's/.*"body"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | sed 's/\\r\\n/ /g' | sed -n '1p')
        if [ -n "$release_notes" ]; then
            printf '%b\n' "${YELLOW}Release notes:${RESET}"
            printf '%b\n' "${BLUE}$release_notes${RESET}"
        fi
    fi
}

show_menu() {
    while true; do
        if [ "$skip_clear" = false ]; then
            clear
        else
            skip_clear=false
        fi

        printf '%b\n' "${BLUE}GitHub: https://github.com/Ameen-Sha-Cheerangan/s23-vulkan-support${RESET}"
        printf '%b\n' "${BOLD}${BLUE}==== S23/S23+/S23U Vulkan Rendering Tool v$VERSION (macOS) ====${RESET}"
        echo "1) Switch to Vulkan - Full (Recommended)"
        echo "2) Switch to Vulkan - Basic"
        echo "3) Switch to OpenGL (Reboot Device)"
        echo "4) Blacklist Apps from Game Driver (Prevent Crashes for Listed Apps)"
        echo "5) Info/Help"
        echo "6) Launch All Apps (Not Recommended)"
        echo "7) Turn GPUWatch On/Off"
        echo "8) Check for Updates"
        echo "9) Exit"
        echo ""
        printf '%b\n' "${YELLOW}Note: Vulkan rendering must be re-applied after every device restart.${RESET}"
        echo ""
        read -p "Choose [1-9, default 1]: " choice
        choice=${choice:-1}

        case "$choice" in
            1)
                run_vulkan full
                pause_if_interactive
                ;;
            2)
                run_vulkan basic
                pause_if_interactive
                ;;
            3)
                run_reboot
                pause_if_interactive
                ;;
            4)
                run_blacklist
                pause_if_interactive
                ;;
            5)
                show_info
                ;;
            6)
                run_launch_all_apps
                pause_if_interactive
                ;;
            7)
                run_gpuwatch_info
                pause_if_interactive
                ;;
            8)
                run_update_check
                pause_if_interactive
                ;;
            9)
                print_success "Thank you for using the S23/S23+/S23U Vulkan Rendering Tool."
                echo "If you found this tool helpful, please consider giving it a star on the GitHub repo."
                printf '%b\n' "${BLUE}GitHub: https://github.com/Ameen-Sha-Cheerangan/s23-vulkan-support${RESET}"
                echo "For updates, visit the GitHub repo above."
                exit 0
                ;;
            *)
                print_error "Invalid choice."
                pause_if_interactive
                ;;
        esac
    done
}

main() {
    case "${1:-}" in
        "")
            INTERACTIVE=true
            show_notice
            show_menu
            ;;
        --full)
            run_vulkan full
            ;;
        --basic)
            run_vulkan basic
            ;;
        --blacklist)
            run_blacklist
            ;;
        --reboot)
            run_reboot
            ;;
        --updates)
            run_update_check
            ;;
        --help|-h)
            show_help
            ;;
        *)
            print_error "Unknown option: $1"
            echo ""
            show_help
            return 1
            ;;
    esac
}

main "$@"
