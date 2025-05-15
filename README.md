# S23/S23+/S23U Vulkan Rendering Tool (Linux / From Phone itself)

A simple menu-driven Bash script to force Vulkan rendering on any Samsung Galaxy S23 variant via ADB from Linux.  
Tested by the author on S23U, and based on community recommendations, this tool may improve performance, reduce device heat, and extend battery life.  
**All changes are temporary and revert on device reboot.(not the auto-optimization restart)**

---
## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Vulkan Modes](#vulkan-modes)
- [Requirements](#requirements)
- [Installation](#installation)
- [Additional Notes](#additional-notes)
- [Uninstall / Switch Back to OpenGL](#uninstall--switch-back-to-opengl)
- [Warnings](#warnings)
- [Disclaimer](#standard-disclaimer-just-in-case)
- [Credits](#credits)
- [How to Check if Vulkan is Active](#how-to-check-if-vulkan-is-active)
- [FAQ](#faq)
- [Issues](#issues)
- [License](#license)

---

## Overview

**Vulkan** is a modern, low-overhead graphics API that offers improved performance and efficiency over older APIs like OpenGL-especially in gaming and graphics-heavy applications. This guide shows you how to enable Vulkan on your S23 device without needing a computer, using only Termux and Shizuku.

---

## Features

- Easy menu-driven interface with safety warnings and notices
- Forces Vulkan rendering via ADB
- Offers two modes for applying Vulkan:
   - **Normal mode** :  Only restarts key system apps (recommended for most users; avoids most issues)
   - **Aggressive mode** :  More complete procedure;(force-stops most of the apps(some are excluded due to various reasons) and Relaunch Previously Running Apps and Widgets;)
                        I have fixed most of the bugs known except, gallery frame not loading. 
- Blacklist apps from Game Driver to prevent crashes(based on [Reddit recommendation](https://www.reddit.com/r/GalaxyS23Ultra/comments/1kgnzru/comment/mr0qdd4/)), based on his recommend
- Clear instructions and user prompts

---
## Vulkan Modes

### Basic Mode
- Only restarts key system apps (SystemUI, Settings, Launcher, AOD, Keyboard)
- Quick (completes in seconds)
- Suitable for users who want a fast application of Vulkan

### Complete Mode
- Force-stops most apps and intelligently relaunches previously running apps and widgets
- More thorough application of Vulkan across the entire system
- Takes slightly longer to complete (1-2 minutes)
- Recommended for users who want the most comprehensive Vulkan implementation
- All previously reported bugs have been fixed in this version
---

## Requirements

- Linux PC
- [ADB](https://developer.android.com/tools/adb) installed (usually pre-installed on most Linux distros)
      Ubuntu - (`sudo apt-get update && sudo apt-get install android-sdk-platform-tools gawk grep coreutils unzip`)
      Fedora/RHEL/CentOS - (`sudo dnf install android-tools gawk grep coreutils unzip`)
- Samsung Galaxy S23/S23+/S23U
- USB Debugging enabled on your phone (`Settings > Developer Options > USB Debugging`)
- A suitable USB cable for connection

---

## Installation / How to switch to Vulkan

Paste this in the terminal. This is will install the latest release and run the script
```
api_response=$(curl -s https://api.github.com/repos/Ameen-Sha-Cheerangan/s23-vulkan-support/releases/latest)
latest_version=$(echo "$api_response" | grep -o '"tag_name": *"[^"]*"' | cut -d'"' -f4)
latest_version_clean=$(echo "$latest_version" | sed 's/^v//')
wget https://github.com/Ameen-Sha-Cheerangan/s23-vulkan-support/archive/refs/tags/$latest_version.zip
unzip $latest_version*.zip && rm $latest_version*.zip* && cd s23-vulkan-support-$latest_version
chmod +x opengl-to-vulkan.sh
./opengl-to-vulkan.sh
```
Follow the on-screen menu instructions.

`./opengl-to-vulkan.sh` can be used to execute the script after restart(auto-optimisation restart doesn't need reapplying, as it won't revert to OpenGL). But I recommend the whole commands in the above block to be pasted in terminal as it will download the latest release and run the script in that.

---

## 🔸 Additional Notes

- All changes made by the script are **temporary** and will **reset on device reboot**.
- **Visual Artifacts**  
  Some users may experience visual glitches or artifacting when Vulkan is enabled. While Adreno GPUs in the S23 series usually handle Vulkan well, your experience may vary.

- **App Compatibility**  
  Not all apps will run properly under Vulkan. The majority do, but exceptions exist due to incomplete support from Samsung and app developers. There has been some methods shared in reddit community like below(3rd option when you run the script)
  - Game Driver blacklist workaround suggested by [Swimming_Minimum6147](https://www.reddit.com/r/GalaxyS23Ultra/comments/1kgnzru/comment/mr0qdd4/) on Reddit
  
---

## Uninstall / Switch Back to OpenGL

- To revert your device back to OpenGL rendering, **simply restart your phone**.  
- No files or settings need to be removed-rebooting the device will reset the GPU renderer to its default (OpenGL).


---

## Warnings

- **All changes are temporary!** Vulkan rendering will reset after a device reboot.(auto-optimisation restart won't remove the changes though)
- The blacklist feature is based on a Reddit user's recommendation and may not work for everyone.


---
## Standard Disclaimer (Just in Case!)

This script is provided "as is" without warranties. While extensively tested and issues are very unlikely, it modifies system settings and may cause unexpected behavior. The author is not responsible for any issues that may arise. Always back up your data before proceeding. This is not an official Samsung or Google product.

---

## Credits

- Original Windows script and concept: https://github.com/popovicialinc/gama
- Game Driver blacklist workaround suggested by [Swimming_Minimum6147](https://www.reddit.com/r/GalaxyS23Ultra/comments/1kgnzru/comment/mr0qdd4/) on Reddit
- Thanks for testing : [Verix](https://github.com/Veriiix)
---

## How to Check if Vulkan is Active

To verify that Vulkan rendering is enabled:

1. **Open Developer Options** on your device.
2. **Enable GPUWatch.**
3. **Open any app** (for example, the Dialer).
4. GPUWatch will display an overlay-look for the renderer information.
   - If Vulkan is active, it will show something like: **Vulkan**

This is the easiest way to confirm that Vulkan is running on your Galaxy S23/S23+/S23U device.

---
## FAQ

### What is Vulkan, why should I switch to it?

Vulkan is a modern graphics API that offers more efficient, low-overhead access to your device’s GPU compared to OpenGL. Switching to Vulkan can improve performance, reduce device heat, and extend battery life as reported by reddit users in S23 Ultra reddit community.


### I see error related to "user 150" in the output. Is this a problem?

No, this is expected and harmless. This message appears because some apps-such as those inside Samsung Secure Folder or other secondary user profiles-cannot be controlled by ADB shell commands unless the device is rooted. The shell user (used by ADB) only has permission to control apps for the main device user (user 0), not for additional users like user 150 (which is typically Secure Folder). Your main device user (user 0) is still fully handled by the script, and this message can be safely ignored

---
## Issues

If you find any issues or have suggestions, please [open an issue](https://github.com/Ameen-Sha-Cheerangan/s23-vulkan-support/issues).

If you found this tool helpful, please consider giving it a ⭐ on [GitHub](https://github.com/Ameen-Sha-Cheerangan/s23-vulkan-support)!

---

## License

MIT License. See [LICENSE](LICENSE) for details.
