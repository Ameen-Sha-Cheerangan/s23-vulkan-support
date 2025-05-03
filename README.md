# S23 Ultra Vulkan Linux Script

This script forces Vulkan rendering on any Samsung Galaxy S23 variant using ADB from Linux. It improves performance, reduces device heat, and extends battery life by switching system rendering from OpenGL to Vulkan.

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
- Original USB cable for connection

---

## Installation
git clone https://github.com/yourusername/s23-ultra-vulkan-linux-script.git
cd s23-ultra-vulkan-linux-script
chmod +x vulkan_switch.sh


---

## Usage
Follow the on-screen menu instructions.

---

## Warnings

- **Launching all apps is NOT recommended!**  
  This may wake up background/sleeping apps, increase battery drain.  
- If you do **not** relaunch all apps, some notifications from important apps may be delayed until you open them manually.
- Changes are **not permanent** and will reset after a device reboot.

---

## Credits

- Original Windows script and concept: [popovicialinc](https://github.com/popovicialinc)
- Linux adaptation & enhancements: [Ameen-Sha-Cheerangan]

---

## License

MIT License. See [LICENSE](LICENSE) for details.
