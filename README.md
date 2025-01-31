# Installing Ubuntu on Acer Aspire ES-15: Complete Guide

## Overview
This guide provides detailed instructions for installing Ubuntu on the Acer Aspire ES-15 laptop, which has a problematic EFI implementation with read-only NVRAM. This guide may also be useful for other laptops with similar EFI limitations.

### Prerequisites
- Ubuntu 18.04 installation media (USB drive)
- Backup of all important data
- External keyboard (recommended, in case internal keyboard becomes unresponsive)
- Approximately 1 hour of time
- Internet connection (for updates)

### Important Notes
- ⚠️ **Backup Warning**: Always back up your data before proceeding with any OS installation
- 🛑 **Version Requirement**: Ubuntu 18.04 is required due to `secureboot-db` package incompatibilities
- 💡 **Recovery**: Note down your Windows product key if dual-booting
- 🔋 **Power**: Keep your laptop plugged in throughout the installation

## Detailed Installation Steps

### Step 1: UEFI Configuration
1. Access UEFI Setup:
   - Power off the laptop completely
   - Power on and repeatedly press `F2` until UEFI Setup appears
   - If `F2` doesn't work, try `Del` or `Esc`

2. Configure UEFI Settings:
   ```
   Security Tab:
   └── Set Supervisor Password: [create simple password, e.g., '1']
   
   Boot Tab:
   ├── Secure Boot: [Disabled]
   └── Boot Mode: [UEFI]
   
   Main Tab:
   ├── Fast Boot: [Disabled]
   └── F12 Boot Menu: [Enabled]
   ```

3. Save and Exit:
   - Press `F10`
   - Select 'Yes' to save changes
   - System will restart

### Step 2: Ubuntu Installation Preparation

1. Boot from USB:
   - Insert Ubuntu USB drive
   - During startup, press `F12` repeatedly
   - Select USB drive from boot menu

2. Modify Boot Parameters:
   ```
   At GRUB menu:
   1. Press 'e' to edit boot options
   2. Find line starting with 'linux'
   3. Add 'PCI=NOAER' after 'splash'
   4. Press F10 to boot
   ```

3. Start Custom Installation:
   ```bash
   # Open terminal (Ctrl + Alt + T)
   ubiquity -b
   ```

4. During Installation:
   - Choose 'Install Ubuntu'
   - Select language and keyboard layout
   - Choose 'Normal Installation'
   - For Wi-Fi, select 'Connect to this network later'
   - For installation type:
     - If dual-booting: 'Install Ubuntu alongside Windows'
     - If single OS: 'Erase disk and install Ubuntu'
   - Select timezone
   - Create user account
   - Wait for installation to complete
   - Select 'Continue Testing' when prompted

### Step 3: Bootloader Configuration

1. Identify Partitions:
   ```bash
   # List all partitions
   sudo fdisk -l
   
   # Or use more readable format
   lsblk -f
   ```

2. Mount Required Partitions:
   ```bash
   # Mount root partition
   sudo mount /dev/sdXY /mnt  # Replace XY with your partition
   
   # Create and mount EFI partition
   sudo mkdir -p /mnt/boot/efi
   sudo mount /dev/sdXZ /mnt/boot/efi  # Replace XZ with EFI partition
   
   # Mount virtual filesystems
   for i in /dev /dev/pts /proc /sys; do
       sudo mount -B $i /mnt$i
   done
   ```

3. Configure GRUB:
   ```bash
   # Load EFI variables
   sudo modprobe efivars
   
   # Reinstall GRUB
   sudo apt-get install --reinstall grub-efi-amd64
   sudo grub-install --no-nvram --root-directory=/mnt
   
   # Update GRUB configuration
   sudo chroot /mnt update-grub
   ```

4. Configure Fallback Bootloader:
   ```bash
   # Copy bootloader files
   cd /boot/efi/EFI
   sudo cp -R ubuntu/* BOOT/
   cd BOOT
   sudo cp grubx64.efi bootx64.efi
   ```

### Step 4: Post-Installation Configuration

1. First Boot:
   - Restart system
   - Press `F12` at startup
   - Select 'Ubuntu' from boot menu

2. Configure Permanent Bootloader:
   ```bash
   # Set bootloader configuration
   echo "grub-efi-amd64 grub2/force_efi_extra_removable boolean true" | \
   sudo debconf-set-selections
   
   # Update GRUB
   sudo update-grub
   ```

3. Remove Problematic Package:
   ```bash
   # Remove secureboot-db
   sudo apt remove secureboot-db
   ```

### Step 5: System Updates

```bash
# Become root
sudo -i

# Run updates
do-release-upgrade
apt update
apt upgrade
apt dist-upgrade
apt autoremove
apt autoclean
```

## Troubleshooting

### Common Issues and Solutions

1. **Black Screen After Boot**
   - Solution: Add `nomodeset` to GRUB boot parameters
   
2. **Wi-Fi Not Working**
   ```bash
   # Install additional drivers
   sudo ubuntu-drivers autoinstall
   ```

3. **GRUB Not Showing Windows**
   ```bash
   # Update GRUB menu
   sudo update-grub
   ```

4. **System Won't Boot**
   - Boot from USB
   - Choose 'Try Ubuntu'
   - Follow Step 3 again

### Recovery Options

1. **Create Recovery USB**
   ```bash
   # Install tools
   sudo apt install boot-repair
   
   # Run boot repair
   boot-repair
   ```

2. **Emergency GRUB Shell**
   ```
   set root=(hd0,gpt2)  # Adjust partition number
   linux /boot/vmlinuz-linux root=/dev/sdaX
   initrd /boot/initrd-linux.img
   boot
   ```

## Additional Tips

1. **Performance Optimization**
   ```bash
   # Install TLP for better battery life
   sudo apt install tlp
   sudo tlp start
   
   # Install hardware sensors
   sudo apt install lm-sensors
   sudo sensors-detect
   ```

2. **Recommended Software**
   - Updated graphics drivers
   - Power management tools
   - Hardware monitoring utilities

## Support and Resources

- [Ubuntu Forums](https://ubuntuforums.org)
- [Acer Community](https://community.acer.com)
- [Ask Ubuntu](https://askubuntu.com)

## Version History

- v1.1: Added troubleshooting section
- v1.0: Initial guide creation

---

📝 **Note**: Keep this guide updated with any new solutions or issues you encounter. Share your experiences to help others with similar hardware.