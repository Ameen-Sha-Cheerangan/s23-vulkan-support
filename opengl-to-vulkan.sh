#!/bin/bash
VERSION="2.3.5"

# Color codes
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
BOLD="\e[1m"
RESET="\e[0m"

clear
#Get the current auto-rotation setting
auto_rotation=$(adb shell settings get system accelerometer_rotation)
#Get the current accessibility services
CURRENT_ACCESSIBILITY=$(adb shell settings get secure enabled_accessibility_services)

echo -e "${BOLD}${RED}==== NOTICE ====${RESET}"
echo -e "${YELLOW}This tool is provided for your convenience and makes changes to system settings via ADB.${RESET}"
echo "I've tested it extensively on my own device and haven't seen any issues, but just to be safe (for both of us!), I'm including this notice."
echo ""
echo -e "${GREEN}Please use responsibly and do not use this tool for any harmful or inappropriate purposes.${RESET}"
echo "If you have any concerns, consider backing up your data first."
echo ""
echo -e "${YELLOW}Standard Disclaimer:${RESET}"
echo "This script is provided “as is,” with no guarantees or warranties-use at your own risk."
echo "The script only changes a system rendering setting temporarily (it reverts on reboot), and does not modify or delete any files on your device."
echo "The author is not responsible for any unexpected issues, data loss, or device instability that may arise from use of this tool."
echo "This is not an official Samsung or Google product."
echo ""
echo "Problems are very unlikely, but always proceed with care!"
echo ""
read -n1 -s -r -p "Press any key to return to the menu..."


cleanup() {
    rm -f all_packages.txt app_to_restart.txt force_stop_errors.log running_apps.log temp_packages.txt keyboard_packages.txt filtered_packages.txt
    echo -e "${YELLOW}Temporary files cleaned up.${RESET}"
}
trap cleanup EXIT

check_device() {
    for cmd in adb awk grep sort; do
        command -v $cmd >/dev/null 2>&1 || { echo -e "${RED}❌ $cmd not found. Please install it.${RESET}"; exit 1; }
    done
    if ! adb get-state 1>/dev/null 2>&1; then
    echo -e "${RED}❌ No device detected. Please connect your device and enable USB debugging.${RESET}"
        read -n1 -s -r -p "Press any key to return to the menu..."
        return 1
    fi
    return 0
}

show_info() {
    clear
    echo -e "${BOLD}${BLUE}==== Info & Help ==== ${RESET}"
    echo ""
    echo "• This script forces Vulkan rendering on your Samsung S23 device."
    echo "• Forcing Vulkan can improve performance, reduce heat, and improve battery life, it also helps with lag. (As per the reddit community)"
    echo "• To revert to OpenGL, simply RESTART your device."
    echo "• You must re-run this script after every device reboot to keep Vulkan active."
    echo -e "${GREEN}• Note: Samsung's auto optimization restarts (background app closures) will NOT reset Vulkan rendering - only a full device reboot will revert to OpenGL.${RESET}"
    echo ""
    echo -e "${BOLD}Blacklist Management:${RESET}"
    echo "• To add apps to blacklist: Edit blacklist.txt and add one package name per line"
    echo "  Example package names: com.example.app"
    echo -e "• To find an app's package name: Use ${YELLOW}'adb shell pm list packages | grep keyword'${RESET} OR You can search in internet"
    echo "• To remove apps from blacklist: Delete the package name from blacklist.txt, and re-run the step 3 in the menu."
    echo "• To clear all blacklisted apps, run:"
    echo -e "  ${YELLOW}adb shell 'settings put global game_driver_blacklist \"\"'${RESET}"
    echo ""
    echo "If you experience issues, simply reboot your device."
    echo ""
    read -n1 -s -r -p "Press any key to return to the menu..."
}
skip_clear=false

