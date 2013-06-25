/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*| MGC Confidential                                                |*/
/*| Property of Mentor Graphics Corp.                               |*/
/*| (C) Copyright Mentor Graphics Corp.  (2006-2008)                |*/
/* _________________________________________________________________ */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*| Title:               Archetype to OAL Conversion Parser         |*/
/*|                                                                 |*/
/*| Abstract -                                                      |*/
/*|   This bison parser assists in the conversion of RSL to OAL.    |*/
/*|                                                                 |*/
/*| Notes -                                                         |*/
/* _________________________________________________________________ */

%{

int i0 = 0;                     /* indent for current line           */
int i1 = 0;                     /* indent for next line              */
int indent = 0;                 /* indent                            */
char * ws[] = {
  "",
  "  ",
  "    ",
  "      ",
  "        ",
  "          ",
  "            "
};
int line_number = 1;
char lw[ 256 ];                 /* leading whitespace                */
int column;
static char pi[ 1024 ];         /* parameter initialization          */

%}
%{
/*-------------------------------------------------------------------*/
#include <stdio.h>
#include <string.h>
//#define YYDEBUG_LEXER_TEXT (yylval)
#define YYDEBUG 1   // ...and uncomment yydebug = 1 in main
#ifndef YYSTYPE
#define YYSTYPE char * /* Interface with flex: should be in header.  */
#endif
extern char yytext[];

#define P0 ""
#define P1(a) a
#define P2(a,b) ({char * s[]={a,b}; stradd( s, 2 );})
#define P3(a,b,c) ({char * s[]={a,b,c}; stradd( s, 3 );})
#define P4(a,b,c,d) ({char * s[]={a,b,c,d}; stradd( s, 4 );})
#define P5(a,b,c,d,e) ({char * s[]={a,b,c,d,e}; stradd( s, 5 );})
#define P6(a,b,c,d,e,f) ({char * s[]={a,b,c,d,e,f}; stradd( s, 6 );})
#define P7(a,b,c,d,e,f,g) ({char * s[]={a,b,c,d,e,f,g}; stradd( s, 7 );})
#define P8(a,b,c,d,e,f,g,h) ({char * s[]={a,b,c,d,e,f,g,h}; stradd( s, 8 );})
#define P9(a,b,c,d,e,f,g,h,i) ({char * s[]={a,b,c,d,e,f,g,h,i}; stradd( s, 9 );})
#define P10(a,b,c,d,e,f,g,h,i,j) ({char * s[]={a,b,c,d,e,f,g,h,i,j}; stradd( s, 10 );})
#define P11(a,b,c,d,e,f,g,h,i,j,k) ({char * s[]={a,b,c,d,e,f,g,h,i,j,k}; stradd( s, 11 );})
#define P12(a,b,c,d,e,f,g,h,i,j,k,l) ({char * s[]={a,b,c,d,e,f,g,h,i,j,k,l}; stradd( s, 12 );})
#define P13(a,b,c,d,e,f,g,h,i,j,k,l,m) ({char * s[]={a,b,c,d,e,f,g,h,i,j,k,l,m}; stradd( s, 13 );})
#define P14(a,b,c,d,e,f,g,h,i,j,k,l,m,n) ({char * s[]={a,b,c,d,e,f,g,h,i,j,k,l,m,n}; stradd( s, 14 );})
#define P15(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o) ({char * s[]={a,b,c,d,e,f,g,h,i,j,k,l,m,n,o}; stradd( s, 15 );})

static char * stradd( char * [], int );
extern char * dtKLname( char * );
extern void loadtable( void );

/*-------------------------------------------------------------------*/
%}

%token SELECTONE       SELECTANY       SELECTMANY      CREATEOBJ
%token OF              IF              FOR             TYPE
%token RELATEDBY       ELIF            ENDFOR          FORMAT
%token FUNCTION        ELSE            BREAKFOR        BAD
%token PARAM           ENDIF           COMMENT         WHERE
%token ENDFUNCTION     FROMINSTOF      TEXT            INCLUDE
%token ASSIGN          PRINTTOK        EXITTOK         EMIT
%token CLEARTOK        INVOKE          IN              UOP
%token RELTRAV         ALXLATE         SPECIALWHERE    DELETEOBJ
%token WHILE           ENDWHILE        BREAKWHILE
%token RELATE ENDRELATE UNRELATE ENDUNRELATE TO FROM ACROSS
%token WORD            LITERAL         REALconstant    INTconstant
%token ARROW                    /*  ->                               */
%token LE GE EQ NE              /*  <=       >=        ==        !=  */
%token AND OR                   /*  and      or                      */

