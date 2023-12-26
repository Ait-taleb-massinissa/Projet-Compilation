%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include <ctype.h>
	#include <atoh.h>
	
	enum token{FIN,PV,AFFECT,COND,ACG,ACD,ID,NUM,OP};
	enum CODEOPERATION {PLUS,MOINS,MOD};
	union {
		char* nom;
		unsigned valeur;
		enum CODEOPERATION cop;
	}attribut;
	void erreur_lexicale();
	
	
%}
%option yylineno
blancs [ \t\n]+
lettres [A-Z]
chiffre [0-9]
ident "$"({chiffre}|{lettres})*
number ({chiffre}|[A-F])+

%%

{blancs} ;
\0 return FIN;
; return PV;
= return AFFECT;
"?" return COND;
"{" return ACG;
"}" return ACD;
{ident}	{ attribut.nom=(char*)malloc(yyleng+1);
	  strcpy(attribut.nom,yytext);
	  return ID;
	}
{number} { attribut.valeur=(int)atoh(yytext);
	   return NUM;
	 }
["+""-""%"] { if(yytext=="+") attribut.cop=PLUS;
	if(yytext=="-") attribut.cop=MOINS;
	else attribut.cop=MOD;
	}
"(%".*")%" ;
.	erreur_lexicale();

%%


int yywrap(){
	return 1;
	}
	
void erreur_lexicale(){
	printf("ligne %d : ",yylineno);
	if (isprint(yytext[0]))
	printf("’%c’ ",yytext[0]);
	printf("caractère illégal.");
	exit(1);
	}
	
	
int main(int argc, char * argv[]){
	enum token tc;
	
	if (--argc>1){
	printf("Usage:\n\t %s [nom_de_fichier]\n",argv[0]);
	exit(2);
	}else if (argc==1){if ((yyin=fopen(argv[1],"r"))==NULL){
	printf("Impossible d’ouvrir le fichier <%s>.\n",
	argv[1]);

	exit(3);
	}
	}
	else
	printf("Taper un programme:\n\n");
	while (tc=yylex()){
		switch(tc){
		case PV : printf("<PV, >\n");break;
		case AFFECT : printf("<AFFECT, >\n");break;
		case COND : printf("<COND, >\n");break;
		case ACG : printf("<ACG, >\n");break;
		case ACD : printf("<ACD, >\n");break;
		case ID: printf("<ID, \"%s\">\n",attribut.nom); break;
		case NUM: printf("<NUM, \"%s\">\n",attribut.valeur); break;
		case OP : printf("<OP, ");
			  if (attribut.cop==PLUS) printf("PLUS>\n");
			  if (attribut.cop==MOINS) printf("MOINS>\n");
			  if (attribut.cop==MOD) printf("MOD>\n");
			  break;
		}
	printf("<FIN, >\n");
	}
	
	return 0;
}	

