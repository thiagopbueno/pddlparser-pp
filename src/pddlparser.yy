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
    END  0      "end of file"
    LPAREN      "("
    RPAREN      ")"
    DEFINE      "define"
    DOMAIN      "domain"
    PROBLEM     "problem"
;
%token <std::string>    NAME            "name"
%token <int>            NUMBER          "number"

%type <std::string>     domain-name     "domain-name"
%type <std::string>     problem-name    "problem-name"

%printer { yyoutput << $$; } <*>;


%%


%start pddl;

pddl
    : domain  { driver.print_domain(); }
    | problem { driver.print_problem(); };

domain: LPAREN DEFINE domain-name RPAREN
{

};

domain-name: LPAREN DOMAIN NAME RPAREN
{
    driver.domain = $$ = $3;
};

problem: LPAREN DEFINE problem-name domain-name RPAREN
{

};

problem-name: LPAREN PROBLEM NAME RPAREN
{
    driver.problem = $$ = $3;
};


%%


void
yy::PDDLParser::error (const location_type& l, const std::string& m)
{
    driver.error (l, m);
}
