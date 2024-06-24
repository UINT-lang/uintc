%{
#include "scanner.hpp"
#include <bits/stdc++.h>
using namespace std;
%}
 
%require "3.8"
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
 
%token LPAREN RPAREN SEMICOLON LBRACE RBRACE EQUAL LEFT_SHIFT PLUS DOT LESS_THAN GREATER_THAN COLON EQUALS QUESTION_MARK STAR COMMA MINUS SLASH PLUS_EQUAL MOD LOGICAL_AND GREATER_EQUAL LESS_EQUAL LBRACKET RBRACKET PIPE DOUBLE_ARROW DOUBLE_COLON
%token CPP FN LET FOR REF LET_MUT WHILE IF ELSE FWD REF_MUT
%token CHAR_LITERAL_NEWLINE

%precedence RPAREN
%precedence ELSE

%left EQUALS
%right QUESTION_MARK
%left LEFT_SHIFT
%left PLUS
%left DOT

%token <std::string> INLINE_STRING_LITERAL
%token <std::string> MULTILINE_STRING_LITERAL
%token <std::string> IDENTIFIER
%token <int32_t> I32_LITERAL
%token <double> F64_LITERAL
%token <char> CHAR_LITERAL

%type <char> char_literal

%type <std::string> identifier
%type <std::string> string_literal
%type <std::string> cpp_statement
%type <std::string> fn_declaration
%type <std::string> statements
%type <std::string> statement
%type <std::string> statement_or_block
%type <std::string> block
%type <std::string> top_levels
%type <std::string> top_level
%type <std::string> variable_declaration
%type <std::string> variable_declaration_left
%type <std::string> expression
%type <std::string> expression16
%type <std::string> expression15
%type <std::string> expression14
%type <std::string> expression13
%type <std::string> expression12
%type <std::string> expression10
%type <std::string> expression9
%type <std::string> expression8
%type <std::string> expression7
%type <std::string> expression6
%type <std::string> expression5
%type <std::string> expression4
%type <std::string> expression2
%type <std::string> call_parameters
%type <std::string> maybe_templated_function_name
%type <std::string> for_statement
%type <std::string> while_statement
%type <std::string> if_statement
%type <std::string> lambda
%type <std::string> variable_declaration_lefts

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
    | variable_declaration
    {
        $$ = "namespace UINT { static " + $1 + " }\n";
    }
    ;

cpp_statement
    : CPP LPAREN string_literal RPAREN
    {
        $$ = $3 + "\n";
    }
    ;

