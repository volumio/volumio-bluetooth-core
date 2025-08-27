# Build Guide: BlueZ for Volumio (Multi-Arch)

This guide explains how to build **BlueZ 5.83** for Volumio OS using Docker on a Linux host (e.g., Ubuntu 24.04). It supports builds for `armhf`, `arm64`, `amd64`, and `armv6`, producing `.deb` packages for use on Volumio across all Raspberry Pi models and x86 platforms.

---

## 🔧 Host Requirements

- **OS**: Ubuntu 24.04 (or equivalent)
- **Docker**: Installed via:
  ```bash
  sudo apt install docker.io
  ```
- **QEMU multi-arch support**:
  ```bash
  docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
  ```

---

## 📁 Project Layout

```
volumio-bluetooth-core/
├── build/
│   └── bluez/                      # BlueZ source and packaging
│       ├── source/                 # BlueZ 5.83 source
│       ├── debian/                 # Debian packaging files
│       └── patches/                # Optional patches
├── docker/
│   ├── Dockerfile.bluez.armhf      # Dockerfile for ARMv7 (armhf)
│   ├── Dockerfile.bluez.armv6      # Dockerfile for ARMv6 (universal Pi build)
│   ├── Dockerfile.bluez.arm64      # Dockerfile for ARM64
│   ├── Dockerfile.bluez.amd64      # Dockerfile for x86_64
│   └── run-docker-bluez.sh         # Docker build runner
├── out/
│   └── <arch>/                     # Output directory for .deb packages
├── package-sources/
│   ├── bluez_5.83-1.debian.tar.xz  # Debian packaging metadata
│   └── bluez_5.83.orig.tar.xz      # BlueZ upstream source
├── scripts/
│   └── extract-bluez-source.sh     # Source unpack + prep script
├── docs/
│   ├── build-bluez.md              # This file
│   └── integration.md              # Integration notes for Volumio
└── README.md
```

---

## 🧭 Build Contexts


| Environment    | Role                                  |
| ---------------- | --------------------------------------- |
| **Host**       | Prepares files and runs Docker builds |
| **Docker**     | Executes`dpkg-buildpackage`           |
| **Volumio OS** | Installs resulting`.deb` packages     |

---

## 🧱 Build Instructions

### 1. Extract and Prepare Source

Run the extraction script to unpack BlueZ 5.83 and set up Debian packaging:

```bash
./scripts/extract-bluez-source.sh
```

This script will:

- Extract BlueZ 5.83 into `build/bluez/source/`
- Copy and apply Debian packaging files to `build/bluez/debian/`

---

### 2. Update the Debian Changelog

Edit the changelog to reflect your custom Volumio build:

```bash
nano build/bluez/debian/changelog
```

Example entry:

```
bluez (5.83-1volumio1) bookworm; urgency=medium

  * Volumio-customized BlueZ 5.83 build

 -- Your Name <you@example.com>  Tue, 26 Mar 2024 12:00:00 +0000
```

---

### 3. Run Docker Build for Target Architecture

Use the provided script to build `.deb` packages for your desired architecture:

```bash
# ARMv6 (universal Pi build, armhf ABI)
./docker/run-docker-bluez.sh bluez armv6 --verbose

# ARMv7 (armhf)
./docker/run-docker-bluez.sh bluez armhf --verbose

# ARMv8 (arm64)
./docker/run-docker-bluez.sh bluez arm64 --verbose

# x86_64 (amd64)
./docker/run-docker-bluez.sh bluez amd64 --verbose
```

> Use `volumio` as an optional third argument to apply custom file renaming (`_armhf.deb → _arm.deb`, etc.)

Example:

```bash
./docker/run-docker-bluez.sh bluez armv6 volumio --verbose
```

---

### 🗂️ Output Location

Built `.deb` packages will appear in:

```
out/armv6/bluez_5.83-1volumio1_arm.deb
out/arm64/bluez_5.83-1volumio1_arm64.deb
out/amd64/bluez_5.83-1volumio1_x64.deb
out/armhf/bluez_5.83-1volumio1_armv7.deb
```

---

## 📦 Installing on Volumio OS

Transfer and install the packages using `dpkg`:

```bash
# For ARMv6 (universal Pi)
dpkg -i out/armv6/bluez_5.83-1volumio1_arm.deb
dpkg -i out/armv6/libbluetooth3_5.83-1volumio1_arm.deb
apt-mark hold bluez libbluetooth3
```

For other architectures, substitute the path accordingly:

```bash
dpkg -i out/arm64/bluez_5.83-1volumio1_arm64.deb
dpkg -i out/amd64/bluez_5.83-1volumio1_x64.deb
dpkg -i out/armhf/bluez_5.83-1volumio1_armv7.deb
```

---

## 🔁 Repeat for Other Architectures

```bash
./docker/run-docker-bluez.sh bluez arm64 volumio --verbose
./docker/run-docker-bluez.sh bluez amd64 volumio --verbose
./docker/run-docker-bluez.sh bluez armv6 volumio --verbose
```

---

## 💡 Notes

- Make sure the correct Dockerfile is selected for each architecture:
  - `Dockerfile.bluez.armv6`, `Dockerfile.bluez.armhf`, etc.
- Re-run `extract-bluez-source.sh` if the source or packaging is updated.
- Use `--verbose` for full build logs (helpful in CI or debugging).
- ARMv6 builds use `-march=armv6 -mfpu=vfp -mfloat-abi=hard -marm` for compatibility with **all Raspberry Pi models** (Pi 0 through Pi 5).
