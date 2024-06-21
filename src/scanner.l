%{
#include "parser.hpp"
#include <bits/stdc++.h>
using namespace std;
using namespace UINTC;
namespace UINTC {
    int currentLineNumber = 1;
    int32_t parseInt32(const string& s) {
        int32_t ret = stoi(s.substr(0, s.size() - 3));
        if (s != to_string(ret) + "i32") {
            cerr << "Invalid i32 literal: " << s << endl;
            exit(1);
        }
        return ret;
    }
}
%}

%option reentrant interactive noyywrap nodefault

inline_string    (["]([^"])*["])
multiline_string (\"\"\"([^"]|\"[^"]|\"\"[^"])*\"\"\")
identifier       ([a-zA-Z_][a-zA-Z0-9_]*)

i32_literal      ([0-9]+)i32

%%
 
"("     return Parser::token::LPAREN;
")"     return Parser::token::RPAREN;
";"     return Parser::token::SEMICOLON;
"{"     return Parser::token::LBRACE;
"}"     return Parser::token::RBRACE;
"="     return Parser::token::EQUALS;
"<<"    return Parser::token::LEFT_SHIFT;
"+"     return Parser::token::PLUS;
"."     return Parser::token::DOT;
"<"     return Parser::token::LESS_THAN;
">"     return Parser::token::GREATER_THAN;

" "     ;
\n      UINTC::currentLineNumber++;

"cpp"   return Parser::token::CPP;
"fn"    return Parser::token::FN;
"let"   return Parser::token::LET;

{inline_string}    yylval->emplace<string>(yytext); return Parser::token::INLINE_STRING;
{multiline_string} yylval->emplace<string>(yytext); return Parser::token::MULTILINE_STRING;
{identifier}       yylval->emplace<string>(yytext); return Parser::token::IDENTIFIER;
{i32_literal}      yylval->emplace<int32_t>(UINTC::parseInt32(yytext)); return Parser::token::I32_LITERAL;

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
