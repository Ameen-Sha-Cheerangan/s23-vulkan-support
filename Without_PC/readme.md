# Enable Vulkan Renderer on Samsung S23 Using Shizuku and Termux

A step-by-step guide to enabling the Vulkan graphics API on your Samsung Galaxy S23 device **directly on-device**-no computer required. This method uses [Shizuku](https://shizuku.rikka.app/) and [Termux](https://termux.com/) to grant privileged access for system property changes. Enabling Vulkan graphics API potentially improves performance, reduces heat, and extends battery life according to reports from Reddit users.
Credits : [adam444555](https://www.reddit.com/user/adam444555/) for this [post](https://www.reddit.com/r/GalaxyS23Ultra/comments/1kbisga/full_tutorial_enable_vulkan_on_s23u_without_pc/)

### This is a simplified guide for mobile users. For complete details including limitations, benefits, and FAQs, please refer to the [main README](https://github.com/Ameen-Sha-Cheerangan/s23-vulkan-support/blob/main/README.md).

---

## ⚠️ Disclaimer

- **Enabling Vulkan may cause app crashes or system instability if there are conflicts.**
- This method worked fine on my device, but **your results may vary**.
- **Proceed at your own risk.** I am not responsible for any issues that may happen.
- **Backup your data** before proceeding.
- **Ensure you are connected to Wi-Fi(Not Mobile Data)** before starting.

---

## Overview

**Vulkan** is a modern, low-overhead graphics API that offers improved performance and efficiency over older APIs like OpenGL. This guide shows you how to enable Vulkan on your S23 device without needing a computer, using only Termux and Shizuku.

---

## Requirements

- Samsung Galaxy S23 
- [Shizuku](https://shizuku.rikka.app/) (from Google Play, F-Droid, or GitHub)
- [Termux](https://termux.com/) (from F-Droid or GitHub; **avoid Play Store version**)
- Wi-Fi connection

---

## Tool Setup (This is initial setup; you just need to do it one time ; It is not that hard )

1. **Install Shizuku**
   - Download from [Google Play](https://play.google.com/store/apps/details?id=moe.shizuku.privileged.api), [F-Droid](https://f-droid.org/packages/moe.shizuku.privileged.api/), or [GitHub](https://github.com/RikkaApps/Shizuku).
2. **Install Termux**
   - Use [F-Droid](https://f-droid.org/packages/com.termux/) or [GitHub](https://github.com/termux/termux-app/releases).
   - **Avoid the Play Store version** (it’s experimental and may not work properly).
3. **Start the Shizuku service**
   - Open the Shizuku app and follow the instructions to start the service (usually via wireless debugging).
4. **Enable Shizuku for terminal apps**
   - In Shizuku, tap **"Use Shizuku in terminal apps"**.
5. **Export Shizuku files**
   - Tap **"Export files"** in Shizuku, choose the **Download** folder, create a folder named `shizuku`, select it, and confirm with **"Use this folder"**.
6. **Set up Termux storage**
   - Open Termux and run:
     ```
     termux-setup-storage
     ```
7. **Move and configure Shizuku files in Termux**
   - Run the following commands in Termux:
     ```
     mkdir -p ~/.local/bin
     mv ~/storage/downloads/shizuku/* ~/.local/bin/
     sed -i 's/PKG/com.termux/g' ~/.local/bin/rish
     chmod 777 ~/.local/bin/rish
     echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
     . .bashrc
     ```
   - This sets up the `rish` command for privileged operations in Termux.
8. **Install dependencies**
   - ```
     cd ~ && apt update && apt upgrade && apt install git wget unzip coreutils grep gawk
     ```


---

9. Clone the repo and run the script(to take the latest release)

```
api_response=$(curl -s https://api.github.com/repos/Ameen-Sha-Cheerangan/s23-vulkan-support/releases/latest)
latest_version=$(echo "$api_response" | grep -o '"tag_name": *"[^"]*"' | cut -d'"' -f4)
latest_version_clean=$(echo "$latest_version" | sed 's/^v//')
cd ~
rm -rf s23-vulkan-*
wget https://github.com/Ameen-Sha-Cheerangan/s23-vulkan-support/archive/refs/tags/$latest_version.zip
unzip $latest_version*.zip && rm $latest_version*.zip* && cd s23-vulkan-support-$latest_version && cd Without_PC
chmod +x script.sh
./script.sh
```

10. Follow the instructions.

---
## After Device Restart

**Note:** You only need to reapply Vulkan after a normal device restart. Samsung's auto-optimization restarts will NOT reset Vulkan rendering.

### Option 1: Get Latest Version (Recommended)
Run this command to download and apply the latest version (requires internet connection):
```
api_response=$(curl -s https://api.github.com/repos/Ameen-Sha-Cheerangan/s23-vulkan-support/releases/latest)
latest_version=$(echo "$api_response" | grep -o '"tag_name": *"[^"]*"' | cut -d'"' -f4)
latest_version_clean=$(echo "$latest_version" | sed 's/^v//')
cd ~
rm -rf s23-vulkan-*
wget https://github.com/Ameen-Sha-Cheerangan/s23-vulkan-support/archive/refs/tags/$latest_version.zip
unzip $latest_version*.zip && rm $latest_version*.zip* && cd s23-vulkan-support-$latest_version && cd Without_PC
chmod +x script.sh
./script.sh
```
### Option 2: Use Existing Installation(>=2.4.9 ; Please don't use builds before that)

If you don't have internet access or want to use your existing installation:
```
 cd ~/s23-vulkan-support*/Without_PC && ./script.sh
```

---


