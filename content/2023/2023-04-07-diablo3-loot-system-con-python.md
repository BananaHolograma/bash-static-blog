---
author: s3r0s4pi3ns
date: 2023-04-07
human_date: 07 Abril, 2023
description: Implementamos una loot table y hacemos una aproximación a traves de código de como se podría construir el sistema que utiliza diablo 3 a la hora de lootear equipamiento y objetos.
title: Diablo 3 loot system con python
path: blog/2023/diablo3-loot-system-con-python
---

- [Aprendiendo un nuevo lenguaje](#aprendiendo-un-nuevo-lenguaje)
- [El aprendizaje no-lineal](#el-aprendizaje-no-lineal)
  - [Enumerando las reglas para alcanzar nuestro objetivo](#enumerando-las-reglas-para-alcanzar-nuestro-objetivo)
    - [Equipamiento](#equipamiento)
    - [Rareza del objeto](#rareza-del-objeto)
    - [Exclusividad de equipo](#exclusividad-de-equipo)
    - [Nivel y dificultad](#nivel-y-dificultad)
    - [Rango de estadisticas](#rango-de-estadisticas)
    - [Origen del loot](#origen-del-loot)
- [Trazando un estado inicial para el proyecto](#trazando-un-estado-inicial-para-el-proyecto)
  - [Clase Character en character.py](#clase-character-en-characterpy)
  - [Loot table maestra solo con origen cofre](#loot-table-maestra-solo-con-origen-cofre)
- [Sentando las bases en loot.py](#sentando-las-bases-en-lootpy)
  - [Cargando items en el pool seleccionado](#cargando-items-en-el-pool-seleccionado)
  - [Seleccionando items en base a su peso](#seleccionando-items-en-base-a-su-peso)
    - [Creando la función que aplica el calculo de weight](#creando-la-función-que-aplica-el-calculo-de-weight)
  - [Cálculo del drop para cada item](#cálculo-del-drop-para-cada-item)

# Aprendiendo un nuevo lenguaje

La metodología que uso para aprender un nuevo lenguaje es hacer cosas con el, suena simple pero no lo es del todo. Este metodo no va a funcionar con aquellas personas que esten empezando en el mundo de la programación sino para aquell@s que ya saben programar y quieren pivotar a otro lenguaje, probar otros paradigmas, etc.

Podría embaucarme en el eterno viaje de tutoriales en video, articulos de blog, documentación y un largo coñazo mas pero prefiero tener una idea en mente y proyectarla con el nuevo lenguaje e ir aprendiendo la sintaxis y conceptos sobre la marcha, tan rudimentario como efectivo.

Después de llevar largas horas farmeando en diablo para hacerme las builds de la temporada 28 para todos los personajes, me apetecía simular un sistema de loot parecido al de diablo a niveles bastante reduccionistas claro está, el de diablo 3 tiene que conllevar mucha mas complejidad pero para empezar me vale.

Algo muy distinto al tipico TODO list que ya aburre infinito.

**_Puedes acceder al repositorio completo aquí: [https://github.com/s3r0s4pi3ns/python-diablo3-loot-system](https://github.com/s3r0s4pi3ns/python-diablo3-loot-system)_**

# El aprendizaje no-lineal

A mi personalmente no me funciona el aprendizaje lineal en el que te lees los capitulos por orden númerico ascendente, prefiero hacer una pequeña mezcla de teoria-práctica en espacios cortos de tiempo mientras voy hilvanando los conceptos para conseguir un mapa mental adecuado, por ejemplo, leo el concepto de diccionario en python y al momento me pongo a teclear para crear memoria muscular e interiorizar esa teoría creando e interaccionando con un diccionario.

Hago un enfoque similar para este proyecto de crear el sistema de loot en python, voy desglosando las funcionalidades que quiero ir aplicando antes de escribir código, un poco de música y a enfrentarme con lo desconocido.

## Enumerando las reglas para alcanzar nuestro objetivo

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
- Soporte 1 mano _(Off-hand)_, Escudo, orbe, mascara de vodoo... _(si utilizas arma 1 mano puedes utilizar la otra para un item de este tipo)_

Esto influye a la hora de seleccionar un rango amplio de objetos a la hora de lootear por lo que da una experiencia mas variada

### Rareza del objeto

La rareza del objeto se divide en:
Normal, Magico, Raro, Legendario, Legendario ancestral, Legendario ancestral primigenio, Conjunto _(ancestral, primigenio)_

- Las piezas de conjunto tienen efectos adicionales si se equipan varias de las piezas.
- El equipamiento tiene su propio nivel que va acorde con el personaje, esto quiere decir que las estadísticas generadas del objeto tendran esta limitación y habra que formar un calculo para ello.
- Piezas de conjunto, ancestrales, primigenios solo lootean a partir del nivel 70 de personaje, el equipamiento que se lootea siempre debe ser menor o igual que el actual nivel del personaje _(si eres nivel 40, solo te aparecen raros o legendarios de <= 40)_
- Los objetos de tipo ancestral o primigenio solo se podran acceder si se jugan fallas de nivel superior +70 en dificultades superiores a tormento I
- Si en el loot aparece un legendario/conjunto, hay una posibilidad 1 entre x _(habra que definir x)_ de que este sea ancestral o primigenio los cuales pueden ofrecer estadisticas mas altas.

### Exclusividad de equipo

Hay equipo global que puede usar cualquier personaje pero su generación será diferente, si el atributo principal es inteligencia, estos objetos vendran con propiedades mágicas acorde a este atributo o habilidades que solo la clase puede utilizar.

Las piezas de conjunto se desbloquean en base a la clase del personaje que estamos utilizando, si usamos un mago solo lootearemos sets equipamiento para esta clase en particular.
**_Se que hay veces que una pieza de conjunto de otra clase se lootea pero por simplificar la lógica no voy a implementar esta característica en el sistema de loot_**

### Nivel y dificultad

El nivel y la dificultad en la que se está jugando influye en los porcentajes de loot para los objetos legendarios y de conjunto.

### Rango de estadisticas

El equipamiento se lootea con unas estadísticas aleatorios siempre en base a unas reglas básicas que ese objeto puede admitir y pueden ser por ejemplo, entre 700 y 1000 de daño, 4 propiedades magicas aleatorias, inteligencia del personaje \* 0.4 + (400 ~700) y un largo etc.

### Origen del loot

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

Con la clave `rules` y su contenido crearemos una funcion dinámica mas adelante que lea estos valores los cuales usara para obtener los items de una rareza en particular, esto nos prepara el json para que sea extensible y no tengamos que modificar nuestro código base.

El peso es clave, lo explicaré mas adelante pero determina si un item tiene mas prioridad _(peso)_ que otro para salir a la hora de realizar un roll, este `max_total_weight` determina que si la cantidad es 10, la suma de los weight de cada item obtenido no podra superar un total de 60 por lo que habria que generarlo de nuevo hasta que no supere el maximo _(no suele pasar pero por mantener un control)_

Prometo que lo entenderás cuando apliquemos el calculo, aquí te dejo nuestro `loot_table.json` final que define las reglas de apertura de cofres:

```json
// loot_table.json
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

In crescendo, mientras mas valioso el cofre, mas valioso los items que pueden salir de el, así mantenemos un balance aunque esto, como ya veremos en el código final, es lo mas díficil del sistema ya nunca llueve a gusto de todos y alcanzar un meta estable es casi imposible.

# Sentando las bases en loot.py

Vamos a empezar definiendo bases sencillas en el core de nuestro sistema, vamos a precargar nuestra tabla maestra para usarla a través de nuestras funciones.

_Siempre tengo en cuenta que el fichero `loot.py` va a estar en la raiz del proyecto a la hora de definir los paths cuando se trata de manejar archivos_

```python
import json
from typing import List, Dict, Annotated
from random import randint, random, randrange, shuffle, choice
from character import Character, GAME_CLASSES

with open('data/loot_table.json', 'r') as loot_table:
    AVAILABLE_POOLS = json.load(loot_table)

def start_loot(character: Character, origin: str) -> List[Dict]:
    selected_pool: dict = build_pool(character, origin)

    return [{}]


def build_pool(character: Character, origin: str) -> dict:
    pool_template: dict = AVAILABLE_POOLS.copy()
    translated_origin: list[str] = origin.upper().split('.')

    for key in translated_origin:
        if key in pool_template:
            pool_template = pool_template[key]
        else:
            raise KeyError(
                f"The access key {key} does not exists in the available pools for the value {origin}")

    return pool_template

```

De momento tenemos precargado nuestra tabla maestra en la variable `AVAILABLE_POOLS` y 2 funciones principales que se encargan de obtener el pool adecuado segun el origen que queremos simular y el personaje.

A menos que explicitamente quiera mutar el pool, vamos a manejar una copia para no alterar el original. Como la variable origin que recibiremos vendra en el formato `chest.normal` o `chest.diabolic` tenemos que aplicar una transformación para convertirlo en una lista tipo `['CHEST', 'NORMAL']` lo que nos permitira acceder al pool de una forma dinámica:

```python
    pool_template: dict = AVAILABLE_POOLS.copy()
    translated_origin: list[str] = origin.upper().split('.')
```

Gracias a esto, podemos usar el siguiente bucle for para seleccionar el pool:

```python
    for key in translated_origin:
        if key in pool_template:
            pool_template = pool_template[key]
        else:
            raise KeyError(
                f"The access key {key} does not exists in the available pools for the value {origin}")

    return pool_template
```

Para un valor de `chest.normal` deberia devolvernos el diccionario:

```json
{
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
```

## Cargando items en el pool seleccionado

El código anterior nos proporciona el template para el origen seleccionado pero no tenemos cargada ninguna entry donde se alojaran los items que se pueden lootear, vamos a crear una nueva función para que cargue las entries según las reglas definidas en el pool:

```python
# Antes vamos a definir el diccionario GAME_ITEMS muy simple de forma global en el script
GAME_ITEMS: dict = {
  "NORMAL_EQUIPMENT": [
       {
        "quantity": 1,
        "name": "Star Helm",
        "type": "armor:helm",
        "rarity": "normal",
        "stats_value_range": { "min": 21, "max": 24 },
        "weight": 4.05,
        "drop": { "chance": 0.46881700267124105, "max_chance": 0.5625804032054893 }
      },
      {
        "quantity": 1,
        "name": "Leather Hood",
        "type": "armor:helm",
        "rarity": "normal",
        "stats_value_range": { "min": 21, "max": 24 },
        "weight": 6.44,
        "drop": { "chance": 0.5196764901634326, "max_chance": 0.6236117881961192 }
      },
  ],

  "RARE_EQUIPMENT": ...
}
```

La estructura que he decidido para los items del juego es esta, ya empezamos a ver porcentajes de drop y el famoso valor weight que define el peso que tendra este item en la lista completa. Estos valores los genero en `scrapper.py` pero de momento no te preocupes y definamos el diccionario manualmente para una vez confirmada nuestra lógica podamos usar archivos .json que nos ayudaran a este propósito.

La siguiente función es la que utilizara este diccionario `GAME_ITEMS` y nos ayudará a cargar usando las claves de `rules` en el pool que hemos obtenido anteriormente y que casualmente son la rareza del equipamiento.

He decidido cargarlas directamente en el pool en lugar de devolver la lista y asignarla despues para evitarme acciones adicionales ademas de que el pool que estamos pasando como parámetro es una copia del original:

```python
def load_item_entries_based_on_pool_rules(selected_pool: dict) -> List[Dict]:
    key: str
    for key in selected_pool['rules'].keys():
        equipment_rarity = key.strip().upper()

        if equipment_rarity in GAME_ITEMS:
            items = GAME_ITEMS[equipment_rarity].copy()
            amount_rule = selected_pool['rules'][key]['amount']
            shuffle(items)

            selected_pool['entries'] += items[:amount_rule]

    return selected_pool
```

Esto es el archivo `loot.py` que hemos conseguido desarrollar hasta ahora:

```python
# loot.py
from json import load

with open('data/loot_table.json', 'r') as loot_table:
    AVAILABLE_POOLS = json.load(loot_table)

GAME_ITEMS: dict = {
  "LEGENDARY_EQUIPMENT": [
     {
        "quantity": 1,
        "name": "Boots of Disregard",
        "type": "armor:boots",
        "rarity": "legendary",
        "stats_value_range": { "min": 30, "max": 34 },
        "weight": 1.34,
        "drop": { "chance": 0.06373878661948736, "max_chance": 0.06692572595046173 }
      },
  ],

  "RARE_EQUIPMENT": []
}

def start_loot(character: Character, origin: str) -> List[Dict]:
    selected_pool: dict = build_pool(character, origin)

    return [{}]

def build_pool(character: Character, origin: str) -> dict:
    pool_template: dict = AVAILABLE_POOLS.copy()
    translated_origin: list[str] = origin.upper().split('.')

    for key in translated_origin:
        if key in pool_template:
            pool_template = pool_template[key]
        else:
            raise KeyError(
                f"The access key {key} does not exists in the available pools for the value {origin}")

    return load_item_entries_based_on_pool_rules(pool_template)

def load_item_entries_based_on_pool_rules(selected_pool: dict) -> List[Dict]:
    key: str
    for key in selected_pool['rules'].keys():
        equipment_rarity = key.strip().upper()

        if equipment_rarity in GAME_ITEMS:
            items = GAME_ITEMS[equipment_rarity].copy()
            amount_rule = selected_pool['rules'][key]['amount']
            shuffle(items)

            selected_pool['entries'] += items[:amount_rule]

    return selected_pool

```

## Seleccionando items en base a su peso

Una vez hemos obtenido una cantidad aleatorio del inventario global para el pool debemos aplicar el calculo del peso para ver que items de esa lista se extraen para su posterior calculo del drop.

Te preguntarás porque no extraemos directamente los items con el calculo del weight, te explico el calculo:

```python
total_weight = sum([entry['weight'] for entry in pool['entries']])

# Obtenenmos la probabilidad de un item individual en base al peso total de la lista en la que se encuentra
probability = item['weight'] / total_weight

# Para luego aplicar el calculo de probabilidad y determinar si aparece
if random() <= probability:
    # //...

```

Si la lista de items normales es grande, pongamos que obtenemos un total_weight de 500, para un item individual la probabilidad se reduciria muchisimo y no saldría casí nunca incluso tratándose de un objeto normal en el juego con un drop alto:

```python
probability = 2.54 / 500

0.00508
```

Si en cambio lo aplicamos con los items extraidos aleatoriamente de nuestra funcion llamada previamente `load_item_entries_based_on_pool_rules` en la que para un pool de `chest.normal` extraemos 10 items de rareza normal donde el total_weight resultante es 25 tendriamos un 18% de probabilidades de que aparezca para un item individual con peso 4.5:

```python
probability = 4.5 / 25

0.18
```

### Creando la función que aplica el calculo de weight

Inmediatamente despues de seleccionar el pool, debemos aplicar el calculo del weight para ver que items serán candidatos para posteriormente aplicar el drop chance.

Para darle dinamismo al cálculo entra en juego **el número de rolls que puede aparecer en el origen seleccionado** por lo que debemos pasarle como parámetro el pool seleccionado a la función y no solo la parte de 'entries'.

```python
def choose_items_with_weight_calculation(pool: Dict) -> List[Dict]:
    number_of_rolls = randint(pool['rolls']['min'], pool['rolls']['max']) + 1
    total_weight = sum([entry['weight'] for entry in pool['entries']])
    result = []

    for _ in range(number_of_rolls):
        for item in pool['entries']:
            probability = item['weight'] / total_weight

            # ¿quitar de la lista una vez añadido para evitar duplicados, o generar duplicados a proposito?
            if random() <= probability:
                result.append(item)

    return result

```

Así se nos va quedando la función `start_loot`:

```python

def start_loot(character: Character, origin: str) -> List[Dict]:
    selected_pool: dict = build_pool(character, origin)
    selected_items: List[Dict] = choose_items_with_weight_calculation(selected_pool)

    return [{}]
```

## Cálculo del drop para cada item

Esta funcionalidad se puede complicar todo lo que quieras, yo he decidido implementar la posibilidad de aplicar modificadores al porcentaje los cuales pueden venir de cualquier tipo de movida en el juego, ya sea por modificadores globales del sistema, equipamiento del personaje, etc.
Nosotros no queremos tener en cuenta el detalle de su origen, solo su aplicación en el cálculo actual

Para tener un control y mantener un 'equilibrio' en el sistema de loot, hemos definido un máximo para cada item que no puede sobrepasarse por muchos buff que tenga el personaje.

Se aprovecha también este momento para generar la estadística base del item en el rango propuesto, si fuera un arma esto representaría el daño, para una armadura la defensa, etc.

```python

def apply_drop_chance(items: List[Dict], modifier: Annotated[float, lambda x: 0.0 <= x <= 1.0] = None) -> List[Dict]:
    safe_items = items.copy()
    result = []

    for item in safe_items:
        chance = item['drop']['chance']
        max_chance = item['drop']['max_chance']
        final_chance = chance

        if modifier is not None:
            new_chance = chance + modifier
            final_chance = new_chance if new_chance < max_chance else max_chance

        if random() <= final_chance:
            item['stat_value'] = randint(
                item['stats_value_range']['min'],  item['stats_value_range']['max'])
            result.append(item)

    return result
```

Los porcentajes en este script se manejan entre los valores 0 y 1 donde 0.05 -> 5% y 1 -> 100%. Esto lo hago porque las funciones random de python funcionan con rangos decimales entre 0 y 1 por lo que la implementación se hace mas natural.

Así va cogiendo forma `start_loot`, por cuestiones logísticas estoy pasando hard codeado el valor del modificador que podría ser None o venir de otra fuente externa:

```python
def start_loot(character: Character, origin: str) -> List[Dict]:
    selected_pool: dict = build_pool(character, origin)
    selected_items: List[Dict] = choose_items_with_weight_calculation(selected_pool)
    dropped_items = apply_drop_chance(selected_items, 0.05)

    return [{}]

```
