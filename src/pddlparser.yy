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

using ActionList    = std::vector<Action*>;
using PredicateList = std::vector<Predicate*>;
using ParameterList = std::pair<StringList*,TypeDict*>;
using ArgumentList  = std::pair<StringList*,TypeDict*>;

using Literal       = std::pair<Predicate*,bool>;
using LiteralList   = std::vector<Literal*>;
using ActionDefBody = std::pair<LiteralList*,LiteralList*>;

using DomainBody    = struct {
    StringList     *requirements;
    PredicateList  *predicates;
    ActionList     *actions;
};


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
%token <int>               NUMBER                 "number"
%token <std::string>       VARIABLE               "variable"
%token <std::string>       REQUIREKEY             "requirekey"

%type <Domain*>            domain-def             "domain-def"
%type <std::string>        domain-name            "domain-name"
%type <DomainBody*>        domain-body            "domain-body"

%type <Problem*>           problem-def            "problem-def"
%type <std::string>        problem-name           "problem-name"
%type <std::string>        domain-reference       "domain-reference"

%type <ActionList*>        actions                "actions"
%type <Action*>            action-def             "action-def"
%type <ActionDefBody*>     action-def-body        "action-def-body"

%type <LiteralList*>     preconditions-list     "preconditions-list"
%type <LiteralList*>     effects-list           "effects-list"
%type <LiteralList*>     atomic-formula         "atomic-formula"

%type <Predicate*>         predicate              "predicate"
%type <Predicate*>         grounded-predicate     "grounded-predicate"

%type <Literal*>           literal                "literal"
%type <LiteralList*>       literal-list           "literal-list"

%type <Literal*>           grounded-literal       "grounded-literal"
%type <LiteralList*>       grounded-literal-list  "grounded-literal-list"

%type <StringList*>        requirements-def      "requirements-def"
%type <StringList*>        requirekeys-list       "requirekeys-list"

%type <PredicateList*>     predicates-def         "predicates-def"
%type <PredicateList*>     predicates-list        "predicates-list"
%type <ParameterList*>     parameters-list        "parameters-list"

%type <TypeDict*>          typed-variables-list   "typed-variables-list"
%type <StringList*>        variables-list         "variables-list"

%type <StringList*>        names-list             "names-list"
%type <TypeDict*>          typed-names-list       "typed-names-list"

%type <StringList*>        objects-def            "objects-def"

%type <LiteralList*>       init-def               "init-def"

%printer { yyoutput << $$; } <*>;


%%


%start pddl;

pddl
    : domain-def  { driver.domain  = $1; }
    | problem-def { driver.problem = $1; }
    ;

domain-def: LPAREN DEFINE domain-name domain-body RPAREN
    {
        $$ = new Domain($3);
        $$->set_requirements($4->requirements);
        $$->set_predicates($4->predicates);
        $$->set_actions($4->actions);
        delete $4;
    } ;

domain-name: LPAREN DOMAIN NAME RPAREN { $$ = $3; } ;

domain-body
    : requirements-def predicates-def actions { $$ = new DomainBody{$1, $2, $3}; }
    | requirements-def constants predicates-def actions { $$ = new DomainBody{$1, $3, $4}; }
    | requirements-def types predicates-def actions { $$ = new DomainBody{$1, $3, $4}; }
    | requirements-def types constants predicates-def actions { $$ = new DomainBody{$1, $4, $5}; }
    ;

requirements-def: LPAREN REQUIREMENTS requirekeys-list RPAREN { $$ = $3; } ;

types
    : LPAREN TYPES names-list RPAREN {}
    | LPAREN TYPES typed-names-list RPAREN {}
    ;

constants
    : LPAREN CONSTANTS names-list RPAREN {}
    | LPAREN CONSTANTS typed-names-list RPAREN {}
    ;

predicates-def: LPAREN PREDICATES predicates-list RPAREN { $$ = $3; } ;

actions
    : action-def         { $$ = new ActionList; $$->push_back($1); }
    | actions action-def { $1->push_back($2); $$ = $1; }
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

problem-def: LPAREN DEFINE problem-name domain-reference objects-def init-def goal RPAREN
    {
        $$ = new Problem($3, $4);
        $$->set_objects($5);
        $$->set_init_state($6);
    } ;

problem-name: LPAREN PROBLEM NAME RPAREN
    {
        $$ = $3;
    } ;

domain-reference: LPAREN DOMAIN NAME RPAREN
    {
        $$ = $3;
    }

objects-def: LPAREN OBJECTS names-list RPAREN { $$ = $3; } ;

init-def: LPAREN INIT grounded-literal-list RPAREN { $$ = $3; } ;

goal: LPAREN GOAL grounded-atomic-formula RPAREN {} ;

requirekeys-list
    : REQUIREKEY { $$ = new StringList; $$->push_back($1); }
    | requirekeys-list REQUIREKEY { $1->push_back($2); $$ = $1; }
    ;

names-list
    : NAME { $$ = new StringList; $$->push_back($1); }
    | names-list NAME { $1->push_back($2); $$ = $1; }
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
    : literal { $$ = new LiteralList; $$->push_back($1); }
    | literal-list literal { $1->push_back($2); $$ = $1; }
    ;

grounded-literal-list
    : grounded-literal { $$ = new LiteralList; $$->push_back($1); }
    | grounded-literal-list grounded-literal { $1->push_back($2); $$ = $1; }
    ;

atomic-formula
    : literal { $$ = new LiteralList; $$->push_back($1); }
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
    : LPAREN NAME names-list RPAREN
        {
            auto args = new ArgumentList($3, nullptr);
            $$ = new Predicate($2, args);
        }
    | LPAREN EQUAL NAME NAME RPAREN
        {
            StringList *vars = new StringList(2);
            (*vars)[0] = $3;
            (*vars)[1] = $4;
            auto args = new ArgumentList(vars, nullptr);
            $$ = new Predicate("=", args);
        }
    ;

literal
    : predicate { $$ = new Literal($1, true); }
    | LPAREN NOT predicate RPAREN { $$ = new Literal($3, false); }
    ;

grounded-literal
    : grounded-predicate { $$ = new Literal($1, true); }
    | LPAREN NOT grounded-predicate RPAREN { $$ = new Literal($3, false); }
    ;


%%


void
yy::PDDLParser::error (const location_type& l, const std::string& m)
{
    driver.error (l, m);
}
