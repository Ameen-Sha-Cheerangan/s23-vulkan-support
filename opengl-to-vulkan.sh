#!/bin/bash

# Color codes
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
BOLD="\e[1m"
RESET="\e[0m"

clear
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
read -n1 -s -r -p "Press any key to continue..."


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
    echo -e "  ${YELLOW}adb shell settings put global game_driver_blacklist ''${RESET}"
    echo "  This will clear the blacklist so all apps can use the Game Driver again."
    echo ""
    echo "• If you experience issues, simply reboot your device."
    echo ""
    read -n1 -s -r -p "Press any key to return to the menu..."
}

while true; do
    # set -x  # Enable trace mode
    clear
    echo -e "${BOLD}${BLUE}==== S23 Vulkan Rendering Tool (Linux) ==== ${RESET}"
    echo "1) Force Vulkan, Stop All Apps, and Relaunch Previously Running Apps and Widgets(Recommended)"
    echo "2) Switch to OpenGL (Reboot Device)"
    echo "3) Blacklist Apps from Game Driver (Prevent Crashes for Listed Apps)"
    echo "4) Info/Help"
    echo "5) Exit"
    echo "6) Launch All Apps (See Warnings, Not Recommended)"

    echo ""
    echo -e "${YELLOW}Note: Vulkan rendering must be re-applied after every device restart.${RESET}"
    read -p "Choose [1-6]: " choice

    case $choice in
        1)
            check_device || continue
            > "all_packages.txt"
            > "app_to_restart.txt"
            > force_stop_errors.log
            > "running_apps.log"
            adb shell '
                for pkg in $(pm list packages | grep -v ia.mo | cut -f2 -d:); do
                    echo "$pkg"
                done
            ' 2>/dev/null | sort > all_packages.txt

            adb shell dumpsys activity processes > running_apps.log

            while read pkg; do
                if grep -q "$pkg" running_apps.log; then
                    echo "$pkg" >> "app_to_restart.txt"
                fi
            done < all_packages.txt

            adb shell "
                setprop debug.hwui.renderer skiavk;
                for a in \$(pm list packages | grep -v ia.mo | cut -f2 -d:); do
                    am force-stop \"\$a\" &
                done
                wait
            " > /dev/null 2> force_stop_errors.log
            echo ""

            echo -e "${GREEN}✅ Vulkan forced! All apps have been stopped.${RESET}"
            adb shell dumpsys appwidget | awk '/^Widgets:/{flag=1; next} /^Hosts:/{flag=0} flag' | grep "provider=" | grep -oP 'ComponentInfo\{\K[^/]+' >> app_to_restart.txt # Getting all widget providers

            sort -u app_to_restart.txt -o app_to_restart.txt # Removing duplicates

            adb shell am force-stop com.sec.android.app.launcher
            sleep 2
            adb shell monkey -p com.sec.android.app.launcher -c android.intent.category.LAUNCHER 1

            adb shell "while read pkg; do monkey -p \"\$pkg\" -c android.intent.category.LAUNCHER 1; done" < app_to_restart.txt

            echo -e "${YELLOW}⚠️  All previously running apps and widget providers have been restarted. Some widgets may require just a tap.${RESET}"

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
                blacklist=$(paste -sd, blacklist.txt)
                adb shell settings put global game_driver_blacklist "$blacklist"
                echo -e "${YELLOW}⚠️  All apps in blacklist.txt have been added to game_driver_blacklist."
                echo "  This step is based on a recommendation from a Reddit user:"
                echo "  https://www.reddit.com/r/GalaxyS23Ultra/comments/1kgnzru/comment/mr0qdd4/"
                echo "  (It may help prevent crashes for some apps, but results may vary.)"
                echo "  To remove apps from the blacklist, edit blacklist.txt and run this step again."
                echo -e "${RESET}"
            fi
            read -n1 -s -r -p "Press any key to return to the menu..."
            ;;
        4)
            show_info
            ;;
        5)
            rm -f all_packages.txt app_to_restart.txt force_stop_errors.log running_apps.log
            echo -e "${GREEN}Thank you for using the S23 Vulkan Rendering Tool!${RESET}"
            echo -e "If you found this tool helpful, please consider giving it a ⭐ on the GitHub repo!"
            echo "GitHub: https://github.com/Ameen-Sha-Cheerangan/s23-vulkan-linux-script"
            exit 0
            ;;
        6)
            show_warning
            read -p "Type 'YES' to continue: " confirm
            if [[ $confirm == "YES" ]]; then
                check_device || continue
                adb shell "for pkg in \$(pm list packages | cut -f2 -d:); do monkey -p \"\$pkg\" -c android.intent.category.LAUNCHER 1; done"
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
