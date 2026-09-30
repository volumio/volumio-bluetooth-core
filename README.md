# Volumio Bluetooth Core

The **Volumio Bluetooth Core** project is designed to provide a streamlined and high-quality Bluetooth audio experience for Volumio OS, focused on improving Bluetooth audio handling, volume behavior, and system integration. It tackles longstanding Bluetooth issues, such as metadata transmission, volume synchronization, and ensuring optimal audio quality for audiophile use.

## 🎯 Purpose

Volumio is a high-quality audio streaming solution designed for audiophiles, prioritizing the shortest possible audio path between the music source and sound output. Bluetooth support is a critical feature, allowing users to connect wireless audio devices with Volumio while maintaining high fidelity.

However, Volumio’s current Bluetooth implementation presents several challenges:

- **Volume Behavior**: Controlling the volume across Bluetooth-connected devices has been inconsistent, with some devices not responding properly to volume changes. This project aims to fix bidirectional volume control, ensuring that both Volumio and Bluetooth-connected devices can control volume seamlessly.
- **Metadata Handling**: Volumio has faced challenges with Bluetooth metadata, such as track information and playback status, not syncing properly with the UI. This project focuses on improving metadata transmission, ensuring that information like track name, artist, and playback status is consistent across the system.
- **Audio Quality**: Maintaining bit-perfect audio quality via Bluetooth is essential for Volumio's audiophile users. This project ensures that Bluetooth audio streaming uses the A2DP (Advanced Audio Distribution Profile) for high-fidelity playback, avoiding low-quality profiles like HFP (Hands-Free Profile).

## ⚙️ Key Features

- **BlueZ-ALSA Integration**: Replaces the older PulseAudio-based Bluetooth stack with **BlueZ-ALSA** (`bluez-alsa-utils`), reducing audio latency and providing better control over Bluetooth audio output.
- **Bidirectional Volume Control**: Ensures that volume changes in Volumio are reflected on Bluetooth devices and vice versa. This feature allows users to control the volume from either the Volumio interface or the connected Bluetooth device.
- **Metadata Synchronization**: Updates the handling of Bluetooth metadata, such as track information, play/pause status, and volume changes. This ensures that the Volumio UI remains up-to-date with what's playing on the Bluetooth-connected device.
- **Bit-Perfect Audio**: Focuses on ensuring that audio output from Volumio remains at the highest quality by using A2DP for Bluetooth connections, while explicitly rejecting low-fidelity profiles like HFP to prevent degradation of the audio stream.

## 🔧 Requirements

- **Volumio OS**: This project targets Volumio OS, which is based on Debian, and requires compatibility with multiple architectures (armhf, arm64, amd64).
- **BlueZ**: The core Bluetooth stack for Linux, specifically version 5.83, for managing Bluetooth connections and streaming.
- **BlueZ-ALSA (bluez-alsa-utils)**: Replaces PulseAudio for Bluetooth audio routing to ensure bit-perfect audio output with low latency.


## 🧭 Architecture Support

This project supports the following architectures:

- **ARMv6** – Pi Zero, Pi 1, Pi 2 (in 32-bit mode)
- **ARMv7** – Pi 2, Pi 3 (32-bit)
- **ARM64** – Pi 3, Pi 4, Pi 5 (64-bit builds, future-facing)
- **x86_64** – Intel/AMD Volumio platforms

> **Note:** Volumio currently uses a single **32-bit universal image** for all Raspberry Pi models (0–5). All builds target **ARMv6 with hard-float (VFP) ABI**, which ensures compatibility across both older and newer boards.


## 🧠 Why Target ARMv6 + VFP?

Volumio uses a single unified 32-bit userland for all Raspberry Pi models, from **Pi Zero** to **Pi 5**. To ensure compatibility across this range, builds are compiled using:

```bash
-march=armv6 -mfpu=vfp -mfloat-abi=hard -marm
```

