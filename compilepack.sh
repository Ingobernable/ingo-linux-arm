#!/bin/sh
clear
echo " Bienvenid@s al script de creacion"
sleep 1
echo " de la imagen linux para una tablet allwinner "
sleep 1
echo " Instalando dependencias"
sleep 1
apt-get update
apt-get install -y gcc-arm-linux-gnueabihf wget tree git debootstrap qemu-user-static build-essential libssl-dev libusb-1.0-0-dev bin86 kernel-package libqt4-dev libncurses5 libncurses5-dev qt4-dev-tools u-boot-tools device-tree-compiler swig libpython-dev libqt4-dev libusb-dev zlib1g-dev pkg-config
echo " Instalación de dependencias completado "
sleep 1
echo " Creando directorios y disco RAM "
sleep 1
mkdir	/mnt/ramdisk
mount -t tmpfs none /mnt/ramdisk -o size=1500M 
mkdir 	/home/sunxi/
mkdir 	/home/sunxi/tools
mkdir 	/mnt/ramdisk/sunxi
mkdir 	/mnt/ramdisk/sunxi/u-boot
mkdir 	/mnt/ramdisk/sunxi/kernel/
mkdir 	/mnt/ramdisk/sunxi/kernel/mainline
mkdir 	/mnt/ramdisk/sunxi/kernel/sunxi
mkdir 	/mnt/ramdisk/sunxi/kernel/zImage
mkdir 	/mnt/ramdisk/sunxi/Imagen
mkdir   /home/sunxi/u-boot
mkdir   /home/sunxi/kernel/
mkdir 	/home/sunxi/kernel/modules
mkdir   /home/sunxi/kernel/mainline
mkdir   /home/sunxi/kernel/sunxi
echo " Directorios creados "
cp TableX_defconfig /mnt/ramdisk/sunxi/
sleep 1
echo " OK "
sleep 1
echo " Instalando sunxi-tools"
sleep 1
cd /home/sunxi/tools
git clone https://github.com/linux-sunxi/sunxi-tools
cd sunxi-tools
sudo make -j$(nproc)
sudo make -j$(nproc) install

echo " Instalación completada"
sleep 1
#echo " Descargando Kernel sunxi"
#cd /home/sunxi/kernel/sunxi
#git clone https://github.com/linux-sunxi/linux-sunxi.git
echo "Preparando Imagen Gnu/Linux"
sleep 1
dd if=/dev/zero of=/mnt/ramdisk/sunxi/Imagen/trusty.img bs=1 count=0 seek=800M
mkfs.ext4 -b 4096 -F /mnt/ramdisk/sunxi/Imagen/trusty.img
chmod 777 /mnt/ramdisk/sunxi/Imagen/trusty.img
mkdir /TableX
mount -o loop /mnt/ramdisk/sunxi/Imagen/trusty.img /TableX
debootstrap --arch=armhf --foreign trusty /TableX
echo " Añadiendo script de inicio "
> /mnt/ramdisk/sunxi/boot.cmd
cat <<+ >> /mnt/ramdisk/sunxi/boot.cmd
setenv bootargs console=ttyS0,115200 root=/dev/mmcblk0p1 rootwait panic=10
load mmc 0:1 0x43000000 ${fdtfile} || load mmc 0:1 0x43000000 boot/${fdtfile}
load mmc 0:1 0x42000000 zImage || load mmc 0:1 0x42000000 boot/zImage
bootz 0x42000000 - 0x43000000
+
mkimage -C none -A arm -T script -d /mnt/ramdisk/sunxi/boot.cmd /mnt/ramdisk/sunxi/boot.scr
cp /mnt/ramdisk/sunxi/boot.scr /TableX/boot
echo " Descargando y descomprimiento Kernel mainline" 
sleep 1
wget -P /mnt/ramdisk/sunxi/kernel/mainline https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.15.7.tar.xz
cd /mnt/ramdisk/sunxi/kernel/mainline/
sudo tar -Jxf /mnt/ramdisk/sunxi/kernel/mainline/linux-4.15.7.tar.xz 
echo " kernel descomprimido "
sleep 1
cp /mnt/ramdisk/sunxi/TableX_defconfig /mnt/ramdisk/sunxi/kernel/mainline/linux-4.15.7/arch/arm/configs
cd /mnt/ramdisk/sunxi/kernel/mainline/linux-4.15.7
echo " Cuando aparezca el menu puedes pulsar---> File---> Quit"
sleep 1
sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf TableX_defconfig
sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs 
sudo ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=/TableX make modules modules_install
cp arch/arm/boot/zImage /home/sunxi/kernel/mainline/zImage /TableX/boot
cp -R arch/arm/boot/dts /home/sunxi/kernel/dts /TableX/boot/dts
cp -r output/lib /home/sunxi/kernel/modules/lib /TabletX/lib
cd ..
sync
sleep 1
echo " Kernel compilado "
sleep 1
echo " Descarga y compilacion de u-boot "
sleep 1
echo " Descargando u-boot denx "
sleep 1
cd /mnt/ramdisk/sunxi/u-boot
wget ftp://ftp.denx.de/pub/u-boot/u-boot-2017.11.tar.bz2  
cp u-boot-2017.11.tar.bz2 /home/sunxi/u-boot
tar -xjvf u-boot-2017.11.tar.bz2
echo " Descarga y descompresión de u-boot finalizada "
sleep 1
echo " Cuando aparezca el menu "
sleep 1
echo " no tiene que configurar nada "
sleep 1
echo "para continuar, seleccione Menu ----> File ----> Quit"
cd u-boot-2017.11
echo "      Menu de compilación del u-boot"
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
sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- xconfig
sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
sudo cp u-boot-sunxi-with-spl.bin /home/sunxi/u-boot/ /TableX/boot
rm -R /mnt/ramdisk/sunxi/u-boot
echo "Compilación de u-boot terminada"
sleep 1

echo "Iniciando proceso deboostrap"
sleep 1

cp /usr/bin/qemu-arm-static /TableX/usr/bin
cp /etc/resolv.conf /TableX/etc
#cp /home/sunxi/kernel/zImage /TableX/boot
#cp /home/sunxi/dts
#cp -r /home/sunxi/modules       /TableX/
#cp /home/sunxi/dts/sun8i-a33-q8-tablet.dtb /TableX/boot
# rm -r /home/sunxi/modules
> /mnt/ramdisk/sunxi/config.sh
cat <<+ >> /mnt/ramdisk/sunxi/config.sh
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
adduser trusty
addgroup trusty sudo
exit
+
chmod +x  /mnt/ramdisk/sunxi/config.sh
cp  /mnt/ramdisk/sunxi/config.sh /TableX/home
echo "Montando directorios"
sleep 3
sudo mount -o bind /dev /TableX/dev && sudo mount -o bind /dev/pts /TableX/dev/pts && sudo mount -t sysfs /sys /TableX/sys && sudo mount -t proc /proc /TableX/proc
chroot /TableX /usr/bin/qemu-arm-static /bin/sh -i ./home/config.sh && exit 
umount /TableX/{sys,proc,dev/pts,dev}
umount /TableX
sync
cp  /mnt/ramdisk/sunxi/Imagen/trusty.img /home/sunxi/Imagen/trusty.img 
sync
exit
