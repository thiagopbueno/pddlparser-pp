#ifndef _PDDL_DRIVER_HH_
#define _PDDL_DRIVER_HH_

#include "pddlparser.tab.hh"
#include "domain.hh"
#include "problem.hh"

#include <string>

// Tell Flex the lexer's prototype ...
# define YY_DECL yy::PDDLParser::symbol_type yylex (PDDLDriver& driver)

// ... and declare it for the parser's sake.
YY_DECL;

class PDDLDriver {
public:
    PDDLDriver();
    virtual ~PDDLDriver();

    Domain *domain;
    Problem *problem;

    // Handling the scanner.
    void scan_begin();
    void scan_end();

    // Run the parser on file F.
    // Return 0 on success.
    int parse(const std::string& f);
    int result;

    // The name of the file being parsed.
    // Used later to pass the file name to the location tracker.
    std::string file;

    // Whether traces should be generated.
    bool trace_scanning;
    bool trace_parsing;

    // Error handling.
    void error(const yy::location& l, const std::string& m);
    void error(const std::string& m);
};

#endif // ! _PDDL_DRIVER_HH_
