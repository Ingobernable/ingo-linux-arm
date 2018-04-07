# Fichero que estará en /vars_inc.sh en el contenedor
USERNAME=@@USERNAME@@

export USERNAME

BASIC="wget git bash-completion lsb-release sudo ca-certificates vim.tiny iputils-ping rsyslog net-tools zip"
FULLMAIL="$ANTISPAM $COURIER $POSTFIX $MYSQL"
COURIER="courier-imap-ssl courier-authlib-mysql libgamin0"
POSTFIX="postfix-mysql sasl2-bin libsasl2-modules"
ANTISPAM="amavisd-new"
MYSQL="mysql-server"
PHP="php-cli php-xml php-mysql php-zip"
CERTBOT="python-certbot-nginx"
APACHE="libapache2-mod-php"
NGINX="nginx-light php-fpm"

function sethost()
{
    HOSTNAME=$(cat /etc/hostname)
    SHORT=$(cat /etc/hostname|cut -d. -f1)
    hostname -F /etc/hostname
    IFACE=$(grep "^iface eth" /etc/network/interfaces|awk '{ print $2 }'|head -n1)
    IP=$(ip r l|grep "dev $IFACE "|grep "proto"|awk '{ print $9 }')
    LINE="$IP    $HOSTNAME $SHORT"
    rm /tmp/hosts 2>/dev/null
    if [[ $(grep -w ^$IP /etc/hosts) ]];then
       sed "s/^$IP.*$/$LINE/" /etc/hosts > /tmp/hosts
       mv /tmp/hosts /etc
    else
       echo "$LINE" >> /etc/hosts
    fi
    TZ="Europe/Madrid"
    echo $TZ>/etc/timezone
    rm /etc/localtime
    ln -s /etc/localtime /usr/share/zoneinfo/$TZ
    locale-gen es_ES.UTF-8
    export LC_ALL="es_ES.UTF-8"
    update-locale LC_ALL=es_ES.UTF-8 LANG=es_ES.UTF-8 LC_MESSAGES=POSIX
    dpkg-reconfigure -f noninteractive tzdata
}

function setuser()
{
    if [[ $(getent passwd $USERNAME) ]];then
        echo "El usuario $USERNAME ya existe"
    else
        echo "Creando usuario $USERNAME:"
        useradd -m -d /home/$USERNAME -s /bin/bash $USERNAME
        if [[ -z $USERPASS ]];then
            USERPASS=$USERNAME
        fi
        echo "Estableciendo a $USERPASS la contraseña de $USERNAME"
        echo "$USERPASS:$USERPASS" | chpasswd $USERNAME
        adduser $USERNAME sudo
    fi
}

function custom_install()
{
    CUSTOM=""
    if [ $USEFULLMAIL];then
        CUSTOM="$CUSTOM $FULLMAIL"
    else
        if [ $USECOURIER ];then
            CUSTOM="$CUSTOM $COURIER"
        fi
        if [ $USEPOSTFIX ];then
            CUSTOM="$CUSTOM $POSTFIX"
        fi
        if [ $USEANTISPAM ];then
            CUSTOM="$CUSTOM $ANTISPAM"
        fi
    fi
    if [ $USEMYSQL ];then
        CUSTOM="$CUSTOM $MYSQL"
    fi

    if [ $USENGINX ];then
        CUSTOM="$CUSTOM $NGINX"
    else
        if [ $USEAPACHE ];then
            CUSTOM="$CUSTOM $APACHE"
        fi
    fi
    if [ $USEPHP ];then
        CUSTOM="$CUSTOM $PHP"
    fi

}
