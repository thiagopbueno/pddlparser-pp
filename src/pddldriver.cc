#include "pddldriver.hh"
#include "pddlparser.tab.hh"

using namespace std;

PDDLDriver::PDDLDriver()
{
    trace_parsing = trace_scanning = false;
    domain = nullptr;
    problem = nullptr;
}

PDDLDriver::~PDDLDriver ()
{
    if (domain)  delete domain;
    if (problem) delete problem;
}

int
PDDLDriver::parse(const string &f)
{
    file = f;
    scan_begin();
    yy::PDDLParser parser(*this);
    parser.set_debug_level(trace_parsing);
    result = parser.parse();
    scan_end();
    return result;
}

void
PDDLDriver::error(const yy::location& l, const string& m)
{
    cerr << l << ": " << m << endl;
}

void
PDDLDriver::error(const string& m)
{
    cerr << m << endl;
}
