mkdir iso
cd iso
wget https://cdimage.debian.org/debian-cd/current/i386/iso-cd/debian-9.9.0-i386-netinst.iso
cd ..
qemu-img create debiani686.img 3G
qemu-system-i386 -boot d -cdrom debian-9.9.0-i386-netinst.iso -hda debiani686.img
# install to disk then run
# qemu-system-i385 debiani686.img 
