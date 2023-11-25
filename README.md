# Interprete del lenguaje Micro

## Definición informal
- El único tipo de dato es entero.
- Todos los identificadores son declarados implícitamente y con una longitud máxima de 32 caracteres.
- Los identificadores deben comenzar con una letra y están compuestos de letras y dígitos.
- Las constantes son secuencias de dígitos (números enteros).
- Hay dos tipos de sentencias:
	- `Asignación ID := Expresión;`  
	  `Expresión` es infija y se construye con identificadores, constantes y los operadores `+` y `–`; los paréntesis están permitidos.
	- Entrada/Salida
		- `leer (lista de IDs);`
		- `escribir (lista de Expresiones);`
- Cada sentencia termina con un "punto y coma" (`;`).
- El cuerpo de un programa está delimitado por `inicio` y `fin`. - `inicio`, `fin`, `leer` y `escribir` son palabras reservadas y deben escribirse en minúscula.

## Tokens

El lenguaje Micro cuenta con 16 Tokens:

| ER                       | Token                      |
|--------------------------|----------------------------|
| `[0-9]+`                 | CONSTANTE                  |
| `[a-zA-Z][a-zA-Z0-9]*`   | ID                         |
| `inicio`                 | INICIO                     |
| `fin`                    | FIN                        |
| `leer`                   | LEER                       |
| `escribir`               | ESCRIBIR                   |
| `imprimir`               | IMPRIMIR                   |
| `:=`                     | ASIGNACION                 |
| `(`                      | PARENTESISIZQUIERDO        |
| `)`                      | PARENTESISDERECHO          |
| `,`                      | COMA                       |
| `;`                      | PUNTOYCOMA                 |
| `+`                      | SUMA                       |
| `-`                      | RESTA                      |

## Gramática sintáctica
```ebnf
<programa> ::= INICIO <listaSentencias> FIN

<listaSentencias> ::= <sentencia>
                   | <listaSentencias> <sentencia>

<sentencia> ::= <ID> ASIGNACION <expresion> PUNTOYCOMA
              | LEER PARENTESISIZQUIERDO <listaIdentificadores> PARENTESISDERECHO PUNTOYCOMA
              | ESCRIBIR PARENTESISIZQUIERDO <listaExpresiones> PARENTESISDERECHO PUNTOYCOMA

<listaIdentificadores> ::= <ID>
                       | <listaIdentificadores> COMA <ID>

<listaExpresiones> ::= <expresion>
                       | <listaExpresiones> COMA <expresion>

<expresion> ::= <termino>
              | <expresion> SUMA <termino>
              | <expresion> RESTA <termino>

<termino> ::= <ID>
            | CONSTANTE
            | PARENTESISIZQUIERDO <expresion> PARENTESISDERECHO
```

## Ejecución
- Si es la primera vez que se ejecuta el programa, se debe ejecutar el archivo ```./compilar.bat``` para compilar el programa.
- Si ya se ha ejecutado el programa anteriormente, se debe ejecutar el archivo ```./micro``` para ejecutar el interprete.