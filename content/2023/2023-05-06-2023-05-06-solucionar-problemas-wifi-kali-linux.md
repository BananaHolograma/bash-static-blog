---
author: s3r0s4pi3ns
date: 2023-05-06
human_date: 06 May, 2023
description: Has instalado kali linux en modo offline y te das cuenta de que tu portatil no tiene una ethernet card y los drivers del wifi parece que no estan cargando correctamente, aqui te muestro la solucion para que puedas volver a conectarte a internet y disfrutar de la vida en general
title: Solucionar problemas de WiFi en kali linux
path: blog/2023/2023-05-06-solucionar-problemas-wifi-kali-linux
thumbnail: /assets/images/stable_diffusion_desktop_workplace.jpg
---

Entiendo que estas soluciones deberian **funcionar para cualquier distro basada en Debian** y no solo kali linux. En mi caso particular quise configurar un dual boot junto a Windows 10 en un portatil basuriento que me pille por unos miserables euros porque ya estaba hasta el nabo de tener problemas de compatibilidad usando el macbook con arquitectura arm64.

# Instalacion offline

En el proceso de instalacion usando un USB bootable previamente flasheado con la imagen de kali linux para amd64, tonto de mi, no detectó una **'ethernet card'** en el proceso y prosigo con la instalacion en modo offline muy confiado.
El problema empezó en mi cabeza eso esta claro, porque pensé **_"na, eso le conecto el cable de red y me bajo los paquetes que me faltan despues"_** pero claro, para empezar, mi portatil no tiene conexion para un cable rj45 y segundo, decía claramente **_'ethernet card not found'._**

Asi que estabamos kali linux y yo mirandonos cara a cara sin conexion a internet, pensando **_"menudo pisapapeles me he instalado en 2023"_**

# La busqueda de una solucion

Estaba claro que este problema ya le habia sucedido a alguien mas, lo que me rompió el culo fue que el 90% de las soluciones **me proponian usar la red que no tenia** y el resto estaban bastante enfocadas en un problema muy particular que no era el mio.

Mirando por el lado positivo, aprendi algunos comandos que no conocia para listar el hardware del sistema y emprendi las acciones necesarias para detectar los drivers que necesitaba mi tarjeta de red inalambrica.

## Deshabilitar Fast Boot

En mi aventura en la red encontré [este link](https://wireless.wiki.kernel.org/en/users/drivers/iwlwifi#about_dual-boot_with_windows_and_fast-boot_enabled) a la documentacion oficial del kernel de linux donde explica porque el fast boot puede dar problemas a la hora de inicializar el wifi cuando queremos usar un dual boot así que mejor deshabilitarlo.

## Sabiendo cual es tu adaptador con VirtualBox

Previamente, yo habia empezado a utilizar kali linux de forma virtualizada con VirtualBox y recordé que en la configuracion de red de la imagen, si eliges habilitar el adaptador puente, aparece la version de tu tarjeta de red inalambrica, informacion util para que sepas cuales son los drivers que tienes que descargar.

El mio es: `Intel® Wi-Fi 6 AX201 160MHz` y a través del [siguiente enlace](https://www.intel.com/content/www/us/en/support/articles/000005511/wireless.html) podrás encontrar la lista de todos los drivers disponibles para Intel.

## Sabiendo cual es tu adaptador a traves de la terminal

Si tu caso no es el anterior y no has utilizado VirtualBox puedes lanzar el siguiente comando, el dato que nos interesa es la linea de **Subsystem:**

```bash
lspci -knn | grep -i net -A3

Network Controller: Intel Corporation Alder Lake-P PCH CNVi WiFi (rev 01)
Subsystem: Intel Corporation Wi-Fi 6 AX201 160MHz
Kernel driver in use: iwlwifi # Es posible que este valor este a 'none' o similar
Kernel modules: iwlwifi  # Es posible que este valor este a 'none' o similar
```

## Instalando el firmware de forma manual

Necesitaras volver a tu Windows 10 o tener otro PC para descargarte los drivers de tu adaptador de red inalambrico especificos para linux _(deberia de tener formato `.tgz`)_ y guardarlos en una memoria usb o tarjeta sd lo que nos permitira traspasarlos a kali linux.

Descomprime el contenido dentro de `/lib/firmware`, importante que sean los archivos `ucode` y `pnwn` y no la carpeta como tal. Una vez hecho esto cargamos los modulos y reiniciamos el network manager:

```bash
sudo modprobe -r iwlwifi && sudo modprobe iwlwifi
systemctl restart NetworkManager
```

Si despues de esta ejecucion no tienes el simbolo del wifi arriba te comento otra solución

## Alternativa instalando paquete firmware-iwlwifi y wpa_supplicant

Necesitaras como en el paso anterior, descargarlos de forma manual en tu otro SO o PC para poder mover estos archivos e instalarlos con `sudo dpkg -i <paquete.deb>` en el siguiente orden:

- [firmware-iwlwifi](https://packages.debian.org/bullseye/kernel/firmware-iwlwifi) que contiene los drivers para todas las versiones:
- [libssl1.1](https://packages.debian.org/en/bullseye/libssl1.1) Dependencia necesaria para wpa_supplicant
- [wpa_supplicant](https://packages.debian.org/bullseye/wpasupplicant)

Esta vez reinicia el sistema despues de aplicar los siguientes comandos:

```bash
sudo modprobe -r iwlwifi && sudo modprobe iwlwifi
rfkill unblock all
reboot

# Una vez reinicie si no ves el menu de WiFi activo reinicia el networ manager de nuevo
systemctl restart NetworkManager
```

Si aun no ves ningun cambio respecto al estado original puedes echarle un vistazo a los mensajes en el kernel ring buffer con `sudo dmesg` y ver si hay alguno respecto a `iwlwifi` con el formato `failed to load iwl-...` para confirmar que al menos esta intentando cargarlos.

Como ultima bala podemos probar a descargarnos el ultimo linux firmware en [https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git](https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git) y copiar nosotros mismos el contenido para iwlwifi:

```bash
# Tu fecha del archivo puede cambiar, esta fue la ultima que descargué antes de escribir este articulo
tar -xvzf linux-firmware-20230404.tar.gz

# https://wireless.wiki.kernel.org/en/users/drivers/iwlwifi#firmware
cp linux-firmware-20230404/iwlwifi-*.{ucode,pnvm} /lib/firmware/

# Nos aseguramos que tienen el propietario y grupo correcto para los nuevos archivos
sudo chown -R /lib/firmware
```

## Problemas de incompatibilidad segun version del kernel

En algunos casos que lei parece que ciertas personas descubrieron que su problema era debido a la version del kernel y tuvieron que hacer un downgrade, en principio no es el caso para las versiones 6+ ya que todo esto les sucedia en el rango de la version 5, en mi caso aprticular, el procedimiento lo realice con una version de kernel `6.1.0-kali7-amd64` y no tuve que aplicar ese downgrade pero no esta de mas echarle un vistazo si todo lo demas no ha funcionado.

# Despedida

Si alguno de los pasos anteriores te ha funcionado, me alegro, solo te deseo que no te hayas pegado toda una tarde y lo solucionaras relativamente rapido para seguir trasteando con linux, saludos terricola.
