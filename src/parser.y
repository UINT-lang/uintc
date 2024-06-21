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
 
%token LPAREN RPAREN SEMICOLON LBRACE RBRACE EQUALS LEFT_SHIFT PLUS DOT LESS_THAN GREATER_THAN
%token CPP FN LET
%token CHAR_LITERAL_NEWLINE

%precedence LPAREN
%left LEFT_SHIFT
%left PLUS
%left DOT

%token <std::string> INLINE_STRING_LITERAL
%token <std::string> MULTILINE_STRING_LITERAL
%token <std::string> IDENTIFIER
%token <int32_t> I32_LITERAL

%type <char> char_literal

%type <std::string> string_literal
%type <std::string> cpp_statement
%type <std::string> fn_declaration
%type <std::string> statements
%type <std::string> statement
%type <std::string> top_levels
%type <std::string> top_level
%type <std::string> call_expression
%type <std::string> variable_declaration
%type <std::string> expression
%type <std::string> maybe_templated_function_name

%code
{
namespace UINTC {
    extern string globalResult;
}  // namespace UINTC
}  // %code
 
%%

root : top_levels
    {
        UINTC::globalResult = $1;
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

cpp_statement
    : CPP LPAREN string_literal RPAREN
    {
        $$ = $3 + "\n";
    }
    ;

fn_declaration  : FN IDENTIFIER LPAREN RPAREN LBRACE statements RBRACE
                {
                    stringstream ss;
                    ss << "namespace UINT {\n";
                    ss << "auto " << $2 << "() {\n";
                    ss << $6;
                    ss << "}\n";
                    ss << "}\n";
                    $$ = ss.str();
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
            | expression SEMICOLON
            {
                $$ = "" + $1 + ";\n";
            }
            | variable_declaration
            {
                $$ = $1;
            }
            ;

call_expression
    : expression LPAREN RPAREN
    {
        $$ = "" + $1 + "()";
    }
    | expression DOT maybe_templated_function_name LPAREN RPAREN
    {
        $$ = "(" + $1 + "." + $3 + ")()";
    }
    ;

variable_declaration
    : LET IDENTIFIER EQUALS expression SEMICOLON
    {
        $$ = "const auto&& " + $2 + " = " + $4 + ";\n";
    }
    ;

expression
    : expression LEFT_SHIFT expression
    {
        $$ = "(" + $1 + " << " + $3 + ")";
    }
    | expression PLUS expression
    {
        $$ = "(" + $1 + " + " + $3 + ")";
    }
    | call_expression
    {
        $$ = $1;
    }
    | string_literal
    {
        $$ = "\"";
        for (char c : $1) {
            if (c == '\n')
                $$ += "\\n";
            else
                $$ += c;
        }
        $$ += "\"";
    }
    | I32_LITERAL
    {
        $$ = to_string($1) + "_i32";
    }
    | char_literal
    {
        stringstream stream;
        stream << "'\\x" << std::setfill('0') << std::setw(2) << std::hex << (int) (unsigned char) $1 << "'";
        $$ = stream.str();
    }
    | IDENTIFIER
    {
        $$ = $1;
    }
    ;

maybe_templated_function_name
    : IDENTIFIER
    {
        $$ = $1;
    }
    | IDENTIFIER LESS_THAN expression GREATER_THAN
    {
        $$ = $1 + "<" + $3 + ">";
    }
    ;

string_literal
    : INLINE_STRING_LITERAL
    {
        $$ = $1;
    }
    | MULTILINE_STRING_LITERAL
    {
        $$ = $1;
    }
    ;

char_literal
    : CHAR_LITERAL_NEWLINE
    {
        $$ = '\n';
    }

%%

namespace UINTC {
    extern int currentLineNumber;
}
void UINTC::Parser::error(const string& msg) {
    cerr << "Line " << currentLineNumber << ": " << msg << endl;
}
