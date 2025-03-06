#!/bin/sh

# WD MyCloud Debian Installation Script (Telnet)
# This script is meant to be run on the WD MyCloud device via telnet
# after booting from the prepared drive

# Show banner
echo "============================================="
echo "  WD MyCloud Debian Installation Script"
echo "============================================="
echo "This script will complete the Debian installation"
echo "on your WD MyCloud device."
echo ""
echo "WARNING: This script will repartition your drive."
echo "All existing data will be lost!"
echo ""
read -p "Do you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Operation cancelled."
    exit 0
fi

# Function to check if a command succeeded
check_status() {
    if [ $? -ne 0 ]; then
        echo "ERROR: $1 failed"
        echo "Script aborted."
        exit 1
    fi
}

# Phase 1: Repartition the drive (Skip 3rd partition)
echo ""
echo "Phase 1: Repartitioning drive (keeping partition 3)..."
echo "Running: parted /dev/sda"

# Create a temporary input file for parted
cat > /tmp/parted_commands.txt << EOF
rm 1
rm 2
rm 4
rm 5
rm 6
rm 7
mkpart primary 0% 1G
q
EOF

# Run parted with the commands
parted /dev/sda < /tmp/parted_commands.txt
check_status "Partitioning"

# Format the new partition
echo "Formatting temporary data partition..."
mkfs.ext4 /dev/sda1
check_status "Formatting /dev/sda1"

# Phase 2: Move firmware files to temporary data partition
echo ""
echo "Phase 2: Moving firmware files to temporary location..."
mkdir -p /mnt/root /mnt/data
mount /dev/sda1 /mnt/data
check_status "Mounting /dev/sda1"

mount /dev/sda3 /mnt/root
check_status "Mounting /dev/sda3"

echo "Copying boot files..."
cp /mnt/root/boot/uImage /mnt/data/
cp /mnt/root/boot/uRamdisk /mnt/data/
cp /mnt/root/boot/jessie-rootfs.tar.gz /mnt/data/
check_status "Copying boot files"

umount /mnt/root
sync
echo "Boot files successfully moved to temporary location."

# Phase 3: Complete disk formatting
echo ""
echo "Phase 3: Completing disk formatting..."
echo "Running: parted /dev/sda"

# Create a temporary input file for parted
cat > /tmp/parted_commands.txt << EOF
rm 3
mkpart primary 4G 100%
mkpart primary 1G 4G
q
EOF

# Run parted with the commands
parted /dev/sda < /tmp/parted_commands.txt
check_status "Partitioning"

# Format the new partitions
echo "Formatting data and root partitions..."
mkfs.ext4 /dev/sda2
check_status "Formatting /dev/sda2"

mkfs.ext4 /dev/sda3
check_status "Formatting /dev/sda3"

# Phase 4: Prepare new firmware
echo ""
echo "Phase 4: Preparing new firmware..."
mount /dev/sda3 /mnt/root
check_status "Mounting /dev/sda3"

echo "Extracting Debian rootfs (this may take a while)..."
tar xf /mnt/data/jessie-rootfs.tar.gz -C /mnt/root
check_status "Extracting rootfs"

echo "Copying boot files to final location..."
mkdir -p /mnt/root/boot
cp /mnt/data/uImage /mnt/root/boot/uImage
cp /mnt/data/uRamdisk /mnt/root/boot/uRamdisk
check_status "Copying boot files"

umount /mnt/root
sync
echo "Debian rootfs successfully installed."

# Phase 5: Convert temporary data partition to swap
echo ""
echo "Phase 5: Converting temporary partition to swap..."
umount /mnt/data
mkswap /dev/sda1
check_status "Creating swap"

# Final steps
echo ""
echo "============================================="
echo "Debian installation completed successfully!"
echo "============================================="
echo ""
echo "The system is now ready to boot into Debian."
echo "After reboot, you can connect via SSH with:"
echo "  Username: root"
echo "  Password: mycloud"
echo ""
echo "Optional: You can install OpenMediaVault (OMV) after booting"
echo "into Debian by following the instructions in the howto."
echo ""
echo "The system will now reboot in 10 seconds..."
echo "Press Ctrl+C to cancel reboot"

# Countdown before reboot
for i in 10 9 8 7 6 5 4 3 2 1; do
    echo -n "$i... "
    sleep 1
done
echo ""

# Final sync and reboot
sync
reboot -f
