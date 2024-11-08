#!/bin/bash
set -euo pipefail

default_mirror="https://mirrors.kernel.org/archlinux/"
download_mirror=""
verification_url="https://archlinux.org/"
iso_path="iso/latest/"
iso_file="archlinux-x86_64.iso"
iso_sig_file="archlinux-x86_64.iso.sig"
iso_sha256sums_file="sha256sums.txt"
iso_b2sums_file="b2sums.txt"
iso_download_dir="/tmp/archiso/"
burn_to_disk="false"

print_intro() {
    clear
    echo "============================================================================"
    echo "               _             _       _     _                                "
    echo "              / \   _ __ ___| |__   | |   (_)_ __  _   ___  __              "
    echo "             / _ \ | '__/ __| '_ \  | |   | | '_ \| | | \ \/ /              "
    echo "            / ___ \| | | (__| | | | | |___| | | | | |_| |>  <               "
    echo "           /_/   \_\_|  \___|_| |_| |_____|_|_| |_|\__,_/_/\_\              "
    echo "        _             ____                      _                 _         "
    echo "       (_)___  ___   |  _ \  _____      ___ __ | | ___   __ _  __| |        "
    echo "       | / __|/ _ \  | | | |/ _ \ \ /\ / / '_ \| |/ _ \ / _  |/ _  |        "
    echo "       | \__ \ (_) | | |_| | (_) \ V  V /| | | | | (_) | (_| | (_| |        "
    echo "       |_|___/\___/  |____/ \___/ \_/\_/ |_| |_|_|\___/ \__,_|\__,_|        "
    echo "                  _  __     __        _  __ _           _   _               "
    echo "   __ _ _ __   __| | \ \   / /__ _ __(_)/ _(_) ___ __ _| |_(_) ___  _ __    "
    echo "  / _  | '_ \ / _  |  \ \ / / _ \ '__| | |_| |/ __/ _  | __| |/ _ \| '_ \   "
    echo " | (_| | | | | (_| |   \ V /  __/ |  | |  _| | (_| (_| | |_| | (_) | | | |  "
    echo "  \__,_|_| |_|\__,_|    \_/ \___|_|  |_|_| |_|\___\__,_|\__|_|\___/|_| |_|  "
    echo "                                                                            "
    echo "============================================================================"
    echo ""
    echo " This script will download and verify the latest Arch Linux iso and burn it "
    echo " to an unmounted drive for installation.                                    "
    echo ""
    echo "============================================================================"
    echo ""
    echo ""
    sleep 2
}


prompt_for_burn_to_disk() {
    while true; do
        echo -e "Do you want to:\n    1) Download and Verify the Arch Linux ISO?\n    2) Download, Verify, and Burn the Arch Linux ISO to a disk?"

        # Prompt for user input
        read -p "Enter your choice: " choice
        choice=${choice:-1} # Default to option 1 if no input is provided

        if [[ "$choice" == "1" ]]; then
            echo "Download and Verify the Arch ISO."
            echo ""
            burn_to_disk="false"
            break
        elif [[ "$choice" == "2" ]]; then
            echo "Download, Verify, and Burn the Arch ISO to a disk."
            echo ""
            burn_to_disk="true"
            break
        else
            echo "Invalid choice. Please enter 1 or 2."
        fi
    done
}


download_and_verify_iso() {
    local json
    json=$(get_mirror_status_json)
    mirrors=($(get_top_mirrors_from_json "$json"))

    for mirror in "${mirrors[@]}"; do
        download_mirror="$mirror$iso_path"
        download_iso

        if verify_sha256sum && verify_b2sum && verify_pgp_signature; then
            echo "All verifications passed for $iso_file from $mirror."
            echo ""
            echo "============================================================================"
            echo ""
            sleep 2
            return 0
        else
            echo "ISO from $mirror failed verification! Trying another mirror..."
            echo ""
        fi
    done

    echo "WARNING: All mirrors failed. Falling back to default mirror..."
    download_mirror="$default_mirror$iso_path"
    echo "$download_mirror"
    echo ""
}

