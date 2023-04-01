---
author: s3r0s4pi3ns
date: 2023-03-01
datetime: 2023-03-01T00:00:00.000Z
description: Si tenías la curiosidad de como se crean las herramientas de bash que te permiten pasar como parámetro opciones específicas este es tu lugar
title: Definir argumentos en un script de bash
---

# El primer markdown bro

[Link to the moon](https://moon.es)

## Segundo heading

- Listita
- Comprita
- Pene

### Un poco de codigo

```bash
while getopts ":h:" arg; do
    case $arg in
        h | *)
            echo "HELP ME!"
        ;;
    esac
done
```