%left UOP
%left UMINUS
 
%start archetypeprogram

%%

archetypeprogram:
        archetypebody
        ;

comment:
        COMMENT commentbody '\n' {$$=P3($1,$2,$3);}
        ;

commentbody:
        /* empty */ {$$=P0;}
        | commentbody TEXT {$$=P2($1,$2);}
        ;

archetypebody:
        code
        ;

code:
        /* empty */ {$$=P0;}
        | code statement {$$=P3($1,ws[indent],$2);}
        | code comment {$$=P3($1,ws[indent],$2);}
        | code literal {$$=P2($1,$2);}
        | code FUNCTION identifier '\n' {pi[0]=0;} fparameters fbody ENDFUNCTION '\n' {$$=""; printf( "%s", P8($3,"@void",$6,"@@@\n",$1,pi,$7,"@@@\n"));}
        ;

statement:
        selectstatement '\n' {$$=P2($1,";\n");}
        | IF condition '\n' {indent++;} code {indent--;} elifclause elseclause endiffer '\n' {$$=P10($1," ",$2,$3,$5,$7,$8,ws[indent],$9,$10);}
        | FOR inst_ref_var IN inst_ref_set_var '\n' {indent++;} code {indent--;} endforrer '\n' {$$=P12($1," ",$2," ",$3," ",$4,$5,$7,ws[indent],$9,$10);}
        | BREAKFOR '\n' {$$=P2($1,";\n");}
        | BREAKWHILE '\n' {$$=P2($1,";\n");}
        | WHILE condition '\n' {indent++;} code {indent--;} endwhiler '\n' {$$=P8($1," ",$2,$3,$5,ws[indent],$7,$8);}
        | CLEARTOK '\n' {$$=P1("T::clear();\n");}
        | INCLUDE string '\n' {$$=P3("T::include(s:",$2,");\n");}
        | PRINTTOK string '\n' {$$=P3("T::print(s:",$2,");\n");}
        | EXITTOK sexpr '\n' {$$=P3("T::exit(i:",$2,");\n");}
        | EMIT string '\n' {$$=P3("T::emit(s:",$2,");\n");}
        | ASSIGN variable '=' expr '\n' {$$ = ( 0 == strncmp( $2, "attr_", 5 ) ) ? P3("return ",$4,";\n") : P4($2," = ",$4,";\n");}
        | INVOKE identifier '(' aparameters ')' '\n' {$$ = (strlen($4)>0) ? P5("::",$2,"( ",$4," );\n") : P6("::",$2,$3,$4,$5,";\n");}
        | INVOKE frag_ref_var '=' identifier '(' aparameters ')' '\n' {$$ = (strlen($6)>0) ? P6($2," = ::",$4,"( ",$6," );\n") : P7($2," = ::",$4,$5,$6,$7,";\n");}
        | ALXLATE activity_type inst_ref_var '\n' {$$=P4($1,$2,$3,";\n");}
        | SPECIALWHERE WORD WORD '\n' {$$=P4($1,$2,$3,$4);}
        | CREATEOBJ inst_ref_var OF obj_keyletters '\n' {$$=P8($1," ",$2," ",$3," ",$4,";\n");}
        | DELETEOBJ inst_ref_var ';' '\n' {$$=P4("delete object instance ",$2,$3,$4);}
        | RELATE inst_ref_var TO inst_ref_var ACROSS reltraversal ';' '\n' code ENDRELATE '\n' {$$=P12("relate ",$2," ",$3," ",$4," ",$5," ",$6,$7,$8);}
        | UNRELATE inst_ref_var FROM inst_ref_var ACROSS reltraversal ';' '\n' code ENDUNRELATE '\n' {$$=P12("unrelate ",$2," ",$3," ",$4," ",$5," ",$6,$7,$8);}
        ;

