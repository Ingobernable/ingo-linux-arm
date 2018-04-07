#!/bin/bash

. /vars_inc.sh

if [ $@ ];then
    echo "$@" >> /vars.inc.sh
fi
# Script para ejecutar como root para instalacion de paquetes adicionales y otras acciones
sethost

apt update
apt -y upgrade

# Poner en CUSTOM las variables necesarias
CUSTOM="$APTEXTRA"
apt install -y $BASIC $CUSTOM
echo -n " Instalación de dependencias completado. Limpiando cache... "
apt-get clean

setuser

echo "Terminado."
# FIN ROOT
