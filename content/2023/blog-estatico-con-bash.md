---
author: s3r0s4pi3ns
date: 2023-04-04
human_date: 04 Abril, 2023
description: Tu blog estatico con solo 80 lineas de bash, aprende a no depender de ningun CMS a la hora de crear tu contenido
title: Construyendo un blog estatico con bash
path: blog/2023/construyendo-un-blog-estatico-con-bash
---

# La idea inicial

Es 2023, mientras escribo este artículo semidesnudo, en el mundo existen multitud de herramientas para construir sitios estáticos como [Hugo](https://gohugo.io/), [Jekyll](https://jekyllrb.com/) o [Astro](https://astro.build/) que hacen un trabajo excelente.
El problema es mi intención minimalista inicial a la hora de querer construir mi blog y es que estas herramientas o frameworks generan un overload de información que me resulta incómoda de manejar para lo que yo realmente quiero.

Llegué a crear un blog con estas 3 herramientas que he mencionado usando un theme fancy super responsive pero algo me decía en mi pechito

> Tío eres programador, montate algo tu mismo, reinventa la rueda cabron

Yo soy feliz con una estructura simple y repetitiva que me permita generar contenido en markdown y transformarlo en html usable. Por eso decidí montarme mi blog con bash y la ayuda del conversor [Pandoc](https://pandoc.org/) para darle un toque web de los años 90 donde todo eran hipervínculos y punto pelota.

El resultado final es este blog que estás leyendo ahora mismo.

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
    pandoc --read=markdown --table-of-contents --toc-depth=2 --preserve-tabs --standalone --template="$templates_path"/article.html --listings "$markdown_path" --highlight-style=espresso -o "$output_path"

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

De forma natural la siguiente función que visualizamos es la de iterarar sobre nuestra lista de archivos markdown que existan en la carpeta `content` y utilizar esta función muy sencilla:

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
