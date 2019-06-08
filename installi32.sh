mkdir iso
cd iso
wget https://cdimage.debian.org/debian-cd/current/i386/iso-cd/debian-9.9.0-i386-netinst.iso
cd ..
mkdir img
cd img
qemu-img create debiani686.img 3G
cd ..
qemu-system-i386 -boot d -cdrom /iso/debian-9.9.0-i386-netinst.iso -hda /img/debiani686.img
# install to disk then run
# qemu-system-i386 /img/debiani686.img 

# see https://wiki.debian.org/QEMU#Networking
# for virtual host network setup

# further
