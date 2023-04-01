# ¿Se puede crear un sitio tipo blog usando la herramienta pandoc y un par de comandos de bash?

Quizas si, voy a enumerar un par de features minimalistas. Digo minimalista porque es el publico objetivo, algo liviano fuera de todo tipo de artificios en el que solo se enfoque en una cosa, mostrar contenido.

- Crear un directorio base de carpetas donde se movera el contenido al directorio source
- Multilenguaje (carpetas con el locale tipo es,en...)
- Metadatos en formato .yml
- Metadatos para categorizar articulos
- Makefile para abstraer las operaciones en un lenguaje humano
- Template minimalista con html y css, nada de frameworks

Requerimentos: pandoc yq(parseo yaml como jq para json) bash v4+
