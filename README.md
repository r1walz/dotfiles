# Guide to Arch

### Installing graphical over vanila arch

 * Install the xorg server and nvidia drivers

```
sudo pacman -S xorg
sudo pacman -S nvidia nvidia-lts nvidia-libgl mesa
```


 * We will need to add a **drm-modeset** to grub. Add the following to `GRUB_CMDLINE_LINUX_DEFAULT` in /etc/defaults/grub
```
GRUB_CMDLINE_LINUX_DEFAULT="nvidia-drm.modeset=1 quiet"
```

 * After adding that, make sure to update grub
```
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

 * Add modules to mkinitcpio. Open /etc/mkinitcpio.conf and add `nvidia` `nvidia_modeset` `nvidia_uvm` `nvidia_drm` to **MODULES** section. It should look something like this after that:

```
MODULES=(ext4 nvidia nvidia_modeset nvidia_uvm nvidia_drm)
```

 * Now run:
```
sudo mkinitcpio -p linux
```

 * We need to create a hook for nvidia driver. Copy the below code to **/etc/pacman.d/hooks/nvidia.hook**. You might have to create hooks directory in case you don't have it previously.

```
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux
# Change the linux part above and in the Exec line if a different kernel is used

[Action]
Description=Update Nvidia module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'
```

 * Now we need to generate a xorg conf. Run:

```
sudo nvidia-xconfig
```

 * Now install window manager and a display manager

```
sudo pacman -S lightdm lightdm-gtk-greeter
sudo pacman -S i3 dmenu rxvt-unicode
```

 * Now we need to tell the greeter used to lightdm. Add this line under the `[Seat:*]` section.

```
greeter-session=lightdm-gtk-greeter
```

 * You are all set. Enable lightdm and reboot.

```
sudo systemctl enable lightdm
sudo reboot
```

### Still experiencing black screen?

I faced a similar situation. Turns out you need to explicitly tell xorg to run nvidia with modesetting. Create a file at /etc/lightdm.

```
sudo vim /etc/lightdm/display_setup.sh
```

Add the following lines:

```
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
```

Don't forget chmod +x the display_setup.sh

Now add the display_setup.sh to /etc/lightdm/lightdm.conf in the `[Seat:*]` section.

```
display-setup-script=/etc/lightdm/display_setup.sh
```

Finally we need to update the xorg.conf to add the modesetting. Update the **Device** section and add a **Module** section. An example is given as:

```
Section "Module"
    Load           "modesetting"
EndSection

Section "Device"
    Identifier     "nvidia"
    Driver         "nvidia"
    BusID          "1:0:0"
    VendorName     "NVIDIA Corporation"
    Option         "AllowEmptyInitialConfiguration"
EndSection
```

This is all I needed to get things to work. Simply reboot the device and everything should work now.
