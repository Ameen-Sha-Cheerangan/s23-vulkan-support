# Enable Vulkan Renderer on Samsung S23 Using Shizuku and Termux(Don't use this now, testing phase)

A step-by-step guide to enabling the Vulkan graphics API on your Samsung Galaxy S23 device **directly on-device**-no computer required. This method uses [Shizuku](https://shizuku.rikka.app/) and [Termux](https://termux.com/) to grant privileged access for system property changes, improving graphics performance for gaming and demanding apps.

---

## ⚠️ Disclaimer

- **Enabling Vulkan may cause app crashes or system instability if there are conflicts.**
- This method worked fine on my device, but **your results may vary**.
- **Proceed at your own risk.** I am not responsible for any issues that may happen.
- **Backup your data** before proceeding.
- **Ensure you are connected to Wi-Fi** before starting.

---

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Tool Setup](#tool-setup)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)
- [Credits](#credits)
- [License](#license)

---

## Overview

**Vulkan** is a modern, low-overhead graphics API that offers improved performance and efficiency over older APIs like OpenGL-especially in gaming and graphics-heavy applications. This guide shows you how to enable Vulkan on your S23 device without needing a computer, using only Termux and Shizuku.

---

## Requirements

- Samsung Galaxy S23 
- [Shizuku](https://shizuku.rikka.app/) (from Google Play, F-Droid, or GitHub)
- [Termux](https://termux.com/) (from F-Droid or GitHub; **avoid Play Store version**)
- Wi-Fi connection

---

## Tool Setup

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

---
