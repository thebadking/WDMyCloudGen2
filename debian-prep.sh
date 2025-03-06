#!/bin/bash

# WD MyCloud Debian Preparation Script (Ubuntu)
# This script prepares a drive with the necessary boot files
# to begin the Debian installation process on a WD MyCloud device

# Error handling function
error_exit() {
    echo "ERROR: $1" >&2
    echo "Exiting script."
    exit 1
}

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    error_exit "This script must be run as root (use sudo)"
fi

# Install required packages
echo "Installing required packages..."
apt-get update
apt-get install -y parted wget e2fsprogs || error_exit "Failed to install required packages"

# List available drives
echo "Available drives:"
lsblk -d -o NAME,SIZE,MODEL
echo ""
echo "WARNING: Be extremely careful when selecting a drive!"
echo "All data on the selected drive will be PERMANENTLY DESTROYED."
echo "Make sure you've selected the correct drive before continuing."
echo ""

# Prompt user to select a drive
read -p "Enter the drive to set up (e.g., sda, sdb): " DRIVE
DEVICE="/dev/$DRIVE"

# Verification
if [ ! -b "$DEVICE" ]; then
    error_exit "Device $DEVICE does not exist."
fi

echo ""
echo "You've selected: $DEVICE"
lsblk "$DEVICE"
echo ""
echo "WARNING: All data on $DEVICE will be DESTROYED!"
read -p "Are you absolutely sure you want to continue? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Function to partition and format the drive
setup_initial_partitions() {
    local device=$1
    
    echo "Setting up initial partitions for Debian installation..."
    
    # Unmount any existing partitions on the drive
    echo "Unmounting any existing partitions on $device..."
    umount ${device}* 2>/dev/null
    
    # Create initial partitions using parted
    echo "Creating initial partitions with parted..."
    parted --script $device \
        mklabel gpt \
        mkpart primary 1049kB 2149MB \
        mkpart primary 8591MB -1MB \
        mkpart primary 7517MB 8591MB \
        mkpart primary 2149MB 3222MB \
        mkpart primary 3222MB 4296MB \
        mkpart primary 4296MB 6443MB \
        mkpart primary 6443MB 7517MB
    
    # Wait for the system to recognize partitions
    echo "Waiting for system to recognize new partitions..."
    sleep 3
    partprobe $device
    sleep 2
    
    # Format boot partition (partition 3)
    echo "Creating ext4 filesystem on ${device}3 (boot partition)..."
    mkfs.ext4 ${device}3 || error_exit "Failed to create ext4 filesystem on ${device}3"
    
    echo "Initial partitioning and formatting completed successfully."
}

# Function to download and install Debian files
install_debian_files() {
    local device=$1
    
    echo "Downloading and installing Debian files..."
    
    # Create temporary and mount directories
    mkdir -p /tmp/wddebian /mnt/wdboot
    
    # Download Debian files
    echo "Downloading Debian files..."
    cd /tmp/wddebian
    wget http://fox-exe.ru/WDMyCloud/WDMyCloud-Gen2/Debian/jessie-rootfs.tar.gz || error_exit "Failed to download Debian rootfs"
    wget http://fox-exe.ru/WDMyCloud/WDMyCloud-Gen2/Debian/uImage || error_exit "Failed to download uImage"
    wget http://fox-exe.ru/WDMyCloud/WDMyCloud-Gen2/Debian/uRamdisk || error_exit "Failed to download uRamdisk"
    
    # Mount the boot partition
    echo "Mounting boot partition ${device}3..."
    mount ${device}3 /mnt/wdboot || error_exit "Failed to mount ${device}3"
    
    # Create boot directory and copy files
    echo "Copying Debian files to boot partition..."
    mkdir -p /mnt/wdboot/boot
    cp /tmp/wddebian/uImage /mnt/wdboot/boot/ || error_exit "Failed to copy uImage"
    cp /tmp/wddebian/uRamdisk /mnt/wdboot/boot/ || error_exit "Failed to copy uRamdisk"
    cp /tmp/wddebian/jessie-rootfs.tar.gz /mnt/wdboot/boot/ || error_exit "Failed to copy jessie-rootfs.tar.gz"
    
    # Copy the second script for telnet installation
    echo "Copying installation script for telnet session..."
    cp /tmp/wdmc-debian-install.sh /mnt/wdboot/ 2>/dev/null || echo "Note: Second script not found, skipping"
    
    # Create informational README
    cat > /mnt/wdboot/README-DEBIAN.txt << EOF
WD MyCloud Debian Installation - Stage 1 Complete
================================================
Date: $(date)

This drive has been prepared with the initial files needed for Debian installation.
The boot partition (partition 3) has been set up with the necessary boot files.

Next steps:
1. Install this drive in your WD MyCloud device
2. Power on the device and wait for it to boot
3. Connect to the device via telnet
4. Run the commands in the next script or follow the instructions in the howto

Note: If you've copied wdmc-debian-install.sh to this drive, you can run it
directly after connecting via telnet.
EOF
    
    # Unmount and sync
    cd /
    umount /mnt/wdboot
    sync
    
    echo "Debian boot files installation completed successfully."
}

# Main function
main() {
    echo "Starting WD MyCloud Debian preparation..."
    
    # Set up initial partitions
    setup_initial_partitions $DEVICE
    
    # Install Debian boot files
    install_debian_files $DEVICE
    
    echo ""
    echo "====================================="
    echo "Preparation for Debian installation is complete."
    echo ""
    echo "Next steps:"
    echo "1. Install the drive in your WD MyCloud device"
    echo "2. Power on the device and wait for it to boot"
    echo "3. Connect to the device via telnet"
    echo "4. Run the second script (wdmc-debian-install.sh) on the device"
    echo "   or follow the manual installation steps from the howto"
    echo "====================================="
}

# Execute the main function
main
