# Integration into Volumio

This document outlines how to integrate **BlueZ** and **bluez-alsa-utils** into Volumio, focusing on package pinning, testing D-Bus interactions, and ensuring compatibility with various device types.

## Package Pinning

To ensure the correct versions of **BlueZ** and **libbluetooth3** are used in Volumio, the following steps should be taken to lock these packages:

1. **Pinning BlueZ and libbluetooth3 Versions:**

   To prevent updates to **BlueZ** or **libbluetooth3** that could break compatibility with Volumio, pin these packages to specific versions in Volumio’s package manager.

   Create or edit the file `/etc/apt/preferences.d/bluez-pin`:

   ```bash
   # /etc/apt/preferences.d/bluez-pin
   Package: bluez libbluetooth3
   Pin: version 5.83-1volumio3
   Pin-Priority: 1001
   
   Package: bluez-alsa-utils
   Pin: version 4.3.1-1volumio1
   Pin-Priority: 1001
   ```

   This ensures that only the specific versions of **BlueZ** and **libbluetooth3** compatible with Volumio are installed, even when newer versions are available in repositories.

2. **Holding BlueZ and libbluetooth3 Packages:**

   Additionally, you can hold these packages to prevent them from being upgraded:

   ```bash
   sudo apt-mark hold bluez libbluetooth3
   ```

   This step will prevent the system from accidentally upgrading these critical packages during routine system updates.

---

## D-Bus Test Matrix

This section outlines key D-Bus interfaces and signals to test in order to ensure full integration of **BlueZ** and **bluez-alsa-utils** with Volumio.

### 1. `org.bluez.MediaPlayer1.Status`

This interface allows the media player status to be queried and controlled.

**Test Steps**:
- Ensure Volumio correctly receives and displays the status of Bluetooth playback.
- Verify that play, pause, and stop commands are correctly reflected in Volumio's UI.
- Confirm that state changes trigger the appropriate callbacks in Volumio’s UI.

**D-Bus Method to Test**:
- `org.freedesktop.DBus.Properties.Get`: Retrieve the current playback status.

```bash
dbus-send --print-reply --session \
  --dest=org.bluez \
  /org/bluez/hci0/dev_XX_XX_XX_XX_XX_XX \
  org.freedesktop.DBus.Properties.Get \
  string:"org.bluez.MediaPlayer1" string:"Status"
```

---

### 2. `org.bluez.MediaTransport1.Volume`

This interface manages the volume control for Bluetooth audio devices.

**Test Steps**:
- Check that volume adjustments from both Volumio and Bluetooth devices are synchronized.
- Verify that volume changes from Volumio's UI are pushed to the connected Bluetooth device.
- Test the volume changes from Bluetooth devices and verify that the volume is reflected in Volumio’s UI.

**D-Bus Method to Test**:
- `org.freedesktop.DBus.Properties.Get`: Retrieve the current volume level.

```bash
dbus-send --print-reply --session \
  --dest=org.bluez \
  /org/bluez/hci0/dev_XX_XX_XX_XX_XX_XX \
  org.freedesktop.DBus.Properties.Get \
  string:"org.bluez.MediaTransport1" string:"Volume"
```

---

### 3. `org.bluez.Media1` Interfaces

This interface is used to interact with the media playback, controlling actions like play/pause, skip, and volume control.

**Test Steps**:
- Verify that Volumio is correctly sending playback control signals to the Bluetooth device (e.g., play/pause, skip).
- Ensure that metadata such as the track name, artist, and album are updated correctly in Volumio.

**D-Bus Methods to Test**:
- `Play`, `Pause`, `Stop`: Test that playback control signals are successfully sent.

```bash
# Play
dbus-send --session \
  --dest=org.bluez \
  /org/bluez/hci0/dev_XX_XX_XX_XX_XX_XX \
  org.bluez.Media1.Play

# Pause
dbus-send --session \
  --dest=org.bluez \
  /org/bluez/hci0/dev_XX_XX_XX_XX_XX_XX \
  org.bluez.Media1.Pause
```

---

## Device Types

This section outlines the different types of devices to test with, including Android and iOS, ensuring compatibility and proper Bluetooth functionality with these devices.

### 1. Android Devices

**Test Devices**:
- OnePlus (various models, pre- and post-Android 14)
- Samsung Galaxy (various models, pre- and post-Android 14)

**Key Testing Points**:
- **Pairing**: Ensure smooth pairing with Volumio.
- **Audio Streaming**: Test A2DP audio streaming from Android devices to Volumio.
- **Volume Control**: Verify bidirectional volume control between Android devices and Volumio.
- **Metadata Handling**: Check that track metadata (e.g., artist, album) is correctly displayed on Volumio.

### 2. iOS Devices

**Test Devices**:
- iPhone 15 (iOS 17)

**Key Testing Points**:
- **Pairing**: Ensure smooth pairing with Volumio.
- **Audio Streaming**: Test A2DP audio streaming from iOS devices to Volumio.
- **Volume Control**: Verify bidirectional volume control between iOS devices and Volumio.
- **Metadata Handling**: Ensure track information, play/pause, and artist metadata are correctly pushed from iOS to Volumio.

---

This integration guide ensures that **BlueZ**, **bluez-alsa-utils**, and their associated D-Bus interfaces are fully functional with Volumio. It covers critical aspects like package pinning, D-Bus testing, and compatibility with Android and iOS devices.