fn_declaration
    : FN identifier LPAREN RPAREN LBRACE statements RBRACE
    {
        stringstream ss;
        ss << "namespace UINT {\n";
        ss << "static auto " << $2 << "() {\n";
        ss << $6;
        ss << "}\n";
        ss << "}\n";
        $$ = ss.str();
    }
    | FN identifier EQUAL FWD expression SEMICOLON
    {
        stringstream ss;
        ss << "namespace UINT { template <typename... Args> static decltype(auto) " << $2 << "(Args&&... args) { return " << $5 << "(std::forward<Args>(args)...); } }\n";
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
    | while_statement
    {
        $$ = $1;
    }
    | if_statement
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
    ;

while_statement
    : WHILE LPAREN expression RPAREN statement_or_block
    {
        $$ = "while (" + $3 + ") " + $5;
    }
    ;

if_statement
    : IF LPAREN expression RPAREN statement_or_block
    {
        $$ = "if (" + $3 + ") " + $5;
    }
    | IF LPAREN expression RPAREN statement_or_block ELSE statement_or_block
    {
        $$ = "if (" + $3 + ") " + $5 + " else " + $7;
    }
    ;

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

variable_declaration_left
    : LET identifier
    {
        $$ = "const auto&& " + $2;
    }
    | LET_MUT identifier
    {
        $$ = "LetMutable auto&& " + $2;
    }
    | REF identifier
    {
        $$ = "const auto& " + $2;
    }
    | REF_MUT identifier
    {
        $$ = "RefMutable auto& " + $2;
    }
    ;

variable_declaration
    : variable_declaration_left EQUAL expression SEMICOLON
    {
        $$ = $1 + " = " + $3 + ";\n";
    }
    ;

variable_declaration_lefts
    : %empty
    {
        $$ = "";
    }
    | variable_declaration_left COMMA variable_declaration_lefts
    {
        $$ = $1 + ", " + $3;
    }
    | variable_declaration_left
    {
        $$ = $1;
    }
    ;

expression
    : expression16
    {
        $$ = $1;
    }
    | lambda
    {
        $$ = $1;
    }
    ;

expression16
    : expression15 QUESTION_MARK expression15 COLON expression15
    {
        $$ = "(" + $1 + " ? " + $3 + " : " + $5 + ")";
    }
    | expression15 PLUS_EQUAL expression16
    {
        $$ = "(" + $1 + " += " + $3 + ")";
    }
    | expression15
    {
        $$ = $1;
    }
    ;

expression15
    : expression14
    {
        $$ = $1;
    }
    ;

expression14
    : expression14 LOGICAL_AND expression13
    {
        $$ = "(" + $1 + " && " + $3 + ")";
    }
    | expression13
    {
        $$ = $1;
    }
    ;

expression13
    : expression13 PIPE expression12
    {
        $$ = "(" + $1 + " | " + $3 + ")";
    }
    | expression12
    {
        $$ = $1;
    }
    ;

expression12
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
    : expression9 LESS_THAN expression8
    {
        $$ = "(" + $1 + " < " + $3 + ")";
    }
    | expression9 GREATER_THAN expression8
    {
        $$ = "(" + $1 + " > " + $3 + ")";
    }
    | expression9 GREATER_EQUAL expression8
    {
        $$ = "(" + $1 + " >= " + $3 + ")";
    }
    | expression9 LESS_EQUAL expression8
    {
        $$ = "(" + $1 + " <= " + $3 + ")";
    }
    | expression8
    {
        $$ = $1;
    }

expression8
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
    | expression5 SLASH expression4
    {
        $$ = "(" + $1 + " / " + $3 + ")";
    }
    | expression5 MOD expression4
    {
        $$ = "(" + $1 + " % " + $3 + ")";
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

lambda
    : LPAREN variable_declaration_lefts RPAREN DOUBLE_ARROW expression
    {
        $$ = "[&](" + $2 + ") { return " + $5 + "; }";
    }
    | LPAREN variable_declaration_lefts RPAREN DOUBLE_ARROW block
    {
        $$ = "[&](" + $2 + ") " + $5;
    }
    | DOUBLE_ARROW expression
    {
        $$ = "[&]() { return " + $2 + "; }";
    }
    | DOUBLE_ARROW block
    {
        $$ = "[&]() " + $2;
    }
    ;

expression2
    : expression2 LPAREN call_parameters RPAREN
    {
        $$ = "" + $1 + "(" + $3 + ")";
    }
    | expression2 DOT maybe_templated_function_name LPAREN call_parameters RPAREN
    {
        $$ = "(" + $1 + "." + $3 + ")(" + $5 + ")";
    }
    | expression2 LBRACE call_parameters RBRACE
    {
        $$ = $1 + "{" + $3 + "}";
    }
    | expression2 LBRACKET expression RBRACKET
    {
        $$ = $1 + "[" + $3 + "]";
    }
    | expression2 DOUBLE_COLON identifier
    {
        $$ = $1 + "::" + $3;
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
    | F64_LITERAL
    {
        $$ = to_string($1) + "_f64";
    }
    | char_literal
    {
        stringstream stream;
        stream << "'\\x" << std::setfill('0') << std::setw(2) << std::hex << (int) (unsigned char) $1 << "'";
        $$ = stream.str();
    }
    | identifier
    {
        $$ = $1;
    }
    ;

identifier:
    IDENTIFIER
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
    : identifier
    {
        $$ = $1;
    }
    | identifier LESS_THAN identifier GREATER_THAN
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
