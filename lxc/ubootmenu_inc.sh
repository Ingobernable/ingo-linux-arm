set +x

MODELS="Tablet a13 q8|q8_a13_tablet
Tablet a23 q8 Resolución 800x480|q8_a23_tablet_800x480
Tablet a33 q8 Resolución 1024x600|q8_a33_tablet_1024x600
Tablet a33 q8 Resolución 800x480|q8_a33_tablet_800x480
iNet_3F|iNet_3F
iNet_3W|iNet_3W
iNet_86VS|iNet_86VS
iNet_D978|iNet_D978
Orange Pi 2|orangepi_2
Raspberry Pi (bcm2835)|rpi
Raspberry Pi 2 (bcm2836)|rpi_2
Raspberry Pi 3 (bcm2837)|rpi_3
Raspberry Pi 3 32bit|rpi_3_32b"

i=0
c=0
cols=2
#for M in $(echo "$MODELS");do
while read M;do
    i=$(( i + 1 ))
    c=$(( c + 1 ))
    if [[ $c -gt $cols ]];then
        c=1
        echo ""
    fi
    DESC[$i]=$(echo "$M"|cut -d\| -f1)
    CONF[$i]=$(echo "$M"|cut -d\| -f2)
    echo -ne "$i .- ${DESC[$i]} \t\t"
done<<<"$MODELS"

echo "

0. No hacer nada"
read -p "	Seleccione una opcion [1 - $i] " uboot

if [[ $uboot -gt 0 && $uboot -le $i ]];then
    ubootconf=${CONF[$uboot]}
    conffile="${ubootconf}_defconfig"
fi
echo "el fichero es $conffile"
