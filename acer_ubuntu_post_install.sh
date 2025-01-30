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

#Reboot
echo "You can reboot now! using 'sudo reboot'"

