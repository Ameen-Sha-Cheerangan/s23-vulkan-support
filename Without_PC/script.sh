#!/data/data/com.termux/files/usr/bin/bash

# Color codes
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
BOLD="\e[1m"
RESET="\e[0m"

clear
echo -e "${BOLD}${RED}==== NOTICE ====${RESET}"
echo -e "${YELLOW}This tool is provided for your convenience and makes changes to system settings.${RESET}"
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
read -n1 -s -r -p "Press any key to continue..."



show_warning() {
    clear
    echo "⚠️  WARNING: Launching all apps may:"
    echo "- Wake sleeping/background apps"
    echo "- Disrupt notification delivery"
    echo "- Increase battery consumption temporarily"
    echo ""
    echo "ℹ️  In rare cases if something might not load this might fix it. But I think you can directly launch it, that would be better"
    echo ""
}

show_info() {
    clear
    echo -e "${BOLD}${BLUE}==== Info & Help ==== ${RESET}"
    echo ""
    echo "• This script forces Vulkan rendering on your Samsung S23 device."
    echo "• Forcing Vulkan can improve performance and reduce heat."
    echo "• To revert to OpenGL, simply RESTART your device."
    echo "• You must re-run this script after every device reboot to keep Vulkan active."
    echo ""
    echo "• If you have blacklisted apps via the Game Driver blacklist and want to remove all of them, run:"
    echo -e "  ${YELLOW}rish -c "settings put global game_driver_blacklist ''"${RESET}"
    echo "  This will clear the blacklist so all apps can use the Game Driver again."
    echo ""
    echo "• If you experience issues, simply reboot your device."
    echo ""
    read -n1 -s -r -p "Press any key to return to the menu..."
}

