---
author: s3r0s4pi3ns
date: 2023-04-11
human_date: 10 Abril, 2023
description: Te comparto unas cuantas funciones y combinaciones de comandos de operaciones que se repiten en el tiempo cuando trabajamos en una terminal
title: Funcionalidades comunes para el dia a dia con bash
path: blog/2023/funcionalidades-comunes-para-el-dia-a-dia-con-bash
thumbnail: /assets/images/stable_difussion_city.jpg
---

- [Colores para tus textos en terminal](#colores-para-tus-textos-en-terminal)
- [Transformar texto a mayusculas o minusculas](#transformar-texto-a-mayusculas-o-minusculas)
- [Comprobar si una url es valida teniendo en cuenta múltiples protocolos](#comprobar-si-una-url-es-valida-teniendo-en-cuenta-múltiples-protocolos)
- [Usar el directorio actual donde se encuentra alojado el script y no donde se ejecuta](#usar-el-directorio-actual-donde-se-encuentra-alojado-el-script-y-no-donde-se-ejecuta)
  - [Importante](#importante)
- [Reemplazar sin sacar output en consola](#reemplazar-sin-sacar-output-en-consola)
- [Reemplazar un bloque especifico de texto en un archivo](#reemplazar-un-bloque-especifico-de-texto-en-un-archivo)
- [Añadir nueva linea despues de un match con sed](#añadir-nueva-linea-despues-de-un-match-con-sed)
- [Convertir una cadena de texto en array](#convertir-una-cadena-de-texto-en-array)
- [Separar valores en nueva linea por multiples delimitadores](#separar-valores-en-nueva-linea-por-multiples-delimitadores)
- [Leer un archivo linea por linea](#leer-un-archivo-linea-por-linea)
- [Comprobar si un usuario existe en el sistema](#comprobar-si-un-usuario-existe-en-el-sistema)
- [Leer input del usuario](#leer-input-del-usuario)
- [Que gestor de paquetes utilizar segun el OS](#que-gestor-de-paquetes-utilizar-segun-el-os)
- [Que sistema operativo es](#que-sistema-operativo-es)
- [Que architectura es](#que-architectura-es)
- [Extraer puertos abiertos desde nmap -oN](#extraer-puertos-abiertos-desde-nmap--on)
- [Extraer puertos abiertos desde nmap -oG](#extraer-puertos-abiertos-desde-nmap--og)
- [Parsear argumentos de un script](#parsear-argumentos-de-un-script)
- [Validar que un parámetro esta en un rango de valores validos definidos en un array](#validar-que-un-parámetro-esta-en-un-rango-de-valores-validos-definidos-en-un-array)
- [Operaciones con arrays asociativos](#operaciones-con-arrays-asociativos)
- [Transformar string en array](#transformar-string-en-array)
- [Convertir string multilinea en array](#convertir-string-multilinea-en-array)
- [Imprimir texto multilinea con sustitucion de variables](#imprimir-texto-multilinea-con-sustitucion-de-variables)
- [Extraer propiedades de un archivo .json](#extraer-propiedades-de-un-archivo-json)
- [Extraer propiedades de un frontmatter en archivos markdown](#extraer-propiedades-de-un-frontmatter-en-archivos-markdown)
- [Reemplazar espacios en blanco por un caracter definido](#reemplazar-espacios-en-blanco-por-un-caracter-definido)
- [Sacando output a shell en lugar de guardar un archivo con wget](#sacando-output-a-shell-en-lugar-de-guardar-un-archivo-con-wget)
- [Convertir texto a hexadecimal](#convertir-texto-a-hexadecimal)
- [Fork bomb](#fork-bomb)
  - [Importantísimo](#importantísimo)

Lo que voy a compartir es una serie de scripts en bash que pueden reutilizarse para realizar operaciones comunes con el, es una serie de recursos que he ido acumulando en mi notion donde voy tomando notas de mi aprendizaje y de algunas soluciones a las que he llegado para yo consultarlas en el futuro y seguir avanzando.

También suelo utilizar [la cheatsheet de devhint](https://devhints.io/bash) como consulta ya que es fácil no tener en la cabeza todas las movidas de sintaxis que usa bash

# Colores para tus textos en terminal

Ayudan a crear una mejor legibilidad de nuestros scripts en consola cuando queremos enfatizar cierta información o mostrar un error, la forma normal que uso yo es con los códigos de escape ANSI:

```bash
greenColour='\033[0;32m'
redColour='\033[0;31m'
blueColour='\033[0;34m'
yellowColour='\033[1;33m'
purpleColour='\033[0;35m'
cyanColour='\033[0;36m'
grayColour='\033[0;37m'

# Reset de color
endColour='\033[0m'

# Ejemplo
# Cuando uso la variable entre {} es para que interprete solo esa parte y no se superponga con el texto que viene
# Si usara $redColour[ ABORTING ] tomaría los ultimos caracteres como parte de la variable
echo -e "${redColour}[ ABORTING ]$endColour ${yellowColour}GNU grep is required. Install it with$endColour ${cyanColour}'brew install grep'$endColour" >&2

```

Puedes encontrar la lista completa en [https://gist.github.com/Prakasaka/219fe5695beeb4d6311583e79933a009](https://gist.github.com/Prakasaka/219fe5695beeb4d6311583e79933a009)

# Transformar texto a mayusculas o minusculas

En ciertos momentos necesito realizar esta transformación por 'x' motivo, aqui te dejo el procedimiento:

```bash
# Con tr
echo "FANTASMAGORICO" | tr '[:upper:]' '[:lower:]' # fantasmagorico
echo "fantasmAgoRico" | tr '[:lower:]' '[:upper:]' # FANTASMAGORICO

# Con simbolos de manipulacion
echo "${FAntaSmagoRico,,}"  #=> "fantasmagorico"
echo "${fantasmagorico^^}"  #=> "FANTASMAGORICO"

```

# Comprobar si una url es valida teniendo en cuenta múltiples protocolos

Una funcion que siempre tengo en el tipico `utils.sh` cuando trabajo con direcciones y múltiples protocolos. Si necesitas solo trabajar con el protocolo Http simplemente elimina los otros y ya:

```bash
is_url() {
    local url=$1
    regex='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'

    [[ $url =~ $regex ]]
}
```

# Usar el directorio actual donde se encuentra alojado el script y no donde se ejecuta

Cuando usas `$(pwd)` en tu script de bash realmente esta utilizando el path donde lo estas ejecutando, muchas veces no nos importa pero hay momentos en los que necesito que el script trabaje en el directorio donde se encuentra para saber donde encontrar archivos en una estructura estática y usar path relativos de forma correcta:

```bash
CURRENT_DIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
```

## Importante

Esta linea se tiene que aplicar en cada script individual ya que si por ejemplo creamos un fichero `utils.sh` en otro directorio con esta funcion y la exportamos no funcionara como esperamos:

```bash
# project/helpers/utils.sh
current_directory() {
		dirname -- "$(readlink -f -- "$BASH_SOURCE")"
}

export -f current_directory

################

# projects/install.sh

source "helpers/utils.sh"

# La ejecución de la funcion nos dará el path de project/helpers y no projects/
CURRENT_DIR=current_directory
```

# Reemplazar sin sacar output en consola

Reemplazos sencillos en los que no quiero que `sed` me saque el output del archivo en pantalla:

```bash
sed -i -e "s/match/replace/g" file

# En sistemas MacOs hay que definir el string vacio
sed -i '' -e "s/match/replace/g" file
```

# Reemplazar un bloque especifico de texto en un archivo

En mi repositorio de [bash-static-blog](https://github.com/s3r0s4pi3ns/bash-static-blog) utilizo esta técnica para generar el indice de los articulos en el index.html en un bloque específico del mismo que he definido con las palabras START Y END:

```bash
# index.html
        <div>
          <ul>
    <!-- START -->

    <!-- END -->
          </ul>
        </div>

# bash
sed -i '' -e "/<!-- START -->/,/<!-- END -->/c\\
    <!-- START -->\\
    $html\\
    <!-- END -->" "$index_html_file"
```

# Añadir nueva linea despues de un match con sed

El procedimiento es simple pero tener que escapar los backslashes la hace mas pesada de leer:

```bash
# /etc/sudoers
//...
Defaults use_pty

sed -i '' '/use_pty/s/.*/&\nDefaults logfile="\/var\/log\/sudo.log"/' /etc/sudoers
# /etc/sudoers
//...
Defaults use_pty
Defaults logfile="/var/log/sudo.log"

```

# Convertir una cadena de texto en array

```bash
local $ALLOWED_USERS="juan mario magdalena"

if ! is_empty "$ALLOWED_USERS"; then
      read -ra names <<< "$ALLOWED_USERS"

      for name in "${names[@]}"; do
	       # do your stuff here
      done
fi
```

# Separar valores en nueva linea por multiples delimitadores

```bash
DOMAINS=$(echo "example.com,example.es|hola.org:adios.es 10000.net" | tr ',|-_/: ' '\n')

echo $DOMAINS

example.com
example.es
hola.org
adios.es
10000.net
```

# Leer un archivo linea por linea

```bash
while IFS=read line; do <command>; done < file.txt
```

# Comprobar si un usuario existe en el sistema

Estoy empezando usar el comando `id` ya que en la man page de `whoami` podemos encontrar el siguiente apartado:

```bash
The whoami utility has been obsoleted by the id(1) utility, and is equivalent to “id -un”.  The command “id -p” is suggested for normal interactive use.
```

```bash
name=eusebio

if ! id -u "$name" 1>/dev/null; then
	  # The user does not exist...
fi
```

# Leer input del usuario

```bash
declare -i number

while $number ~= '^[0-9]+$'; do
	read -rp "Selecciona un numero" number
done
```

# Que gestor de paquetes utilizar segun el OS

Una version rudimentaria para determinar que gestor de paquetes utilizar si queremos instalar dependencias en nuestro script

```bash
function whichPM() {
    local package_manager=''

		# MacOS
    if [[ $OSTYPE == 'darwin'* ]]; then
        package_manager='brew'
    # Ubuntu, Debian and Linux mint
    elif [ -n "$(command -v apt)" ]; then
			package_manager="apt"

    # CentOS, RHEL and Fedora
    elif [ -n "$(command -v yum)" ]; then
			package_manager="yum"
    elif [ -n "$(command -v dnf)" ]; then
			package_manager="dnf"

   # Arch Linux and Manjaro Systems
    elif [ -n "$(command -v pacman)" ]; then
			package_manager="pacman"
    # OpenSuse systems
    elif [ -n "$(command -v zypper)" ]; then
			package_manager="zypper"
    else
      echo -e "Package manager not found (apt,yum,dnf,pacman or zypper)"
      exit 1;
    fi

    echo "$package_manager"
}

export -f whichPM
```

# Que sistema operativo es

```bash
#!/usr/bin/env bash

function whichOS() {
    local operating_system=''

    if [[ $OSTYPE == 'darwin'* ]]; then
       operating_system="macOS"
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ] || [ "$(uname)" == "cygwin"]; then
       operating_system="linux"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ] || [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
       operating_system="windows"
    else
	    exit 1;
    fi

    echo "$operating_system"
}

export -f whichOS
```

# Que architectura es

```bash
system_architecture=$(uname -m)

case $system_architecture in
        arm64 | aarch64)
            kitty_release="kitty-0.27.1-arm64.txz"
        ;;
        64-bit | x86_64)
            kitty_release="kitty-0.27.1-x86_64.txz"
        ;;
        i386| i486| i586| i686)
        kitty_release="kitty-0.27.1-i686.txz"
        ;;
    esac
```

# Extraer puertos abiertos desde nmap -oN

```bash
#!/usr/bin/env bash

file=$1

if  [ ! $# -eq 0 ] && [ -f $file ] && [ -s $file ]; then
	grep -E '[0-9]{1,5}/(tcp|udp)' $file | sed -r 's/\/(tcp|udp)//g' | awk '{print $1}' | xargs | tr ' ' ',' | tr -d '\n' | xclip -sel clip
else
	echo -e "The file passed as parameter does not exists or is not valid"
fi
```

# Extraer puertos abiertos desde nmap -oG

Este script lo he sacado de un gist de [s4vitar](https://gist.github.com/anibalardid/5e05b6472feb3d31116729dc24e6d3e2) y lo suelo combinar con el anterior dependiendo en que formato saco el output del escaneo de nmap

```bash
ports="$(cat $1 | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
	ip_address="$(cat $1 | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u | head -n 1)"
	echo -e "\n[*] Extracting information...\n" > extractPorts.tmp
	echo -e "\t[*] IP Address: $ip_address"  >> extractPorts.tmp
	echo -e "\t[*] Open ports: $ports\n"  >> extractPorts.tmp
	echo $ports | tr -d '\n' | xclip -sel clip
	echo -e "[*] Ports copied to clipboard\n"  >> extractPorts.tmp
	cat extractPorts.tmp; rm extractPorts.tmp
```

# Parsear argumentos de un script

Explico en detalle el procedimiento para lograr esto en mi artículo [Leer argumentos en tu script bash](../leer-argumentos-en-tu-script-bash):

```bash
# Añadir mas opciones tipo --name)
# Este bucle inicial permite mapear formato opcion larga a corta
# que es la unica que entiende bash

for arg in "$@"; do
  shift
  case "$arg" in
    '--help')      set -- "$@" '-h'   ;;
    *)             set -- "$@" "$arg" ;;
  esac
done

# Añadir mas parametros a conveniencia en geopts y case
while getopts ":h:" arg; do
    case $arg in
        h | *)
            showHelpPanel
        ;;
    esac

done
shift $(( OPTIND - 1))
```

# Validar que un parámetro esta en un rango de valores validos definidos en un array

En otros lenguajes es mas sencillo pero en bash tenemos que utilizar a veces hasta la imaginación para conseguir algo tan simple, aquí te dejo el enfoque de como lo trato yo. Utilizo este acercamiento en mi herramienta [ipharvest](https://github.com/s3r0s4pi3ns/ipharvest):

```bash
# Example
set_mode() {
    declare -a available_modes=("ipv4" "ipv6" "both")
    declare -i valid_mode=0
    local selected_mode=$1

    for mode in "${available_modes[@]}"; do
        if [ "$mode" = "$selected_mode" ]; then
            MODE=$mode
            valid_mode=1
            break
        fi
    done

    if [ $valid_mode -eq 0 ]; then
        echo -e "The selected mode $selected_mode is invalid, allowed values are: ${available_modes[*]}. The default mode $MODE will be used instead"
    fi
}
```

# Operaciones con arrays asociativos

```bash
# Onicializar
declare -A mydict

# Asignar multiples valores en una accion
mydict=([key1]=1 [key2]=2 [key3]=3)

# Asignar un elemento al final
mydict+=(key4=4)

# Obtener claves y valores
echo ${mydict[@]} #### Obtener todos los valores
3 2 1
echo ${mydict[*]}  ###  Obtener todos los valores
3 2 1
echo ${!mydict[*]}  ### Obtener todas las claves
key3 key2 key1

# Validar si un elemento existe, 'abc' puede ser cualquier otro valor
# Si el elemento existe retorna 'abc' por lo tanto es verdadero
# Si no existe no retorna abc por lo que la siguiente operacion echo no se ejecuta
[ ${mydict[key]+abc} ] && echo 'existe'

# Alternativa

# Comprobar que no existe
if [[ ! -v mydict["$key"] ]]; then
	//...
fi

#Comprobar que si existe
if [[ -v mydict["$key"] ]]; then
	//...
fi

# Borrar elemento
unset mydict[key2]

# Numero de elementos en el array, usar prefijo #
echo ${#STAR_PLAYERS[@]}
```

# Transformar string en array

```bash
names="Juanito Especialito Enrique Kiko"
array=($names) # Esta transformacion usa IFS=' ' como delimitador
```

# Convertir string multilinea en array

```bash
# Bash utiliza la variable IFS que por defecto utiliza \n como separador
# Si quisieramos definir otro simplemente IFS=<separator>
# A su vez readarray inicializa la variable MAPFILE con los valores en este formato
# Esta funcionalidad solo esta disponible en bash 4+

readarray -t ip_addreses <<< "192.168.1.1\n10.10.10.25\n67.89.133.11"
# Ejemplo
for ip in "${ip_addreses[@]}"; do
      if [ ! ${IP_GEOLOCATION_DICTIONARY[$ip]+exists} ]; then
          IP_GEOLOCATION_DICTIONARY[$ip]=$(geolocate_ip "$ip")
      fi
done

# Soporte para versiones bash antiguas
$ arr=()
$ while IFS= read -r ip; do arr+=("$ip"); done <<<"$ip_addreses"
```

# Imprimir texto multilinea con sustitucion de variables

La palabra clave elegida (EOF en el ejemplo) no debe contener comillas si deseamos sustituir variables dentro:

```bash
banner() {
    cat << EOF

___ _           _      _ _____
 | |_)__|_| /\ |_)\  /|_(_  |
_|_|    | |/--\| \ \/ |___) | v(${VERSION})


EOF
}
```

# Extraer propiedades de un archivo .json

Despues de una larga lucha con chatGPT esta es la versión que me ha funcionado correctamente con valores anidados en un json:

```bash
json='{"status":"success","description":"Data successfully received.","data":{"geo":{"host":"74.220.199.8","ip":"74.220.199.8","rdns":"parking.hostmonster.com","asn":46606,"isp":"UNIFIEDLAYER-AS-1","country_name":"United States","country_code":"US","region_name":null,"region_code":null,"city":null,"postal_code":null,"continent_name":"North America","continent_code":"NA","latitude":37.751,"longitude":-97.822,"metro_code":null,"timezone":"America\/Chicago","datetime":"2023-03-18 04:23:49"}}}'

# con jq disponible y queremos acceder a la propiedad status
 echo "$json" | jq '.status' # success

# Puro bash
extract_json_property() {
    local json="$1"
    local prop="$2"

    # Usamos grep para matchear la propiedad a buscar
    local regex="\"${prop}\":\s*([^,}]+)"

    if [[ $json =~ $regex ]]; then
        local value="${BASH_REMATCH[1]}"

        # Si el valor es una string con comillas se las quitamos
        if [[ $value =~ ^\"(.*)\"$ ]]; then
            echo "${BASH_REMATCH[1]}"
        else
            echo "$value"
        fi
    else
        # Si no se encuentra nada devolvemos una cadena vacía para seguir la ejecución
        echo ""
    fi
}

extract json_property "$json" "latitude"
```

# Extraer propiedades de un frontmatter en archivos markdown

Para generar los articulos de este blog utilizo esta función que me permite extraer propiedades y aplicar unas transformaciones despues o simplemente leer el dato, muy útil si trabajas con markdown:

```bash
### Estructura de frontmatter en un markdown para alojar metadatos
# ---
# author: s3r0s4pi3ns
# date: 2023-03-01
# datetime: 2023-03-01T00:00:00.000Z
# description: Si tenías la curiosidad de como se crean las herramientas de bash que te permiten pasar como parámetro opciones específicas este es tu # lugar
# title: Definir argumentos en un script de bash
# ---
###

function extract_frontmatter_property() {
    local markdown_file=$1
    local property=$2

    if [ -f "$markdown_file" ]; then
        frontmatter=$(awk '/^---*$/{p=!p;next}p' "$markdown_file")
        echo "$frontmatter" | $GREP_COMMAND -E "^${property}: (.*)" | sed 's/^[^:]*:\s*//'
    else
        echo ''
    fi
}

# Ejemplos
title=$(extract_frontmatter_property "$file" "title")
date=$(extract_frontmatter_property "$file" "date")
human_date=$(extract_frontmatter_property "$file" "human_date")
```

# Reemplazar espacios en blanco por un caracter definido

```bash
# Se reemplazaran por _
sed 's/[[:space:]]\{1,\}/_/g'

# Bonus: Eliminar comillas dobles "
sed 's/\"//g'
```

# Sacando output a shell en lugar de guardar un archivo con wget

Al definir un output de `qO-` sin un redirector `>` va directamente a la shell:

```bash
wget -qO- https://example.com
```

# Convertir texto a hexadecimal

```bash
# Quitar el espacio inicial de " %02x"' si lo queremos todo junto
 echo "example" | hexdump -ve '1/1 " %02x"'

65 6a 65 6d 70 6c 6f 0a
```

# Fork bomb

[Wikipedia Fork_bomb](https://en.wikipedia.org/wiki/Fork_bomb)
Yo cuando la vi por primera vez en el típico artículo random, no la entendía, solo era una amalgama de caracteres en fila india pero si la descomponemos vemos que es un simple función que se llama asi misma recursivamente agotando los recursos del sistema.

## Importantísimo

No la tires en tu PC de uso normal, hazlo en un entorno virtualizado porque es muy probable que se te congele si tu sistema no tiene definido un numero maximo de procesos. Los procesadores modernos tienen mitigado esta movida pero nunca se sabe.

```bash

:(){ :|:& };:

# Si sustitimos los ; por fork se puede entender como
fork() {
    fork | fork &
}
fork
```
