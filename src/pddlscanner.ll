%{ /* -*- C++ -*- */

#include <cerrno>
#include <climits>
#include <cstdlib>
#include <string>
#include "pddldriver.hh"
#include "pddlparser.tab.hh"

// Work around an incompatibility in flex (at least versions
// 2.5.31 through 2.5.33): it generates code that does
// not conform to C89.  See Debian bug 333231
// <http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=333231>.
#undef yywrap
#define yywrap() 1


// The location of the current token.
static yy::location loc;

%}

%option noyywrap nounput batch debug noinput

name      [a-zA-Z][a-zA-Z_0-9\-]*
variable  \?[a-zA-Z][a-zA-Z_0-9\-]*
int       [0-9]+
blank     [ \t]

requirekey (":strips"|":typing"|":equality")

%{
// Code run each time a pattern is matched.
#define YY_USER_ACTION  loc.columns (yyleng);
%}

%%

%{
// Code run each time yylex is called.
loc.step ();
%}

{blank}+              { loc.step(); };
[\n\r]+               { loc.lines(yyleng); loc.step(); };

"define"              { return yy::PDDLParser::make_DEFINE(loc); };

"domain"|":domain"    { return yy::PDDLParser::make_DOMAIN(loc); };
"problem"             { return yy::PDDLParser::make_PROBLEM(loc); };

":requirements"       { return yy::PDDLParser::make_REQUIREMENTS(loc); };

":types"              { return yy::PDDLParser::make_TYPES(loc); };
":constants"          { return yy::PDDLParser::make_CONSTANTS(loc); };
":predicates"         { return yy::PDDLParser::make_PREDICATES(loc); };

":action"             { return yy::PDDLParser::make_ACTION(loc); };
":parameters"         { return yy::PDDLParser::make_PARAMETERS(loc); };
":precondition"       { return yy::PDDLParser::make_PRECONDITIONS(loc); };
":effect"             { return yy::PDDLParser::make_EFFECTS(loc); };

":objects"            { return yy::PDDLParser::make_OBJECTS(loc); };
":init"               { return yy::PDDLParser::make_INIT(loc); };
":goal"               { return yy::PDDLParser::make_GOAL(loc); };

"and"|"AND"           { return yy::PDDLParser::make_AND(loc); };
"not"|"NOT"           { return yy::PDDLParser::make_NOT(loc); };
"="                   { return yy::PDDLParser::make_EQUAL(loc); };

{requirekey}          { return yy::PDDLParser::make_REQUIREKEY(yytext, loc); };

"("                   { return yy::PDDLParser::make_LPAREN(loc); };
")"                   { return yy::PDDLParser::make_RPAREN(loc); };
"-"                   { return yy::PDDLParser::make_HYPHEN(loc); };

{name}                { return yy::PDDLParser::make_NAME(yytext, loc); };
{variable}            { return yy::PDDLParser::make_VARIABLE(yytext, loc); };

{int} {
    errno = 0;
    long n = strtol(yytext, NULL, 10);
    if (!(INT_MIN <= n && n <= INT_MAX && errno != ERANGE)) {
        driver.error(loc, "integer is out of range");
    }
    return yy::PDDLParser::make_NUMBER(n, loc);
}

.           { driver.error(loc, "invalid character"); };

<<EOF>>     { return yy::PDDLParser::make_END(loc); };


%%


void
PDDLDriver::scan_begin()
{
    yy_flex_debug = trace_scanning;
    if (file.empty() || file == "-") {
       yyin = stdin;
    }
    else if (!(yyin = fopen(file.c_str(), "r"))) {
        error("cannot open " + file + ": " + strerror(errno));
        exit(EXIT_FAILURE);
    }
}



void
PDDLDriver::scan_end()
{
    fclose (yyin);
}

