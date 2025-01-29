# Tutorial: Installing Ubuntu on an Acer Aspire ES-15

The Acer Aspire ES-15 has a poor EFI implementation, making the NVRAM read-only. This causes normal Linux installations to fail. This tutorial walks you through the installation process step by step. It may also work with minimal changes on other laptops with weak EFI implementations.

## Step 1: Enter UEFI Setup
1. Restart your laptop and enter the UEFI Setup screen.
2. Go to the **'Security'** tab and set a **'Supervisor password'** (e.g., `1`).
3. Navigate to the **'Boot'** tab and disable **'Secure Boot'**.
4. Return to the **'Main'** tab and:
   - Disable **'Fast Boot'**
   - Enable **'F12 Boot Menu'**

> **NOTE:** Use Ubuntu **18.04** for installation. Newer versions won't boot due to a package called `secureboot-db`.

## Step 2: Boot Ubuntu Install USB
1. Insert your Ubuntu USB installation media.
2. Press `F12` at startup and select your USB drive.
3. On the GRUB screen, press `e` to edit boot options.
4. Locate the Linux line and add the following after `splash`:
   ```
   PCI=NOAER
   ```
   > This step may not be required, but it won't hurt.
5. Boot into Ubuntu and open a terminal.
6. Run the following command to install Ubuntu **without a bootloader**:
   ```
   ubiquity -b
   ```
7. Follow the on-screen Ubuntu installation steps.
8. After installation, select **'Continue testing Ubuntu'** and open a terminal.

## Step 3: Configure the Bootloader
### Identify Your Partitions
Determine your newly installed Linux partition (root) and EFI partition:
```sh
lsblk
```
Substitute `/dev/sdx` (root) and `/dev/sdy` (EFI) in the commands below.

### Mount the Partitions
```sh
sudo mount /dev/sdx /mnt
sudo mkdir /mnt/boot/efi
sudo mount /dev/sdy /mnt/boot/efi
for i in /dev /dev/pts /proc /sys; do sudo mount -B $i /mnt$i; done
```

### Ensure `efivars` is Loaded
```sh
sudo modprobe efivars
```

### Reinstall and Install GRUB
```sh
sudo apt-get install --reinstall grub-efi-amd64
sudo grub-install --no-nvram --root-directory=/mnt
```

### Change Root to Installed Ubuntu & Update GRUB
```sh
sudo chroot /mnt
update-grub
```

### Hijack the Fallback Bootloader
```sh
cd /boot/efi/EFI
cp -R ubuntu/* BOOT/
cd BOOT
cp grubx64.efi bootx64.efi
```

Now, boot the system into Ubuntu. If you are dual-booting with Windows, follow the additional step mentioned below. To boot Ubuntu for now, press `F12` at startup and select Ubuntu.

## Step 4: Permanently Hijack the Fallback Bootloader
After booting into Ubuntu, open a terminal and run:
```sh
echo "grub-efi-amd64 grub2/force_efi_extra_removable boolean true" | sudo debconf-set-selections
```
Enter your password (it won't be visible on screen).

Now, update GRUB:
```sh
update-grub
```

## Step 5: Remove `secureboot-db`
To prevent issues later, remove this package:
```sh
sudo apt remove secureboot-db
```
Ensure you never reinstall it.

## Step 6: Final System Update
To update your system, follow these steps:
```sh
sudo -i
```
Enter your password, then execute these commands in order:
```sh
do-release-upgrade
apt update
apt upgrade
apt dist-upgrade
apt autoremove
apt autoclean
```
Reboot and repeat from `sudo -i` until `do-release-upgrade` reports **'no releases found'**.

---
Congratulations! 🎉 You have successfully installed Ubuntu on your Acer Aspire ES-15.

