

#!/bin/bash

# Ensure the script runs as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root (use sudo)."
    exit 1
fi

echo "Setting GRUB to install in the fallback bootloader location..."
echo "grub-efi-amd64 grub2/force_efi_extra_removable boolean true" | sudo debconf-set-selections

echo "Removing secureboot-db to prevent boot issues..."
sudo apt remove -y secureboot-db

echo "Preventing secureboot-db from reinstalling..."
echo "secureboot-db hold" | sudo dpkg --set-selections

echo "Updating GRUB configuration..."
sudo update-grub

echo "Done! Your system is now protected from Acer's buggy UEFI."

# Completion message
echo "Installation complete! Reboot your system."
