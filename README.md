# S23 Ultra Vulkan Linux Script

This script forces Vulkan rendering on any Samsung Galaxy S23 variant using ADB from Linux. It is believed or reported by users to improve performance, reduce device heat, and extend battery life by switching system rendering from OpenGL to Vulkan, though long-term effects have not been extensively tested by the author

---

## Features

- **Menu-driven interface** with safety warnings
- Forces Vulkan rendering via ADB
- Force-stops all apps to apply the change
- Optionally launches all apps (not recommended, see warnings)
- Clear instructions and user prompts

---

## Requirements

- Linux PC
- [ADB](https://developer.android.com/tools/adb) installed (`sudo apt install android-sdk-platform-tools`)
- Samsung Galaxy S23/S23+/S23U
- USB Debugging enabled on your phone (`Settings > Developer Options > USB Debugging`)
- A suitable USB cable for connection

---

## Installation
`git clone https://github.com/Ameen-Sha-Cheerangan/s23-ultra-vulkan-linux-script.git`

`cd s23-ultra-vulkan-linux-script`

`chmod +x opengl-to-vulkan.sh`

`./opengl-to-vulkan.sh`
Follow the on-screen menu instructions.


## Uninstall / Switch Back to OpenGL

To revert your device back to OpenGL rendering, **simply restart your phone**.  
No files or settings need to be removed-rebooting the device will reset the GPU renderer to its default (OpenGL).


---

## Warnings

- **Launching all apps is NOT recommended!**  
  This may wake up background/sleeping apps, increase battery drain.  
- If you do **not** relaunch all apps, some notifications from important apps may be delayed until you open them manually.
- Changes are **not permanent** and will reset after a device reboot.

---

## Credits

- Original Windows script and concept: [[popovicialinc](https://github.com/popovicialinc)
](https://github.com/popovicialinc/gama)
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
## License

MIT License. See [LICENSE](LICENSE) for details.