get_mirror_status_json() {
    curl -s https://archlinux.org/mirrors/status/json/ || { echo "Warning: Error fetching mirror status"; return 1; }
}

get_top_mirrors_from_json() {
    local json="$1"
    echo "$json" | jq -r '
        .urls
        | map(select(.active == true and .protocol == "https" and .score != null and .delay < 60))
        | sort_by(.score)  # Sort by score in ascending order
        | .[:10]            # Limit to top 10 mirrors
        | .[] | .url'       # Return valid mirrors
}

create_download_directory() {
    if [[ ! -d "$iso_download_dir" ]]; then
        echo "Creating temporary directory at $iso_download_dir..."
        echo ""
        mkdir -p "$iso_download_dir"
    fi
}

download_iso() {
    local iso_url="$download_mirror$iso_file"
    local iso_target="$iso_download_dir$iso_file"
    echo "Downloading iso $iso_file"
    echo "  from $iso_url"
    echo "  to $iso_target"
    curl -# -o "$iso_target" "$iso_url"
}

download_iso_verification_files() {
    local files=("$iso_sig_file" "$iso_sha256sums_file" "$iso_b2sums_file")
    echo "Downloading iso verification files..."
    for file in "${files[@]}"; do
        local url="${verification_url}${iso_path}${file}"
        local target="${iso_download_dir}${file}"

        echo "Downloading $file"
        echo "  from $url"
        echo "  to $target..."

        if curl -# -o "$target" "$url"; then
            echo "Download successful!"
            echo ""
        else
            echo "Error: Failed to download $file from $url" >&2
            echo ""
            return 1
        fi
    done
}

verify_sha256sum() {
    echo "Verifying SHA256 checksum..."

    cd "$iso_download_dir" || {
        echo "Error: Unable to change to $iso_download_dir" >&2
        echo ""
        return 1
    }

    # Ensure both the ISO and SHA256SUM files exist
    if [[ ! -f "$iso_sha256sums_file" ]]; then
        echo "Error: SHA256SUM file not found: $iso_sha256sums_file" >&2
        echo ""
        return 1
    fi

    if [[ ! -f "$iso_file" ]]; then
        echo "Error: ISO file not found: $iso_file" >&2
        echo ""
        return 1
    fi

    # Extract the expected checksum for the specific ISO file
    expected_checksum=$(grep "$(basename "$iso_file")" "$iso_sha256sums_file" | awk '{print $1}')
    if [[ -z "$expected_checksum" ]]; then
        echo "Error: No matching checksum found for $iso_file in $iso_sha256sums_file" >&2
        echo ""
        return 1
    fi

    # Calculate the actual checksum of the ISO
    actual_checksum=$(sha256sum "$iso_file" | awk '{print $1}')

    # Compare the checksums
    if [[ "$expected_checksum" == "$actual_checksum" ]]; then
        echo "SHA256 checksum verification passed."
        echo ""
        return 0
    else
        echo "Error: SHA256 checksum verification failed." >&2
        echo "Expected:   $expected_checksum"
        echo "Calculated: $actual_checksum"
        echo ""
        return 1
    fi
}

