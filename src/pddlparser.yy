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

using StringList    = std::vector<std::string>;
using TypeDict      = std::map<std::string,std::string>;

using PredicateList = std::vector<Predicate*>;
using ParameterList = std::pair<StringList*,TypeDict*>;
using ArgumentList  = std::pair<StringList*,TypeDict*>;

using Literal       = std::pair<Predicate*,bool>;
using AtomicFormula = std::vector<Literal*>;
using ActionDefBody = std::pair<AtomicFormula*,AtomicFormula*>;


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
%token <std::string>       NAME                   "name"
%token <std::string>       VARIABLE               "variable"
%token <int>               NUMBER                 "number"

%type <std::string>        domain-name            "domain-name"
%type <std::string>        problem-name           "problem-name"
%type <std::string>        domain-reference       "domain-reference"

%type <Action*>            action-def             "action-def"
%type <ActionDefBody*>     action-def-body        "action-def-body"

%type <AtomicFormula*>     preconditions-list     "preconditions-list"
%type <AtomicFormula*>     effects-list           "effects-list"
%type <AtomicFormula*>     atomic-formula         "atomic-formula"

%type <Predicate*>         predicate              "predicate"
%type <Literal*>           literal                "literal"

%type <PredicateList*>     predicates-list        "predicates-list"
%type <ParameterList*>     parameters-list        "parameters-list"
%type <AtomicFormula*>     literal-list           "literal-list"

%type <TypeDict*>          typed-variables-list   "typed-variables-list"
%type <StringList*>        variables-list         "variables-list"


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

types
    : LPAREN TYPES names-list RPAREN {}
    | LPAREN TYPES typed-names-list RPAREN {}
    ;

constants
    : LPAREN CONSTANTS names-list RPAREN {}
    | LPAREN CONSTANTS typed-names-list RPAREN {}
    ;

predicates: LPAREN PREDICATES predicates-list RPAREN {} ;

actions
    : action-def         { driver.domain->add_action($1); }
    | actions action-def { driver.domain->add_action($2); }
    ;

action-def: LPAREN ACTION NAME parameters-list action-def-body RPAREN
    {
        $$ = new Action($3, $4, $5->first, $5->second);
        delete $5;
    };

predicates-list
    : predicate { $$ = new PredicateList; $$->push_back($1); }
    | predicates-list predicate { $1->push_back($2); $$ = $1;}
    ;

parameters-list
    : PARAMETERS LPAREN typed-variables-list RPAREN
        {
            StringList *parameters = new StringList();
            for (const auto& param : *$3) {
                parameters->push_back(param.first);
            }
            $$ = new ParameterList(parameters, $3);
        }
    | PARAMETERS LPAREN variables-list RPAREN
        {
            $$ = new ParameterList($3, nullptr);
        }
    | PARAMETERS LPAREN RPAREN
        {
            $$ = new ParameterList(nullptr, nullptr);
        }
    ;

action-def-body: preconditions-list effects-list
    {
        $$ = new ActionDefBody($1, $2);
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

names-list
    : NAME {}
    | names-list NAME {}
    ;

typed-names-list
    : names-list HYPHEN NAME {}
    | typed-names-list names-list HYPHEN NAME {}
    ;

variables-list
    : VARIABLE { $$ = new StringList; $$->push_back($1); }
    | variables-list VARIABLE { $1->push_back($2); $$ = $1; }
    ;

typed-variables-list
    : variables-list HYPHEN NAME
        {
            std::string type($3);
            $$ = new TypeDict;
            for (const auto& var : *$1) {
                (*$$)[var] = type;
            }
        }
    | typed-variables-list variables-list HYPHEN NAME
        {
            std::string type($4);
            for (const auto& var : *$2) {
                (*$1)[var] = type;
            }
            $$ = $1;
        }
    ;

literal-list
    : literal { $$ = new AtomicFormula; $$->push_back($1); }
    | literal-list literal { $1->push_back($2); $$ = $1; }
    ;

grounded-literal-list
    : grounded-literal {}
    | grounded-literal-list grounded-literal {}
    ;

atomic-formula
    : literal { $$ = new AtomicFormula; $$->push_back($1); }
    | LPAREN AND literal-list RPAREN { $$ = $3; }
    ;

grounded-atomic-formula
    : grounded-literal {}
    | LPAREN AND grounded-literal-list RPAREN {}
    ;

predicate
    : LPAREN NAME typed-variables-list RPAREN
        {
            StringList *vars = new StringList;
            for (const auto& var : *$3) {
                vars->push_back(var.first);
            }
            auto args = new ArgumentList(vars, $3);
            $$ = new Predicate($2, args);
        }
    | LPAREN NAME variables-list RPAREN
        {
            auto args = new ArgumentList($3, nullptr);
            $$ = new Predicate($2, args);
        }
    | LPAREN EQUAL VARIABLE VARIABLE RPAREN
        {
            StringList *vars = new StringList(2);
            (*vars)[0] = $3;
            (*vars)[1] = $4;
            auto args = new ArgumentList(vars, nullptr);
            $$ = new Predicate("=", args);
        }
    ;

grounded-predicate
    : LPAREN NAME names-list RPAREN {}
    | LPAREN EQUAL NAME NAME RPAREN {}
    ;

literal
    : predicate { $$ = new Literal($1, true); }
    | LPAREN NOT predicate RPAREN { $$ = new Literal($3, false); }
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
