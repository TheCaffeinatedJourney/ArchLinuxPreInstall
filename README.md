# Arch Linux Pre-Install

This project provides a Bash script to automate the process of downloading, verifying, and burning the latest Arch Linux ISO to a USB drive. It's ideal for users who frequently create bootable Arch installation media and want to streamline the process.

---

## Features
- **Download**: Uses the Arch Linux Mirror Status to download the latest Arch Linux ISO from the highest scoring https mirror. 
- **ISO Verification**: Verifies the download SHA256 and B2 checksums as well as PGP signature verification to ensure integrity.  If verification fails, will automatically download from another mirror.
- **Burn ISO to USB**: Automates burning the ISO to a user-selected device.  Only unmounted devices can be selected, providing some protection against writing to an incorrect device. 
---

## Installation

1. **Clone the Repository**:
```bash
git clone --depth=1 https://github.com/your-username/ArchLinuxPreInstall.git
cd ArchLinuxPreInstall
```

2. **Make the Script Executable**:
```bash
chmod +x ArchLinuxPreInstall.sh
```
---

## Usage

### 1. Basic Command
   Run the script to download and verify the ISO:
```bash
./ArchLinuxPreInstall.sh
```

### 2. Select whether to Download and Verify the ISO, or also burn to a disk
   When prompted, select whether to Download and Verify the ISO, or also burn to a disk.
```bash
Do you want to:
    1) Download and Verify the Arch Linux ISO?
    2) Download, Verify, and Burn the Arch Linux ISO to a disk?
Enter your choice:
```

### 3. Specify a Target Device
   When prompted, select the device you want to burn the ISO to.
```bash
Select a device to burn the ISO to:
/dev/sda - USB_2.0_FD - 16GiB
/dev/sdb - USB_2.0_FD - 64Gib

1) /dev/sda
2) /dev/sdb
Enter the number corresponding to the device: 
```

**WARNING**: Be cautious – **all data will be erased** from the target device!

---

## Modifiable Variables

Inside `ArchLinuxPreInstall.sh`, you can modify the following variables to customize the script's behavior:

```bash
# Path to download the ISO and verification files
iso_download_dir="/tmp/archiso/"
```
---

## Example Run
In this example, you'll see the following:
* Selecting option to Download, Verify, and Burn to Disk
* Creating the download directory
* Downloading the archlinux-x86_64.iso.sig file, sha256sums.txt, and b2sums.txt
* Finding the highest ranked mirror and downloading the ISO
* The verification on this ISO failing
* Finding the next highest ranked mirror and downloading the ISO
* The verification on the ISO passing
* Printing unmounted devices and prompting for the device to burn the ISO to
* Verifying the ISO was burned correctly, which failed.