verify_b2sum() {
    echo "Verifying B2 checksum..."

    cd "$iso_download_dir" || {
        echo "Error: Unable to change to $iso_download_dir" >&2
        echo ""
        return 1
    }

    # Ensure both the ISO and B2SUM files exist
    if [[ ! -f "$iso_b2sums_file" ]]; then
        echo "Error: B2SUM file not found: $iso_b2sums_file" >&2
        echo ""
        return 1
    fi

    if [[ ! -f "$iso_file" ]]; then
        echo "Error: ISO file not found: $iso_file" >&2
        echo ""
        return 1
    fi

    # Extract the expected checksum for the specific ISO file
    expected_checksum=$(grep "$(basename "$iso_file")" "$iso_b2sums_file" | awk '{print $1}')
    if [[ -z "$expected_checksum" ]]; then
        echo "Error: No matching checksum found for $iso_file in $iso_b2sums_file" >&2
        echo ""
        return 1
    fi

    # Calculate the actual checksum of the ISO
    actual_checksum=$(b2sum "$iso_file" | awk '{print $1}')

    # Compare the checksums
    if [[ "$expected_checksum" == "$actual_checksum" ]]; then
        echo "B2 checksum verification passed."
        echo ""
        return 0
    else
        echo "Error: B2 checksum verification failed." >&2
        echo "Expected:   $expected_checksum"
        echo "Calculated: $actual_checksum"
        echo ""
        return 1
    fi
}

import_public_key() {
    local email="$1"
    echo "Importing public key for $email..."

    if gpg --auto-key-locate clear,wkd -v --locate-external-key "$email" >/dev/null 2>1; then
        echo "Public key for $email imported successfully."
        echo ""
    else
        echo "Failed to import public key for $email. Please check manually."
        echo ""
        return 1
    fi
}

verify_pgp_signature() {
    echo "Verifying PGP signature..."

    cd "$iso_download_dir" || {
        echo "Error: Unable to change to $iso_download_dir" >&2
        echo ""
        return 1
    }

    # Ensure both the ISO and signature files exist
    if [[ ! -f "$iso_sig_file" ]]; then
        echo "Error: Signature file not found: $iso_sig_file" >&2
        echo ""
        return 1
    fi

    if [[ ! -f "$iso_file" ]]; then
        echo "Error: ISO file not found: $iso_file" >&2
        echo ""
        return 1
    fi

    import_public_key "pierre@archlinux.org" || return 1

    # Verify the PGP signature using GPG
    if gpg --verify "$iso_sig_file" "$iso_file" 2>&1 | grep -q "Good signature"; then
        echo "PGP signature verification passed."
        echo ""
        return 0
    else
        echo "Error: PGP signature verification failed." >&2
        echo ""
        gpg --verify "$iso_sig_file" "$iso_file" 2>&1  # Display detailed GPG output for debugging
        return 1
    fi
}

list_unmounted_devices() {
    found_device=false

    # Iterate over all root devices (like /dev/sda, /dev/nvme0n1, /dev/mmcblk0)
    for device in /dev/sd* /dev/nvme* /dev/mmcblk*; do
        # Ensure it's a valid block device and not a partition (skip numbered ones)
        [[ ! -b "$device" || "$device" =~ [0-9]+$ ]] && continue

        # Check if any partition or LVM associated with this device is mounted
        skip_device=false
        for child in $(lsblk -ln -o NAME "$device" | grep -v "^$(basename "$device")$"); do
            if mount | grep -q "/dev/${child}"; then
                skip_device=true
                break
            fi
        done

        # If any associated partition is mounted, skip this root device
        $skip_device && continue

        # If a valid device is found, mark found_device as true
        found_device=true

        # Gather device details: Model and Size
        model=$(udevadm info --query=property --name="$device" | grep ID_MODEL= | cut -d= -f2)
        size=$(lsblk -b -dn -o SIZE "$device" | numfmt --to=iec-i --suffix=B)

        # Output device info
        echo "$device - $model - $size"
    done

    # If no valid devices were found, print a warning message
    if ! $found_device; then
        echo "No device found!"
        echo "Please insert or unmount a device to burn the ISO to."
        exit 1
    fi

    echo
}

