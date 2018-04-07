ingo-linux-arm
==============

El proyecto generado en La Ingobernable, tiene como objetivo instalar linux de forma nativa (sin android) en dispositivos
con arquitectura arm, principalmente tablets y móviles.

Está dividido en dos partes:

1) Un script [TableX.sh](https://github.com/Ingobernable/ingo-linux-arm/TableX.md) con todos los pasos que se utiliza directamente en la máquina linux

2) Un [conjunto de scripts](https://github.com/Ingobernable/ingo-linux-arm/lxc/README_lxc.md) que crean un contenedor lxc dentro de la máquina, con la intención de poder abarcar distintas
variedades, tanto de distribución host, guest y dispositivos.
