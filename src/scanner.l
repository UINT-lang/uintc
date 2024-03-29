%{
#include <bits/stdc++.h>
#include "parser.hpp"
using namespace std;
using namespace UINTC;
%}

%option reentrant interactive noyywrap noyylineno nodefault

inline_string    (["]([^"])*["])
multiline_string (\"\"\"([^"]|\"[^"]|\"\"[^"])*\"\"\")
identifier       ([a-zA-Z_][a-zA-Z0-9_]*)

%%
 
"("     return Parser::token::LPAREN;
")"     return Parser::token::RPAREN;
";"     return Parser::token::SEMICOLON;
"{"     return Parser::token::LBRACE;
"}"     return Parser::token::RBRACE;

" "     ;
\n      ;

"cpp"   return Parser::token::CPP;
"fn"    return Parser::token::FN;

{inline_string}    yylval->emplace<string>(yytext); return Parser::token::INLINE_STRING;
{multiline_string} yylval->emplace<string>(yytext); return Parser::token::MULTILINE_STRING;
{identifier}       yylval->emplace<string>(yytext); return Parser::token::IDENTIFIER;

<<EOF>>     return Parser::token::YYEOF;
.           { cerr << "Unrecognized token: " << yytext << endl; exit(1); }

%%

int main() {
    yyscan_t scanner;
    yylex_init(&scanner);
    UINTC::Parser parser{ scanner };
    parser.parse();
    yylex_destroy(scanner);
}
