flex scanner.l &&
bison -yd parser.y &&
gcc lex.yy.c y.tab.c -o micro &&
./micro