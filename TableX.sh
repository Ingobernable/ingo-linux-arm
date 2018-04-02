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
mount -t tmpfs none /mnt/ramdisk -o size=8000M 
mkdir /home/sunxi/
mkdir /home/sunxi/tools
sudo mkdir /home/sunxi/u-boot
mkdir /mnt/ramdisk/sunxi
mkdir /mnt/ramdisk/sunxi/u-boot
mkdir /mnt/ramdisk/sunxi/kernel/
mkdir /mnt/ramdisk/sunxi/kernel/mainline
mkdir /mnt/ramdisk/sunxi/kernel/sunxi
mkdir /mnt/ramdisk/sunxi/kernel/zImage
mkdir /mnt/ramdisk/sunxi/Imagen
mkdir /home/sunxi/kernel/
mkdir /home/sunxi/kernel/modules
mkdir /home/sunxi/kernel/mainline
mkdir /home/sunxi/kernel/sunxi
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
dd if=/dev/zero of=/mnt/ramdisk/sunxi/Imagen/trusty.img bs=1 count=0 seek=700M
mkfs.ext4 -b 4096 -F /mnt/ramdisk/sunxi/Imagen/trusty.img
chmod 777 /mnt/ramdisk/sunxi/Imagen/trusty.img
mkdir /TableX
mount -o loop /mnt/ramdisk/sunxi/Imagen/trusty.img /TableX
debootstrap --arch=armhf --foreign trusty /TableX
echo " Añadiendo script de inicio "
> /mnt/ramdisk/sunxi/boot.cmd
cat <<+ >> /mnt/ramdisk/sunxi/boot.cmd
setenv bootargs console=ttyS0,115200 root=/dev/mmcblk0p1 rootwait panic=10
load mmc 0:1 0x43000000 sun8i-a33-q8-tablet.dtb || load mmc 0:1 0x43000000 boot/sun8i-a33-q8-tablet.dtb
load mmc 0:1 0x42000000 zImage || load mmc 0:1 0x42000000 boot/zImage
bootz 0x42000000 - 0x43000000
+
mkimage -C none -A arm -T script -d /mnt/ramdisk/sunxi/boot.cmd /mnt/ramdisk/sunxi/boot.scr
cp /mnt/ramdisk/sunxi/boot.scr /TableX/boot
echo " Descargando y descomprimiento Kernel mainline" 
sleep 1
wget -P /mnt/ramdisk/sunxi/kernel/mainline https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.16.tar.xz
cd /mnt/ramdisk/sunxi/kernel/mainline/
sudo tar -Jxf /mnt/ramdisk/sunxi/kernel/mainline/linux-4.16.tar.xz
cp /mnt/ramdisk/sunxi/TableX_defconfig /mnt/ramdisk/sunxi/kernel/mainline/linux-4.16/arch/arm/configs
cd /mnt/ramdisk/sunxi/kernel/mainline/linux-4.16
# sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf TableX_defconfig
sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- xconfig
sudo make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs 
sudo ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=/TableX make modules modules_install
sudo cp arch/arm/boot/zImage  /TableX/boot
sudo cp arch/arm/boot/dts/sun8i-a33-q8-tablet.dtb /TableX/boot/
cd ..
clear
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
cat <<END > /etc/apt/apt.conf.d/71-no-recommends
APT::Install-Recommends "0";
APT::Install-Suggests "0";
END
apt-get update
echo "Reconfigurando parametros locales"
sleep 1
locale-gen es_ES.UTF-8
export LC_ALL="es_ES.UTF-8"
update-locale LC_ALL=es_ES.UTF-8 LANG=es_ES.UTF-8 LC_MESSAGES=POSIX
dpkg-reconfigure locales
dpkg-reconfigure -f noninteractive tzdata
# apt-get install -y account-plugin-aim account-plugin-facebook account-plugin-flickr account-plugin-google account-plugin-jabber account-plugin-salut account-plugin-twitter account-plugin-yahoo accountsservice acl acpid activity-log-manager activity-log-manager-control-center adduser adium-theme-ubuntu aisleriot alsa-base alsa-utils anacron apg app-install-data app-install-data-partner apparmor appmenu-qt appmenu-qt5 apport apport-gtk apport-symptoms apt apt-transport-https apt-utils apt-xapian-index aptdaemon aptdaemon-data apturl apturl-common aspell aspell-en at-spi2-core avahi-autoipd avahi-daemon avahi-utils bamfdaemon baobab base-files base-passwd bash bash-completion bc bind9-host binutils bluez bluez-alsa bluez-cups branding-ubuntu brasero brasero-cdrkit brasero-common brltty bsdmainutils bsdutils busybox-initramfs busybox-static bzip2 ca-certificates checkbox-gui checkbox-ng checkbox-ng-service cheese cheese-common colord command-not-found command-not-found-data compiz compiz-core compiz-gnome compiz-plugins-default console-setup coreutils cpio cpp cpp-4.8 cracklib-runtime crda cron cups cups-browsed cups-bsd cups-client cups-common cups-core-drivers cups-daemon cups-filters cups-filters-core-drivers cups-pk-helper cups-ppdc cups-server-common curl dash dbus dbus-x11 dc dconf-cli dconf-gsettings-backend dconf-service debconf debconf-i18n debianutils deja-dup deja-dup-backend-gvfs desktop-file-utils dh-python dialog dictionaries-common diffstat diffutils dmidecode dmsetup dmz-cursor-theme dnsmasq-base dnsutils doc-base dosfstools dpkg duplicity dvd+rw-tools e2fslibs e2fsprogs ed eject empathy empathy-common enchant eog espeak-data ethtool evince evince-common evolution-data-server evolution-data-server-common evolution-data-server-online-accounts example-content file file-roller findutils firefox firefox-locale-en firefox-locale-es folks-common fontconfig fontconfig-config fonts-dejavu-core fonts-droid fonts-freefont-ttf fonts-kacst fonts-kacst-one fonts-khmeros-core fonts-lao fonts-liberation fonts-lklug-sinhala fonts-nanum fonts-opensymbol fonts-sil-abyssinica fonts-sil-padauk fonts-takao-pgothic fonts-thai-tlwg fonts-tibetan-machine fonts-tlwg-garuda fonts-tlwg-kinnari fonts-tlwg-loma fonts-tlwg-mono fonts-tlwg-norasi fonts-tlwg-purisa fonts-tlwg-sawasdee fonts-tlwg-typewriter fonts-tlwg-typist fonts-tlwg-typo fonts-tlwg-umpush fonts-tlwg-waree foomatic-db-compressed-ppds friendly-recovery friends friends-dispatcher friends-facebook friends-twitter ftp fuse gcc gcc-4.8 gcc-4.8-base gcc-4.9-base gconf-service gconf-service-backend gconf2 gconf2-common gcr gdb gdisk gedit gedit-common genisoimage geoclue geoclue-ubuntu-geoip geoip-database gettext gettext-base ghostscript ghostscript-x gir1.2-accounts-1.0 gir1.2-appindicator3-0.1 gir1.2-atk-1.0 gir1.2-atspi-2.0 gir1.2-dbusmenu-glib-0.4 gir1.2-dee-1.0 gir1.2-ebook-1.2 gir1.2-ebookcontacts-1.2 gir1.2-edataserver-1.2 gir1.2-freedesktop gir1.2-gdata-0.0 gir1.2-gdkpixbuf-2.0 gir1.2-glib-2.0 gir1.2-gmenu-3.0 gir1.2-gnomebluetooth-1.0 gir1.2-gnomekeyring-1.0 gir1.2-goa-1.0 gir1.2-gst-plugins-base-1.0 gir1.2-gstreamer-1.0 gir1.2-gtk-3.0 gir1.2-gtksource-3.0 gir1.2-gudev-1.0 gir1.2-ibus-1.0 gir1.2-javascriptcoregtk-3.0 gir1.2-messagingmenu-1.0 gir1.2-networkmanager-1.0 gir1.2-notify-0.7 gir1.2-packagekitglib-1.0 gir1.2-pango-1.0 gir1.2-peas-1.0 gir1.2-rb-3.0 gir1.2-secret-1 gir1.2-signon-1.0 gir1.2-soup-2.4 gir1.2-totem-1.0 gir1.2-totem-plparser-1.0 gir1.2-udisks-2.0 gir1.2-unity-5.0 gir1.2-vte-2.90 gir1.2-webkit-3.0 gir1.2-wnck-3.0 gkbd-capplet glib-networking glib-networking-common glib-networking-services gnome-accessibility-themes gnome-bluetooth gnome-calculator gnome-contacts gnome-control-center-shared-data gnome-desktop3-data gnome-disk-utility gnome-font-viewer gnome-icon-theme gnome-icon-theme-symbolic gnome-keyring gnome-mahjongg gnome-menus gnome-mines gnome-orca gnome-power-manager gnome-screensaver gnome-screenshot gnome-session-bin gnome-session-canberra gnome-session-common gnome-settings-daemon-schemas gnome-sudoku gnome-system-log gnome-system-monitor gnome-terminal gnome-terminal-data gnome-user-guide gnome-user-share gnome-video-effects gnomine gnupg gpgv grep groff-base growisofs grub-common   gsettings-desktop-schemas gsettings-ubuntu-schemas gsfonts gstreamer0.10-alsa gstreamer0.10-nice gstreamer0.10-plugins-base gstreamer0.10-plugins-base-apps gstreamer0.10-plugins-good gstreamer0.10-pulseaudio gstreamer0.10-tools gstreamer0.10-x gstreamer1.0-alsa gstreamer1.0-clutter gstreamer1.0-nice gstreamer1.0-plugins-base gstreamer1.0-plugins-base-apps gstreamer1.0-plugins-good gstreamer1.0-pulseaudio gstreamer1.0-tools gstreamer1.0-x gtk2-engines-murrine gtk3-engines-unico gucharmap guile-2.0-libs gvfs gvfs-backends gvfs-bin gvfs-common gvfs-daemons gvfs-fuse gvfs-libs gzip hardening-includes hdparm hicolor-icon-theme hostname hplip hplip-data hud humanity-icon-theme hunspell-en-us hwdata hyphen-en-us ibus ibus-gtk ibus-gtk3 ibus-pinyin ibus-table ifupdown im-config indicator-application indicator-appmenu indicator-bluetooth indicator-datetime indicator-keyboard indicator-messages indicator-power indicator-printers indicator-session indicator-sound info init-system-helpers initramfs-tools initramfs-tools-bin initscripts inputattach insserv install-info intltool-debian iproute iproute2 iptables iputils-arping iputils-ping iputils-tracepath irqbalance isc-dhcp-client isc-dhcp-common iso-codes iw kbd kerneloops-daemon keyboard-configuration klibc-utils kmod krb5-locales landscape-client-ui-install language-pack-en language-pack-en-base language-pack-es language-pack-es-base language-pack-gnome-en language-pack-gnome-en-base language-pack-gnome-es language-pack-gnome-es-base language-selector-common language-selector-gnome laptop-detect less libaa1 libaccount-plugin-1.0-0 libaccount-plugin-generic-oauth libaccount-plugin-google libaccounts-glib0 libaccounts-qt5-1 libaccountsservice0 libacl1 libandroid-properties1 libapparmor-perl libapparmor1 libappindicator3-1 libapt-inst1.5 libapt-pkg-perl libapt-pkg4.12 libarchive-extract-perl libarchive-zip-perl libarchive13 libart-2.0-2 libasan0 libasn1-8-heimdal libasound2 libasound2-data libasound2-plugins libaspell15 libasprintf-dev libasprintf0c2 libassuan0 libasyncns0 libatasmart4 libatk-adaptor libatk-bridge2.0-0 libatk1.0-0 libatk1.0-data libatkmm-1.6-1 libatomic1 libatspi2.0-0 libattr1 libaudio2 libaudit-common libaudit1 libauthen-sasl-perl libautodie-perl libavahi-client3 libavahi-common-data libavahi-common3 libavahi-core7 libavahi-glib1 libavahi-gobject0 libavc1394-0 libbamf3-2 libbind9-90 libblkid1 libbluetooth3 libboost-date-time1.54.0 libboost-system1.54.0 libbrasero-media3-1 libbrlapi0.6 libbsd0 libburn4 libbz2-1.0 libc-bin libc-dev-bin libc6 libc6-dbg libc6-dev libcaca0 libcairo-gobject2 libcairo2 libcairomm-1.0-1 libcamel-1.2-45 libcanberra-gtk-module libcanberra-gtk0 libcanberra-gtk3-0 libcanberra-gtk3-module libcanberra-pulse libcanberra0 libcap-ng0 libcap2 libcap2-bin libcdio-cdda1 libcdio-paranoia1 libcdio13 libcdparanoia0 libcdr-0.0-0 libcgmanager0 libcheese-gtk23 libcheese7 libclass-accessor-perl libclone-perl libcloog-isl4 libclucene-contribs1 libclucene-core1 libclutter-1.0-0 libclutter-1.0-common libclutter-gst-2.0-0 libclutter-gtk-1.0-0 libcmis-0.4-4 libcogl-common libcogl-pango15 libcogl15 libcolamd2.8.0 libcolord1 libcolorhug1 libcolumbus1 libcolumbus1-common libcomerr2 libcompizconfig0 libcrack2 libcroco3 libcrypt-passwdmd5-perl libcups2 libcupscgi1 libcupsfilters1 libcupsimage2 libcupsmime1 libcupsppdc1 libcurl3 libcurl3-gnutls libdaemon0 libdatrie1 libdb5.3 libdbus-1-3 libdbus-glib-1-2 libdbusmenu-glib4 libdbusmenu-gtk3-4 libdbusmenu-gtk4 libdbusmenu-qt2 libdbusmenu-qt5 libdconf1 libdebconfclient0 libdecoration0 libdee-1.0-4 libdevmapper1.02.1 libdigest-hmac-perl libdjvulibre-text libdjvulibre21 libdmapsharing-3.0-2 libdns100 libdotconf0 libdpkg-perl libdrm-amdgpu1 libdrm-nouveau2 libdrm-radeon1 libdrm2 libdv4 libebackend-1.2-7 libebook-1.2-14 libebook-contacts-1.2-0 libecal-1.2-16 libedata-book-1.2-20 libedata-cal-1.2-23 libedataserver-1.2-18 libedit2 libegl1-mesa-lts-xenial libelf1 libelfg0 libemail-valid-perl libenchant1c2a libepoxy0 libespeak1 libestr0 libevdev2 libevdocument3-4 libevent-2.0-5 libevview3-3 libexempi3 libexif12 libexiv2-12 libexpat1 libexttextcat-2.0-0 libexttextcat-data libfarstream-0.1-0 libfarstream-0.2-2 libffi6 libfftw3-single3 libfile-basedir-perl libfile-copy-recursive-perl libfile-desktopentry-perl libfile-fcntllock-perl libfile-mimeinfo-perl libflac8 libfolks-eds25 libfolks-telepathy25 libfolks25 libfontconfig1 libfontembed1 libfontenc1 libframe6 libfreerdp-plugins-standard libfreerdp1 libfreetype6 libfribidi0 libfriends0 libfs6 libfuse2 libgail-3-0 libgail-common libgail18 libgbm1 libgbm1-lts-xenial libgc1c2 libgcc-4.8-dev libgcc1 libgck-1-0 libgconf-2-4 libgcr-3-common libgcr-base-3-1 libgcr-ui-3-1 libgcrypt11 libgd3 libgdata-common libgdata13 libgdbm3 libgdk-pixbuf2.0-0 libgdk-pixbuf2.0-common libgee-0.8-2 libgee2 libgeis1 libgeoclue0 libgeoip1 libgettextpo-dev libgettextpo0 libgexiv2-2 libgirepository-1.0-1 libgl1-mesa-dri-lts-xenial libgl1-mesa-glx-lts-xenial libglapi-mesa-lts-xenial libgles1-mesa-lts-xenial libgles2-mesa-lts-xenial libglew1.10 libglewmx1.10 libglib2.0-0 libglib2.0-bin libglib2.0-data libglibmm-2.4-1c2a libglu1-mesa libgmime-2.6-0 libgmp10 libgnome-bluetooth11 libgnome-control-center1 libgnome-desktop-3-7 libgnome-keyring-common libgnome-keyring0 libgnome-menu-3-0 libgnomekbd-common libgnomekbd8 libgnutls-openssl27 libgnutls26 libgoa-1.0-0b libgoa-1.0-common libgomp1 libgpg-error0 libgpgme11 libgphoto2-6 libgphoto2-l10n libgphoto2-port10 libgpm2 libgpod-common libgpod4 libgrail6 libgraphite2-3 libgrip0 libgs9 libgs9-common libgsettings-qt1 libgssapi-krb5-2 libgssapi3-heimdal libgssdp-1.0-3 libgstreamer-plugins-base0.10-0 libgstreamer-plugins-base1.0-0 libgstreamer-plugins-good1.0-0 libgstreamer0.10-0 libgstreamer1.0-0 libgtk-3-0 libgtk-3-bin libgtk-3-common libgtk2.0-0 libgtk2.0-bin libgtk2.0-common libgtkmm-3.0-1 libgtksourceview-3.0-1 libgtksourceview-3.0-common libgtop2-7 libgtop2-common libgucharmap-2-90-7 libgudev-1.0-0 libgupnp-1.0-4 libgupnp-igd-1.0-4 libgusb2 libgutenprint2 libgweather-3-6 libgweather-common libgxps2 libharfbuzz-icu0 libharfbuzz0b libhcrypto4-heimdal libheimbase1-heimdal libheimntlm0-heimdal libhpmud0 libhud2 libhunspell-1.3-0 libhx509-5-heimdal libhyphen0 libibus-1.0-5 libical1 libice6 libicu52 libidn11 libido3-0.1-0 libiec61883-0 libieee1284-3 libijs-0.35 libimobiledevice4 libindicator3-7 libio-pty-perl libio-socket-inet6-perl libio-socket-ssl-perl libio-string-perl libipc-run-perl libipc-system-simple-perl libisc95 libisccc90 libisccfg90 libisl10 libisofs6 libiw30 libjack-jackd2-0 libjasper1 libjavascriptcoregtk-3.0-0 libjbig0 libjbig2dec0 libjpeg-turbo8 libjpeg8 libjson-c2 libjson-glib-1.0-0 libjson-glib-1.0-common libjson0 libjte1 libk5crypto3 libkeyutils1 libklibc libkmod2 libkpathsea6 libkrb5-26-heimdal libkrb5-3 libkrb5support0 liblangtag-common liblangtag1 liblcms2-2 libldap-2.4-2 libldb1 liblightdm-gobject-1-0 liblircclient0 liblist-moreutils-perl libllvm3.8v4 liblocale-gettext-perl liblockfile-bin liblockfile1 liblog-message-simple-perl liblouis-data liblouis2 libltdl7 liblua5.2-0 liblwres90 liblzma5 liblzo2-2 libmagic1 libmailtools-perl libmbim-glib0 libmeanwhile1 libmessaging-menu0 libmetacity-private0a libmhash2 libminiupnpc8 libmission-control-plugins0 libmm-glib0 libmnl0 libmodule-pluggable-perl libmount1 libmpc3 libmpdec2 libmpfr4 libmspub-0.0-0 libmtdev1 libmtp-common libmtp-runtime libmtp9 libmythes-1.2-0 libnatpmp1 libnautilus-extension1a libncurses5 libncursesw5 libneon27-gnutls libnet-dns-perl libnet-domain-tld-perl libnet-ip-perl libnet-libidn-perl libnet-smtp-ssl-perl libnet-ssleay-perl libnetfilter-conntrack3 libnettle4 libnewt0.52 libnfnetlink0 libnice10 libnih-dbus1 libnih1 libnl-3-200 libnl-genl-3-200 libnl-route-3-200 libnm-glib-vpn1 libnm-glib4 libnm-gtk-common libnm-gtk0 libnm-util2 libnotify-bin libnotify4 libnspr4 libnss-mdns libnss3 libnss3-nssdb libnux-4.0-0 libnux-4.0-common liboauth0 libogg0 libopencc1 libopenobex1 liborc-0.4-0 liborcus-0.6-0 liboxideqt-qmlplugin liboxideqtcore0 liboxideqtquick0 libp11-kit-gnome-keyring libp11-kit0 libpackagekit-glib2-16 libpam-cap libpam-gnome-keyring libpam-modules libpam-modules-bin libpam-runtime libpam-systemd libpam0g libpango-1.0-0 libpango1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libpangomm-1.4-1 libpangox-1.0-0 libpangoxft-1.0-0 libpaper-utils libpaper1 libparse-debianchangelog-perl libparted0debian1 libpcap0.8 libpci3 libpciaccess0 libpcre3 libpcsclite1 libpeas-1.0-0 libpeas-common libperl5.18 libperlio-gzip-perl libpipeline1 libpixman-1-0 libplist1 libplymouth2 libpng12-0 libpocketsphinx1 libpod-latex-perl libpolkit-agent-1-0 libpolkit-backend-1-0 libpolkit-gobject-1-0 libpoppler-glib8 libpoppler44 libpopt0 libportaudio2 libprocps3 libprotobuf8 libproxy1 libproxy1-plugin-gsettings libproxy1-plugin-networkmanager libpulse-mainloop-glib0 libpulse0 libpulsedsp libpurple-bin libpurple0 libpwquality-common libpwquality1 libpython-stdlib libpython2.7 libpython2.7-minimal libpython2.7-stdlib libpython3-stdlib libpython3.4 libpython3.4-minimal libpython3.4-stdlib libpyzy-1.0-0 libqmi-glib0 libqpdf13 libqt4-dbus libqt4-declarative libqt4-designer libqt4-help libqt4-network libqt4-opengl libqt4-script libqt4-scripttools libqt4-sql libqt4-sql-sqlite libqt4-svg libqt4-test libqt4-xml libqt4-xmlpatterns libqt5core5a libqt5dbus5 libqt5feedback5 libqt5gui5 libqt5multimedia5 libqt5network5 libqt5opengl5 libqt5organizer5 libqt5positioning5 libqt5printsupport5 libqt5qml-graphicaleffects libqt5qml5 libqt5quick5 libqt5sensors5 libqt5sql5 libqt5sql5-sqlite libqt5svg5 libqt5test5 libqt5webkit5 libqt5webkit5-qmlwebkitplugin libqt5widgets5 libqt5xml5 libqtassistantclient4 libqtcore4 libqtdbus4 libqtgui4 libqtwebkit4 libraptor2-0 librasqal3 libraw1394-11 libraw9 librdf0 libreadline5 libreadline6 libreoffice-avmedia-backend-gstreamer libreoffice-base-core libreoffice-calc libreoffice-common libreoffice-core libreoffice-draw libreoffice-gnome libreoffice-gtk libreoffice-help-en-us libreoffice-help-es libreoffice-impress libreoffice-l10n-es libreoffice-math libreoffice-ogltrans libreoffice-pdfimport libreoffice-presentation-minimizer libreoffice-style-human libreoffice-writer librest-0.7-0 librhythmbox-core8 libroken18-heimdal librsvg2-2 librsvg2-common librsync1 librtmp0 libsamplerate0 libsane libsane-common libsane-hpaio libsasl2-2 libsasl2-modules libsasl2-modules-db libsbc1 libsecret-1-0 libsecret-common libselinux1 libsemanage-common libsemanage1 libsensors4 libsepol1 libsgutils2-2 libshout3 libsigc++-2.0-0c2a libsignon-extension1 libsignon-glib1 libsignon-plugins-common1 libsignon-qt5-1 libslang2 libsm6 libsmbclient libsndfile1 libsnmp-base libsnmp30 libsocket6-perl libsonic0 libsoup-gnome2.4-1 libsoup2.4-1 libspectre1 libspeechd2 libspeex1 libspeexdsp1 libsphinxbase1 libsqlite3-0 libss2 libssh-4 libssl1.0.0 libstartup-notification0 libstdc++6 libsub-identify-perl libsub-name-perl libsystemd-daemon0 libsystemd-journal0 libsystemd-login0 libt1-5 libtag1-vanilla libtag1c2a libtalloc2 libtasn1-6 libtcl8.6 libtdb1 libtelepathy-farstream3 libtelepathy-glib0 libtelepathy-logger3 libterm-ui-perl libtevent0 libtext-charwidth-perl libtext-iconv-perl libtext-levenshtein-perl libtext-soundex-perl libtext-wrapi18n-perl libthai-data libthai0 libtheora0 libthumbnailer0 libtiff5 libtimedate-perl libtimezonemap1 libtinfo5 libtk8.6 libtotem-plparser18 libtotem0 libtxc-dxtn-s2tc0 libudev1 libudisks2-0 libufe-xidgetter0 libunistring0 libunity-action-qt1 libunity-control-center1 libunity-core-6.0-9 libunity-gtk2-parser0 libunity-gtk3-parser0 libunity-misc4 libunity-protocol-private0 libunity-scopes-json-def-desktop libunity-webapps0 libunity9 libunityvoice1 libupower-glib1 liburi-perl liburl-dispatcher1 libusb-0.1-4 libusb-1.0-0 libusbmuxd2 libustr-1.0-1 libutempter0 libuuid-perl libuuid1 libv4l-0 libv4lconvert0 libvisio-0.0-0 libvisual-0.4-0 libvisual-0.4-plugins libvncserver0 libvorbis0a libvorbisenc2 libvorbisfile3 libvpx1 libvte-2.90-9 libvte-2.90-common libwacom-common libwacom2 libwavpack1 libwayland-client0 libwayland-cursor0 libwayland-egl1-mesa-lts-xenial libwayland-server0 libwbclient0 libwebkitgtk-3.0-0 libwebkitgtk-3.0-common libwebp5 libwebpmux1 libwhoopsie-preferences0 libwhoopsie0 libwind0-heimdal libwmf0.2-7 libwmf0.2-7-gtk libwnck-3-0 libwnck-3-common libwnck-common libwnck22 libwpd-0.9-9 libwpg-0.2-2 libwps-0.2-2 libwrap0 libx11-6 libx11-data libx11-xcb1 libxapian22 libxatracker2-lts-xenial libxau6 libxaw7 libxcb-dri2-0 libxcb-dri3-0 libxcb-glx0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-present0 libxcb-randr0 libxcb-render-util0 libxcb-render0 libxcb-shape0 libxcb-shm0 libxcb-sync1 libxcb-util0 libxcb-xfixes0 libxcb-xkb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxdmcp6 libxext6 libxfixes3 libxfont1 libxft2 libxi6 libxinerama1 libxkbcommon-x11-0 libxkbcommon0 libxkbfile1 libxklavier16 libxml2 libxmu6 libxmuu1 libxp6 libxpm4 libxrandr2 libxrender1 libxres1 libxshmfence1 libxslt1.1 libxss1 libxt6 libxtables10 libxtst6 libxv1 libxvmc1 libxxf86dga1 libxxf86vm1 libyajl2 libyaml-tiny-perl libyelp0 libzeitgeist-1.0-1 libzeitgeist-2.0-0 libzephyr4 light-themes lightdm lintian linux-firmware linux-generic-lts-xenial linux-headers-4.4.0-31 linux-headers-4.4.0-31-generic linux-headers-generic-lts-xenial linux-image-4.4.0-31-generic linux-image-generic-lts-xenial linux-libc-dev linux-sound-base locales lockfile-progs login logrotate lp-solve lsb-base lsb-release lshw lsof ltrace make makedev man-db manpages manpages-dev mawk mcp-account-manager-uoa media-player-info metacity-common mime-support mlocate mobile-broadband-provider-info modemmanager module-init-tools mount mountall mousetweaks mscompress mtools mtr-tiny multiarch-support myspell-en-au myspell-en-gb myspell-en-za myspell-es mythes-en-us nano nautilus nautilus-data nautilus-sendto nautilus-sendto-empathy nautilus-share ncurses-base ncurses-bin net-tools netbase netcat-openbsd network-manager network-manager-gnome network-manager-pptp network-manager-pptp-gnome notify-osd notify-osd-icons ntfs-3g ntpdate nux-tools obex-data-server obexd-client onboard onboard-data oneconf oneconf-common openoffice.org-hyphenation openprinting-ppds openssh-client openssl os-prober overlay-scrollbar overlay-scrollbar-gtk2 overlay-scrollbar-gtk3 oxideqt-codecs p11-kit p11-kit-modules parted passwd patch patchutils pciutils pcmciautils perl perl-base perl-modules pkg-config plainbox-provider-checkbox plainbox-provider-resource-generic plainbox-secure-policy plymouth plymouth-label plymouth-theme-ubuntu-logo plymouth-theme-ubuntu-text pm-utils policykit-1 policykit-1-gnome policykit-desktop-privileges poppler-data poppler-utils popularity-contest powermgmt-base ppp pppconfig pppoeconf pptp-linux printer-driver-c2esp printer-driver-foo2zjs printer-driver-foo2zjs-common printer-driver-gutenprint printer-driver-hpcups printer-driver-min12xxw printer-driver-pnm2ppa printer-driver-postscript-hp printer-driver-ptouch printer-driver-pxljr printer-driver-sag-gdi printer-driver-splix procps psmisc pulseaudio pulseaudio-module-bluetooth pulseaudio-module-x11 pulseaudio-utils python python-apt python-apt-common python-aptdaemon python-aptdaemon.gtk3widgets python-cairo python-chardet python-commandnotfound python-crypto python-cups python-cupshelpers python-dbus python-dbus-dev python-debian python-debtagshw python-defer python-dirspec python-gconf python-gdbm python-gi python-gi-cairo python-gnomekeyring python-gobject python-gobject-2 python-gtk2 python-httplib2 python-ibus python-imaging python-ldb python-libxml2 python-lockfile python-lxml python-minimal python-notify python-oauthlib python-oneconf python-openssl python-pam python-pexpect python-pil python-piston-mini-client python-pkg-resources python-qt4 python-qt4-dbus python-renderpm python-reportlab python-reportlab-accel python-requests python-samba python-serial python-sip python-six python-smbc python-talloc python-tdb python-twisted-bin python-twisted-core python-twisted-web python-ubuntu-sso-client python-urllib3 python-xapian python-xdg python-zeitgeist python-zope.interface python2.7 python2.7-minimal python3 python3-apport python3-apt python3-aptdaemon python3-aptdaemon.gtk3widgets python3-aptdaemon.pkcompat python3-brlapi python3-cairo python3-chardet python3-checkbox-ng python3-checkbox-support python3-commandnotfound python3-crypto python3-dbus python3-debian python3-defer python3-distupgrade python3-feedparser python3-gdbm  python3-gi python3-gi-cairo python3-httplib2 python3-louis python3-lxml python3-mako python3-markupsafe python3-minimal python3-oauthlib python3-oneconf python3-piston-mini-client python3-pkg-resources python3-plainbox python3-problem-report python3-pyatspi python3-pycurl python3-pyparsing python3-requests python3-six python3-software-properties python3-speechd python3-uno python3-update-manager python3-urllib3 python3-xdg python3-xkit python3.4 python3.4-minimal qdbus qpdf qt-at-spi  qtchooser qtcore4-l10n qtdeclarative5-accounts-plugin qtdeclarative5-dialogs-plugin  qtdeclarative5-localstorage-plugin  qtdeclarative5-privatewidgets-plugin  qtdeclarative5-qtfeedback-plugin  qtdeclarative5-qtquick2-plugin  qtdeclarative5-ubuntu-ui-extras-browser-plugin  qtdeclarative5-ubuntu-ui-extras-browser-plugin-assets qtdeclarative5-ubuntu-ui-toolkit-plugin  qtdeclarative5-unity-action-plugin  qtdeclarative5-window-plugin  readline-common remmina remmina-common remmina-plugin-rdp remmina-plugin-vnc resolvconf rfkill rhythmbox rhythmbox-data rhythmbox-mozilla rhythmbox-plugin-cdrecorder rhythmbox-plugin-magnatune rhythmbox-plugin-zeitgeist rhythmbox-plugins rsync rsyslog rtkit samba-common samba-common-bin samba-libs  sane-utils seahorse sed sensible-utils session-migration sessioninstaller sgml-base shared-mime-info shotwell shotwell-common signon-keyring-extension signon-plugin-oauth2 signon-plugin-password signon-ui signond simple-scan smbclient sni-qt  software-center software-center-aptdaemon-plugins software-properties-common software-properties-gtk sound-theme-freedesktop speech-dispatcher speech-dispatcher-audio-plugins  sphinx-voxforge-hmm-en sphinx-voxforge-lm-en ssh-askpass-gnome ssl-cert strace sudo system-config-printer-common system-config-printer-gnome system-config-printer-udev systemd-services systemd-shim sysv-rc sysvinit-utils t1utils tar tcl tcl8.6 tcpd tcpdump telepathy-gabble telepathy-haze telepathy-idle telepathy-indicator telepathy-logger telepathy-mission-control-5 telepathy-salut telnet thunderbird thunderbird-gnome-support thunderbird-locale-en thunderbird-locale-en-us thunderbird-locale-es thunderbird-locale-es-es time tk tk8.6 totem totem-common totem-mozilla totem-plugins transmission-common transmission-gtk ttf-indic-fonts-core ttf-punjabi-fonts ttf-ubuntu-font-family tzdata ubuntu-artwork ubuntu-desktop ubuntu-docs ubuntu-drivers-common ubuntu-extras-keyring ubuntu-keyring ubuntu-minimal ubuntu-mono ubuntu-release-upgrader-core ubuntu-release-upgrader-gtk ubuntu-session ubuntu-settings ubuntu-sounds ubuntu-sso-client ubuntu-sso-client-qt ubuntu-standard ubuntu-system-service ubuntu-ui-toolkit-theme ubuntu-wallpapers ubuntu-wallpapers-trusty ubuntuone-client-data ucf udev udisks2 ufw unattended-upgrades unity unity-asset-pool unity-control-center unity-control-center-signon unity-greeter unity-gtk-module-common unity-gtk2-module  unity-gtk3-module  unity-lens-applications unity-lens-files unity-lens-friends unity-lens-music unity-lens-photos unity-lens-video unity-scope-audacious unity-scope-calculator unity-scope-chromiumbookmarks unity-scope-clementine unity-scope-colourlovers unity-scope-devhelp unity-scope-firefoxbookmarks unity-scope-gdrive unity-scope-gmusicbrowser unity-scope-gourmet unity-scope-guayadeque unity-scope-home unity-scope-manpages unity-scope-musicstores unity-scope-musique unity-scope-openclipart unity-scope-texdoc unity-scope-tomboy unity-scope-video-remote unity-scope-virtualbox unity-scope-yelp unity-scope-zotero unity-scopes-master-default unity-scopes-runner unity-services unity-settings-daemon unity-voice-service  unity-webapps-common unity-webapps-qml unity-webapps-service uno-libs3 unzip update-inetd update-manager update-manager-core update-notifier update-notifier-common upower upstart ure ureadahead usb-modeswitch usb-modeswitch-data usbmuxd usbutils util-linux uuid-runtime vim-common vim-tiny vino wamerican wbritish webaccounts-extension-common webapp-container webbrowser-app wget whiptail whoopsie whoopsie-preferences wireless-regdb wireless-tools wodim wpasupplicant wspanish x11-apps x11-common x11-session-utils x11-utils x11-xfs-utils x11-xkb-utils x11-xserver-utils xauth xbitmaps xcursor-themes xdg-user-dirs xdg-user-dirs-gtk xdg-utils xdiagnose xfonts-base xfonts-encodings xfonts-mathml xfonts-scalable xfonts-utils xinit xinput xkb-data xml-core xorg xorg-docs-core xserver-common xserver-xorg-core-lts-xenial xserver-xorg-input-all-lts-xenial xserver-xorg-input-evdev-lts-xenial xserver-xorg-input-synaptics-lts-xenial xserver-xorg-input-wacom-lts-xenial xserver-xorg-lts-xenial xserver-xorg-video-all-lts-xenial xserver-xorg-video-amdgpu-lts-xenial xserver-xorg-video-ati-lts-xenial xserver-xorg-video-cirrus-lts-xenial xserver-xorg-video-fbdev-lts-xenial xserver-xorg-video-mga-lts-xenial xserver-xorg-video-neomagic-lts-xenial xserver-xorg-video-nouveau-lts-xenial xserver-xorg-video-qxl-lts-xenial xserver-xorg-video-radeon-lts-xenial xserver-xorg-video-savage-lts-xenial xserver-xorg-video-siliconmotion-lts-xenial xserver-xorg-video-sisusb-lts-xenial xserver-xorg-video-tdfx-lts-xenial xserver-xorg-video-trident-lts-xenial xserver-xorg-video-vesa-lts-xenial xterm xul-ext-ubufox xul-ext-unity xul-ext-webaccounts xul-ext-websites-integration xz-utils yelp yelp-xsl zeitgeist zeitgeist-core zeitgeist-datahub zenity zenity-common zip zlib1g  
adduser trusty
addgroup trusty sudo
exit
+
chmod +x  /mnt/ramdisk/sunxi/config.sh
sudo cp  /mnt/ramdisk/sunxi/config.sh /TableX/home
echo "Montando directorios"
sleep 1
sudo mount -o bind /dev /TableX/dev 
sudo mount -o bind /dev/pts /TableX/dev/pts
sudo mount -t sysfs /sys /TableX/sys
sudo mount -t proc /proc /TableX/proc

chroot /TableX /usr/bin/qemu-arm-static /bin/sh -i ./home/config.sh && exit 
sudo umount /TableX/{sys,proc,dev/pts,dev}
umount /TableX
sudo cp -R /mnt/ramdisk/sunxi/Imagen/trusty.img /home/sunxi/Imagen/trusty.img 
exit
