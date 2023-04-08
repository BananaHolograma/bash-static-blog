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

Sin grandes complicaciones, quiero tener la posibilidad de ejecutar **n simulaciones** y me devuelva la información de las cantidades looteadas para ver si los porcentajes de drop se asocian a un buen gameplay donde se premia la constancia.
Vamos a ponernos en contexto con las características principales que dispone el sistema de loot enumerando los items y los condicionantes que lo rodean:

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
- Soporte 1 mano (Off-hand), Escudo, orbe, mascara de vodoo... _(si utilizas arma 1 mano puedes utilizar la otra para un item de este tipo)_

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

# Trazando un estado inicial para el proyecto

Como cualquier inicio necesitamos un punto de partida para ir pivotando y desarrollando sobre el para ver hasta donde podemos llegar. Teniendo las reglas basicas anteriores en mente vamos a crear nuestras primeras carpetas y archivos:

```bash
.
├── character.py
├── data
│   ├── equipment
│   │   ├── character_set_equipment.json
│   │   ├── legendary_equipment.json
│   │   ├── magic_equipment.json
│   │   ├── normal_equipment.json
│   │   └── rare_equipment.json
│   ├── gems
│   │   └── gems.json
│   └── loot_table.json
├── loot.py
├── requirements.txt
└── scrapper
    └── equipment.py
```

- `character.py` será un modulo con la `clase Character` que representara un personaje de Diablo III y contendrá datos básicos como el nivel y clase.
- `data` esta dividido en `equipment` donde volcaremos los items que usaremos en el loot segun el tipo de rareza y `gems` donde tendremos los tipos de gemas disponibles en el loot
- `loot_table.json` es nuestra tabla maestra y definirá el template de cada tipo de origen como pueden ser cofre, enemigo, mapa...
- `scrapper` Con esta funcionalidad extraremos los items oficiales del juego desde la página oficial, he decidido este camino porque su API oficial es bastante mala de consumir

## Clase Character en character.py

Para modularizar el código vamos a empezar separando esta clase ya que `loot.py` va a crecer como el pene de un adolescente salido estudiando matemáticas a las 17:00 de la tarde:

```python
from random import randint, choice
from typing import Annotated

# CHARACTER CLASSES
BARBARIAN = 'barbarian'
WIZARD = 'wizard'
NECROMANCER = 'necromancer'
WITCH_DOCTOR = 'witch doctor'
DEMON_HUNTER = 'demon hunter'
CRUSADER = 'crusader'
MONK = 'monk'

GAME_CLASSES = [
    BARBARIAN, WIZARD, NECROMANCER, WITCH_DOCTOR, DEMON_HUNTER, CRUSADER,
    MONK
]

class Character:
    def __init__(self, level: int = None, character_class: str = None) -> None:
        self.level: int = self._ensure_level_is_on_valid_range(
            level) if level is not None else randint(1, 70)

        self.character_class: str = self._ensure_character_class_is_implemented(
            character_class or choice(GAME_CLASSES))

        self.gold: float = 0

    def _ensure_level_is_on_valid_range(self, value: Annotated[int, lambda x: 1 <= x <= 70]) -> int:
        if (value < 1 or value > 70):
            raise ValueError(
                f"The level {value} is not allowed, the system can handle levels between 1 and 70"
            )
        return value

    def _ensure_character_class_is_implemented(self, value: str) -> str:
        if value.lower() not in GAME_CLASSES:
            raise ValueError(
                f"The character class {value} is not implemented on diablo 3")

        return value
```

Una clase sencilla con par de validaciones para nuestros argumentos y nos va de lujo para empezar, de momento crear clases en python me resulta un poco feo con respecto a otros lenguajes como PHP o C#

## Loot table maestra solo con origen cofre

Como no quiero centrarme en los detalles al empezar un proyecto, prefiero tener una base que pueda ser extensible a lo largo del mismo y solo definir de momento, que el origen del loot sea la apertura de un cofre. Como es extensible y todos usarán la misma estructura, añadir una nueva key con otro origen como por ejemplo matar al jefe de una falla es bastante trivial:

La estructura básica que quiero llevar a cabo es la siguiente:

```json
  "<ORIGEN>": {
    "<TIPO>": {
      "rolls": {
        "min": 1,
        "max": 3
      },
      "entries": [], # Se inicializa vacio ya que nuestro sistema de loot trabaja de forma dinamica con la reglas
      "rules": {
        "<type_of_item>": {
          "amount": 10,
          "max_total_weight": 60
        },
      }
    }
  }
```

A traves de la clave `roll` estamos diciendole cuantas veces generar el loot a la hora de abrir un cofe para añadir las `entries` correspondientes, es decir, de forma aleatoria si salen 2 rolls, se aplicara la generacion de items desde las plantillas de equipamiento 2 veces.

En `rules` esta la clave ya que crearemos una funcion dinámica mas adelante que lea estos valores los cuales usara para obtener los items de una rareza en particular, esto nos prepara el json para que sea extensible y no tengamos que modificar nuestro código base.

El peso es clave, lo explicaré mas adelante pero determina si un item tiene mas prioridad _(peso)_ que otro para salir a la hora de realizar un roll, este `max_total_weight` determina que si la cantidad es 10, la suma de los weight de cada item obtenido no podra superar un total de 60 por lo que habria que generarlo de nuevo hasta que no supere el maximo _(no suele pasar pero por mantener un control)_

Prometo que lo entenderás cuando apliquemos el calculo, aquí te dejo nuestro `loot_table.json` final que define las reglas de apertura de cofres:

```json
{
  "CHEST": {
    "NORMAL": {
      "rolls": {
        "min": 1,
        "max": 3
      },
      "entries": [],
      "rules": {
        "normal_equipment": {
          "amount": 10,
          "max_total_weight": 60
        },
        "rare_equipment": {
          "amount": 5,
          "max_total_weight": 45
        }
      }
    },
    "BEAMING": {
      "rolls": {
        "min": 3,
        "max": 6
      },
      "entries": [],
      "rules": {
        "normal_equipment": {
          "amount": 3,
          "max_total_weight": 15
        },
        "magic_equipment": {
          "amount": 15,
          "max_total_weight": 50
        },
        "rare_equipment": {
          "amount": 5,
          "max_total_weight": 30
        },
        "legendary_equipment": {
          "amount": 3,
          "max_total_weight": 15
        },
        "character_set_equipment": {
          "amount": 1,
          "max_total_weight": 5
        }
      }
    },
    "DIABOLIC": {
      "rolls": {
        "min": 6,
        "max": 10
      },
      "entries": [],
      "rules": {
        "magic_equipment": {
          "amount": 10,
          "max_total_weight": 30
        },
        "rare_equipment": {
          "amount": 20,
          "max_total_weight": 75
        },
        "legendary_equipment": {
          "amount": 10,
          "max_total_weight": 55
        },
        "character_set_equipment": {
          "amount": 5,
          "max_total_weight": 20
        }
      }
    }
  }
}
```

In crescendo, mientras mas valioso el cofre, mas valioso los items que pueden salir de el, así mantenemos un balance aunque esto como ya veremos en el código final es lo mas díficil del sistema, nunca llueve a gusto de todos.
