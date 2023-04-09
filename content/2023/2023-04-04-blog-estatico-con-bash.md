---
author: s3r0s4pi3ns
date: 2023-04-04
human_date: 04 Abril, 2023
description: Tu blog estatico con solo 80 lineas de bash, aprende a no depender de ningun CMS a la hora de crear tu contenido
title: Construyendo un blog estatico con bash
path: blog/2023/construyendo-un-blog-estatico-con-bash
---

- [Antes de empezar](#antes-de-empezar)
- [La idea inicial](#la-idea-inicial)
- [Iniciando el camino](#iniciando-el-camino)
  - [README.md](#readmemd)
    - [¿Se puede crear un sitio tipo blog usando la herramienta pandoc y un par de comandos de bash?](#se-puede-crear-un-sitio-tipo-blog-usando-la-herramienta-pandoc-y-un-par-de-comandos-de-bash)
  - [Que he terminado de ese README inicial](#que-he-terminado-de-ese-readme-inicial)
- [El script](#el-script)
  - [Generando html desde markdown con pandoc](#generando-html-desde-markdown-con-pandoc)
  - [Iteración de archivos markdown para generar el html](#iteración-de-archivos-markdown-para-generar-el-html)
  - [Construyendo el índice de artículos cada vez que lanzamos el script](#construyendo-el-índice-de-artículos-cada-vez-que-lanzamos-el-script)
    - [Extrayendo el frontmatter y generando un índice de artículos aceptable](#extrayendo-el-frontmatter-y-generando-un-índice-de-artículos-aceptable)
- [Resultado final del script](#resultado-final-del-script)
  - [Como está el directorio de trabajo después de todo este proceso](#como-está-el-directorio-de-trabajo-después-de-todo-este-proceso)
- [Toque gourmet con Docker y Nginx](#toque-gourmet-con-docker-y-nginx)
  - [Definiendo nuestra configuración de Nginx](#definiendo-nuestra-configuración-de-nginx)
    - [Dockerfile](#dockerfile)
    - [default.conf](#defaultconf)
    - [nginx.conf](#nginxconf)
    - [docker-compose.yml](#docker-composeyml)
  - [Construyendo y levantando nuestro contenedor de nginx](#construyendo-y-levantando-nuestro-contenedor-de-nginx)
- [Imagen docker de pandoc](#imagen-docker-de-pandoc)
- [Conclusiones finales](#conclusiones-finales)

# Antes de empezar

Si te importa un carajo como he construido esta basura puedes ir directamente al código en el repositorio [https://github.com/s3r0s4pi3ns/bash-static-blog](https://github.com/s3r0s4pi3ns/bash-static-blog) y ahorrarte toda esta fumada.

`Se requiere que tengas conocimientos previos de:`

- **_Linux_**
- **_Bash scripting_**
- **_Docker & Nginx (opcional)_**

# La idea inicial

Es 2023, mientras escribo este artículo semidesnudo, en el mundo existen multitud de herramientas para construir sitios estáticos como [Hugo](https://gohugo.io/), [Jekyll](https://jekyllrb.com/) o [Astro](https://astro.build/) que hacen un trabajo excelente.
El problema es mi intención minimalista inicial a la hora de querer construir mi blog y es que estas herramientas o frameworks generan un overload de información que me resulta incómoda de manejar para lo que yo realmente quiero.

Llegué a crear un blog con estas 3 herramientas que he mencionado usando un theme fancy super responsive pero algo me decía en mi pechito

> Tío eres programador, montate algo tu mismo, reinventa la rueda cabron

Yo soy feliz con una estructura simple y repetitiva que me permita generar contenido en markdown y transformarlo en html usable. Por eso decidí montarme mi blog con bash y la ayuda del conversor [Pandoc](https://pandoc.org/) para darle un toque web de los años 90 donde todo eran hipervínculos y punto pelota.

El resultado final es este blog que estás leyendo ahora mismo con un javascript inexistente ¿XSS? eso que es.

# Iniciando el camino

Llamadme persona extraña pero me gusta comentar el proceso mental _(o retroceso)_ que he tenido a la hora de construir este blog estático y no enseñar el resultado final de primeras. Todo empezó con una estructura de carpetas y archivos donde había apuntado algunas ideas sueltas en el `README.md`:

```bash
├── README.md
├── content
│   ├── 2023
│   │   ├── como-dejar-de-mirar-en-la-oscuridad.md
│   │   └── bash-para-payasos.md
├── test.sh
└── src
    ├── assets
    │   └── images
    │       └── avatar.png
    ├── index.html
    └── styles
        ├── globals.css
        └── normalize.css
```

La idea rudimentaria era alojar el contenido markdown dentro de la carpeta `content` y sacarlo como output hacia `src` que es la carpeta que mi servidor web va a ofrecer a los amables usuarios de internet usando el script avanzado nivel avengers `test.sh`.
Este es el contenido del README.md en su estado fetal:

## README.md

### ¿Se puede crear un sitio tipo blog usando la herramienta pandoc y un par de comandos de bash?

Quizas si, voy a enumerar un par de features minimalistas. Digo minimalista porque es el publico objetivo, algo liviano fuera de todo tipo de artificios en el que solo se enfoque en una cosa, mostrar contenido.

- Crear un directorio base de carpetas donde se movera el contenido al directorio source
- Multilenguaje (carpetas con el locale tipo es,en...)
- Metadatos en formato .yml para la configuracion basica del blog
- Metadatos para categorizar articulos
- Makefile para abstraer las operaciones en un lenguaje humano
- Template minimalista con html y css, nada de frameworks
- Entorno docker con Nginx y Pandoc separados

Requerimentos: pandoc yq(parseo yaml como jq para json) bash v4+

## Que he terminado de ese README inicial

Uno sabe como empieza pero no como acaba, de esas ideas que enumeré en ese momento de retrolucidez extrema solo llegué a implementar:

- Crear un directorio base de carpetas donde se movera el contenido al directorio source
- Metadatos para categorizar articulos _(ni le llamo metadatos, el frontmatter del markdown tipico)_
- Template minimalista con html y css, nada de frameworks
- Entorno docker con Nginx y Pandoc separados

# El script

El script que ahora se nombra `generate.sh` ha tenido trescientos mil cambios y no se parece en nada con el que empecé, a medida que iba descubriendo cosas por el camino, bloqueos mentales y todo tipo de miserias humanas del primer mundo llegué a una versión final nada mal.

En mi mente este código tenia que realizar 2 operaciones importantes: Transformar el markdown en html, Generar un indice de artículos en mi index html

Vamos a trocearlo un poquito:

```bash
#!/usr/bin/env bash

# REMINDER OUTPUT STYLES FOR SYNTAX HIGHLIGHT pandoc --highlight-style=zenburn ./content/2023/definir-argumentos-script-de-bash.md -s -o readme2.html

GREP_COMMAND='grep' # GNU Linux grep command by default

function is_macOs() {
    [[ "$OSTYPE" == 'darwin'* ]]
}

if is_macOs; then
    GREP_COMMAND='ggrep'
    if ! command -v "$GREP_COMMAND" >/dev/null 2>&1; then
        echo -e "GNU grep is required. Install it with 'brew install grep'" >&2
        exit 1
    fi
fi
```

De momento lo que vemos no tiene nada que ver con un blog, yo utilizo un Macbook para mi día a día y descubres que comandos que usas en un linux tipo `sed` o `grep` no funcionan de la misma manera por eso tengo que comprobar si el sistema que ejecuta el script es un mac y utilizar el comando apropiado que en mi caso serà `ggrep` el cual tiene el mismo comportamiento que el nativo de Linux.

El comentario REMINDER tiene historia ya que casi abandono este proyecto por no conseguir que pandoc me aplicara los estilos de syntax highlighting en el html generado cuando usaba la opción --standalone. No conseguía dar con la tecla ni leyendo la documentación oficial así que se me ocurrió transformar un markdown de prueba a un html cualquiera donde aplicara un theme de syntax highlighting via --highlight-style ya que de esta forma pandoc aplica los estilos en linea en el html generado.

Si, es triste, para obtener un theme de resaltado tengo que extraerlo como si fuera carbón pero lo bueno es que solo tengo que hacerlo una vez si ya tengo decidido que theme usar _(zenburn)_.

## Generando html desde markdown con pandoc

Si tuviera que picarme yo un parseador de markdown si que estaría loco, así que haciendo un par de búsquedas parece que [Pandoc](https://pandoc.org/) era el way to go aceptado por la industria en general

```bash
CURRENT_DIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # No te rayes, usa $(pwd)
MARKDOWN_FILES=$(find "$CURRENT_DIR/content" -type f -iname '*.md' -print | xargs -0)

function generate_html_from_markdown() {
    local markdown_path=$1
    local base_dir=$(echo "$markdown_path" | sed 's|/content/.*||')
    local templates_path="$base_dir/content/templates"

    local html_path=$(echo "$markdown_path" | sed 's|.*/content/||' | sed 's/\.md$/.html/')
    local output_path="$base_dir/src/blog/$html_path"

    mkdir -p "$(dirname "$output_path")"
    pandoc --read=markdown --table-of-contents --toc-depth=2 --preserve-tabs --standalone --template="$templates_path"/article.html --listings "$markdown_path" --highlight-style=zenburn -o "$output_path"

    echo -e "Generated html from article $(dirname "$markdown_path")"
}
```

Este par de líneas es el core, la función que se encarga de recibir por parámetro el path absoluto donde se encuentra un archivo markdown para posteriormente, despues de aplicar unos filtros y extraer cierta información, convertirlo en html.

Aquí entra el juego el sistema de templates que incluye pandoc y es que puedes proveerle de un archivo base donde puedes inyectarle variables con la sintaxis `$variable$`. Estas variables las obtiene del frontmatter de markdown _(a excepción de $body$ que es el contenido markdown)_, todos los artículos que genere a partir de ahora usaran el siguiente `article.html` como base:

```html
<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="$description$" />
    <title>S3r0s4pi3ns - $title$</title>
    <link rel="stylesheet" href="../../styles/normalize.css" />
    <link rel="stylesheet" href="../../styles/globals.css" />
    <link rel="stylesheet" href="../../styles/article.css" />
  </head>
  <body>
    <main>
      <div class="terminal">
        <pre>
          <span class="output" data-prompt="$path$"><a class="terminal-link" href="/">cd &#36;HOME</a></span>
        </pre>
      </div>
      <article>
        <header>
          <h1>$title$</h1>
        </header>
      </article>
      <section>$body$</section>
    </main>
  </body>
</html>
```

## Iteración de archivos markdown para generar el html

De forma natural la siguiente función que visualizamos es la de iterarar sobre nuestra lista de archivos markdown que existan en la carpeta `content`, utilizarla es sencillo:

```bash
function generate_html_articles() {
    local markdown_files=$1

    while IFS= read -r  markdown_file; do
        generate_html_from_markdown "$markdown_file"
    done <<< "$markdown_files"
}
```

Y ya podemos hacer que la magia computacional suceda en una linea corta y directa, recordemos que `$MARKDOWN_FILES` lo obtenemos del comando `find` en el inicio del script:

```bash
MARKDOWN_FILES=$(find "$CURRENT_DIR/content" -type f -iname '*.md' -print | xargs -0)

generate_html_articles "$MARKDOWN_FILES"

```

## Construyendo el índice de artículos cada vez que lanzamos el script

Una de las partes que mas me ha dado el coñazo sin duda, fui feliz durante unos instantes cuando conseguí transformar el markdown y sacarlo como output a `src` hasta que me acordé que mi `index.html` había que actualizarlo de forma manual para reflejar los nuevos artículos. Me puse manos a la obra despues de tomarme un café bastante amargo y frio
.
Antes de empezar necesitaba unos cuantos datos importantes como era el título, la fecha de publicación, etc. Esta información la tengo en el frontmatter del archivo markdown así que vamos a combinar `awk` y `sed` para el procesamiento de texto definitivo.

Cree una función para realizar exclusivamente esta tarea que recibiera 2 parámetros, el archivo markdown y la propiedad a buscar:

```bash
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
```

Voy a intentar desenroscar un poco el lenguaje críptico que usan estos comandos de procesamiento de texto de bash:

`awk /^---\*$/{p=!p;next}`

`/^---\*$/:` Esta expresión regular busca las líneas típicas de un frontmatter de markdown ---, he añadido un \* por si hubiera mas de 3 pero en realidad no debería.

`{p=!p;next}`: Esto es propio de awk, es como un bucle donde p es una expresión booleana la cual es true si la linea a procesar coincide con la expresion regular anterior. Mi objetivo principal es obtener la información del frontmatter que se encuentra entre `--- data ---` por lo que me esta procesando las líneas hasta que se encuentre la siguiente --- que sería la última y define el fin de los metadatos del markdown.

`echo "$frontmatter" | $GREP_COMMAND -E "^${property}: (.*)" | sed 's/^[^:]*:\s*//'`

Ya una vez tengo el frontmatter y he guardado el resultado de `awk` en la variable `$frontmatter` esta expresión nos permite obtener el valor de una propiedad especifica del mismo, `sed 's/^[^:]*:\s*//'` elimina la propiedad para que solo me devuelva el valor, por ejemplo:

`title: titulazo para el articulo` se convierte en `titulazo para el articulo`

### Extrayendo el frontmatter y generando un índice de artículos aceptable

Una vez en la recta final, ya disponemos de todas las herramientas necesarias para generar nuestro índice de artículos cada vez que lanzemos el script y generemos contenido desde nuestra carpeta maestra `content`

```bash
function generate_blog_index() {
    local articles=$1
    local index_html_file="$CURRENT_DIR/src/index.html"

    # Insert the updated article list
    local html=''
    while IFS= read -r  file; do
        if [ -f "$file" ]; then
            title=$(extract_frontmatter_property "$file" "title")
            date=$(extract_frontmatter_property "$file" "date")
            human_date=$(extract_frontmatter_property "$file" "human_date")
            year=$(echo "$date" | $GREP_COMMAND -o '[0-9]\{4\}')
            path=$(echo "/blog/$year/$(basename "$file")" | sed 's/\.md$//')

            html+="<li><a href=\"$path\">$title</a><span class=\"date\">$human_date</span></li>"
        fi
    done <<< "$articles"

    sed -i '' -e "/<!-- START -->/,/<!-- END -->/c\\
    <!-- START -->\\
    $html\\
    <!-- END -->" "$index_html_file"
}
```

Aquí la clave esta en las líneas START Y END ya que las utilizo para borrar el contenido que existe entre ellas e insertar el nuevo con el comando `sed` por lo que siempre tendre un nuevo y fresco índice listo para ser consumido, este es el `index.html` versión básica donde sucederá toda la magia:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="" />
    <link rel="stylesheet" href="styles/normalize.css" />
    <link rel="stylesheet" href="styles/globals.css" />
    <link rel="stylesheet" href="styles/index.css" />
    <title>s3r0s4pi3ns - Blog</title>
  </head>
  <body>
    <main>
      <section>
        <div class="recent-articles">
          <ul>
            <!-- START -->

            <!-- END -->
          </ul>
        </div>
      </section>
    </main>
  </body>
</html>
```

# Resultado final del script

Uniendo todas las piezas de este lego de aliexpress nos queda algo liviano de 81 lineas que podemos utilizar para empezar a generar contenido como locos, la parte clave son las llamadas a las funciones justo al final del script donde primero generamos nuestros artículos y despues el índice:

```bash
#!/usr/bin/env bash

# REMINDER OUTPUT STYLES FOR SYNTAX HIGHLIGHT pandoc --highlight-style=zenburn ./content/2023/definir-argumentos-script-de-bash.md -s -o readme2.html

GREP_COMMAND='grep' # GNU Linux grep command by default

function is_macOs() {
    [[ "$OSTYPE" == 'darwin'* ]]
}

if is_macOs; then
    GREP_COMMAND='ggrep'
    if ! command -v "$GREP_COMMAND" >/dev/null 2>&1; then
        echo -e "GNU grep is required. Install it with 'brew install grep'" >&2
        exit 1
    fi
fi

CURRENT_DIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
MARKDOWN_FILES=$(find "$CURRENT_DIR/content" -type f -iname '*.md' -print | xargs -0)

function generate_html_from_markdown() {
    local markdown_path=$1
    local base_dir=$(echo "$markdown_path" | sed 's|/content/.*||')
    local templates_path="$base_dir/content/templates"

    local html_path=$(echo "$markdown_path" | sed 's|.*/content/||' | sed 's/\.md$/.html/')
    local output_path="$base_dir/src/blog/$html_path"

    mkdir -p "$(dirname "$output_path")"
    pandoc --read=markdown --table-of-contents --toc-depth=2 --preserve-tabs --standalone --template="$templates_path"/article.html --listings "$markdown_path" --highlight-style=zenburn -o "$output_path"

    echo -e "Generated html from article $(dirname "$markdown_path")"
}

function generate_html_articles() {
    local markdown_files=$1

    while IFS= read -r  markdown_file; do
        generate_html_from_markdown "$markdown_file"
    done <<< "$markdown_files"
}

function generate_blog_index() {
    local articles=$1
    local index_html_file="$CURRENT_DIR/src/index.html"

    # Insert the updated article list
    local html=''
    while IFS= read -r  file; do
        if [ -f "$file" ]; then
            title=$(extract_frontmatter_property "$file" "title")
            date=$(extract_frontmatter_property "$file" "date")
            human_date=$(extract_frontmatter_property "$file" "human_date")
            year=$(echo "$date" | $GREP_COMMAND -o '[0-9]\{4\}')
            path=$(echo "/blog/$year/$(basename "$file")" | sed 's/\.md$//')

            html+="<li><a href=\"$path\">$title</a><span class=\"date\">$human_date</span></li>"
        fi
    done <<< "$articles"

    sed -i '' -e "/<!-- START -->/,/<!-- END -->/c\\
    <!-- START -->\\
    $html\\
    <!-- END -->" "$index_html_file"
}

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

generate_html_articles "$MARKDOWN_FILES"
generate_blog_index "$MARKDOWN_FILES"
```

## Como está el directorio de trabajo después de todo este proceso

Este camino que hemos recorrido ha expandido la estructura de carpetas que teniamos anteriormente, una vez tengas las carpetas `content` y `src` todo lo que queda es añadir html y css para darle un toque mas bonito. He añadido unos estilos css que solo se cargaran en el template de `article.html`, las fuentes de forma local para evitar llamadas externas usando [https://transfonter.org/](https://transfonter.org/).

Despues de lanzar un `bash generate.sh` se queda algo como esto dependiendo del contenido markdown que dispongas claro:

```bash
├── content
│   ├── 2023
│   │   ├── blog-estatico-con-bash.md
│   │   └── definir-argumentos-script-de-bash.md
│   └── templates
│       └── article.html
├── generate.sh
└── src
    ├── assets
    │   ├── fonts
    │   │   ├── Lato-Black.ttf
    │   │   ├── Lato-Black.woff
    │   │   ├── Lato-Black.woff2
    │   │   ├── Lato-BlackItalic.ttf
    │   │   ├── Lato-BlackItalic.woff
    │   │   ├── Lato-BlackItalic.woff2
    │   │   ├── Lato-Bold.ttf
    │   │   ├── Lato-Bold.woff
    │   │   ├── Lato-Bold.woff2
    │   │   ├── Lato-BoldItalic.ttf
    │   │   ├── Lato-BoldItalic.woff
    │   │   ├── Lato-BoldItalic.woff2
    │   │   ├── Lato-Hairline.ttf
    │   │   ├── Lato-Hairline.woff
    │   │   ├── Lato-Hairline.woff2
    │   │   ├── Lato-HairlineItalic.ttf
    │   │   ├── Lato-HairlineItalic.woff
    │   │   ├── Lato-HairlineItalic.woff2
    │   │   ├── Lato-Italic.ttf
    │   │   ├── Lato-Italic.woff
    │   │   ├── Lato-Italic.woff2
    │   │   ├── Lato-Light.ttf
    │   │   ├── Lato-Light.woff
    │   │   ├── Lato-Light.woff2
    │   │   ├── Lato-LightItalic.ttf
    │   │   ├── Lato-LightItalic.woff
    │   │   ├── Lato-LightItalic.woff2
    │   │   ├── Lato-Regular.ttf
    │   │   ├── Lato-Regular.woff
    │   │   └── Lato-Regular.woff2
    │   └── images
    │       └── avatar.png
    ├── blog
    │   └── 2023
    │       ├── blog-estatico-con-bash.html
    │       └── definir-argumentos-script-de-bash.html
    ├── index.html
    └── styles
        ├── article.css
        ├── globals.css
        ├── index.css
```

# Toque gourmet con Docker y Nginx

Para probar este sistemita estaba usando el típico e innigualable `python3 -m http.server` dentro de `src` para servir el contenido estático y ver si estaba funcionando todo como debería.
Date cuenta que el contenido de `src` lo puedes subir a cualquier plataforma como por ejemplo [Github pages](https://pages.github.com/) y ya tendrías tu blog funcionando, cada vez que quieras actualizarlo lanzas el script, vuelves actualizar el repo y listo, solo son archivos estáticos html y css.

Para el toque gourmet especial, he decidido añadir un servidor nginx usando [Docker](https://www.docker.com/) ya que me permite simular mi entorno de producción lo mas parecido posible. Me di cuenta que la url se mostraba con la terminación en **.html** y se ve un poco feo para una web moderna.

Yo creo que es mas agradable ver `/blog/articulo` que `/blog/articulo.html` aunque realmente daría igual, nuestro blog funciona y punto.

## Definiendo nuestra configuración de Nginx

Antes que nada me dispongo a crear la siguiente estructura de carpetas en la raíz del proyecto:

```bash
├── nginx
│   ├── Dockerfile
│   └── config
│       ├── default.conf
│       └── nginx.conf
```

### Dockerfile

Mas sencillo imposible, descargamos la imagen que sea stable en el momento de construir el contenedor y copiamos nuestros archivos de configuración

```dockerfile
FROM nginx:stable

RUN mkdir -p /var/www/html && \
    chown nginx:nginx /var/www/html && \
    chown nginx /var/log/nginx/*.log

COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/default.conf /etc/nginx/conf.d/default.conf
```

### default.conf

Esta es la configuración que utilizara nuestro servidor para un host virtual en específico, veras el dominio `serosapiens.com`, sustituyelo por el que te convenga. De forma local este valor da un poco igual pero tenlo en cuenta a la hora de utilizar un servidor de producción. He añadido algunas reglas de seguridad así como la regla de redirección para archivos .html y conseguir esa url limpia:

```bash
server {
    listen 80;
    listen [::]:80;
    #rewrite ^/(.*) https://serosapiens.com/$1 permanent;
    server_name serosapiens.com www.serosapiens.com;
    root /var/www/html;
    index index.html index.htm;

    error_log  /var/log/nginx/serosapiens.com.error.log;
    access_log /var/log/nginx/serosapiens.com.access.log;

    limit_req_status 429;
    limit_req zone=limitreq burst=2 nodelay;
    limit_conn limitconn 30;

    location / {
        try_files $uri $uri.html $uri/ $uri/index.html @html_extension;

        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header X-Scheme $scheme;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_set_header X-Real-IP $remote_addr;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_next_upstream error timeout http_502 http_503 http_504;
    }

    location @html_extension {
        if (-f $request_filename) {
            rewrite ^/(.*)\.html(\?|$) /$1 permanent;
        }
        return 404;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
        log_not_found off;
        add_header 'Cache-Control' 'no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0';
        expires off;
    }

    gzip on;
    gzip_comp_level 3;
    gzip_types text/plain text/css image/*;

    if ($request_method !~ ^(GET|HEAD)$ )
    {
        return 405;
    }
}

# server {
#     listen 443 ssl http2;
#     listen [::]:443 ssl http2;
#     server_name serosapiens.com www.serosapiens.com;
#     root /var/www/html;
#     index index.html;

#

#     ssl_certificate /root/certs/serosapiens.com/serosapiens.com.crt;
#     ssl_certificate_key /root/certs/serosapiens.com/serosapiens.com.key;
#     ssl_dhparam /root/certs/serosapiens.com/dhparam4096.pem;
#     ssl_prefer_server_ciphers on;
#     ssl_session_cache shared:SSL:10m;
#     ssl_session_timeout 10m;
#     #ssl_stapling on;
#     #ssl_stapling_verify on;
#     #ssl_trusted_certificate /root/certs/serosapiens.com/serosapiens.com.crt;

#     location / {
#         try_files $uri $uri/ =404;
#         proxy_set_header Host $http_host;
#         proxy_set_header X-Real-IP $remote_addr;
#         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#         proxy_set_header X-Forwarded-Proto $scheme;

# 	     gzip_static on;
#     }

#   if ($request_method !~ ^(GET|HEAD)$ )
#   {
#     return 405;
#   }
# }
```

### nginx.conf

El archivo de configuración global para nginx, los parámetros aquí descritos se aplican a todos los hosts virtuales que hayamos definido

```bash
user nginx;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
	worker_connections 768;
	# multi_accept on;
}

http {

	##
	# Basic Settings
	##

	#proxy_cache_path /var/www/serosapiens.com/cache/ keys_zone=one:1m max_size=500m inactive=24h use_temp_path=off;
	sendfile on;
	tcp_nopush on;
	types_hash_max_size 2048;
	server_tokens off;
	underscores_in_headers on;

	limit_req_zone $binary_remote_addr$uri zone=limitreq:10m rate=1r/s;
	limit_conn_zone $binary_remote_addr zone=limitconn:10m;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";
    add_header Content-Security-Policy "default-src 'self'; upgrade-insecure-requests;";
    add_header X-Frame-Options "DENY";
    add_header Referrer-Policy strict-origin-when-cross-origin;
    #add_header Strict-Transport-Security 'max-age=31536000; includeSubDomains; preload';

	proxy_hide_header X-Powered-By;
	#fastcgi_hide_header X-Powered-By;

	keepalive_timeout 75;
    # server_names_hash_bucket_size 64;
	# server_name_in_redirect off;

	include /etc/nginx/mime.types;
	default_type application/octet-stream;

	##
	# SSL Settings
	##

	ssl_protocols TLSv1.1 TLSv1.2; #TLSv1.3;  Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;
    ssl_ciphers "EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH+aRSA+RC4 EECDH EDH+aRSA RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS !MEDIUM !RC4";
	ssl_session_cache shared:SSL:50m;
	ssl_session_timeout 5m;
	##
	# Logging Settings
	##

	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;

	##
	# Gzip Settings
	##

 	gzip                on;
    gzip_disable        "msie6";
    gzip_vary           on;
    gunzip              on;
    gzip_proxied        any;
    gzip_comp_level     9;
    gzip_buffers        16 8k;
    gzip_http_version   1.1;
    gzip_min_length     1000;
    gzip_types          text/plain text/css application/json application/x-javascript application/javascript text/xml application/xml application/xml+rss text/javascript;
	##
	# Virtual Host Configs
	##

	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;

    ##Buffer policy
    client_body_buffer_size 1K;
    client_header_buffer_size 1k;
    client_max_body_size 1k;
    large_client_header_buffers 2 1k;
    ##End buffer policy

}

```

### docker-compose.yml

Realmente este no hace falta pero para mi trabajar con `docker-compose` se me hace más facil y me permite organizar los contendores de una forma mas fácil e intuituiva:

```yaml
version: "3.9"

networks:
  server-network:
    driver: bridge

services:
  nginx:
    build:
      context: ./nginx
      dockerfile: Dockerfile
    container_name: "nginx-blog-server"
    ports:
      - 8888:80
    restart: unless-stopped
    volumes:
      - ./src:/var/www/html
```

## Construyendo y levantando nuestro contenedor de nginx

Una vez hayas levantado la historia esta, visita el puerto que hayas expuesto para el servicio nginx en el docker-compose que en mi caso es el **8888** y deberías ver el contenido de `src` en tu navegador web de confianza servido por un maravilloso nginx de ultima generacion.

```bash
docker-compose up -d --build

# Vemos si esta todo up
docker-compose ps

NAME                IMAGE                   COMMAND                  SERVICE             CREATED             STATUS              PORTS
nginx-blog-server   pandoc-showcase-nginx   "/docker-entrypoint.…"   nginx               56 minutes ago      Up 56 minutes       0.0.0.0:8888->80/tcp


# Leemos el log de nginx a ver si no ha habido algun error en el proceso
docker-compose logs nginx

nginx-blog-server  | /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
nginx-blog-server  | /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
nginx-blog-server  | /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
nginx-blog-server  | 10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
nginx-blog-server  | 10-listen-on-ipv6-by-default.sh: info: /etc/nginx/conf.d/default.conf differs from the packaged version
nginx-blog-server  | /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
nginx-blog-server  | /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
nginx-blog-server  | /docker-entrypoint.sh: Configuration complete; ready for start up
```

# Imagen docker de pandoc

Por circunstancias de la vida, la imagen de Docker oficial para pandoc a día de hoy no tiene soporte para arm64 y tengo que instalarlo en mi pc pero si tu tienes una arquitectura amd64 o x86 puedes aplicar este bloque a tu docker-compose y utilizarlo como servicio sin tener que ensuciar tu sistema:

```yaml
version: "3.9"

networks:
  server-network:
    driver: bridge

services:
  nginx:
    build:
      context: ./nginx
      dockerfile: Dockerfile
    container_name: "nginx-blog-server"
    ports:
      - 8888:80
    restart: unless-stopped
    volumes:
      - ./src:/var/www/html

    pandoc:
      container_name: pandoc-generator
      image: pandoc/core:3.1.1.0
      volumes:
        - ./content:/content
        - ./src:/src
```

El único cambio que debemos hacer es en el script `generate.sh` donde en lugar de llamar al comando pandoc, lo ejecutamos desde el contenedor de docker:

```bash
docker-compose exec <service_name> <command>

docker-compose exec pandoc --read=markdown --table-of-contents --toc-depth=2 --preserve-tabs --standalone --template="$templates_path"/article.html --listings "$markdown_path" --highlight-style=zenburn -o "$output_path"
```

# Conclusiones finales

Como borrador inicial me ha parecido suficiente para lanzar mi contenido al mundo a través del formato blog, como podemos comprobar, si tenemos los conocimientos adecuados podemos tener un poco de diversión creando nuestras propias movidas aunque reinventemos la rueda de nuevo. Mi intención era puramente individual y no tenía pensado crearlo como una herramienta que pueda utilizarse a gran escala pero aquí algunas mejoras que podríamos implementarle:

- Archivo de configuración .yml para definir carpetas, templates, etc
- i18n para el soporte de múltiples idiomas (traducciones automáticas en el proceso de generación)
- Makefile para abstraer ciertas operaciones (make articles, make template, bla bla...)

Seguro que hay muchas cosas mas para hacerle, como todo en esta vida, el cambio es la unica constante y es posible que en el paso de este año haya añadido algunas mejoras a este pequeño generador de contenido estático y tenga que crear un nuevo post.

Si has llegado hasta aquí vaya puto valiente eres, gracias.
