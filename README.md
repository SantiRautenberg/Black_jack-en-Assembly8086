# Blackjack en Assembly 8086

Proyecto desarrollado en **Assembler 8086** que implementa una versión del juego **Blackjack** en modo texto, utilizando interrupciones del BIOS, interrupciones de DOS, memoria de video y una interrupción personalizada.

El objetivo principal del proyecto fue aplicar conceptos de arquitectura de computadoras y programación de bajo nivel sobre el procesador Intel 8086.

## Características

- Juego de Blackjack funcional en modo texto.
- Interfaz visual utilizando memoria de video `B800h`.
- Uso de colores, posicionamiento de cursor y limpieza de pantalla.
- Manejo de teclado para interacción con el usuario.
- Separación del código en programa principal y librería de procedimientos.
- Implementación de una interrupción personalizada `INT 67h`.
- Manejo de puntajes del jugador y del crupier.
- Lógica de turnos, pedido de cartas, plantarse y decisión del ganador.

## Tecnologías utilizadas

- Assembly 8086
- TASM
- TLINK
- DOSBox
- Sublime Text o editor de texto a elección

## Interrupciones utilizadas

### INT 10h

Se utiliza para el manejo de pantalla:

- Cambiar modo de video.
- Limpiar pantalla.
- Posicionar el cursor.
- Pintar franjas de color.
- Trabajar con la interfaz visual del juego.

### INT 16h

Se utiliza para la lectura del teclado:

- Leer opciones del menú.
- Leer decisiones durante la partida.

### INT 21h

Se utiliza para funciones de DOS:

- Imprimir cadenas.
- Obtener valores de tiempo para generar cartas.
- Finalizar el programa.

### INT 67h

Interrupción personalizada utilizada para resolver parte de la lógica del juego:

- Controlar si el jugador puede seguir pidiendo cartas.
- Decidir el ganador de la partida.
- Centralizar condiciones de victoria, empate o derrota.

## Estructura del proyecto

```text
.
├── BJ.ASM          # Programa principal
├── CLIB.ASM        # Librería de procedimientos
├── COMPILAR.BAT    # Script para ensamblar y linkear
└── README.md
```

## Requisitos

Para compilar y ejecutar el proyecto se necesita:

- DOSBox
- `TASM.EXE`
- `TLINK.EXE`
- Archivos fuente del proyecto:
  - `BJ.ASM`
  - `CLIB.ASM`

Se recomienda guardar todo en una carpeta simple, por ejemplo:

```text
C:\BLACK
```

Dentro de esa carpeta deberían estar:

```text
BJ.ASM
CLIB.ASM
COMPILAR.BAT
TASM.EXE
TLINK.EXE
```

## Compilación manual

Abrir DOSBox y montar la carpeta del proyecto:

```dos
mount c C:\BLACK
c:
dir
```

Ensamblar el programa principal:

```dos
tasm /zi BJ.ASM
```

Ensamblar la librería:

```dos
tasm /zi CLIB.ASM
```

Linkear los archivos objeto:

```dos
tlink /v BJ.OBJ CLIB.OBJ
```

Ejecutar el programa:

```dos
BJ
```

## Compilación con archivo BAT

También se puede compilar usando `COMPILAR.BAT`.

Contenido del archivo:

```bat
@echo off
cls

echo Ensamblando BLACKJACK...
tasm /zi BJ.ASM

echo Ensamblando LIBRERIA...
tasm /zi CLIB.ASM

echo Linkeditando...
tlink /v BJ.OBJ CLIB.OBJ

echo.
echo Listo. Si no hubo errores, ejecutar BJ.EXE
pause
```

En DOSBox:

```dos
COMPILAR
```

Si no hubo errores:

```dos
BJ
```

## Controles

Durante la partida:

```text
C - Pedir carta
S - Plantarse
```

En el menú se utilizan las opciones indicadas en pantalla.

## Conceptos trabajados

Este proyecto aplica conceptos fundamentales de arquitectura y programación de bajo nivel:

- Registros del 8086.
- Segmentación de memoria.
- Uso de `CS`, `DS`, `ES` y `SS`.
- Memoria de video en modo texto color.
- Direccionamiento mediante registros.
- Procedimientos `near` y `far`.
- Uso de pila con `push` y `pop`.
- Interrupciones BIOS y DOS.
- Instalación de una interrupción personalizada.
- Saltos condicionales.
- Manejo de flags.
- Separación entre programa principal y librería.

## Capturas

Se pueden agregar capturas del juego ejecutándose en DOSBox:

```text
/menu
/reglas
/partida
```

## Autor

Desarrollado por **Santiago Rautenberg**.