while true; do
    #set -x  # Enable trace mode
    if [ "$skip_clear" = false ]; then
        clear
    else
        skip_clear=false  # Reset after skipping once
    fi

    echo -e "${BLUE}GitHub: https://github.com/Ameen-Sha-Cheerangan/s23-vulkan-support${RESET}"
    echo -e "${BOLD}${BLUE}==== S23/S23+/S23U Vulkan Rendering Tool v${VERSION} (Linux) ==== ${RESET}"
    echo "1) Switch to Vulkan(Recommended)"
    echo "2) Switch to OpenGL (Reboot Device)"
    echo "3) Blacklist Apps from Game Driver (Prevent Crashes for Listed Apps)"
    echo "4) Info/Help"
    echo "5) Exit"
    echo "6) Turn GPUWatch On/Off"
    echo "7) Check for Updates"

    echo ""
    echo -e "${YELLOW}Note: Vulkan rendering must be re-applied after every device restart.${RESET}"
    echo ""
    read -p "Choose [1-7]: " choice

    case $choice in
        1)
            echo ""
            check_device || continue
            echo -e "${YELLOW}How aggressive should the script be when stopping apps?${RESET}"
            echo -e "${GREEN}1) Normal${RESET} (only restart key system apps: SystemUI, Settings, Launcher, AOD, Keyboard)"
            echo -e "${GREEN}2) Aggressive${RESET}(force-stop ALL apps and Relaunch Previously Running Apps and Widgets; More complete procedure) "
            echo ""
            read -p "Choose [1-2]: " aggressive_choice

            if [[ $aggressive_choice == "1" ]]; then
                if adb shell setprop debug.hwui.renderer skiavk; then
                    echo -e "${GREEN}✅ Vulkan renderer property set successfully.${RESET}"
                else
                    echo -e "${RED}❌ Failed to set Vulkan renderer property.${RESET}"
                    read -n1 -s -r -p "Press any key to return to the menu..."
                    continue
                fi
                > "app_to_restart.txt"
                adb shell am crash com.android.systemui > /dev/null 2>&1
                adb shell am force-stop com.android.settings > /dev/null 2>&1
                adb shell am force-stop com.sec.android.app.launcher > /dev/null 2>&1
                adb shell am force-stop com.samsung.android.app.aodservice > /dev/null 2>&1
                adb shell am crash com.google.android.inputmethod.latin b > /dev/null 2>&1
                echo -e "${GREEN}✅ Vulkan forced!${RESET}"
            else
                > "all_packages.txt"
                > "app_to_restart.txt"
                > "temp_packages.txt"
                > "keyboard_packages.txt"
                > "force_stop_errors.log"
                > "running_apps.log"
                > "filtered_packages.txt"
                adb shell pm list packages 2>/dev/null| grep -v ia.mo |grep -v com.netflix.mediaclient | cut -f2 -d: | sort > temp_packages.txt

                adb shell ime list -s | cut -d'/' -f1 > keyboard_packages.txt
                cat temp_packages.txt | grep -v -f keyboard_packages.txt | sort -u > all_packages.txt
                adb shell dumpsys activity processes > running_apps.log

                while read pkg; do
                    if grep -q "$pkg" running_apps.log; then
                        echo "$pkg" >> "app_to_restart.txt"
                    fi
                done < all_packages.txt

                if adb shell setprop debug.hwui.renderer skiavk; then
                    echo -e "${GREEN}✅ Vulkan renderer property set successfully.${RESET}"
                else
                    echo -e "${RED}❌ Failed to set Vulkan renderer property.${RESET}"
                    read -n1 -s -r -p "Press any key to return to the menu..."
                    continue
                fi

                grep -v -e "com.samsung.android.wcmurlsnetworkstack" -e "com.sec.unifiedwfc" -e "com.samsung.android.net.wifi.wifiguider" -e "com.sec.imsservice" -e "com.samsung.ims.smk" -e "com.sec.epdg" -e "com.samsung.android.networkstack" -e "com.samsung.android.networkdiagnostic" -e "com.samsung.android.ConnectivityOverlay" all_packages.txt > filtered_packages.txt # to prevent wifi calling from breaking and keep the current live wallpaper intact

                cmds=''
                while read pkg; do
                    count=$((count + 1))
                    cmds+="am force-stop $pkg; "
                done < filtered_packages.txt

                adb shell "$cmds"
                echo ""



                echo -e "${GREEN}✅ Vulkan forced! All apps have been stopped.${RESET}"
                adb shell dumpsys appwidget | awk '/^Widgets:/{flag=1; next} /^Hosts:/{flag=0} flag' | grep "provider=" | grep -oP 'ComponentInfo\{\K[^/]+' >> app_to_restart.txt # Getting all widget providers

                sort -u app_to_restart.txt -o app_to_restart.txt # Removing duplicates

                adb shell am force-stop com.sec.android.app.launcher
                sleep 2
                adb shell monkey -p com.sec.android.app.launcher -c android.intent.category.LAUNCHER 1

                adb shell "while read pkg; do monkey -p \"\$pkg\" -c android.intent.category.LAUNCHER 1; done" < app_to_restart.txt

                echo -e "${YELLOW}⚠️  All previously running apps and widget providers have been restarted. Some widgets may require just a tap.${RESET}"
            fi
            adb shell settings put system accelerometer_rotation $auto_rotation
            adb shell settings put secure enabled_accessibility_services "$CURRENT_ACCESSIBILITY"
            echo "ℹ️  To revert to OpenGL, simply restart your device."
            read -n1 -s -r -p "Press any key to return to the menu..."
            ;;
        2)
            echo -e "${YELLOW}Reboot your device to revert to OpenGL. If you want the script to do it for you, type 'YES' to continue.${RESET}"
            read -p "Type 'YES' to continue: " confirm
            if [[ $confirm == "YES" ]]; then
                adb reboot
            else
                echo -e "${RED}❌ Reboot canceled.${RESET}"
            fi
            read -n1 -s -r -p "Press any key to return to the menu..."
            ;;
        3)
            check_device || continue
            if [[ ! -f blacklist.txt ]]; then
                echo -e "${RED}❌ blacklist.txt not found! Please create this file with one package name per line.${RESET}"
            else
                echo -e "${GREEN}Current Game Driver Blacklist:${RESET}"
                current_blacklist=$(adb shell settings get global game_driver_blacklist)
                if [[ -z "$current_blacklist" || "$current_blacklist" == "null" ]]; then
                    echo -e "${YELLOW}No apps are currently blacklisted.${RESET}"
                else
                    # Print each package on a new line for readability
                    echo "$current_blacklist" | tr ',' '\n'
                fi
                echo ""
                blacklist=$(paste -sd, blacklist.txt)
                adb shell settings put global game_driver_blacklist "$blacklist"
                echo -e "${YELLOW}⚠️  All apps in blacklist.txt have been added to game_driver_blacklist."
                echo "   This step is based on a recommendation from a Reddit user:"
                echo -e "${BLUE}   https://www.reddit.com/r/GalaxyS23Ultra/comments/1kgnzru/comment/mr0qdd4/${RESET}"
                echo "   (It may help prevent crashes for some apps, but results may vary.)"
                echo "   To remove apps from the blacklist, edit blacklist.txt and run this step again."
                echo ""
                echo -e "${GREEN}Updated Game Driver Blacklist:${RESET}"
                current_blacklist=$(adb shell settings get global game_driver_blacklist)
                if [[ -z "$current_blacklist" ]]; then
                    echo -e "${GREEN}No apps are currently blacklisted.${RESET}"
                else
                    # Print each package on a new line for readability
                    echo "$current_blacklist" | tr ',' '\n'
                fi
                echo ""
            fi
            read -n1 -s -r -p "Press any key to return to the menu..."
            ;;
        4)
            show_info
            ;;
        5)
            echo -e "${GREEN}Thank you for using the S23/S23+/S23U Vulkan Rendering Tool!${RESET}"
            echo -e "If you found this tool helpful, please consider giving it a ⭐ on the GitHub repo!"
            echo -e "${BLUE}GitHub: https://github.com/Ameen-Sha-Cheerangan/s23-vulkan-support${RESET}"
            echo -e "For updates, visit the GitHub repo above."
            exit 0
            ;;
        6)
            echo -e "${BOLD}${YELLOW}GPUWatch cannot be enabled via ADB.${RESET}"
            echo ""
            echo -e "${GREEN}To enable GPUWatch, follow these steps on your device:${RESET}"
            echo "1. Go to Settings > Developer Options > GPU Watch"
            echo "2. Toggle ON"
            echo ""
            echo -e "${YELLOW}You will see a persistent notification, allowing you to control the overlay.${RESET}"
            echo ""
            read -n1 -s -r -p "Press any key to return to the menu..."
            ;;
        7)
            echo -e "${BOLD}${YELLOW}Checking for updates...${RESET}"
            # Get latest release info using GitHub API
            api_response=$(curl -s https://api.github.com/repos/Ameen-Sha-Cheerangan/s23-vulkan-support/releases/latest)

            # Extract the tag_name (version) from the JSON response
            latest_version=$(echo "$api_response" | grep -o '"tag_name": *"[^"]*"' | cut -d'"' -f4)

            # Remove the 'v' prefix if present for comparison
            latest_version_clean=$(echo "$latest_version" | sed 's/^v//')
            current_version_clean=$(echo "$VERSION")

            if [ -z "$latest_version" ]; then
                echo -e "${RED}Failed to check for updates. Please check your internet connection.${RESET}"
            elif [ "$current_version_clean" = "$latest_version_clean" ]; then
                echo -e "${GREEN}You are using the latest version (v${VERSION}).${RESET}"
            else
                skip_clear=true
                echo -e "${RED}A new version (${latest_version}) is available. You are using v${VERSION}.${RESET}"
                echo -e "${YELLOW}If you want to update, please exit this running program and run these commands:${RESET}"
                echo -e "${YELLOW}Commands:${RESET}"
                echo -e "${GREEN}cd .. && rm -rf s23-vulkan-support-$VERSION* $VERSION*.zip${RESET}"
                echo -e "${GREEN}wget https://github.com/Ameen-Sha-Cheerangan/s23-vulkan-support/archive/refs/tags/$latest_version.zip${RESET}"
                echo -e "${GREEN}unzip $latest_version*.zip && cd s23-vulkan-support-$latest_version${RESET}"
                echo -e "${GREEN}chmod +x opengl-to-vulkan.sh${RESET}"
                echo -e "${YELLOW}Then run the script:${RESET}"
                echo -e "${GREEN}./opengl-to-vulkan.sh${RESET}"

                # Display release notes if available
                release_notes=$(echo "$api_response" | grep -o '"body": *"[^"]*"' | cut -d'"' -f4 | sed 's/\\r\\n/\n/g')
                if [ ! -z "$release_notes" ]; then
                    echo -e "${YELLOW}Release notes:${RESET}"
                    echo -e "${BLUE}$release_notes${RESET}"
                fi
            fi
            read -n1 -s -r -p "Press any key to return to the menu..."
            ;;
        *)
            echo -e "${RED}Invalid choice${RESET}"
            ;;
    esac
done