```bash
============================================================================
               _             _       _     _
              / \   _ __ ___| |__   | |   (_)_ __  _   ___  __
             / _ \ | '__/ __| '_ \  | |   | | '_ \| | | \ \/ /
            / ___ \| | | (__| | | | | |___| | | | | |_| |>  <
           /_/   \_\_|  \___|_| |_| |_____|_|_| |_|\__,_/_/\_\
        _             ____                      _                 _
       (_)___  ___   |  _ \  _____      ___ __ | | ___   __ _  __| |
       | / __|/ _ \  | | | |/ _ \ \ /\ / / '_ \| |/ _ \ / _  |/ _  |
       | \__ \ (_) | | |_| | (_) \ V  V /| | | | | (_) | (_| | (_| |
       |_|___/\___/  |____/ \___/ \_/\_/ |_| |_|_|\___/ \__,_|\__,_|
                  _  __     __        _  __ _           _   _
   __ _ _ __   __| | \ \   / /__ _ __(_)/ _(_) ___ __ _| |_(_) ___  _ __
  / _  | '_ \ / _  |  \ \ / / _ \ '__| | |_| |/ __/ _  | __| |/ _ \| '_ \
 | (_| | | | | (_| |   \ V /  __/ |  | |  _| | (_| (_| | |_| | (_) | | | |
  \__,_|_| |_|\__,_|    \_/ \___|_|  |_|_| |_|\___\__,_|\__|_|\___/|_| |_|

============================================================================

 This script will download and verify the latest Arch Linux iso and burn it
 to an unmounted drive for installation.

============================================================================

Do you want to:
    1) Download and Verify the Arch Linux ISO?
    2) Download, Verify, and Burn the Arch Linux ISO to a disk?
Enter your choice: 2
Download, Verify, and Burn the Arch ISO to a disk.

Downloading iso verification files...
Downloading archlinux-x86_64.iso.sig
  from https://archlinux.org/iso/latest/archlinux-x86_64.iso.sig
  to /tmp/archiso/archlinux-x86_64.iso.sig...
################################################################################################## 100.0%
Download successful!

Downloading sha256sums.txt
  from https://archlinux.org/iso/latest/sha256sums.txt
  to /tmp/archiso/sha256sums.txt...
################################################################################################## 100.0%
Download successful!

Downloading b2sums.txt
  from https://archlinux.org/iso/latest/b2sums.txt
  to /tmp/archiso/b2sums.txt...
################################################################################################## 100.0%
Download successful!

Downloading iso archlinux-x86_64.iso
  from https://mirror.lty.me/archlinux/iso/latest/archlinux-x86_64.iso
  to /tmp/archiso/archlinux-x86_64.iso
################################################################################################## 100.0%
Verifying SHA256 checksum...
Error: SHA256 checksum verification failed.
Expected:   b72dd6ffef7507f8b7cddd7c69966841650ba0f82c29a318cb2d182eb3fcb1db
Calculated: 398dceea2d04767fbb8b61a9e824f2c8f5eacf62b2cb5006fd63321d978d48bc

ISO from https://mirror.lty.me/archlinux/ failed verification! Trying another mirror...

Downloading iso archlinux-x86_64.iso
  from https://mirror.pilotfiber.com/archlinux/iso/latest/archlinux-x86_64.iso
  to /tmp/archiso/archlinux-x86_64.iso
################################################################################################## 100.0%
Verifying SHA256 checksum...
SHA256 checksum verification passed.

Verifying B2 checksum...
B2 checksum verification passed.

Verifying PGP signature...
Importing public key for pierre@archlinux.org...
Public key for pierre@archlinux.org imported successfully.

PGP signature verification passed.

All verifications passed for archlinux-x86_64.iso from https://mirror.pilotfiber.com/archlinux/.

============================================================================

Select a device to burn the ISO to:
/dev/sda - USB_2.0_FD - 16GiB

1) /dev/sda
Enter the number corresponding to the device: 1
You selected: /dev/sda

WARNING: THIS IS A DESTRUCTIVE COMMAND!
Are you sure you want to proceed with burning the iso to /dev/sda?
Type YES in capital letters to continue, (N)o to select another device, or (Q)uit: YES
Target device set to: /dev/sda
Burning /tmp/archiso/archlinux-x86_64.iso to /dev/sda...
[sudo] password for user:
1173389312 bytes (1.2 GB, 1.1 GiB) copied, 149 s, 7.9 MB/s
279+1 records in
279+1 records out
1173389312 bytes (1.2 GB, 1.1 GiB) copied, 149.164 s, 7.9 MB/s
archlinux-x86_64.iso burned to /dev/sda

Verifying ISO was burned successfully...
Comparing the ISO with the burned content on /dev/sda
Note: This process may take some time, depending on the device speed.

Verification successful: ISO was burned successfully!
You may now restart and boot into the installation medium.

Do you want to remove the ISO and verification files? [y/N]: y
Removing files...
Removed: /tmp/archiso/archlinux-x86_64.iso
Removed: /tmp/archiso/archlinux-x86_64.iso.sig
Removed: /tmp/archiso/sha256sums.txt
Removed: /tmp/archiso/b2sums.txt
Cleanup complete.
```
---

## Contributions

Feel free to submit issues or pull requests to enhance the script. Contributions are welcome!

---
## License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.



