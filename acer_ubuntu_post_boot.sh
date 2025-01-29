

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

# Final system updates
echo "Updating system..."
sudo chroot /mnt /bin/bash -c "do-release-upgrade -y && apt update && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y && apt autoclean -y"

# Completion message
echo "Installation complete! Reboot your system."
