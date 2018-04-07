# script para contenedores lxc

## INTRODUCCION
Basado en TableX.sh, los scripts de este directorio son la base para generar scripts específicos de la distribución.

## INSTALACION
Los scripts se pueden poner en cualquier directorio

## INICIO
Se ejecuta el script install.sh como root o sudo. Automatiza la creación de un contenedor lxc y realiza los pasos necesarios para tener una imagen Linux junto con el kernel y el bootloader u-boot.

Utiliza menuconfig, y permite seleccionar unas imágenes para compilar.

Para su mejor comprensión, se ha dividido el proceso se divide en 3 fases, según los permisos necesarios:
- Instalación de los paquetes necesarios (0-root_install.sh). Este script dependerá de la distribución, ya que cada cual tiene sus paquetes para el mismo fin.
- Tareas que se pueden realizar como usuario (1-user.sh). Este script debería ser igual para todas las distribuciones.
- Tareas finales que tienen que realizarse como root (2-root.sh)

Se puede entrar posteriormente al contenedor con lxc-attach -n <contenedor>, realizar manualmente las modificaciones que se consideren y rehacer pasos, bien mediante las instrucciones aisladas de los scripts 1 y 2, o bien ejecutando directamente los scripts desde el correspondiente $HOME, donde hay una copia de seguridad, ya que en el reinicio, la copia en /tmp queda borrada.
