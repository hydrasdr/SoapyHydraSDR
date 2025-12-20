# SoapySDR Plugin for HydraSDR

SoapySDR driver module for HydraSDR RFOne software-defined radio hardware.

Provides seamless integration with the SoapySDR ecosystem and applications like GQRX, SDR++, GNU Radio, and more.

## Dependencies

* **SoapySDR** - https://github.com/pothosware/SoapySDR
* **libhydrasdr** - https://github.com/hydrasdr/rfone_host

## Installation

### Option 1: Pre-built Packages (Recommended)

Download the latest packages from the [Releases](https://github.com/hydrasdr/SoapyHydraSDR/releases) page.

**Debian/Ubuntu/Mint (.deb):**
```bash
sudo dpkg -i soapyhydrasdr-*.deb
sudo ldconfig
```

**Fedora/RHEL/AlmaLinux (.rpm):**
```bash
sudo dnf install soapyhydrasdr-*.rpm
```

**openSUSE (.rpm):**
```bash
sudo zypper install soapyhydrasdr-*.rpm
```

**macOS (.tar.gz):**
```bash
# Extract and copy to SoapySDR modules directory
tar -xzf soapyhydrasdr-macOS-*.tar.gz
sudo cp libSoapyHydraSDR.so /usr/local/lib/SoapySDR/modules0.8-3/
sudo cp libhydrasdr.dylib /usr/local/lib/
```

**Windows (.zip):**
1. Download and extract the Windows zip from [Releases](https://github.com/hydrasdr/SoapyHydraSDR/releases)
2. Copy `SoapyHydraSDR.dll` to your SoapySDR modules directory (typically `C:\Program Files\SoapySDR\lib\SoapySDR\modules0.8\`)
3. Copy `hydrasdr.dll` and other DLLs to the same directory or add to PATH
4. Connect the HydraSDR device (driver installs automatically via WCID)

### Option 2: Build from Source

#### Linux/macOS

For best compatibility, especially if you've built SoapySDR from source, build SoapyHydraSDR from source as well:

```bash
# Install dependencies (Debian/Ubuntu)
sudo apt-get install build-essential cmake pkg-config libusb-1.0-0-dev

# Optional: Clean up previous installations
sudo rm -f /usr/local/lib/libhydrasdr*
sudo rm -f /usr/local/lib/SoapySDR/modules*/libSoapyHydraSDR*
sudo ldconfig

# Build and install SoapySDR from source (recommended)
rm -rf SoapySDR
git clone https://github.com/pothosware/SoapySDR.git
cd SoapySDR && mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
sudo make install
sudo ldconfig
cd ../..

# Build and install libhydrasdr (shared library required)
rm -rf rfone_host
git clone https://github.com/hydrasdr/rfone_host.git
cd rfone_host && mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DENABLE_SHARED_LIB=ON
make -j$(nproc)
sudo make install
sudo ldconfig
cd ../..

# Build and install SoapyHydraSDR
rm -rf SoapyHydraSDR
git clone https://github.com/hydrasdr/SoapyHydraSDR.git
cd SoapyHydraSDR && mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
sudo make install
sudo ldconfig

# Verify installation
SoapySDRUtil --info
SoapySDRUtil --probe="driver=hydrasdr"
```

#### Windows

Building on Windows requires Visual Studio and vcpkg:

```powershell
# Install vcpkg (if not already installed)
git clone https://github.com/Microsoft/vcpkg.git C:\vcpkg
C:\vcpkg\bootstrap-vcpkg.bat

# Install dependencies
C:\vcpkg\vcpkg.exe install soapysdr:x64-windows libusb:x64-windows

# Clone and build libhydrasdr
git clone https://github.com/hydrasdr/rfone_host.git
cd rfone_host
mkdir build && cd build
cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_TOOLCHAIN_FILE=C:\vcpkg\scripts\buildsystems\vcpkg.cmake
cmake --build . --config Release
cmake --install . --config Release
cd ..\..

# Clone and build SoapyHydraSDR
git clone https://github.com/hydrasdr/SoapyHydraSDR.git
cd SoapyHydraSDR
mkdir build && cd build
cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_TOOLCHAIN_FILE=C:\vcpkg\scripts\buildsystems\vcpkg.cmake
cmake --build . --config Release
cmake --install . --config Release
```

## ABI Compatibility Note

**Important:** SoapySDR uses an ABI (Application Binary Interface) version to ensure module compatibility. The pre-built packages are compiled against **SoapySDR ABI 0.8-3** (source-built version).

If you experience module loading errors like:
```
SoapySDR module ... refuses to load. Check module file permissions and ABI version
```

This typically means there's a mismatch between your installed SoapySDR and the module. Solutions:

1. **Build SoapyHydraSDR from source** (see above) - This ensures the module is compiled against your installed SoapySDR version.

2. **Build SoapySDR from source** - Distribution packages may have older ABI versions. Building from source ensures compatibility with pre-built SoapyHydraSDR packages.

## Verification

After installation, verify the module is detected:

```bash
# Check if SoapySDR can find the module
SoapySDRUtil --info

# Look for HydraSDR devices
SoapySDRUtil --find

# Probe device details (with device connected)
SoapySDRUtil --probe="driver=hydrasdr"
```

## Troubleshooting

### Module not found
1. Check the SoapySDR module search paths:
   ```bash
   SoapySDRUtil --info | grep "Search path"
   ```
2. Verify the module is installed in one of those paths:
   ```bash
   ls -la /usr/local/lib/SoapySDR/modules*/
   ls -la /usr/lib/x86_64-linux-gnu/SoapySDR/modules*/
   ```

### ABI version mismatch
Build both SoapySDR and SoapyHydraSDR from source to ensure ABI compatibility. See the build instructions above.

### Device not detected
1. Ensure the device is connected via USB
2. Check USB permissions - you may need udev rules:
   ```bash
   # Install udev rules from libhydrasdr
   sudo cp /usr/local/lib/udev/rules.d/53-hydrasdr.rules /etc/udev/rules.d/
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   ```
3. Re-plug the device or log out/in

### Permission denied (Linux)
Add your user to the `plugdev` group:
```bash
sudo usermod -aG plugdev $USER
# Log out and log back in
```

### Windows: Device not recognized
1. HydraSDR RFOne uses WCID for automatic driver installation
2. Ensure the device is properly connected via USB
3. Check Device Manager for any driver issues
4. Verify with `SoapySDRUtil --find`

### Windows: Module not loaded
1. Ensure all DLLs are in the SoapySDR modules directory or in PATH
2. Check the module path: `SoapySDRUtil --info`
3. Typical paths:
   - `C:\Program Files\SoapySDR\lib\SoapySDR\modules0.8\`
   - `C:\vcpkg\installed\x64-windows\lib\SoapySDR\modules0.8\`

## Device Capabilities

Example output from `SoapySDRUtil --probe="driver=hydrasdr"`:

```
######################################################
##     Soapy SDR -- the SDR abstraction library     ##
######################################################

Probe device driver=hydrasdr

----------------------------------------------------
-- Device identification
----------------------------------------------------
  driver=HydraSDR
  hardware=HydraSDR
  serial=36b463dc395884c7

----------------------------------------------------
-- Peripheral summary
----------------------------------------------------
  Channels: 1 Rx, 0 Tx
  Timestamps: NO
  Other Settings:
     * Bias tee - Enable the 4.5v DC Bias tee to power LNA / etc. via antenna connection.
       [key=biastee, default=false, type=bool]
     * Bit Pack - Enable packing 4 12-bit samples into 3 16-bit words for 25% less USB traffic.
       [key=bitpack, default=false, type=bool]

----------------------------------------------------
-- RX Channel 0
----------------------------------------------------
  Full-duplex: NO
  Supports AGC: YES
  Stream formats: CS16, CF32
  Native format: CS16 [full-scale=32767]
  Antennas: RX
  Full gain range: [0, 45] dB
    LNA gain range: [0, 15] dB
    MIX gain range: [0, 15] dB
    VGA gain range: [0, 15] dB
  Full freq range: [24, 1800] MHz
    RF freq range: [24, 1800] MHz
  Sample rates: 10, 5, 2.5 MSps
```

## License

This software is licensed exclusively for HydraSDR products and related development. See [LICENSE.txt](LICENSE.txt) for details.

## Links

* **HydraSDR**: https://hydrasdr.com
* **Issue Tracker**: https://github.com/hydrasdr/SoapyHydraSDR/issues
* **SoapySDR Documentation**: https://github.com/pothosware/SoapySDR/wiki
