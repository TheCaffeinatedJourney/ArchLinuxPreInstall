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
git clone https://github.com/your-username/ArchLinuxPreInstall.git
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

### 2. Specify a Target Device
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

# Country Code of the Mirrors you want to download from
country_code="US"
```
---

## Example Run
This example shows the output of the script.  
In this example, you'll see the following:
* Creating the download directory
* Downloading the archlinux-x86_64.iso.sig file, sha256sums.txt, and b2sums.txt
* Finding the highest ranked mirror and downloading the ISO
* The verification on this ISO failing
* Finding the next highest ranked mirror and downloading the ISO
* The verification on the ISO passing
* Printing unmounted devices and prompting for the device to burn the ISO to
* Verifying the ISO was burned correctly, which failed.

```bash
Creating temporary directory at /tmp/archiso/...

Downloading iso verification files...
Downloading archlinux-x86_64.iso.sig
  from https://archlinux.org/iso/latest/archlinux-x86_64.iso.sig
  to /tmp/archiso/archlinux-x86_64.iso.sig...
####################################################################################### 100.0%
Download successful!

Downloading sha256sums.txt
  from https://archlinux.org/iso/latest/sha256sums.txt
  to /tmp/archiso/sha256sums.txt...
####################################################################################### 100.0%
Download successful!

Downloading b2sums.txt
  from https://archlinux.org/iso/latest/b2sums.txt
  to /tmp/archiso/b2sums.txt...
####################################################################################### 100.0%
Download successful!

Downloading iso archlinux-x86_64.iso
  from https://mirror.lty.me/archlinux/iso/latest/archlinux-x86_64.iso
  to /tmp/archiso/archlinux-x86_64.iso
####################################################################################### 100.0%
Verifying SHA256 checksum...
Error: SHA256 checksum verification failed.
Expected:   b72dd6ffef7507f8b7cddd7c69966841650ba0f82c29a318cb2d182eb3fcb1db
Calculated: 398dceea2d04767fbb8b61a9e824f2c8f5eacf62b2cb5006fd63321d978d48bc

ISO from https://mirror.lty.me/archlinux/ failed verification! Trying another mirror...

Downloading iso archlinux-x86_64.iso
  from https://mirror.pilotfiber.com/archlinux/iso/latest/archlinux-x86_64.iso
  to /tmp/archiso/archlinux-x86_64.iso
####################################################################################### 100.0%
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
Type YES to continue, (N)o to select another device, or (Q)uit: YES
Target device set to: /dev/sda
Burning /tmp/archiso/archlinux-x86_64.iso to /dev/sda...
archlinux-x86_64.iso burned to /dev/sda

Verifying iso was burned successfully...
Calculating SHA256 checksum of /tmp/archiso/archlinux-x86_64.iso
Calculating SHA256 checksum of /dev/sda
Note: this may take up to 10 minutes depending on the speed of the device.
Started at: 2024-10-27 23:34:53
Verification failed!
Expected:   b72dd6ffef7507f8b7cddd7c69966841650ba0f82c29a318cb2d182eb3fcb1db
Calculated: 33611103701e4e2c856f2c68abc7103c8816287eaf3d76a73d53003295372678
```
---

## Contributions

Feel free to submit issues or pull requests to enhance the script. Contributions are welcome!

---
## License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.



