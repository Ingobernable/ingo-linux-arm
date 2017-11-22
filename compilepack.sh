#!/bin/sh
clear
echo " Bienvenid@s al script de creacion"
sleep 1
echo " de la imagen linux para una tablet allwinner "
sleep 1
echo " Instalando dependencias"
sleep 3
apt-get update
apt-get install -y gcc-arm-linux-gnueabihf wget git debootstrap qemu-user-static build-essential bin86 kernel-package libqt4-dev libncurses5 libncurses5-dev qt4-dev-tools u-boot-tools device-tree-compiler swig libpython-dev libqt4-dev
clear
echo " Instalación de dependencias completado "
sleep 3
echo " Creando directorios y disco RAM "
sleep 3
mkdir /tmp/ramdisk
mkdir /home/sunxi
mkdir /home/sunxi/u-boot
mkdir /home/sunxi/kernel
mkdir /home/sunxi/kernel/zImage
mkdir /home/sunxi/modules
mkdir /home/sunxi/Imagen
echo " Directorios creados "
sleep 1
echo " OK "
sleep 1
cd ..
clear
echo " Descargando Kernel mainline" 
sleep 3
cd /home/sunxi/kernel
wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.14.1.tar.xz
echo " Descarga kernel "
sleep 1
echo " OK "
sudo tar -Jxf linux-4.14.1.tar.xz
cd linux-4.14.1
echo " Cuando aparezca el menu puedes pulsar---> File---> Quit"
sleep 3
sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf sunxi_defconfig
sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- xconfig
sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage dtbs
sudo ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=output make modules modules_install
cp arch/arm/boot/zImage /home/sunxi/kernel/zImage
cp -r arch/arm/boot/dts /home/sunxi/dts
cp -r output/lib /home/sunxi/modules/lib
sleep 5
cd ..
echo " Disco RAM creado "
sleep 1
echo " ok "
sleep 2
clear
echo " Descarga y compilacion de u-boot "
sleep 2
echo " Descargando u-boot denx "
sleep 1
git clone git://git.denx.de/u-boot.git /home/sunxi/u-boot

echo " Cuando aparezca el menu "
sleep 1
echo " no tiene que configurar nada "
sleep 1
echo " para continuar, seleccione Menu ----> File ----> Quit "
cd /home/sunxi/u-boot
clear
echo " Menu de compilación del u-boot "
echo " Elija una opción para compilación del u-boot según su modelo de tablet"
sleep 2
echo "1. 	Tablet a13 q8 "
echo ""
echo "2. 	Tablet a23 q8 Resolución 800x480"
echo ""
echo "3. 	Tablet a33 q8 Resolución 1024x600"
echo ""
echo "4. 	Tablet a33 q8 Resolución 800x480"
echo ""
echo "5. 	iNet_3F"
echo ""
echo "6. 	iNet_3W"
echo ""
echo "7. 	iNet_86VS"
echo ""
echo "8. 	iNet_D978"
echo ""
echo -n "	Seleccione una opcion [1 - 8]"
read uboot
case $uboot in
1) sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- q8_a13_tablet_defconfig;;
2) sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- q8_a23_tablet_800x480_defconfig;;
3) sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- q8_a33_tablet_1024x600_defconfig;;
4) sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- q8_a33_tablet_800x480_defconfig;;
5) sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- iNet_3F_defconfig ;;
6) sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- iNet_3W_defconfig;;
7) sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- iNet_86VS_defconfig;;
8) sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- iNet_D978_rev2_defconfig;;
*) echo "$opc no es una opcion válida.";
echo "Presiona una tecla para continuar...";
read foo;;
esac
sudo make  -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- xconfig
sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
sudo cp u-boot-sunxi-with-spl.bin /home/sunxi/u-boot
cd ..
rm -r u-boot
echo " Esperando para desmontar " 
sleep 3
dd if=/dev/zero of=/home/sunxi/Imagen/rootfs.img bs=1 count=0 seek=3500M
mkfs.ext4 -b 4096 -F mkdir /home/sunxi/Imagen/rootfs.img
chmod 777 /home/sunxi/Imagen/rootfs.img
mkdir /TableX
mount -o loop /home/sunxi/Imagen/rootfs.img /TableX
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
