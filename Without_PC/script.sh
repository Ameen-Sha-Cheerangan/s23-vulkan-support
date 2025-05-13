z#!/data/data/com.termux/files/usr/bin/bash

# Color codes
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
BOLD="\e[1m"
RESET="\e[0m"


clear
# Get the current auto-rotation setting
auto_rotation=$(rish -c "settings get system accelerometer_rotation")

# Get the current accessibility services
CURRENT_ACCESSIBILITY=$(rish -c "settings get secure enabled_accessibility_services")

echo -e "${BOLD}${RED}==== NOTICE ====${RESET}"
echo -e "${YELLOW}This tool is provided for your convenience and makes changes to system settings .${RESET}"
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
    echo "• To remove apps from blacklist: Delete the package name from blacklist.txt, and re-run the step 3 in the menu."
    echo "• To clear all blacklisted apps, run:"
    echo -e "  ${YELLOW}rish -c \"settings put global game_driver_blacklist ''\"${RESET}"
    echo "  This will clear the blacklist so all apps can use the Game Driver again."
    echo ""
    echo "If you experience issues, simply reboot your device."
    echo ""
    read -n1 -s -r -p "Press any key to return to the menu..."
}

while true; do
    # set -x  # Enable trace mode
    clear

    echo -e "${BLUE}GitHub: https://github.com/Ameen-Sha-Cheerangan/s23-vulkan-support${RESET}"
    echo -e "${BOLD}${BLUE}==== S23/S23+/S23U Vulkan Rendering Tool v${VERSION} (Mobile) ==== ${RESET}"
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
            echo -e "${YELLOW}How aggressive should the script be when stopping apps?${RESET}"
            echo -e "${GREEN}1) Normal${RESET} (only restart key system apps: SystemUI, Settings, Launcher, AOD, Keyboard)"
            echo -e "${GREEN}2) Aggressive ${YELLOW}[Recommended]${RESET} (force-stop ALL apps and Relaunch Previously Running Apps and Widgets; More complete procedure) ${RESET}"
            echo ""
            read -p "Choose [1-2]: " aggressive_choice

            if [[ $aggressive_choice == "1" ]]; then
                rish -c "setprop debug.hwui.renderer skiavk; am crash com.android.systemui; am force-stop com.android.settings; am force-stop com.sec.android.app.launcher; am force-stop com.samsung.android.app.aodservice; am crash com.google.android.inputmethod.latin b" > /dev/null 2>&1
                echo -e "${GREEN}✅ Vulkan forced! Key system apps have been restarted.${RESET}"
            else
                > "all_packages.txt"
                > "app_to_restart.txt"
                > "force_stop_errors.log"
                > "running_apps.log"
                > "temp_packages.txt"
                > "keyboard_packages.txt"
                > "filtered_packages.txt"
                rish -c "dumpsys package | grep 'Package \[' | cut -d '[' -f2 | cut -d ']' -f1" | grep -v "ia.mo" | grep -v "com.google.android.trichromelibrary.*" | grep -v "com.netflix.mediaclient" | grep -v "com.termux"| grep -v "moe.shizuku.privileged.api"| grep -v "com.google.android.gsf" > temp_packages.txt

                rish -c "ime list -s | cut -d'/' -f1" > keyboard_packages.txt #to avoid force-stopping the default keyboard
                cat temp_packages.txt | grep -v -f keyboard_packages.txt | sort -u > all_packages.txt
                echo "$(wc -l < temp_packages.txt) packages found."
                echo "After filtering keyboard package$(wc -l < all_packages.txt) packages found."

                rish -c "dumpsys activity processes" > running_apps.log

                while read pkg; do
                    if grep -q "$pkg" running_apps.log; then
                        echo "$pkg" >> "app_to_restart.txt"
                    fi
                done < all_packages.txt

                cmds='setprop debug.hwui.renderer skiavk; count=0; total='"$total"'; '
                # while read pkg; do
                #     cmds+="am force-stop $pkg; "
                #     cmds+='count=$((count + 1)); '
                #     cmds+='printf "\rProgress: %d/%d packages stopped - %s" "$count" "$total" '"$pkg"'; '
                # done < all_packages.txt
                grep -v -e "com.samsung.android.wcmurlsnetworkstack" -e "com.sec.unifiedwfc" -e "com.samsung.android.net.wifi.wifiguider" -e "com.sec.imsservice" -e "com.samsung.ims.smk" -e "com.sec.epdg" -e "com.samsung.android.networkstack" -e "com.samsung.android.networkdiagnostic" -e "com.samsung.android.ConnectivityOverlay" all_packages.txt > filtered_packages.txt
                # to prevent wifi calling from breaking
                mv filtered_packages.txt all_packages.txt
                count=0
                mapfile -t packages < all_packages.txt
                total=${#packages[@]}
                for pkg in "${packages[@]}"; do
                    cmds+="am force-stop $pkg; "
                    cmds+='count=$((count + 1)); '
                    cmds+='printf "\rProgress: %d/%d packages stopped - %s" "$count" "$total" '"$pkg"'; '
                done

                rish -c "$cmds"
                echo
                echo -e "${GREEN}✅ Vulkan forced! All apps have been stopped.${RESET}"

                rish -c "dumpsys appwidget" | awk '/^Widgets:/{flag=1; next} /^Hosts:/{flag=0} flag' | grep "provider=" | grep -oP 'ComponentInfo\{\K[^/]+' >> app_to_restart.txt
                sort -u app_to_restart.txt -o app_to_restart.txt # Removing duplicates
                rish -c "am force-stop com.sec.android.app.launcher; sleep 2; monkey -p com.sec.android.app.launcher -c android.intent.category.LAUNCHER 1"

                cmds=''
                while read pkg; do
                    cmds+="monkey -p \"$pkg\" -c android.intent.category.LAUNCHER 1; "
                done < app_to_restart.txt

                rish -c "$cmds"

                echo ""
                echo -e "${YELLOW}⚠️  All previously running apps and widget providers have been restarted. Some widgets may require just a tap.${RESET}"
            fi
            rish -c "settings put system accelerometer_rotation $auto_rotation"
            rish -c "settings put secure enabled_accessibility_services \"$CURRENT_ACCESSIBILITY\""
            echo "ℹ️  To revert to OpenGL, simply restart your device."
            read -n1 -s -r -p "Press any key to return to the menu..."
            ;;
        2)
            echo -e "${YELLOW}Reboot your device to revert to OpenGL. If you want the script to do it for you, type 'YES' to continue.${RESET}"
            read -p "Type 'YES' to continue: " confirm
            if [[ $confirm == "YES" ]]; then
                rish -c "reboot"
            else
                echo -e "${RED}❌ Reboot canceled.${RESET}"
            fi
            read -n1 -s -r -p "Press any key to return to the menu..."
            ;;
        3)
            if [[ ! -f blacklist.txt ]]; then
                echo -e "${RED}❌ blacklist.txt not found! Please create this file with one package name per line.${RESET}"
            else
                echo -e "${BLUE}Current Game Driver Blacklist:${RESET}"
                current_blacklist=$(rish -c "settings get global game_driver_blacklist")
                if [[ -z "$current_blacklist" ]]; then
                    echo -e "${GREEN}No apps are currently blacklisted.${RESET}"
                else
                    # Print each package on a new line for readability
                    echo "$current_blacklist" | tr ',' '\n'
                fi
                blacklist=$(paste -sd, blacklist.txt)
                rish -c "settings put global game_driver_blacklist '$blacklist'"
                echo -e "${YELLOW}⚠️  All apps in blacklist.txt have been added to game_driver_blacklist.${RESET}"
                echo "  This step is based on a recommendation from a Reddit user:"
                echo -e "${BLUE}  https://www.reddit.com/r/GalaxyS23Ultra/comments/1kgnzru/comment/mr0qdd4/${RESET}"
                echo "  (It may help prevent crashes for some apps, but results may vary.)"
                echo "  To remove apps from the blacklist, edit blacklist.txt and run this step again."
                echo -e "${BLUE}Updated Game Driver Blacklist:${RESET}"
                current_blacklist=$(rish -c "settings get global game_driver_blacklist")
                if [[ -z "$current_blacklist" ]]; then
                    echo -e "${GREEN}No apps are currently blacklisted.${RESET}"
                else
                    # Print each package on a new line for readability
                    echo "$current_blacklist" | tr ',' '\n'
                fi
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
            echo -e "${YELLOW}You will see a persistent notification in the status bar, allowing you to control the overlay.${RESET}"
            echo ""
            read -n1 -s -r -p "Press any key to return to the menu..."
            ;;
        *)
            echo -e "${RED}Invalid choice${RESET}"
            ;;
    esac
done
