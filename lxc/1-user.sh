#!/bin/bash
# Script que se ejecuta en el contenedor como usuario
# Se encarga de crear los directorios para contener el software que se va a compilar
# y posteriormente se encarga exclusivamente de la compilación:
# 1) sunxi-tools
# 2) kernel de linux
# 3) u-boot

SUNXI="$HOME/sunxi"
KERNELVERSION="4.15.12"
UBOOT="2018.03"
UBOOT="2017.11"

. /vars_inc.sh

if [ $USER = "root" ];then
    cp $0 /home/$USERNAME/
    chown $USERNAME /home/$USERNAME/*.sh
    su $USERNAME -c $0
    exit
fi

KERNELDIR="linux-$KERNELVERSION"
UBOOTDIR="u-boot-$UBOOT"

# Hacemos una copia del script en $HOME para posteriores ejecuciones
SCRIPT=$(basename $0)
if [ ! -f $HOME/$SCRIPT ];then
    cp $0 $HOME/
fi

# Creamos los directorios en $HOME
mkdir -p $SUNXI/kernel/mainline
cd $SUNXI
for dir in tools u-boot kernel/sunxi kernel/zImage Imagen;do mkdir -p $dir;done
echo " Directorios creados "
sleep 1

if [ -f /tmp/ubootmenu_inc.sh ];then
    cp /tmp/ubootmenu_inc.sh $SUNXI
fi

# Descarga y compliación de sunxi-tools
echo " Instalando sunxi-tools"
sleep 3
cd $SUNXI/tools
if [ ! -d sunxi-tools ];then
    git clone https://github.com/linux-sunxi/sunxi-tools
fi
cd sunxi-tools
# Nos aseguramos de tener la última versión
git pull
make -j$(nproc)
for f in sunxi-*;do
    if [ ! -f /usr/local/bin/$f ];then
        sudo -S true && sudo make -j$(nproc) install
    fi
done
echo " Instalación completada"

# Descarga y compilación kernel
sleep 2
echo " Descargando y descomprimiendo Kernel mainline $KERNELVERSION"
sleep 3
cd $SUNXI/kernel/mainline
if [ ! -d $KERNELDIR ];then
    wget https://cdn.kernel.org/pub/linux/kernel/v4.x/$KERNELDIR.tar.xz
    echo -n " Descomprimiendo Kernel mainline..."
    tar -Jxf $KERNELDIR.tar.xz
    echo " finalizado. "
    rm $KERNELDIR.tar.xz
fi
cd $KERNELDIR

sleep 1
if [ ! -f ~/TableX_defconfig ];then
    cp /tmp/TableX_defconfig ~/TableX_defconfig
fi
if [ ! -f .config ];then
    cp ~/TableX_defconfig sunxi_defconfig
    make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf sunxi_defconfig
else
    echo " Cuando aparezca el menu puedes pulsar---> Exit"
    make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- menuconfig
fi
echo "Compilando el núcleo $KERNELDIR ..."
make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs
stat arch/arm/boot/zImage


# Descarga y complicación de u-boot
sleep 1
echo " Descarga y compilacion de u-boot $UBOOT"
echo " Descargando u-boot denx "
sleep 1

cd $SUNXI/u-boot/
if [ ! -d $UBOOTDIR ];then
    wget ftp://ftp.denx.de/pub/u-boot/u-boot-$UBOOT.tar.bz2
    echo -n " Descomprimiendo u-boot..."
    tar -xjf u-boot-$UBOOT.tar.bz2
    echo " finalizada"
else
    echo "Ya existe $UBOOTDIR. Omitiendo descarga"
fi
sleep 1
echo " Cuando aparezca el menu no tiene que configurar nada.
Para continuar, seleccione Menu ----> File ----> Quit"
cd $UBOOTDIR

make mrproper
make clean
. $SUNXI/ubootmenu_inc.sh

if [ $ubootconf ];then
    make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- $conffile
    #echo ${conf%%_defconfig} > $SUNXI/tabletconf.txt
else
    make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- menuconfig
fi
make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
DTB=$(grep 'CONFIG_DEFAULT_DEVICE_TREE' .config |cut -d\" -f2)
#BOOTFILE=$(find $(pwd) -mmin -2 -size +300k -name "u-boot*.bin"|grep -v 'nodtb')
BOOTFILE=$(ls -1tra u-boot-*.bin|tail -n1)
echo "Compilación de u-boot ($DTB) terminada"

    #grep 'CONFIG_DEFAULT_DEVICE_TREE' .config |cut -d\" -f2 > $SUNXI/tabletconf.txt
echo "
DTBFILE=${DTB}.dtb
MODEL=$ubootconf
BOOTFILE=$BOOTFILE
" > $SUNXI/tabletconf.txt

exit 0
# echo "$p"|grep bin$
#  OBJCOPY examples/standalone/hello_world.bin
#  OBJCOPY u-boot-nodtb.bin
#  CAT     u-boot-dtb.bin
#  COPY    u-boot.bin
#  OBJCOPY spl/u-boot-spl-nodtb.bin
#  COPY    spl/u-boot-spl.bin
#  MKSUNXI spl/sunxi-spl.bin
#  BINMAN  u-boot-sunxi-with-spl.bin

#  OBJCOPY u-boot-nodtb.bin
#  COPY    u-boot.bin
