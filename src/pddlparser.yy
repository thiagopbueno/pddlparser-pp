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
#include <tuple>

#include "domain.hh"
#include "problem.hh"
#include "action.hh"
#include "predicate.hh"

using PredicateList = std::vector<Predicate*>;
using ActionDefBody = std::pair<PredicateList*,PredicateList*>;
using StringList    = std::vector<std::string>;

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
%token <std::string>     NAME                "name"
%token <std::string>     VARIABLE            "variable"
%token <int>             NUMBER              "number"

%type <std::string>      domain-name         "domain-name"
%type <std::string>      problem-name        "problem-name"
%type <std::string>      domain-reference    "domain-reference"

%type <Action*>          action-def           "action-def"
%type <ActionDefBody*>   action-def-body      "action-def-body"

%type <PredicateList*>   atomic-formula      "atomic-formula"
%type <PredicateList*>   preconditions-list  "preconditions-list"
%type <PredicateList*>   effects-list        "effects-list"

%type <Predicate*>       predicate           "predicate"
%type <Predicate*>       literal             "literal"

%type <StringList*>      parameters-list     "parameters-list"
%type <StringList*>      variables-list      "variables-list"
%type <PredicateList*>   literal-list        "literal-list"


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
        $$ = new Action($3, $4, $5->first, $5->second);
        delete $5;
    };

parameters-list
    : PARAMETERS LPAREN typed-variables-list RPAREN {}
    | PARAMETERS LPAREN variables-list RPAREN { $$ = $3; }
    | PARAMETERS LPAREN RPAREN { $$ = nullptr; }
    ;

action-def-body: preconditions-list effects-list
    {
        $$ = new std::pair<PredicateList*,PredicateList*>($1, $2);
    };

preconditions-list: PRECONDITIONS atomic-formula { $$ = $2; } ;

effects-list: EFFECTS atomic-formula { $$ = $2; } ;

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
    : /* empty */ { $$ = new StringList; }
    | variables-list VARIABLE { $1->push_back($2); $$ = $1; }
    ;

typed-variables-list
    : variables-list HYPHEN NAME {}
    | typed-variables-list variables-list HYPHEN NAME {}
    ;

literal-list
    : /* empty */ { $$ = new std::vector<Predicate*>; }
    | literal-list literal { $1->push_back($2); $$ = $1; }
    ;

grounded-literal-list
    : grounded-literal {}
    | grounded-literal-list grounded-literal {}
    ;

atomic-formula
    : literal { $$ = new std::vector<Predicate*>; $$->push_back($1); }
    | LPAREN AND literal-list RPAREN { $$ = $3; }
    ;

grounded-atomic-formula
    : grounded-literal {}
    | LPAREN AND grounded-literal-list RPAREN {}
    ;

predicate
    : LPAREN NAME typed-variables-list RPAREN {}
    | LPAREN NAME variables-list RPAREN { $$ = new Predicate($2, $3); }
    | LPAREN EQUAL VARIABLE VARIABLE RPAREN
        {
            StringList *args = new StringList(2);
            (*args)[0] = $3;
            (*args)[1] = $4;
            $$ = new Predicate("=", args);
        }
    ;

grounded-predicate
    : LPAREN NAME names-list RPAREN {}
    | LPAREN EQUAL NAME NAME RPAREN {}
    ;

literal
    : predicate { $$ = $1; }
    | LPAREN NOT predicate RPAREN { $3->negate(); $$ = $3; }
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
