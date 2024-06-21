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
 
%token LPAREN RPAREN SEMICOLON LBRACE RBRACE EQUAL LEFT_SHIFT PLUS DOT LESS_THAN GREATER_THAN COLON EQUALS QUESTION_MARK STAR COMMA MINUS
%token CPP FN LET FOR REF MUT
%token CHAR_LITERAL_NEWLINE

%left EQUALS
%right QUESTION_MARK
%left LEFT_SHIFT
%left PLUS
%left DOT

%token <std::string> INLINE_STRING_LITERAL
%token <std::string> MULTILINE_STRING_LITERAL
%token <std::string> IDENTIFIER
%token <int32_t> I32_LITERAL
%token <char> CHAR_LITERAL

%type <char> char_literal

%type <std::string> string_literal
%type <std::string> cpp_statement
%type <std::string> fn_declaration
%type <std::string> statements
%type <std::string> statement
%type <std::string> statement_or_block
%type <std::string> block
%type <std::string> top_levels
%type <std::string> top_level
%type <std::string> call_expression
%type <std::string> variable_declaration
%type <std::string> variable_declaration_left
%type <std::string> expression
%type <std::string> expression16
%type <std::string> expression15
%type <std::string> expression10
%type <std::string> expression9
%type <std::string> expression7
%type <std::string> expression6
%type <std::string> expression5
%type <std::string> expression4
%type <std::string> expression2
%type <std::string> call_parameters
%type <std::string> maybe_templated_function_name
%type <std::string> for_statement

%code
{
namespace UINTC {
    extern string globalResult;
}  // namespace UINTC
}  // %code
 
%%

root
    : top_levels
    {
        UINTC::globalResult = $1;
    }
    ;

top_levels
    : %empty
    {
        $$ = "";
    }
    | top_levels top_level
    {
        $$ = $1 + $2;
    }
    ;

top_level
    : cpp_statement
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

fn_declaration
    : FN IDENTIFIER LPAREN RPAREN LBRACE statements RBRACE
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

statements
    : %empty
    {
        $$ = "";
    }
    | statements statement
    {
        $$ = $1 + $2;
    }
    ;

statement
    : SEMICOLON
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
    | for_statement
    {
        $$ = $1;
    }
    ;

statement_or_block
    : statement
    {
        $$ = $1;
    }
    | block
    {
        $$ = $1;
    }
    ;

block
    : LBRACE statements RBRACE
    {
        $$ = "{\n" + $2 + "}\n";
    }
    ;

for_statement
    : FOR LPAREN variable_declaration_left COLON expression RPAREN statement_or_block
    {
        $$ = "for (" + $3 + " : " + $5 + ") " + $7;
    }

call_parameters
    : %empty
    {
        $$ = "";
    }
    | expression COMMA call_parameters
    {
        $$ = $1 + ", " + $3;
    }
    | expression
    {
        $$ = $1;
    }
    ;

call_expression
    : expression2 LPAREN call_parameters RPAREN
    {
        $$ = "" + $1 + "(" + $3 + ")";
    }
    | expression2 DOT maybe_templated_function_name LPAREN call_parameters RPAREN
    {
        $$ = "(" + $1 + "." + $3 + ")(" + $5 + ")";
    }
    ;

variable_declaration_left
    : LET IDENTIFIER
    {
        $$ = "const auto&& " + $2;
    }
    | LET MUT IDENTIFIER
    {
        $$ = "LetMutable auto&& " + $3;
    }
    | REF IDENTIFIER
    {
        $$ = "const auto& " + $2;
    }
    ;

variable_declaration
    : variable_declaration_left EQUAL expression SEMICOLON
    {
        $$ = $1 + " = " + $3 + ";\n";
    }
    ;

expression
    : expression16
    {
        $$ = $1;
    }
    ;

expression16
    : expression15 QUESTION_MARK expression15 COLON expression15
    {
        $$ = "(" + $1 + " ? " + $3 + " : " + $5 + ")";
    }
    | expression15
    {
        $$ = $1;
    }
    ;

expression15
    : expression10
    {
        $$ = $1;
    }
    ;

expression10
    : expression10 EQUALS expression9
    {
        $$ = "(" + $1 + " == " + $3 + ")";
    }
    | expression9
    {
        $$ = $1;
    }

expression9
    : expression7
    {
        $$ = $1;
    }
    ;

expression7
    : expression7 LEFT_SHIFT expression6
    {
        $$ = "(" + $1 + " << " + $3 + ")";
    }
    | expression6
    {
        $$ = $1;
    }
    ;

expression6
    : expression6 PLUS expression5
    {
        $$ = "(" + $1 + " + " + $3 + ")";
    }
    | expression6 MINUS expression5
    {
        $$ = "(" + $1 + " - " + $3 + ")";
    }
    | expression5
    {
        $$ = $1;
    }
    ;

expression5
    : expression5 STAR expression4
    {
        $$ = "(" + $1 + " * " + $3 + ")";
    }
    | expression4
    {
        $$ = $1;
    }
    ;

expression4
    : expression2
    {
        $$ = $1;
    }
    ;

expression2
    : call_expression
    {
        $$ = $1;
    }
    | LPAREN expression RPAREN
    {
        $$ = "(" + $2 + ")";
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
        $$ += "\"s";
    }
    | CHAR_LITERAL
    {
        $$ = "'" + string(1, $1) + "'";
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
        assert($1.size() > 0);
        if ($1.back() == '!')
            $$ = $1.substr(0, $1.size() - 1) + "_exclamation";
        else if ($1.back() == '?')
            $$ = $1.substr(0, $1.size() - 1) + "_question";
        else
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
