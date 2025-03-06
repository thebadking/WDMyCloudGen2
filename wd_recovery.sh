#!/bin/bash

# WD MyCloud Recovery Preparation Script for Ubuntu
# This script partitions a drive according to WD MyCloud specifications
# and installs the recovery files

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
setup_drive() {
    local device=$1
    
    echo "Setting up partitions according to WD MyCloud specifications..."
    
    # Unmount any existing partitions on the drive
    echo "Unmounting any existing partitions on $device..."
    umount ${device}* 2>/dev/null
    
    # Create partitions using parted
    echo "Creating partitions with parted..."
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
    
    # Format partitions
    echo "Setting up swap on ${device}1..."
    mkswap ${device}1 || error_exit "Failed to create swap on ${device}1"
    
    echo "Creating ext4 filesystem on ${device}3..."
    mkfs.ext4 ${device}3 || error_exit "Failed to create ext4 filesystem on ${device}3"
    
    echo "Partitioning and formatting completed successfully."
}

# Function to download and install recovery files
install_recovery() {
    local device=$1
    
    echo "Downloading and installing WD recovery files..."
    
    # Create temporary and mount directories
    mkdir -p /tmp/wdrecovery /mnt/wdboot
    
    # Download recovery files
    echo "Downloading recovery files..."
    cd /tmp/wdrecovery
    wget http://fox-exe.ru/WDMyCloud/WDMyCloud-Gen2/usbrecovery.tar.gz || error_exit "Failed to download recovery files"
    tar -xzf usbrecovery.tar.gz || error_exit "Failed to extract recovery files"
    
    # Mount the boot partition
    echo "Mounting boot partition ${device}3..."
    mount ${device}3 /mnt/wdboot || error_exit "Failed to mount ${device}3"
    
    # Copy boot files
    echo "Copying boot files..."
    mkdir -p /mnt/wdboot/boot
    cp -r /tmp/wdrecovery/boot/* /mnt/wdboot/boot/ || error_exit "Failed to copy boot files"
    
    # Rename boot files as specified
    echo "Renaming boot files..."
    cd /mnt/wdboot/boot
    rm -f uImage uRamdisk
    mv uImage-wdrecovery uImage || error_exit "Failed to rename uImage-wdrecovery"
    mv uRamdisk-wdrecovery uRamdisk || error_exit "Failed to rename uRamdisk-wdrecovery"
    
    # Create information file
    echo "Creating information file..."
    cat > /mnt/wdboot/README.txt << EOF
This drive has been prepared for WD MyCloud Recovery.
Date: $(date)
Setup performed by: WD MyCloud Recovery Script

The following partitions have been created:
1. Swap partition (1049kB to 2149MB)
2. Data partition (8591MB to end)
3. Boot partition (7517MB to 8591MB)
4-7. System partitions

Recovery boot files have been installed to partition 3.
EOF
    
    # Unmount and sync
    cd /
    umount /mnt/wdboot
    sync
    
    echo "WD Recovery installation completed successfully."
}

# Main function
main() {
    echo "Starting WD MyCloud recovery preparation on Ubuntu..."
    
    # Set up drive
    setup_drive $DEVICE
    
    # Install recovery files
    install_recovery $DEVICE
    
    echo ""
    echo "====================================="
    echo "WD MyCloud recovery has been successfully prepared."
    echo "You can now remove the drive and install it in your WD MyCloud device."
    echo "After powering on, the device should be accessible via Web-GUI (Recovery mode)."
    echo "Use original firmware (.bin file) in the Web-GUI."
    echo "====================================="
}

# Execute the main function
main
