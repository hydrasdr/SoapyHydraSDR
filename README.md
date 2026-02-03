# SoapySDR Plugin for HydraSDR

SoapySDR driver module for HydraSDR RFOne software-defined radio hardware.

Provides seamless integration with the SoapySDR ecosystem and applications like GQRX, CubicSDR, and any Soapy-compatible SDR application across Windows, Linux, and macOS

## Dependencies

* **SoapySDR** - https://github.com/pothosware/SoapySDR
* **libhydrasdr** - https://github.com/hydrasdr/hydrasdr-host

## Installation

### Option 1: Pre-built Packages (Recommended)

Pre-built packages are available for multiple platforms. You need to install three components:
1. **SoapySDR** - The SDR abstraction library
2. **hydrasdr-host-tools** - HydraSDR host library and tools (provides libhydrasdr)
3. **soapyhydrasdr** - This SoapySDR module

**Download packages from:**
- **hydrasdr-host-tools**: https://github.com/hydrasdr/hydrasdr-host/releases
- **soapyhydrasdr**: https://github.com/hydrasdr/SoapyHydraSDR/releases

#### Debian / Ubuntu / Linux Mint
```bash
# Step 1: Install SoapySDR from distribution packages
sudo apt-get update
sudo apt-get install -y libsoapysdr0.8 libsoapysdr-dev soapysdr-tools

# Step 2: Download and install hydrasdr-host-tools
# Download the appropriate .deb for your distro from: https://github.com/hydrasdr/hydrasdr-host/releases
sudo dpkg -i hydrasdr-host-tools-<your-distro>-*.deb
sudo ldconfig

# Step 3: Download and install soapyhydrasdr
# Download the appropriate .deb for your distro from: https://github.com/hydrasdr/SoapyHydraSDR/releases
sudo dpkg -i soapyhydrasdr-<your-distro>-*.deb
sudo ldconfig

# Step 4: Reload udev rules and verify
sudo udevadm control --reload-rules
sudo udevadm trigger
SoapySDRUtil --info
SoapySDRUtil --find
```

**Available .deb packages:**
| Distribution | Package name pattern |
|--------------|----------------------|
| Ubuntu 24.04 LTS | `*-Ubuntu-24.04-LTS-Noble-Numbat-*.deb` |
| Ubuntu 22.04 LTS | `*-Ubuntu-22.04-LTS-Jammy-Jellyfish-*.deb` |
| Ubuntu 20.04 LTS | `*-Ubuntu-20.04-LTS-Focal-Fossa-*.deb` |
| Debian 13 Trixie | `*-Debian-13-Trixie-*.deb` |
| Debian 12 Bookworm | `*-Debian-12-Bookworm-*.deb` |
| Debian 11 Bullseye | `*-Debian-11-Bullseye-*.deb` |
| Linux Mint 22 | `*-Linux-Mint-22-Wilma-*.deb` |
| Linux Mint 21.x | `*-Linux-Mint-21.*-*.deb` |

#### Fedora
```bash
# Step 1: Install SoapySDR from Fedora repositories
sudo dnf install -y SoapySDR SoapySDR-devel soapysdr-tools

# Step 2: Download and install hydrasdr-host-tools
# Download the appropriate .rpm for your Fedora version from: https://github.com/hydrasdr/hydrasdr-host/releases
sudo dnf install ./hydrasdr-host-tools-Fedora-*.rpm

# Step 3: Download and install soapyhydrasdr
# Download the appropriate .rpm for your Fedora version from: https://github.com/hydrasdr/SoapyHydraSDR/releases
sudo dnf install ./soapyhydrasdr-Fedora-*.rpm

# Step 4: Reload udev rules and verify
sudo udevadm control --reload-rules
sudo udevadm trigger
SoapySDRUtil --info
SoapySDRUtil --find
```

**Available Fedora .rpm packages:** `*-Fedora-41-*.rpm`, `*-Fedora-42-*.rpm`

#### openSUSE Tumbleweed
```bash
# Step 1: Install SoapySDR from openSUSE repositories
sudo zypper install soapy-sdr soapy-sdr-devel

# Step 2: Download and install hydrasdr-host-tools
# Download the .rpm from: https://github.com/hydrasdr/hydrasdr-host/releases
sudo zypper install ./hydrasdr-host-tools-openSUSE-Tumbleweed-*.rpm

# Step 3: Download and install soapyhydrasdr
# Download the .rpm from: https://github.com/hydrasdr/SoapyHydraSDR/releases
sudo zypper install ./soapyhydrasdr-openSUSE-Tumbleweed-*.rpm

# Step 4: Reload udev rules and verify
sudo udevadm control --reload-rules
sudo udevadm trigger
SoapySDRUtil --info
SoapySDRUtil --find
```

#### AlmaLinux 9 / RHEL 9
```bash
# Step 1: Enable EPEL and install SoapySDR
sudo dnf install -y epel-release
sudo dnf config-manager --set-enabled crb
sudo dnf install -y SoapySDR SoapySDR-devel

# Step 2: Download and install hydrasdr-host-tools
# Download the .rpm from: https://github.com/hydrasdr/hydrasdr-host/releases
sudo dnf install ./hydrasdr-host-tools-AlmaLinux-9-*.rpm

# Step 3: Download and install soapyhydrasdr
# Download the .rpm from: https://github.com/hydrasdr/SoapyHydraSDR/releases
sudo dnf install ./soapyhydrasdr-AlmaLinux-9-*.rpm

# Step 4: Reload udev rules and verify
sudo udevadm control --reload-rules
sudo udevadm trigger
SoapySDRUtil --info
SoapySDRUtil --find
```

