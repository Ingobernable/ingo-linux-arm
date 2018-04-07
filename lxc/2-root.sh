#!/bin/bash
# Script que se ejecuta dentro del contenedor en segundo lugar como root o mediante sudo

. /vars_inc.sh
USERHOME=$(getent passwd $USERNAME|cut -d: -f6)
SUNXI="$USERHOME/sunxi"
if [ ! -d $SUNXI ];then
    SUNXI="/root/sunxi"
fi

# Hacemos una copia del script en $HOME para posteriores ejecuciones
if [ ! -f $USERHOME/2-root.sh ];then
    cp $0 $USERHOME
fi

. $SUNXI/tabletconf.txt

# Copiar los archivos del kernel a la imagen de la distro
cd $SUNXI/kernel/mainline/linux-*/
ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=$TABLEX make modules_install
cp arch/arm/boot/zImage $TABLEX/boot
mkdir -p $TABLEX/boot/dts/
cp -p arch/arm/boot/dts/*.dts* $TABLEX/boot/dts/

# Copiar los archivos de u-boot a la imagen de la distro
cd $SUNXI/u-boot/
cd u-boot-$UBOOT/
cp $BOOTFILE $TABLEX/boot
cp -p arch/arm/dts/*.dtb $TABLEX/boot/dts/
echo " Añadiendo script de inicio "
echo "# swarren's branch already sets this automatically, so you can skip this
# Mainline U-Boot will set the following automatically soon
setenv fdtfile boot/dts/$DTBFILE

mmc dev 0
fatload mmc 0:1 ${kernel_addr_r} boot/zImage
# IMPORTANT NOTE: On mainline u-boot, the correct variable to use here is ${fdt_addr} and NOT ${fdt_addr_r}
fatload mmc 0:1 ${fdt_addr_r} ${fdtfile}
setenv bootargs earlyprintk console=tty0 console=ttyAMA0 root=/dev/mmcblk0p1 rootfstype=ext4 rootwait noinitrd
# IMPORTANT NOTE: On mainline u-boot, the correct variable to use here is ${fdt_addr} and NOT ${fdt_addr_r}
bootz ${kernel_addr_r} - ${fdt_addr_r}
" >$SUNXI/boot.cmd



echo "setenv bootargs console=ttyS0,115200 root=/dev/mmcblk0p1 rootwait panic=10
load mmc 0:1 0x43000000 boot/dts/${DTBFILE} || load mmc 0:1 0x43000000 ${DTBFILE}
load mmc 0:1 0x42000000 boot/zImage || load mmc 0:1 0x42000000 zImage
bootz 0x42000000 - 0x43000000
" >$SUNXI/boot_old.cmd

mkimage -C none -A arm -T script -d $SUNXI/boot.cmd $SUNXI/boot.scr
cp $SUNXI/boot.scr $TABLEX/boot

ARMHOSTNAME="TableX-$ARMDISTRO"
> $SUNXI/config.sh
cat <<+ >> $SUNXI/config.sh
#!/bin/sh
echo " Configurando debootstrap segunda fase"
sleep 3
/debootstrap/debootstrap --second-stage
export LANG=C
echo "$REPOS" > /etc/apt/sources.list
echo "nameserver 213.186.33.99" > /etc/resolv.conf
echo "Europe/Madrid" > /etc/timezone
echo "$ARMHOSTNAME" > /etc/hostname
echo "127.0.0.1 $ARMHOSTNAME localhost
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts" > /etc/hosts
#echo "auto lo
#iface lo inet loopback" > /etc/network/interfaces
echo "/dev/mmcblk0p1 /	   ext4	    errors=remount-ro,noatime,nodiratime 0 1
tmpfs    /tmp        tmpfs    nodev,nosuid,mode=1777 0 0
tmpfs    /var/tmp    tmpfs    defaults    0 0" > /etc/fstab
sync
echo "APT::Install-Recommends \"0\";
APT::Install-Suggests \"0\";
"> /etc/apt/apt.conf.d/71-no-recommends

apt-get update
echo "Reconfigurando parametros locales"
sleep 3
locale-gen es_ES.UTF-8
export LC_ALL="es_ES.UTF-8"
update-locale LC_ALL=es_ES.UTF-8 LANG=es_ES.UTF-8 LC_MESSAGES=POSIX
dpkg-reconfigure -f noninteractive tzdata
echo "Creando usuario $ARMRELEASE:"
useradd -m -d /home/$ARMRELEASE -s /bin/bash $ARMRELEASE
echo "Estableciendo a $ARMRELEASE la contraseña de $ARMRELEASE"
echo "$ARMRELEASE:$ARMRELEASE" | chpasswd $ARMRELEASE
adduser $ARMRELEASE sudo
exit
+

chmod +x $SUNXI/config.sh
cp $SUNXI/config.sh $TABLEX/home

cp /usr/bin/qemu-arm-static $TABLEX/usr/bin
cp /etc/resolv.conf $TABLEX/etc
