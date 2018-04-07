SUDO="1"
LXCPREFIX="tablex-"
DESTROY=""
ARMDISTRO=${3:-lubuntu}
echo "ARMDISTRO=$ARMDISTRO"
ARMRELEASE=${4:-trusty}
. ./$1/vars_inc.sh
LXCNAME="${LXCPREFIX}${RELEASE}"

export DISTRO RELEASE LXCNAME

if [ $ARMDISTRO = "debian" ];then
    DEBOOTSTRAP="http://httpredir.debian.org/debian"

    REPOS="deb $DEBOOTSTRAP $ARMRELEASE main
deb $DEBOOTSTRAP $ARMRELEASE-updates main

# Security
deb http://security.debian.org/ $ARMRELEASE/updates main
deb-src http://security.debian.org/ $ARMRELEASE/updates main
deb http://security.debian.org/debian-security $ARMRELEASE/updates main
"
else
    DEBOOTSTRAP="http://ports.ubuntu.com/"
    REPOS="deb http://ports.ubuntu.com/ $ARMRELEASE main restricted universe multiverse
deb http://ports.ubuntu.com/ $ARMRELEASE-security main restricted universe multiverse
deb http://ports.ubuntu.com/ $ARMRELEASE-updates main restricted universe multiverse
deb http://ports.ubuntu.com/ $ARMRELEASE-backports main restricted universe multiverse
"
fi

EXPORT="
# Paquetes extra específicos para la distribucion
APTEXTRA='postfix bc curl python binfmt-support make gcc-arm-linux-gnueabihf tree git debootstrap qemu-user-static build-essential libssl-dev libusb-1.0-0-dev bin86 libncurses5 libncurses5-dev u-boot-tools device-tree-compiler swig libpython-dev libusb-dev zlib1g-dev pkg-config'

TABLEX=/TableX

KERNELVERSION=4.16
UBOOT=2018.03

ARMDISTRO=$ARMDISTRO
ARMRELEASE=$ARMRELEASE
DEBOOTSTRAP=$DEBOOTSTRAP
REPOS=\"$REPOS\"
"

COPY="TableX_defconfig"