select_target_device() {
    echo "Select a device to burn the ISO to:"

    # Call list_unmounted_devices() to display available devices
    list_unmounted_devices

    # Store available devices in an array
    mapfile -t available_devices < <(list_unmounted_devices | grep -E "^/dev/" | awk '{print $1}')

    # If no devices are available, exit early
    if [[ ${#available_devices[@]} -eq 0 ]]; then
        echo "No available devices. Insert a device or unmount any mounted partitions."
        exit 1
    fi

    # Display devices for user selection
    PS3="Enter the number corresponding to the device: "
    select device in "${available_devices[@]}"; do
        if [[ -n "$device" ]]; then
            # Safety checks to prevent burning the ISO to the current root device
            current_root_device=$(findmnt -no SOURCE / | sed 's/[0-9]*$//')

            if [[ "$device" == "$current_root_device" ]]; then
                echo "Error: You cannot select the current root device ($current_root_device)."
                exit 1
            fi

            echo "You selected: $device"
            echo ""
            echo "WARNING: THIS IS A DESTRUCTIVE COMMAND!"
            echo "Are you sure you want to proceed with burning the iso to $device?"
            read -rp "Type YES in capital letters to continue, (N)o to select another device, or (Q)uit: " confirm
            if [[ "$confirm" == "YES" ]]; then
                target_device="$device"
                echo "Target device set to: $target_device"
                burn_iso_to_disk
                return 0
            elif [[ "${confirm^^}" == "N" || "${confirm^^}" == "NO" ]]; then
                echo "Selection cancelled. Please choose another device."
            elif [[ "${confirm^^}" == "Q" || "${confirm^^}" == "QUIT" ]]; then
                echo "The dd command to manually burn the ISO to $target_device is:"
                echo "dd if=\"$iso_download_dir$iso_file\" of=\"$target_device\" bs=4M status=progress oflag=sync"
                exit 1
            else
                echo "Invalid response. Please try again."
            fi
        else
            echo "Invalid selection. Please try again."
        fi
    done
}

burn_iso_to_disk() {
    local input_file="$iso_download_dir$iso_file"
    local output_file="$target_device"

    echo "Burning $input_file to $output_file..."
    sudo dd if="$input_file" of="$output_file" bs=4M status=progress oflag=sync
    echo "$iso_file burned to $output_file"
    echo ""
}

verify_iso_burn() {
    local iso_file="$iso_download_dir$iso_file"
    local iso_size
    echo "Verifying ISO was burned successfully..."

    # Get the size of the ISO file
    iso_size=$(stat --format="%s" "$iso_file")

    echo "Comparing the ISO with the burned content on $target_device"
    echo "Note: This process may take some time, depending on the device speed."

    # Use cmp to compare the ISO with the target device, limited to the ISO size
    sudo cmp --bytes="$iso_size" "$iso_file" "$target_device"

    if [[ $? -eq 0 ]]; then
        echo "Verification successful: ISO was burned successfully!"
        echo "You may now restart and boot into the installation medium."
        return 0
    else
        echo "Verification failed! The ISO may not have been burned successfully."
        echo "Please verify manually or try again."
        echo "The dd command to burn the ISO to $target_device is:"
        echo "dd if=\"$iso_download_dir$iso_file\" of=\"$target_device\" bs=4M status=progress oflag=sync"
        exit 1
    fi
}

cleanup() {

    # List of files to delete
    files_to_remove=(
        "$iso_download_dir$iso_file"
        "$iso_download_dir$iso_sig_file"
        "$iso_download_dir$iso_sha256sums_file"
        "$iso_download_dir$iso_b2sums_file"
    )

    echo ""
    read -p "Do you want to remove the ISO and verification files? [y/n]: " response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        for file in "${files_to_remove[@]}"; do
            if [[ -f "$file" ]]; then
                rm "$file"
                echo "Removed: $file"
            else
                echo "File not found: $file"
            fi
        done
    else
        return
    fi

    echo "Cleanup complete."
}

main() {
    print_intro
    prompt_for_burn_to_disk

    create_download_directory
    download_iso_verification_files
    download_and_verify_iso

    if [[ "$burn_to_disk" == "true" ]]; then
        select_target_device
        verify_iso_burn
        cleanup
    fi
}

main
