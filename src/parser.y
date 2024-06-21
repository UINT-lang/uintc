%{
#include "scanner.hpp"
#include <bits/stdc++.h>
using namespace std;
%}
 
%require "3.7.4"
%language "C++"

%define api.parser.class {Parser}
%define api.namespace {UINTC}
%define api.value.type variant
%define parse.error verbose
%param {yyscan_t scanner}

%code provides
{
    #define YY_DECL \
        int yylex(UINTC::Parser::semantic_type *yylval, yyscan_t yyscanner)
    YY_DECL;
}
 
%token LPAREN RPAREN SEMICOLON LBRACE RBRACE
%token CPP FN

%token <std::string> INLINE_STRING
%token <std::string> MULTILINE_STRING
%token <std::string> IDENTIFIER

%type <std::string> string
%type <std::string> cpp_statement
%type <std::string> fn_declaration
%type <std::string> statements
%type <std::string> statement
%type <std::string> top_levels
%type <std::string> top_level
%type <std::string> call_statement

%code
{
    namespace UINTC {
        bool hasMain = false;
    }  // namespace UINTC
}  // %code
 
%%

root        : top_levels
            {
                cout << "#include \"uintcpplib.hpp\"\n";
                cout << $1;
                if (UINTC::hasMain) {
                    cout << "int main() {\n";
                    cout << "    UINT::main();\n";
                    cout << "}\n";
                }
            }
            ;

top_levels  : %empty
            {
                $$ = "";
            }
            | top_levels top_level
            {
                $$ = $1 + $2;
            }
            ;

top_level   : cpp_statement
            {
                $$ = $1;
            }
            | fn_declaration
            {
                $$ = $1;
            }
            ;

cpp_statement   : CPP LPAREN string RPAREN
                {
                    $$ = $3 + "\n";
                }
                ;

fn_declaration  : FN IDENTIFIER LPAREN RPAREN LBRACE statements RBRACE
                {
                    stringstream ss;
                    ss << "namespace UINT {\n";
                    ss << "    auto " << $2 << "() {\n";
                    ss << $6;
                    ss << "    }\n";
                    ss << "}\n";
                    $$ = ss.str();

                    if ($2 == "main") {
                        UINTC::hasMain = true;
                    }
                }
                ;

statements  : %empty
            {
                $$ = "";
            }
            | statements statement
            {
                $$ = $1 + $2;
            }
            ;

statement   : SEMICOLON
            {
                $$ = "";
            }
            | cpp_statement
            {
                $$ = $1;
            }
            | call_statement
            {
                $$ = $1;
            }
            ;

call_statement  : IDENTIFIER LPAREN RPAREN SEMICOLON
                {
                    $$ = "    " + $1 + "();\n";
                }
                ;

string      : INLINE_STRING
            {
                assert($1.size() >= 2);
                assert($1.front() == '"');
                assert($1.back() == '"');
                $$ = $1.substr(1, $1.size() - 2);
            }
            | MULTILINE_STRING
            {
                assert($1.size() >= 6);
                assert($1.substr(0, 3) == "\"\"\"");
                assert($1.substr($1.size() - 3, 3) == "\"\"\"");
                $$ = $1.substr(3, $1.size() - 6);
            }
            ;
 
%%

namespace UINTC {
    extern int currentLineNumber;
}
void UINTC::Parser::error(const string& msg) {
    cerr << "Line " << currentLineNumber << ": " << msg << endl;
}