#### macOS
```bash
# Step 1: Install SoapySDR via Homebrew
brew install soapysdr

# Step 2: Download and extract hydrasdr-host-tools
# Download from: https://github.com/hydrasdr/hydrasdr-host/releases
# - Apple Silicon (M1/M2/M3): hydrasdr-host-tools-macOS-ARM64-*.tar.gz
# - Intel Mac: hydrasdr-host-tools-macOS-x86_64-*.tar.gz
tar -xzf hydrasdr-host-tools-macOS-*.tar.gz
sudo cp libhydrasdr.dylib /usr/local/lib/
sudo cp hydrasdr_* /usr/local/bin/  # optional: command-line tools

# Step 3: Download and extract soapyhydrasdr
# Download from: https://github.com/hydrasdr/SoapyHydraSDR/releases
# - Apple Silicon (M1/M2/M3): soapyhydrasdr-macOS-ARM64-*.tar.gz
# - Intel Mac: soapyhydrasdr-macOS-x86_64-*.tar.gz
tar -xzf soapyhydrasdr-macOS-*.tar.gz

# Find SoapySDR modules directory and install
SOAPY_MODULE_DIR=$(SoapySDRUtil --info | grep "Search path" | head -1 | awk '{print $3}')
sudo mkdir -p "$SOAPY_MODULE_DIR"
sudo cp libSoapyHydraSDR.so "$SOAPY_MODULE_DIR/"

# Step 4: Verify installation
SoapySDRUtil --info
SoapySDRUtil --find
```

#### Windows

1. **Install SoapySDR** via PothosSDR installer or vcpkg:
   - **PothosSDR** (includes SoapySDR): https://github.com/pothosware/PothosSDR/releases
   - Or via vcpkg: `vcpkg install soapysdr:x64-windows`

2. **Download hydrasdr-host-tools**:
   - Download `hydrasdr-host-tools-Windows-x64-*.zip` from: https://github.com/hydrasdr/hydrasdr-host/releases
   - Extract the archive

3. **Download soapyhydrasdr**:
   - Download `soapyhydrasdr-Windows-x64-*.zip` from: https://github.com/hydrasdr/SoapyHydraSDR/releases
   - Extract the archive

4. **Install files**:
```powershell
   # Find SoapySDR modules directory (check SoapySDRUtil --info)
   # Typical locations:
   #   C:\Program Files\PothosSDR\lib\SoapySDR\modules0.8\
   #   C:\Program Files\SoapySDR\lib\SoapySDR\modules0.8\
   
   # Copy SoapyHydraSDR.dll to SoapySDR modules directory
   Copy-Item SoapyHydraSDR.dll "C:\Program Files\PothosSDR\lib\SoapySDR\modules0.8\"
   
   # Copy hydrasdr.dll and dependencies to the modules directory or add to PATH
   Copy-Item hydrasdr.dll "C:\Program Files\PothosSDR\lib\SoapySDR\modules0.8\"
   Copy-Item libusb-1.0.dll "C:\Program Files\PothosSDR\lib\SoapySDR\modules0.8\"
```

5. **Verify installation**:
```powershell
   SoapySDRUtil --info
   SoapySDRUtil --find
```

**Note:** HydraSDR RFOne uses WCID for automatic USB driver installation on Windows 10/11.

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
rm -rf hydrasdr-host
git clone https://github.com/hydrasdr/hydrasdr-host.git
cd hydrasdr-host && mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DENABLE_SHARED_LIB=ON -DINSTALL_UDEV_RULES=ON
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
git clone https://github.com/hydrasdr/hydrasdr-host.git
cd hydrasdr-host
mkdir build && cd build
cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_TOOLCHAIN_FILE=C:\vcpkg\scripts\buildsystems\vcpkg.cmake -DENABLE_SHARED_LIB=ON
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

**Important:** SoapySDR uses an ABI (Application Binary Interface) version to ensure module compatibility. The pre-built soapyhydrasdr packages install to multiple module paths for maximum compatibility with both distribution packages and source-built SoapySDR.

If you experience module loading errors like:
```
SoapySDR module ... refuses to load. Check module file permissions and ABI version
```

This typically means there's a mismatch between your installed SoapySDR and the module. Solutions:

1. **Build SoapyHydraSDR from source** (see Option 2) - This ensures the module is compiled against your exact SoapySDR version.

2. **Build SoapySDR from source** - If distribution packages cause issues:
```bash
   git clone https://github.com/pothosware/SoapySDR.git
   cd SoapySDR && mkdir build && cd build
   cmake .. -DCMAKE_BUILD_TYPE=Release
   make -j$(nproc)
   sudo make install
   sudo ldconfig
```

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

2. Check USB permissions - udev rules must be installed:

   **If using pre-built packages:** udev rules are included automatically. Just reload and replug:
```bash
   sudo udevadm control --reload-rules
   sudo udevadm trigger
```

   **If built from source:** ensure you built libhydrasdr with udev rules enabled:
```bash
   cd hydrasdr-host/build
   cmake .. -DINSTALL_UDEV_RULES=ON
   make
   sudo make install
   sudo udevadm control --reload-rules
   sudo udevadm trigger
```

3. Verify udev rules are installed:
```bash
   ls -la /etc/udev/rules.d/*hydrasdr*
```

4. Re-plug the device or log out/in

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
   - `C:\Program Files\PothosSDR\lib\SoapySDR\modules0.8\`
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

MIT License - See [LICENSE.txt](LICENSE.txt) for details.

## Links

* **HydraSDR**: https://hydrasdr.com
* **Issue Tracker**: https://github.com/hydrasdr/SoapyHydraSDR/issues
* **SoapySDR Documentation**: https://github.com/pothosware/SoapySDR/wiki
