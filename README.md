# compilepack

Este script realiza los pasos necesarios para tener una imagen Linux ubuntu 14.04 junto con el kernel y el bootloader u-boot
decarga, compila y instala las sunxi-tools  descarga y compila un kernel y un u-boot en memoria RAM despues los copia en local, 
acto seguido crea una imagen de ubuntu armhf y copia el kernel y los modulos en el lugar apropiado en la imagen
todo este proceso lo hace en RAm el resultado son 2 carpetas en home:

sunxi/u-boot
sunxi/Imagen
