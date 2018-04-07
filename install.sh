#!/bin/bash

# Script para automatizar la creacion de contenedores lxc para diferentes propósitos

DESTROY=""

if [ -z $1 ]; then
    echo "No se ha indicado directorio"
    exit 1
else
    LXCPREFIX="$1-"
    DIRNAME=$1
    shift
    if [ ! -f $DIRNAME/vars_inc.sh ];then
        echo "No existe $DIRNAME/vars_inc.sh"
        exit 1
    else
        DISTRO=${1:-debian}
        RELEASE=${2:-stretch}
        pushd $DIRNAME
            . ./vars_inc.sh $@
        popd
    fi
fi

echo "DISTRO $DISTRO RELEASE $RELEASE LXCNAME $LXCNAME"
export DISTRO RELEASE LXCNAME

if [ $SUDO ];then
    if [ $USER != "root" ];then
        echo "Tiene que ser el usuario root. Saliendo"
        exit 1
    fi
fi

if [ $DESTROY ];then
  lxc-stop -n $LXCNAME
  lxc-destroy -n $LXCNAME
fi
LXCBASE="/var/lib/lxc"
export LXCHOME="$LXCBASE/$LXCNAME"
export LXCROOT="$LXCHOME/rootfs"

lxc-info -n $LXCNAME 2>/dev/null
if [ $? = 1 ];then
    lxc-create -n $LXCNAME -t $DISTRO -- -r $RELEASE
    if [ $? = 1 ];then
        echo "No se puede crear $LXCNAME"
        exit 1
    fi
fi
if [[ $LXCEXTRA ]];then
    echo "$LXCEXTRA" >> $LXCHOME/config
fi

lxc-start -n $LXCNAME
echo "Iniciando contenedor $LXCNAME ..."
sleep 5
if [ -z $USERNAME ];then
    USERNAME="$LXCNAME"
fi
export USERNAME
sed "s/@@NAME@@/$LXCNAME/" lxc_vars_inc.sh |
   sed "s/@@USERNAME@@/$USERNAME/" > $DIRNAME/_vars_inc.sh
if [[ $EXPORT ]];then
    echo "$EXPORT" >> $DIRNAME/_vars_inc.sh
fi
mv $DIRNAME/_vars_inc.sh $LXCROOT/vars_inc.sh
cd $DIRNAME
cp [0-9]*.sh $LXCROOT/tmp
chmod a+x $LXCROOT/tmp/[0-9]*.sh
echo "$LXCNAME.lxc.localnet" > $LXCROOT/etc/hostname

if [[ $COPY ]];then
    cp $COPY $LXCROOT/tmp
fi

if [ -f "install.sh" ];then
    time ./install.sh $DISTRO $RELEASE
else
    time ./install_${LXCNAME}.sh $@
fi