selectstatement:
        SELECTONE inst_ref_var RELATEDBY inst_chain whereclause {$$=P8($1," ",$2," ",$3," ",$4,$5);}
        | SELECTANY inst_ref_var RELATEDBY inst_chain whereclause {$$=P8($1," ",$2," ",$3," ",$4,$5);}
        | SELECTMANY inst_ref_set_var RELATEDBY inst_chain whereclause {$$=P8($1," ",$2," ",$3," ",$4,$5);}
        | SELECTANY inst_ref_var FROMINSTOF obj_keyletters whereclause {$$=P8($1," ",$2," ",$3," ",$4,$5);}
        | SELECTMANY inst_ref_set_var FROMINSTOF obj_keyletters whereclause {$$=P8($1," ",$2," ",$3," ",$4,$5);}
        ;

whereclause:
        /* empty */ {$$=P0;}
        | WHERE condition {$$=P3($1," ",$2);}
        ;

fparameters:
        /* empty */ {$$=P0;}
        | fparameters PARAM TYPE param_name COMMENT commentbody '\n' {$$=P5($1,"@@",$4,"@",$3); strcat(pi,P6($4," = param.",$4,"; // ",$6,"\n"));}
        | fparameters PARAM TYPE param_name '\n' {
          if ( 0 == strncmp($3,"inst_ref",8) ) {
            char * t = dtKLname($4);
            $$=P8($1,"@@",$4,"@",$3,"<",dtKLname($4),">");
          } else {
            $$=P5($1,"@@",$4,"@",$3);
          }
          strcat(pi,P4($4," = param.",$4,";\n"));
        }
        ;

fbody:
        /* empty */ {$$=P0;}
        | statement code {$$=P3(ws[indent],$1,$2);}
        | comment code {$$=P3(ws[indent],$1,$2);}
        | literal code {$$=P2($1,$2);}
        ;

aparameters:
        /* empty */ {$$=P0;}
        | term aparameters {$$=P4($1,":",$1,$2);}
        | ',' term aparameters {$$=P5(", ",$2,":",$2,$3);}
        ;

elifclause:
        /* empty */ {$$=P0;}
        | elifclause ELIF condition '\n' {indent++;} code {indent--; $$=P7($1,ws[indent],$2," ",$3,$4,$6);}
        ;

elseclause:
        /* empty */ {$$=P0;}
        | elseclause ELSE '\n' {indent++;} code {indent--; $$=P5($1,ws[indent],$2,$3,$5);}
        ;

endiffer:
        ENDIF {$$=P2($1,";");}
        | ENDIF COMMENT commentbody {$$=P4($1,"; ",$2,$3);}
        ;

endwhiler:
        ENDWHILE {$$=P2($1,";");}
        | ENDWHILE COMMENT commentbody {$$=P4($1,"; ",$2,$3);}
        ;

endforrer:
        ENDFOR {$$=P2($1,";");}
        | ENDFOR COMMENT commentbody {$$=P4($1,"; ",$2,$3);}
        ;

condition:
        '(' expr ')' {$$=P5($1," ",$2," ",$3);}
        ;

sexpr:
        UOP term {$$=P3($1," ",$2);}
        | '-' term %prec UMINUS {$$=P2($1,$2);}
        | term bop expr {$$=P5($1," ",$2," ",$3);}
        | term
        | inst_ref_set_var '|' inst_ref_set_var
        ;

expr:
        '(' expr ')' {$$=P5($1," ",$2," ",$3);}
        | UOP '(' expr ')' {$$=P7($1," ",$2," ",$3," ",$4);}
        | '(' expr ')' bop expr {$$=P9($1," ",$2," ",$3," ",$4," ",$5);}
        | sexpr
        ;

term:
        string
        | identifier
        | substitutionvariable
        | INTconstant
        | REALconstant
        | term ARROW identifier {$$=P3($1,$2,$3);}
        | term ':' parsekeyword {$$=P3($1,$2,$3);}
        | term '.' attribute {$$ = ( ( 0 == strcmp( $1, "r" ) ) && ( 0 == strcmp( $3, "result" ) ) ) ? "r" : P3($1,$2,$3);}
        ;

reltraversal:
        RELTRAV
        | RELTRAV '.' '\'' relphrase '\'' {$$=P5($1,$2,$3,$4,$5);}
        | RELTRAV '.' RELTRAV {$$=P3($1,$2,$3);}
        ;

