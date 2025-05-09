# S23/S23+/S23U Vulkan Rendering Tool (Linux)

A simple menu-driven Bash script to force Vulkan rendering on any Samsung Galaxy S23 variant via ADB from Linux.  
Tested by the author on S23U, and based on community recommendations, this tool may improve performance, reduce device heat, and extend battery life.  
**All changes are temporary and revert on device reboot.**

---

## Features

- Easy menu-driven interface with safety warnings and notices
- Forces Vulkan rendering via ADB
- Stops all apps and relaunches previously running apps and widgets
- Blacklist apps from Game Driver (based on [Reddit recommendation](https://www.reddit.com/r/GalaxyS23Ultra/comments/1kgnzru/comment/mr0qdd4/))
- Clear instructions and user prompts

---

## Requirements

- Linux PC
- [ADB](https://developer.android.com/tools/adb) installed (usually pre-installed on most Linux distros)
      Ubuntu - (`sudo apt-get update && sudo apt-get install android-sdk-platform-tools gawk grep coreutils`)
      Fedora/RHEL/CentOS - (`sudo dnf install android-tools gawk grep coreutils`)
- Samsung Galaxy S23/S23+/S23U
- USB Debugging enabled on your phone (`Settings > Developer Options > USB Debugging`)
- A suitable USB cable for connection

---

## Installation / How to switch to Vulkan
Clone the repository (do this once):
`git clone https://github.com/Ameen-Sha-Cheerangan/s23-ultra-vulkan-linux-script.git`

`cd s23-ultra-vulkan-linux-script`

`chmod +x opengl-to-vulkan.sh`

**Running (repeat after every device restart):**

`./opengl-to-vulkan.sh`

Follow the on-screen menu instructions.


## Uninstall / Switch Back to OpenGL

To revert your device back to OpenGL rendering, **simply restart your phone**.  
No files or settings need to be removed-rebooting the device will reset the GPU renderer to its default (OpenGL).


---

## Warnings

- **All changes are temporary!** Vulkan rendering will reset after a device reboot.
- **Launching all apps is NOT recommended!**  
  This may wake up background/sleeping apps and increase battery drain.
- If you do **not** relaunch all apps, some notifications from important apps may be delayed until you open them manually.
- The blacklist feature is based on a Reddit user's recommendation and may not work for everyone.


## Standard Disclaimer (Just in Case!)

This script is provided for your convenience.  
I've tested it extensively on my own device and haven't seen any issues,  
but just to be safe (for both of us!), I'm including this notice:

- It makes changes to system settings. Please use responsibly.
- If you have any concerns, consider backing up your data first.
- Please do not use this tool for any harmful or inappropriate purposes.
- By using this tool, you accept responsibility for your actions.

While issues are very unlikely, always proceed with care.  
The author is not responsible for any unexpected issues, data loss, or device instability that may arise from use of this tool.  
This is not an official Samsung or Google product.

---

## Credits

- Original Windows script and concept: https://github.com/popovicialinc/gama
- Game Driver blacklist workaround suggested by [Swimming_Minimum6147](https://www.reddit.com/r/GalaxyS23Ultra/comments/1kgnzru/comment/mr0qdd4/) on Reddit
---

## How to Check if Vulkan is Active

To verify that Vulkan rendering is enabled:

1. **Open Developer Options** on your device.
2. **Enable GPUWatch.**
3. **Open any app** (for example, the Dialer).
4. GPUWatch will display an overlay-look for the renderer information.
   - If Vulkan is active, it will show something like: **Vulkan Renderer (skiavk)**

This is the easiest way to confirm that Vulkan is running on your Galaxy S23 device.

---
## Issues

If you find any issues or have suggestions, please [open an issue](https://github.com/Ameen-Sha-Cheerangan/s23-vulkan-linux-script/issues).

If you found this tool helpful, please consider giving it a ⭐ on [GitHub](https://github.com/Ameen-Sha-Cheerangan/s23-vulkan-linux-script)!


---
## License

MIT License. See [LICENSE](LICENSE) for details.
