#!/bin/sh

# WD MyCloud OpenMediaVault Installation Script
# Run this after booting into Debian to install OpenMediaVault

# Show banner
echo "============================================="
echo "  WD MyCloud OpenMediaVault Installation"
echo "============================================="
echo "This script will install OpenMediaVault (OMV)"
echo "on your WD MyCloud running Debian."
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

# Update hostname configuration
echo "Setting up hostname configuration..."
echo "127.0.1.1       wdmc.lan wdmc" >> /etc/hosts
check_status "Updating hosts file"

# Add OpenMediaVault repository
echo "Adding OpenMediaVault repository..."
echo "deb http://packages.openmediavault.org/public erasmus main" > /etc/apt/sources.list.d/omv.list
check_status "Adding repository"

# Update package list and install keyring
echo "Updating package lists and installing keyring..."
apt-get update
check_status "Updating package lists"

apt-get install --force-yes openmediavault-keyring
check_status "Installing OpenMediaVault keyring"

# Update again and install OpenMediaVault
echo "Installing OpenMediaVault (this may take a while)..."
apt-get update
check_status "Updating package lists"

apt-get install -y openmediavault
check_status "Installing OpenMediaVault"

# Display post-installation information
echo ""
echo "============================================="
echo "OpenMediaVault installation completed!"
echo "============================================="
echo ""
echo "Access the web interface at:"
echo "  http://[your-device-ip]"
echo ""
echo "Default login credentials:"
echo "  Username: admin"
echo "  Password: openmediavault"
echo ""
echo "IMPORTANT NOTES:"
echo "- Create a network interface in the web GUI"
echo "  or you'll lose network connection after restart!"
echo "- Mount data partition (/dev/sda2) as 'User data'"
echo "- Configure any other settings as needed"
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
