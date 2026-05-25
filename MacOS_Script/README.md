# macOS Vulkan Script for Samsung S23

This folder contains a macOS-friendly script for forcing Vulkan rendering on Samsung Galaxy S23/S23+/S23U devices over ADB.

The script is based on the v2.6.0 PC flow, but avoids GNU-only command options, uses macOS-safe terminal output, and writes temporary files under macOS temp storage with `mktemp`.

## Requirements

- macOS
- [ADB platform tools](https://developer.android.com/tools/adb)
- Samsung Galaxy S23/S23+/S23U
- USB Debugging enabled on the phone: `Settings > Developer Options > USB Debugging`
- A USB cable that supports data transfer

Install ADB with Homebrew:

```bash
brew install android-platform-tools
```

Verify the phone is visible:

```bash
adb devices
```

## Run

From this folder:

```bash
chmod +x opengl-to-vulkan-macos.sh
./opengl-to-vulkan-macos.sh
```

The full Vulkan flow is the default recommended menu action.

## Demo

![macOS Vulkan script demo](demo.gif)

## Shortcuts

You can skip the interactive menu with these flags:

```bash
./opengl-to-vulkan-macos.sh --full       # Apply full Vulkan and restart most apps
./opengl-to-vulkan-macos.sh --basic      # Apply Vulkan and restart only key system apps
./opengl-to-vulkan-macos.sh --blacklist  # Apply packages from blacklist.txt
./opengl-to-vulkan-macos.sh --reboot     # Reboot the phone to revert to OpenGL
./opengl-to-vulkan-macos.sh --updates    # Check for a newer release
./opengl-to-vulkan-macos.sh --help       # Show help
```

## Blacklist

Edit `blacklist.txt` in this folder and add one package name per line.

Example:

```text
com.example.problematicapp
```

Then run:

```bash
./opengl-to-vulkan-macos.sh --blacklist
```

The blacklist feature is based on a community workaround and may help with apps that crash or behave badly with Vulkan rendering.

## Reverting to OpenGL

The renderer change is temporary. To revert to OpenGL, reboot the phone:

```bash
./opengl-to-vulkan-macos.sh --reboot
```

Samsung auto-optimization restarts should not reset Vulkan rendering. A full device reboot does.

## Notes

- Temporary files are created under macOS temp storage and removed when the script exits.
- The script checks for ADB and an attached device before reading phone settings.
- If you experience issues after enabling Vulkan, reboot the phone.
