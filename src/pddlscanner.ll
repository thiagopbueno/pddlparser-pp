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

name  [a-zA-Z][a-zA-Z_0-9\-]*
int   [0-9]+
blank [ \t]

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

"("                   { return yy::PDDLParser::make_LPAREN(loc); };
")"                   { return yy::PDDLParser::make_RPAREN(loc); };

{name}                { return yy::PDDLParser::make_NAME(yytext, loc); };

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