while true; do
    # set -x  # Enable trace mode
    clear

    echo -e "${BLUE}GitHub: https://github.com/Ameen-Sha-Cheerangan/s23-vulkan-linux-script${RESET}"
    echo -e "${BOLD}${BLUE}==== S23/S23+/S23U Vulkan Rendering Tool (Linux) ==== ${RESET}"
    echo "1) Switch to Vulkan(Recommended)"
    echo "2) Switch to OpenGL (Reboot Device)"
    echo "3) Blacklist Apps from Game Driver (Prevent Crashes for Listed Apps)"
    echo "4) Info/Help"
    echo "5) Exit"
    echo "6) Launch All Apps (See Warnings, Not at all recommended)"

    echo ""
    echo -e "${YELLOW}Note: Vulkan rendering must be re-applied after every device restart.${RESET}"
    read -p "Choose [1-6]: " choice

    case $choice in
        1)
            echo -e "${YELLOW}How aggressive should the script be when stopping apps?${RESET}"
            echo -e "${GREEN}1) Normal (only restart key system apps: SystemUI, Settings, Launcher, AOD, Keyboard)${RESET}"
            echo -e "${GREEN}2) Aggressive (force-stop ALL apps and Relaunch Previously Running Apps and Widgets; ensures Vulkan is applied everywhere) [Recommended if you can read little more for the workarounds]${RESET}"
            echo ""
            echo "   Note: Some users have reported that using the Aggressive option can cause:"
            echo "     - The default browser and default keyboard to be reset."
            echo "     - Loss of WiFi-Calling/VoLTE capability."
            echo "       Fix: Go to Settings > Connections > SIM manager, then toggle SIM 1/2 off and back on."
            echo ""
            echo "   (Many thanks to Fun-Flight4427 and ActualMountain7899 for reporting the bug and finding a solution.)"
            echo "   This information and workaround are based on reports and documentation from the GAMA project:"
            echo -e "${BLUE}   https://github.com/popovicialinc/gama${RESET}"
            echo ""
            read -p "Choose [1-2]: " aggressive_choice

            if [[ $aggressive_choice == "1" ]]; then
                rish -c "setprop debug.hwui.renderer skiavk"
                rish -c "am crash com.android.systemui"
                rish -c "am force-stop com.android.settings"
                rish -c "am force-stop com.sec.android.app.launcher"
                rish -c "am force-stop com.samsung.android.app.aodservice"
                rish -c "am crash com.google.android.inputmethod.latin b"
                echo -e "${GREEN}✅ Vulkan forced! Key system apps have been restarted.${RESET}"
            else
                > "app_to_restart.txt"
                > "app_to_restart.txt"
                > "force_stop_errors.log"
                > "running_apps.log"
                rish -c "dumpsys package | grep 'Package \[' | cut -d '[' -f2 | cut -d ']' -f1" | grep -v "ia.mo" | grep -v "com.google.android.trichromelibrary" | grep -v "com.netflix.mediaclient" | grep -v "com.termux"| grep -v "moe.shizuku.privileged.api"| grep -v "com.google.android.gsf"|sort -u > all_packages.txt

                rish -c "dumpsys activity processes" > running_apps.log

                while read pkg; do
                    if grep -q "$pkg" running_apps.log; then
                        echo "$pkg" >> "app_to_restart.txt"
                    fi
                done < all_packages.txt

                cp all_packages.txt /sdcard/all_packages.txt
                rish -c "
                    # Count total packages for progress reporting
                    total=\$(wc -l < /sdcard/all_packages.txt)
                    count=0

                    while IFS= read -r pkg; do
                        am force-stop "$pkg"
                        echo "$pkg"
                        count=\$((count + 1))
                        # printf \"\\rProgress: %d/%d packages stopped - %s\" \$count \$total \"\$pkg\"
                    done < /sdcard/all_packages.txt
                    echo ""
                    echo \"All \$total packages have been stopped successfully.\"
                "


                #     # Count total packages for progress reporting
                # total=\$(wc -l < /sdcard/all_packages.txt)
                # count=0

                # while IFS= read -r pkg; do
                #     rish -c "am force-stop \"\$pkg\""
                #     count=\$((count + 1))
                #     printf \"\\rProgress: %d/%d packages stopped - %s\" \$count \$total \"\$pkg\"
                # done < /sdcard/all_packages.txt
                echo ""
                echo \"All \$total packages have been stopped successfully.\"


                echo ""
                echo -e "${GREEN}✅ Vulkan forced! All apps have been stopped.${RESET}"
                # dumpsys appwidget | awk '/^Widgets:/{flag=1; next} /^Hosts:/{flag=0} flag' | grep "provider=" | grep -oP 'ComponentInfo\{\K[^/]+' >> app_to_restart.txt # Getting all widget providers

                # sort -u app_to_restart.txt -o app_to_restart.txt # Removing duplicates

                # am force-stop com.sec.android.app.launcher
                # sleep 2
                # monkey -p com.sec.android.app.launcher -c android.intent.category.LAUNCHER 1

                # "while read pkg; do monkey -p \"\$pkg\" -c android.intent.category.LAUNCHER 1; done" < app_to_restart.txt

                # echo -e "${YELLOW}⚠️  All previously running apps and widget providers have been restarted. Some widgets may require just a tap.${RESET}"

            fi
            # rm -f all_packages.txt app_to_restart.txt force_stop_errors.log running_apps.log
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
            echo -e "${BLUE}GitHub: https://github.com/Ameen-Sha-Cheerangan/s23-vulkan-linux-script${RESET}"
            echo -e "For updates, visit the GitHub repo above."
            exit 0
            ;;
        6)
            show_warning
            read -p "Type 'YES' to continue: " confirm
            if [[ $confirm == "YES" ]]; then
                for pkg in $(pm list packages | cut -f2 -d:); do
                    monkey -p "$pkg" -c android.intent.category.LAUNCHER 1
                done
                echo "⚠️  All apps launched! Close unused apps from Recents immediately."
            else
                echo "❌ Launch canceled."
            fi
            read -n1 -s -r -p "Press any key to return to the menu..."
            ;;
        *)
            echo -e "${RED}Invalid choice${RESET}"
            sleep 1
            ;;
    esac
done
