%{
int yylex();

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define TABLA_DE_SIMBOLOS

// Tabla de símbolos per se
#define TAMAN_TS 100

typedef struct {
    char id[32]; // los IDs tienen hasta 32 caracteres
    int val;
} SIMBOLO;

// Funciones para leer/escribir a la TS
void init_TS(void);
int ValorSimbolo(char* s);
int IndiceTabla(char* s);
void EscribirATabla(char* s, int v);
void cargarEntradas(char* p1); // para Leer(IDs);

SIMBOLO TS[TAMAN_TS]; // La tabla de símbolos per se

void yyerror(char *s);

extern int yynerrs;
extern int yylexerrs;
extern FILE* yyin;

%}

%token INICIO FIN LEER ESCRIBIR PUNTOYCOMA COMA ASIGNACION SUMA RESTA PARENTESISIZQUIERDO PARENTESISDERECHO
%token <id> ID
%token <cte> CONSTANTE
%union {
    char* id;
    int cte;
}
%left SUMA RESTA COMA
%right ASIGNACION

%type <cte> expresion termino

%%

programa:
       INICIO listaSentencias FIN                       {if (yynerrs || yylexerrs) YYABORT; return -1;}
; 

listaSentencias:
    sentencia
    |  listaSentencias sentencia
;

sentencia:
    |   ID ASIGNACION expresion PUNTOYCOMA               {EscribirATabla($1, $3);}         
    |  LEER PARENTESISIZQUIERDO listaIdentificadores PARENTESISDERECHO PUNTOYCOMA     
    |  ESCRIBIR PARENTESISIZQUIERDO listaExpresiones PARENTESISDERECHO PUNTOYCOMA
;

listaIdentificadores:
       ID                               {cargarEntradas($1);}                                                   
    |  listaIdentificadores COMA ID      {cargarEntradas($3);}
;

listaExpresiones:
       expresion                        {printf("%d\n", $1);}
    |  listaExpresiones COMA expresion   {printf("%d\n", $3);}
;

expresion:
       termino                          {$$ = $1;}
    |  expresion SUMA termino            {$$ = $1 + $3;}
    |  expresion RESTA termino            {$$ = $1 - $3;}                    
;

termino:
       ID                               {$$ = ValorSimbolo($1);}
    |  CONSTANTE                        {$$ = $1;}
    |  PARENTESISIZQUIERDO expresion PARENTESISDERECHO                {$$ = $2;}
;

%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

// Funciones para leer/escribir a la TS

void init_TS(){
    for(int i=0; i<TAMAN_TS; (TS[i].val = -1, i++)); // valores inadmitidos en Micro
}

// Retorna valor de un ID si está en la TS, de lo contrario termina el programa
int ValorSimbolo(char* s){
    int ind = IndiceTabla(s);
    if (ind<0){
        printf("Error: No hay valor asignado para '%s'\n",s);
        exit(EXIT_FAILURE);
    }
    return TS[ind].val;
}

// Retorna el índice si está, o -1 si no
int IndiceTabla(char* s){
    int i=0;
    for (i; i<TAMAN_TS; i++)
        if (!strcmp(TS[i].id, s)) return i;
    return -1;
}

// Si ya está en la tabla lo actualiza, si no, crea una entrada nueva
void EscribirATabla(char* s, int v){
    int ind = IndiceTabla(s);
    // No está en la TS
    if (ind == -1){
        int i=0;
        for (i; (i<TAMAN_TS && TS[i].val != -1); i++); // busca la primera entrada vacía

        if (i > TAMAN_TS-1){
            printf("No hay mas espacio en la TS.\n");
            return;
        }
        // Asigna ID y su valor
        TS[i].val = v;
        sprintf(TS[i].id, s);
    }
    // Sí está en la TS
    else
        TS[ind].val = v;
}

// Para la estructura Leer(IDs);

// Retorna el número que representa si la cadena es numérica, o -1 caso contrario
static int numerico(char* s){
    for(int i=0; i<strlen(s); i++)
        if (!isdigit(s[i])) return -1;
    return atoi(s);
}

// Va asignando a cada entrada leida con Leer(IDs); el valor y después se escribe a la tabla
// Si se intenta asignar un no número, tira error
void cargarEntradas(char* p1){
    int valor;
    char temp[15];
    printf("Ingresa el valor de %s: ", p1);
    fscanf(stdin, "%s", temp);

    if((valor = numerico(temp)) == -1){
        printf("Error: El valor '%s' no es un numero\n", temp);
        exit(EXIT_FAILURE);
    }
    EscribirATabla(p1, valor);
}

////// MAIN //////
int main(int argc, char** argv) {
    
    // Argumentos
    if (argc > 2){
        printf("Numero incorrecto de argumentos.");
        return EXIT_FAILURE;
    }
    else if (argc == 2) {
        char filename[50];                  // Nombre del archivo
        sprintf(filename, "%s", argv[1]);   // El 2do argumento
        int largo = strlen(filename);       // Largo del nombre del archivo

        // Si no termina en .m dar error
        if (argv[1][largo-1] != 'm' || argv[1][largo-2] != '.'){
            printf("Extension incorrecta (debe ser .m)");
            return EXIT_FAILURE;
        }

        yyin = fopen(filename, "r");
    }
    else
        yyin = stdin;

    init_TS(); // Inicializa la tabla con todo en -1

    // Parser
    switch (yyparse()){
        case 0: printf("\n\nProceso de compilacion termino exitosamente");
        break;
        case 1: printf("\n\nErrores de compilacion");
        break;
        case 2: printf("\n\nNo hay memoria suficiente");
        break;
    }
    printf("\n\nErrores sintacticos: %i\tErrores lexicos: %i\n", yynerrs, yylexerrs);

    return 0;
}