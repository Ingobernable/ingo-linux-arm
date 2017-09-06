#!/bin/sh
echo " Bienvenid@s al script de creacion"
sleep 1
echo " de la imagen linux para una tablet allwinner "
sleep 1
echo " Instalando dependencias"
sleep 3
apt-get update
apt-get install -y gcc-arm-linux-gnueabihf wget git debootstrap qemu-user-static 
echo " Instalación de dependencias completado "
sleep 3
echo " Creando directorios y disco RAM "
sleep 3
mkdir /tmp/ramdisk
mkdir /home/sunxi
mkdir /home/sunxi/u-boot
mkdir /home/sunxi/kernel
mkdir /home/sunxi/modules
mkdir /home/sunxi/Imagen
mount -t tmpfs none /tmp/ramdisk -o size=1800M
echo " Directorios creados "
sleep 1
echo " OK "
sleep 1
cd ..
echo " Descargando Kernel " 
sleep 3
cd /tmp/ramdisk/
wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.12.10.tar.xz
cp linux-4.12.10.tar.xz /home/sunxi/kernel
echo " Descarga kernel "
sleep 1
echo " OK "
sudo tar -Jxf linux-4.12.10.tar.xz
cd linux-4.12.10
echo " Cuando aparezca el menu puedes pulsar---> File---> Quit"
sleep 3
sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf sunxi_defconfig
sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- xconfig
sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage dtbs
sudo ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=output make modules modules_install
cp arch/arm/boot/zImage /home/sunxi/kernel
cp -r arch/arm/boot/dts /home/sunxi/dts
cp -r output/lib /home/sunxi/modules/lib
sleep 5
cd ..
rm -r linux-4.12.10
rm /tmp/ramdisk/linux-4.12.10.tar.xz
echo " Disco RAM creado "
sleep 1
echo " ok "
sleep 2
echo " Descarga y compilacion de u-boot "
sleep 2
echo " Descargando u-boot denx "
sleep 1
git clone git://git.denx.de/u-boot.git /tmp/ramdisk/u-boot

echo " Cuando aparezca el menu "
sleep 1
echo " no tiene que configurar nada "
sleep 1
echo " para continuar, seleccione Menu ----> File ----> Quit "
cd /tmp/ramdisk/u-boot
sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-  q8_a33_tablet_800x480_defconfig
sudo make  -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- xconfig
sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
sudo cp u-boot-sunxi-with-spl.bin /home/sunxi/u-boot
cd ..
rm -r u-boot
echo " Esperando para desmontar " 
sleep 3
dd if=/dev/zero of=/tmp/ramdisk/rootfs.img bs=1 count=0 seek=1700M
mkfs.ext4 -b 4096 -F /tmp/ramdisk/rootfs.img
chmod 777 /tmp/ramdisk/rootfs.img
mkdir /TableX
mount -o loop /tmp/ramdisk/rootfs.img /TableX
echo "Iniciando proceso deboostrap"
sleep 3
debootstrap --arch=armhf --foreign trusty /TableX
cp /usr/bin/qemu-arm-static /TableX/usr/bin
cp /etc/resolv.conf /TableX/etc
#cp /home/sunxi/kernel/zImage /TableX/boot
#cp /home/sunxi/dts
#cp -r /home/sunxi/modules       /TableX/
#cp /home/sunxi/dts/sun8i-a33-q8-tablet.dtb /TableX/boot

# rm -r /home/sunxi/modules
> config.sh
cat <<+ > config.sh
#!/bin/sh
echo " Configurando debootstrap segunda fase"
sleep 3
/debootstrap/debootstrap --second-stage
export LANG=C
echo "deb http://ports.ubuntu.com/ trusty main restricted universe multiverse" > /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ trusty-security main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ trusty-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ trusty-backports main restricted universe multiverse" >> /etc/apt/sources.list
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "Europe/Berlin" > /etc/timezone
echo "TableX" >> /etc/hostname
echo "127.0.0.1 TableX localhost
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts" >> /etc/hosts
echo "auto lo
iface lo inet loopback" >> /etc/network/interfaces
echo "/dev/mmcblk0p1 /	   ext4	    errors=remount-ro,noatime,nodiratime 0 1" >> /etc/fstab
echo "tmpfs    /tmp        tmpfs    nodev,nosuid,mode=1777 0 0" >> /etc/fstab
echo "tmpfs    /var/tmp    tmpfs    defaults    0 0" >> /etc/fstab
sync			
cat <<END > /etc/apt/apt.conf.d/71-no-recommends
APT::Install-Recommends "0";
APT::Install-Suggests "0";
END

apt-get update

echo "Reconfigurando parametros locales"
sleep 3
locale-gen es_ES.UTF-8
export LC_ALL="es_ES.UTF-8"
update-locale LC_ALL=es_ES.UTF-8 LANG=es_ES.UTF-8 LC_MESSAGES=POSIX
dpkg-reconfigure locales
dpkg-reconfigure -f noninteractive tzdata
apt-get install -y lubuntu-desktop
adduser usuario --disabled-password
addgroup usuario sudo
exit
+
chmod +x config.sh 
cp config.sh /TableX/home
echo "Montando directorios"
sleep 3
sudo mount -o bind /dev /TableX/dev
sudo mount -o bind /dev/pts /TableX/dev/pts
sudo mount -t sysfs /sys /TableX/sys
sudo mount -t proc /proc /TableX/proc
chroot /TableX /usr/bin/qemu-arm-static /bin/sh -i ./home/config.sh && exit 
umount /TableX/{sys,proc,dev/pts,dev}
umount /TableX
cp  /tmp/ramdisk/rootfs.img /home
rm config.sh
exit
