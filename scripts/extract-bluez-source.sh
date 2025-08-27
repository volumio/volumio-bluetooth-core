#!/bin/bash
set -e

# Check if the script is being run from the root of the project
if [[ ! -d "package-sources" ]]; then
  echo "Error: This script should be run from the root of the project directory."
  exit 1
fi

# Set the paths for bluez source and debian tarballs (adjust if needed)
ORIG_TAR_PATH="package-sources/bluez_5.83.orig.tar.xz"  # Path to the original source tarball
DEBIAN_TAR_PATH="package-sources/bluez_5.83-1.debian.tar.xz"  # Path to the debian tarball

# Ensure both tarballs exist
if [[ ! -f "$ORIG_TAR_PATH" ]]; then
  echo "Error: $ORIG_TAR_PATH does not exist."
  exit 1
fi

if [[ ! -f "$DEBIAN_TAR_PATH" ]]; then
  echo "Error: $DEBIAN_TAR_PATH does not exist."
  exit 1
fi

# Set the destination for extracted source
DEST_DIR="build/bluez/source"

# Cleanup the destination directory before extraction
echo "[+] Cleaning up destination directory: $DEST_DIR"
rm -rf "$DEST_DIR"
mkdir -p "$DEST_DIR"

# Step 1: Extract the original tarball (bluez.orig) directly into the destination directory
echo "[+] Extracting bluez.orig.tar.xz to $DEST_DIR"
tar -xvf "$ORIG_TAR_PATH" -C "$DEST_DIR" --strip-components=1

# Step 2: Create the subdirectory for debian files under the package folder
DEBIAN_DIR="$DEST_DIR/debian"
mkdir -p "$DEBIAN_DIR"

# Step 3: Extract the debian tarball (bluez.debian) into the debian subfolder
echo "[+] Extracting bluez.debian.tar.xz to $DEBIAN_DIR"
tar -xvf "$DEBIAN_TAR_PATH" -C "$DEBIAN_DIR" --strip-components=1

echo "[+] Step 1 completed. Bluez sources and debian files are extracted to $DEST_DIR"
