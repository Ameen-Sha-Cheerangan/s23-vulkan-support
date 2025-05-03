#!/bin/bash

check_device() {
    if ! adb get-state 1>/dev/null 2>&1; then
        echo "❌ No device detected. Please connect your device and enable USB debugging."
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
    echo "ℹ️  If you do NOT launch all apps, some apps may not deliver notifications until you open them manually."
    echo ""
}

show_info() {
    clear
    echo "==== Info & Help ===="
    echo ""
    echo "• This script forces Vulkan rendering on your Samsung S23 device."
    echo "• Forcing Vulkan can improve performance and reduce heat."
    echo "• To revert to OpenGL, simply RESTART your device."
    echo "• You must re-run this script after every device reboot to keep Vulkan active."
    echo ""
    echo "• Option 2 (Launch All Apps) is NOT recommended unless necessary."
    echo "  It may cause battery drain and disrupt background processes."
    echo ""
    echo "• If you experience issues, simply reboot your device."
    echo ""
    read -n1 -s -r -p "Press any key to return to the menu..."
}

while true; do
    clear
    echo "==== S23 Vulkan Rendering Tool (Linux) ===="
    echo "1) Force Vulkan & Stop All Apps (Recommended)"
    echo "2) Launch All Apps (See Warnings)"
    echo "3) Info/Help"
    echo "4) Exit"
    echo ""
    echo "Note: Vulkan rendering must be re-applied after every device restart."
    read -p "Choose [1-4]: " choice

    case $choice in
        1)
            check_device || continue
            adb shell "(setprop debug.hwui.renderer skiavk;for a in \$(pm list packages|grep -v ia.mo|cut -f2 -d:);do am force-stop \"\$a\"&done)>/dev/null 2>&1&"
            echo ""
            echo "✅ Vulkan forced! All apps have been stopped."
            echo "ℹ️  To revert to OpenGL, simply restart your device."
            read -n1 -s -r -p "Press any key to return to the menu..."
            ;;
        2)
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
        3)
            show_info
            ;;
        4)
            exit 0
            ;;
        *)
            echo "Invalid choice"
            sleep 1
            ;;
    esac
done
