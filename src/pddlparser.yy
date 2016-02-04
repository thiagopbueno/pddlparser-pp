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
#include <iostream>

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
    END  0          "end of file"
    LPAREN          "("
    RPAREN          ")"
    DEFINE          "define"
    DOMAIN          "domain"
    PROBLEM         "problem"
    PREDICATES      "predicates"
    REQUIREMENTS    "requirements"
    REQUIREKEY      "requirekey"
    ACTION          "action"
    PARAMETERS      "parameters"
    PRECONDITIONS   "preconditions"
    EFFECTS         "effects"
    AND             "and"
    NOT             "not"
    OBJECTS         "objects"
    INIT            "init"
    GOAL            "goal"
;
%token <std::string>    NAME            "name"
%token <std::string>    VARIABLE        "variable"
%token <int>            NUMBER          "number"

%type <std::string>     domain-name     "domain-name"
%type <std::string>     problem-name    "problem-name"

%printer { yyoutput << $$; } <*>;


%%


%start pddl;

pddl
    : domain  { driver.print_domain(); }
    | problem { driver.print_problem(); }
    ;

domain: LPAREN DEFINE domain-name requirements predicates actions RPAREN {} ;

domain-name: LPAREN DOMAIN NAME RPAREN { driver.domain = $$ = $3; } ;

requirements: LPAREN REQUIREMENTS requirekeys-list RPAREN {} ;

predicates: LPAREN PREDICATES predicates-list RPAREN {} ;

actions
    : action-def {}
    | actions action-def {}
    ;

action-def: LPAREN ACTION NAME parameters action-def-body RPAREN { std::cout << "action: " + $3 << std::endl; } ;

parameters
    : PARAMETERS LPAREN variables-list RPAREN {}
    | PARAMETERS LPAREN RPAREN {}
    ;

action-def-body: preconditions effects {} ;

preconditions: PRECONDITIONS atomic-formula {} ;

effects: EFFECTS atomic-formula {} ;

problem: LPAREN DEFINE problem-name domain-name objects init goal RPAREN {} ;

problem-name: LPAREN PROBLEM NAME RPAREN { driver.problem = $$ = $3; } ;

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

variables-list
    : VARIABLE {}
    | variables-list VARIABLE {}
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


predicate: LPAREN NAME variables-list RPAREN {} ;

grounded-predicate: LPAREN NAME names-list RPAREN {} ;

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
