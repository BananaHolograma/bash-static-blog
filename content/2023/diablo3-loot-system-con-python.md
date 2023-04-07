---
author: s3r0s4pi3ns
date: 2023-04-07
human_date: 07 Abril, 2023
description: Implementamos una loot table y hacemos una aproximación a traves de código de como se podría construir el sistema que utiliza diablo 3 a la hora de lootear equipamiento y objetos.
title: Diablo 3 loot system con python
path: blog/2023/diablo3-loot-system-con-python
---

La metodología que uso para aprender un nuevo lenguaje es hacer cosas con el, suena simple pero no lo es del todo. Este metodo no va a funcionar con aquellas personas que esten empezando en el mundo de la programación sino para aquell@s que ya saben programar y quieren pivotar a otro lenguaje, probar otros paradigmas, etc.

Podría embaucarme en el eterno viaje de tutoriales en video, articulos de blog, documentación y un largo coñazo mas pero prefiero tener una idea en mente y proyectarla con el nuevo lenguaje e ir aprendiendo la sintaxis y conceptos sobre la marcha, tan rudimentario como efectivo.

Después de llevar largas horas farmeando en diablo para hacerme las builds de la temporada 28 para todos los personajes, me apetecía simular un sistema de loot parecido al de diablo a niveles bastante reduccionistas claro está, el de diablo 3 tiene que conllevar mucha mas complejidad pero para empezar me vale.

Algo muy distinto al tipico TODO list que ya aburre infinito.

## El aprendizaje no-lineal

A mi personalmente no me funciona el aprendizaje lineal en el que te lees los capitulos por orden númerico ascendente, prefiero hacer una pequeña mezcla de teoria-práctica en espacios cortos de tiempo mientras voy hilvanando los conceptos para conseguir un mapa mental adecuado, por ejemplo, leo el concepto de diccionario en python y al momento me pongo a teclear para crear memoria muscular e interiorizar esa teoría creando e interaccionando con un diccionario.

Hago un enfoque similar para este proyecto de crear el sistema de loot en python, voy desglosando las funcionalidades que quiero ir aplicando antes de escribir código, un poco de música y a enfrentarme con lo desconocido.

## El objetivo

Vamos a poner en contexto con las características principales que dispone el sistema de loot enumerando los items y los condicionantes que lo rodean:

### Equipamiento

Tener claro el equipamiento que puede disponer nuestro personaje nos acercará a una mayor precision y realismo a la hora de crear nuestras loot tables:

- Yelmo
- Peto
- Hombros
- Brazos
- Cinto
- Piernas
- pies
- 2 Huecos para anillos
- 1 Hueco para amuleto
- Arma 2 manos
- Arma 1 mano
- Soporte 1 mano, Escudo, orbe, mascara de vodoo... _(si utilizas arma 1 mano puedes utilizar la otra para un item de este tipo)_

Esto influye a la hora de seleccionar un rango amplio de objetos a la hora de lootear por lo que da una experiencia mas variada

## Rareza del objeto

La rareza del objeto se divide en:
Normal, Magico, Raro, Legendario, Legendario ancestral, Legendario ancestral primigenio, Conjunto _(ancestral, primigenio)_

- Las piezas de conjunto tienen efectos adicionales si se equipan varias de las piezas.
- El equipamiento tiene su propio nivel que va acorde con el personaje, esto quiere decir que las estadísticas generadas del objeto tendran esta limitación y habra que formar un calculo para ello.
- Piezas de conjunto, ancestrales, primigenios solo lootean a partir del nivel 70 de personaje, el equipamiento que se lootea siempre debe ser menor o igual que el actual nivel del personaje _(si eres nivel 40, solo te aparecen raros o legendarios de <= 40)_
- Los objetos de tipo ancestral o primigenio solo se podran acceder si se jugan fallas de nivel superior +70 en dificultades superiores a tormento I
- Si en el loot aparece un legendario/conjunto, hay una posibilidad 1 entre x _(habra que definir x)_ de que este sea ancestral o primigenio los cuales pueden ofrecer estadisticas mas altas.

## Exclusividad de equipo

Hay equipo global que puede usar cualquier personaje pero su generación será diferente, si el atributo principal es inteligencia, estos objetos vendran con propiedades mágicas acorde a este atributo o habilidades que solo la clase puede utilizar.

Las piezas de conjunto se desbloquean en base a la clase del personaje que estamos utilizando, si usamos un mago solo lootearemos sets equipamiento para esta clase en particular.
**_Se que hay veces que una pieza de conjunto de otra clase se lootea pero por simplificar la lógica no voy a implementar esta característica en el sistema de loot_**

## Nivel y dificultad

El nivel y la dificultad en la que se está jugando influye en los porcentajes de loot para los objetos legendarios y de conjunto.

## Rango de estadisticas

El equipamiento se lootea con unas estadísticas aleatorios siempre en base a unas reglas básicas que ese objeto puede admitir y pueden ser por ejemplo, entre 700 y 1000 de daño, 4 propiedades magicas aleatorias, inteligencia del personaje \* 0.4 + (400 ~700) y un largo etc.

## Origen del loot

Este apartado se refiere a si se ha abierto un cofre, matado un enemigo, completado un evento. Segun el origen, el proceso de loot recibirá ciertas reglas y calculos especiales para ese loot en especifico. Usaremos claves en el formato `origen:tipo` que seran una via de acceso a nuestro pool y su forma de generarse.

**Ejemplos:** _*chest.normal, greater_rift.killed_guardian, chest.diabolic*_