relphrase:
        WORD
        | keyword
        | relphrase WORD {$$=P3($1," ",$2);}
        | relphrase keyword {$$=P3($1," ",$2);}
        ;

attribute:
        identifier
        | keyword
        ;

parsekeyword:
        identifier
        | substitutionvariable
        ;

format:
        /* empty */ {$$=P0;}
        | FORMAT
        ;

variable:
        identifier
        | identifier '.' identifier {$$ = ( ( 0 == strcmp( $1, "r" ) ) && ( 0 == strcmp( $3, "result" ) ) ) ? "r" : P3($1,$2,$3);}
        | identifier '.' keyword {$$=P3($1,$2,$3);}
        | keyword               /* This practice is not recommended. */
        ;

keyword:
        UOP | TYPE | WHERE | IN | AND | OR
        ;

param_name:
        WORD
        ;

frag_ref_var:
        WORD
        ;

inst_ref_var:
        WORD
        ;

inst_ref_set_var:
        WORD
        ;

inst_chain:
        WORD
        | inst_chain ARROW WORD '[' reltraversal ']' {$$=P6($1,$2,$3,$4,$5,$6);}
        ;

obj_keyletters:
        WORD
        ;

activity_type:
        WORD
        ;

identifier:
        WORD
        | WORD '[' reltraversal ']' {$$=P4($1,$2,$3,$4);}
        ;

bop:
        LE | GE | EQ | NE | AND | OR
        | '>' | '<' | '+' | '-' | '*' | '/'
        ;

literal:
        LITERAL literalbody '\n' {$$=P4("T::b(s:",$1,$2,");\n");}
        | '\n'
        ;

literalbody:
        /* empty */ {$$=P0;}
        | literalbody LITERAL {$$=P2($1,$2);}
        | literalbody substitutionvariable {$$=P2($1,$2);}
        ;

substitutionvariable:
        '$' format '{' term '}' {char * f = $2; if ( 0 == strcmp( $2, "" ) ) f = "s"; $$=P5("T::",f,"(",$4,")");}
        ;


string:
        '"' stringbody '"' {$$ = ( 0 == strncmp( $2, "T::", 3 ) ) ? P1($2) : P3($1,$2,$3);}
        ;

stringbody:
        /* empty */ {$$=P0;}
        | stringbody TEXT {$$=P2($1,$2);}
        | stringbody substitutionvariable {$$=P2($1,$2);}
        ;

%%

static char * stradd( char * sin[], int n )
{
  static char b[10000000];
  static int ii = 0;
  char * s = &b[ii];
  int len = 0;
  int j;
  for ( j = 0; j < n; j++ ) {
    len = len + strlen( sin[ j ] );
  }
  ii = ii + len + 1;
  if ( ii >= 10000000 ) {
    s = &b[0];
    ii = len + 1;
  }
  *s = 0;
  for ( j = 0; j < n; j++ ) {
    strcat( s, sin[ j ] );
  }
  b[ii]=0;
  return s;
}
static char * stradd2( char *, char * );
static char * stradd2( char * s1, char * s2 )
{
  static int i = 0;
  static char b[1000000];
  char * s = &b[i];
  int len = strlen( s1 ) + strlen( s2 );
  i = i + len + 1;
  if ( i >= 1000000 ) {
    s = &b[0];
    i = len + 1;
  }
  strcpy( s, s1 );
  strcat( s, s2 );
  b[i]=0;
  return s;
}
static char * stradd3( char * , char * );
static char * stradd3( char * s1, char * s2 )
{
  int len1 = strlen( s1 );
  int len2 = strlen( s2 );
  char * s = malloc( len1 + len2 );
  if ( s ) {
    strcat( s, s1 );
    strcat( s, s2 );
  } else {
    printf( "Failed to allocate memory.\n" );
  }
  return s;
}

/*===================================================================*/
/* Error recovery routine.                                           */
/*===================================================================*/
yyerror(char *string)
{
  fprintf( stderr, "rsl2oal:  %s, at \"%s\" near line %d.\n",
    string, yytext, line_number );
}

/*===================================================================*/
/* main program to call yyparse                                      */
/*===================================================================*/
int
main( int argc, char ** argv )
{
  //yydebug = 1;
  loadtable();
  yyparse();
}

