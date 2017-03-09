%skeleton "lalr1.cc" /* -*- C++ -*- */

%require "3.0.4"

%defines
%define parser_class_name {PDDLParser}
%define api.token.constructor
%define api.value.type variant
%define parse.assert

%code requires
{
#include <string>
#include <vector>

#include "domain.hh"
#include "problem.hh"
#include "action.hh"

class PDDLDriver;
}

// The parsing context.
%param { PDDLDriver& driver }

%locations
%initial-action
{
// Initialize the initial location.
@$.begin.filename = @$.end.filename = &driver.file;
};

%define parse.trace
%define parse.error verbose

%code
{
#include "pddldriver.hh"
}

%define api.token.prefix {TOK_}
%token
    DEFINE          "define"
    DOMAIN          "domain"
    PROBLEM         "problem"
    REQUIREMENTS    "requirements"
    TYPES           "types"
    CONSTANTS       "constants"
    PREDICATES      "predicates"
    REQUIREKEY      "requirekey"
    ACTION          "action"
    PARAMETERS      "parameters"
    PRECONDITIONS   "preconditions"
    EFFECTS         "effects"
    AND             "and"
    NOT             "not"
    EQUAL           "="
    OBJECTS         "objects"
    INIT            "init"
    GOAL            "goal"
    LPAREN          "("
    RPAREN          ")"
    HYPHEN           "-"
    END  0          "end of file"
;
%token <std::string>    NAME                "name"
%token <std::string>    VARIABLE            "variable"
%token <int>            NUMBER              "number"

%type <std::string>     domain-name         "domain-name"
%type <std::string>     problem-name        "problem-name"
%type <std::string>     domain-reference    "domain-reference"

%type <Action*>         action-def          "action-def"

%type <std::vector<std::string>*> parameters-list "parameters-list"
%type <std::vector<std::string>*> variables-list  "variables-list"

%printer { yyoutput << $$; } <*>;


%%


%start pddl;

pddl
    : domain  {}
    | problem {}
    ;

domain: LPAREN DEFINE domain-name domain-body RPAREN {} ;

domain-name: LPAREN DOMAIN NAME RPAREN
    {
        $$ = $3;
        driver.domain = new Domain($$);
    } ;

domain-body
    : requirements predicates actions {}
    | requirements constants predicates actions {}
    | requirements types predicates actions {}
    | requirements types constants predicates actions {}
    ;

requirements: LPAREN REQUIREMENTS requirekeys-list RPAREN {} ;

types: LPAREN TYPES names-list RPAREN {} ;

constants: LPAREN CONSTANTS typed-names-list RPAREN {} ;

predicates: LPAREN PREDICATES predicates-list RPAREN {} ;

actions
    : action-def { driver.domain->add_action($1); }
    | actions action-def { driver.domain->add_action($2); }
    ;

action-def: LPAREN ACTION NAME parameters-list action-def-body RPAREN
    {
        $$ = new Action($3, $4);
    };

parameters-list
    : PARAMETERS LPAREN typed-variables-list RPAREN {}
    | PARAMETERS LPAREN variables-list RPAREN { $$ = $3; }
    | PARAMETERS LPAREN RPAREN { $$ = nullptr; }
    ;

action-def-body: preconditions effects {} ;

preconditions: PRECONDITIONS atomic-formula {} ;

effects: EFFECTS atomic-formula {} ;

problem: LPAREN DEFINE problem-name domain-reference objects init goal RPAREN {} ;

problem-name: LPAREN PROBLEM NAME RPAREN
    {
        $$ = $3;
        driver.problem = new Problem($$);
    } ;

domain-reference: LPAREN DOMAIN NAME RPAREN
    {
        $$ = $3;
    }

objects: LPAREN OBJECTS names-list RPAREN {} ;

init: LPAREN INIT grounded-literal-list RPAREN {} ;

goal: LPAREN GOAL grounded-atomic-formula RPAREN {} ;

requirekeys-list
    : REQUIREKEY {}
    | requirekeys-list REQUIREKEY {}
    ;

predicates-list
    : predicate {}
    | predicates-list predicate {}
    ;

names-list
    : NAME {}
    | names-list NAME {}
    ;

typed-names-list
    : names-list HYPHEN NAME {}
    | typed-names-list names-list HYPHEN NAME {}
    ;

variables-list
    : /* empty */ { $$ = new std::vector<std::string>; }
    | variables-list VARIABLE { $1->push_back($2); $$ = $1; }
    ;

typed-variables-list
    : variables-list HYPHEN NAME {}
    | typed-variables-list variables-list HYPHEN NAME {}
    ;

literal-list
    : literal {}
    | literal-list literal {}
    ;

grounded-literal-list
    : grounded-literal {}
    | grounded-literal-list grounded-literal {}
    ;

atomic-formula
    : literal {}
    | LPAREN AND literal-list RPAREN {}
    ;

grounded-atomic-formula
    : grounded-literal {}
    | LPAREN AND grounded-literal-list RPAREN {}
    ;

predicate
    : LPAREN NAME typed-variables-list RPAREN {}
    | LPAREN NAME variables-list RPAREN {}
    | LPAREN EQUAL VARIABLE VARIABLE RPAREN {}
    ;

grounded-predicate
    : LPAREN NAME names-list RPAREN {}
    | LPAREN EQUAL NAME NAME RPAREN {}
    ;

literal
    : predicate {}
    | LPAREN NOT predicate RPAREN {}
    ;

grounded-literal
    : grounded-predicate {}
    | LPAREN NOT grounded-predicate RPAREN {}
    ;

%%


void
yy::PDDLParser::error (const location_type& l, const std::string& m)
{
    driver.error (l, m);
}