This produces **ARMv6-compatible binaries with hard-float support (VFP)**.

### Why not target newer instruction sets?

- **ARMv7 or ARMv8** builds would break compatibility with older Pi models (like Pi Zero and Pi 1).
- **Soft-float ABI** (used on `armel`) is incompatible with Volumio’s core system, which is built around `armhf` with hardware float (hard-float).
- **ARMv6 hard-float** serves as a **lowest common denominator** — working on all Pi generations while still offering floating-point performance.

### Does this limit performance on newer boards?

No. While newer Pi boards (Pi 4, Pi 5) support more advanced instruction sets, they **remain fully backward-compatible** with ARMv6 and VFP binaries. The performance impact is negligible for audio processing workloads, and ensures that a **single set of `.deb` packages** can be safely deployed across all supported devices.

## 🛠️ Installation

### 1. Prepare the Source

Begin by running the `extract-bluez-source.sh` and `extract-bluez-alsa-utils-source.sh` scripts to prepare the necessary **BlueZ** and **bluez-alsa-utils** source files and Debian packaging metadata:

```bash
./scripts/extract-bluez-source.sh
```

This script will:

- Extract BlueZ 5.83 source.
- Set up the required packaging metadata for building the BlueZ package.

```bash
./scripts/extract-bluez-alsa-utils-source.sh
```

This script will:

- Extract **bluez-alsa 4.3.1** source.
- Set up the required packaging metadata for building the **bluez-alsa-utils** package.

### 2. Build the BlueZ and BlueZ-ALSA Utils Packages

Once the source is prepared, you can build the **BlueZ** and **bluez-alsa-utils** packages using the Docker setup:

```bash
# Build for ARMv7 (armhf)
./docker/run-docker-bluez.sh bluez armhf --verbose
./docker/run-docker-bluez-alsa-utils.sh bluez-alsa-utils armhf --verbose

# Build for ARMv8 (arm64)
./docker/run-docker-bluez.sh bluez arm64 --verbose
./docker/run-docker-bluez-alsa-utils.sh bluez-alsa-utils arm64 --verbose

# Build for x86_64 (amd64)
./docker/run-docker-bluez.sh bluez amd64 --verbose
./docker/run-docker-bluez-alsa-utils.sh bluez-alsa-utils amd64 --verbose

# Build for ARMv6 (universal Pi)
./docker/run-docker-bluez.sh bluez armv6 --verbose
./docker/run-docker-bluez-alsa-utils.sh bluez-alsa-utils armv6 --verbose
```

Packages will be placed in the `out/` directory for each architecture.

### 3. Install the Packages on Volumio OS

```bash
# Example: install on ARMv6 / universal Pi image
dpkg -i out/armv6/bluez_5.83-1volumio3_arm.deb
dpkg -i out/armv6/libbluetooth3_5.83-1volumio3_arm.deb
dpkg -i out/armv6/bluez-alsa-utils_4.3.1-1volumio1_arm.deb
dpkg -i out/armv6/bluez-alsa-utils-common_4.3.1-1volumio1_all.deb
apt-mark hold bluez libbluetooth3 bluez-alsa-utils bluez-alsa-utils-common
```

Adjust architecture in the path (`arm64`, `amd64`, etc.) if you're installing to other platforms.

## 🔄 Future Enhancements

- **Enhanced Party Mode**: Allow multiple Bluetooth devices to stay connected, but only allow playback from the last device that started streaming audio.
- **Automatic Profile Switching**: Implement seamless switching between A2DP and other profiles based on the device capabilities.
- **Advanced Audio Features**: Integrate features like multi-room audio and low-latency streaming for certain use cases.

## 🤝 Contributing

Contributions to improve Bluetooth integration and overall functionality are welcome. Please feel free to fork the repository, make changes, and submit pull requests. Before contributing, ensure your changes are aligned with Volumio's high-quality audio and system integration standards.
