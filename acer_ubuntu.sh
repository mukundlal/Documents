#!/bin/bash

# Exit on errors
set -e

# Prompt user for partition details
echo "Enter the root partition (e.g., /dev/sdX):"
read ROOT_PARTITION
echo "Enter the EFI partition (e.g., /dev/sdY):"
read EFI_PARTITION

# Mount the partitions
echo "Mounting partitions..."
sudo mount "$ROOT_PARTITION" /mnt
sudo mkdir -p /mnt/boot/efi
sudo mount "$EFI_PARTITION" /mnt/boot/efi
for i in /dev /dev/pts /proc /sys; do sudo mount -B $i /mnt$i; done

# Load efivars
sudo modprobe efivars

# Reinstall and install GRUB
echo "Installing GRUB..."
sudo apt-get install --reinstall grub-efi-amd64 -y
sudo grub-install --no-nvram --root-directory=/mnt

# Change root and update GRUB
echo "Updating GRUB..."
sudo chroot /mnt update-grub

# Hijack the fallback bootloader
echo "Configuring fallback bootloader..."
sudo chroot /mnt /bin/bash -c "cd /boot/efi/EFI && cp -R ubuntu/* BOOT/ && cd BOOT && cp grubx64.efi bootx64.efi"

# Make fallback bootloader permanent
echo "Making fallback bootloader permanent..."
echo "grub-efi-amd64 grub2/force_efi_extra_removable boolean true" | sudo chroot /mnt debconf-set-selections
sudo chroot /mnt update-grub

# Remove secureboot-db
echo "Removing secureboot-db..."
sudo chroot /mnt apt remove secureboot-db -y

# # Final system updates
# echo "Updating system..."
# sudo chroot /mnt /bin/bash -c "do-release-upgrade -y && apt update && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y && apt autoclean -y"

# # Completion message
# echo "Installation complete! Reboot your system."
