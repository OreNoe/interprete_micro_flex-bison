%{
int yylex();

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "TS.h" // Todas las funciones de la TS

void yyerror(char *s);

extern int yynerrs;
extern int yylexerrs;
extern FILE* yyin;

%}

%token INICIO FIN LEER ESCRIBIR PUNTOYCOMA PARENDERECHO PARENIZQUIERDO COMA ASIGNACION SUMA RESTA
%token <id> ID
%token <cte> CONSTANTE
%union {
    char* id;
    int cte;
}
%left SUMA RESTA 
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
       ID ASIGNACION expresion PUNTOYCOMA               {EscribirATabla($1, $3);}         
    |  LEER PARENIZQUIERDO listaIdentificadores PARENDERECHO PUNTOYCOMA     
    |  ESCRIBIR PARENIZQUIERDO listaExpresiones PARENDERECHO PUNTOYCOMA
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
    |  PARENIZQUIERDO expresion PARENDERECHO                {$$ = $2;}
;

%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
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
