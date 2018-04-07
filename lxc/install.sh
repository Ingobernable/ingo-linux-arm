#!/bin/bash

# Script para automatizar la creacion de un contenedor lxc para $NAME con debian

LXCPREFIX="tablex-"
DISTRO=$1
RELEASE=$2
if [[ -z $LXCROOT ]];then
    LXCROOT="/var/lib/lxc/${LXCPREFIX}${RELEASE}/rootfs"
fi
. $LXCROOT/vars_inc.sh

if [ $DISTRO ];then
    if [ -f $DISTRO/vars_inc.sh ];then
        . vars_inc.sh $DISTRO $RELEASE $ARMDISTRO $ARMRELEASE
    fi
else
    echo "No existe $DISTRO"
    exit 1
fi
echo "USERNAME es $USERNAME"

time lxc-attach -n $LXCNAME -- /tmp/0-root_install.sh
if [ -f $USERNAME.zip ];then
    cp -p $USERNAME.zip $LXCROOT/home/$USERNAME
fi

echo "Preparando Imagen Gnu/Linux"
DISKIMAGEDIR=./diskimages/uboot-$UBOOT
mkdir -p $DISKIMAGEDIR
ARMIMAGE=$DISKIMAGEDIR/$ARMDISTRO-$ARMRELEASE-arm.img
TABLEX=$1/TableX
if [ ! -d $TABLEX ];then
    mkdir $TABLEX
fi
umount $TABLEX 2>/dev/null
umount $ARMIMAGE 2>/dev/null
if [ ! -d $LXCROOT/TableX ];then
    mkdir -p $LXCROOT/TableX
fi
umount $LXCROOT/TableX 2>/dev/null

if [ ! -f $ARMIMAGE ];then
    echo "Creando $ARMIMAGE"
    dd if=/dev/zero of=$ARMIMAGE bs=1 count=0 seek=400M
    mkfs.ext4 -b 4096 -F $ARMIMAGE
    mount -o loop $ARMIMAGE $TABLEX
    echo "Creado $ARMRELEASE en $TABLEX y repo en $DEBOOTSTRAP"
    debootstrap --arch=armhf --foreign $ARMRELEASE $TABLEX $DEBOOTSTRAP
    umount $TABLEX
    sync
    DOSECOND="1"
fi

cp ubootmenu_inc.sh $LXCROOT/tmp/
lxc-attach -n $LXCNAME -- su - $USERNAME -c "/tmp/1-user.sh"

#MODEL=$(cat $LXCROOT/home/$USERNAME/sunxi/tabletconf.txt)
. $LXCROOT/home/$USERNAME/sunxi/tabletconf.txt
#DTBFILE="${MODEL}.dtb"
TABLETIMG=$DISKIMAGEDIR/$ARMDISTRO-$ARMRELEASE-$MODEL.img
if [ ! -f $TABLETIMG ];then

    mount -o loop $ARMIMAGE $TABLEX
    mount -o bind $TABLEX $LXCROOT/TableX
    echo "Imagen $ARMIMAGE montada en $TABLEX"

    lxc-attach -n $LXCNAME -- /tmp/2-root.sh

    if [ $DOSECOND ];then
        echo "Montando directorios para second stage"
        sleep 3
        mount -o bind /dev $TABLEX/dev
        mount -o bind /dev/pts $TABLEX/dev/pts
        mount -t sysfs sys $TABLEX/sys
        mount -t proc proc $TABLEX/proc
        echo "Ejecutando second stage"
        time chroot $TABLEX /usr/bin/qemu-arm-static /bin/sh -i ./home/config.sh
        sync
        umount $LXCROOT/TableX/dev
    fi
    #umount $TABLEX/{sys,proc,dev/pts,dev}
    umount $LXCROOT/TableX
    umount $TABLEX
    cp $ARMIMAGE $TABLETIMG
else
    echo "Ya existe $TABLETIMG"
fi
