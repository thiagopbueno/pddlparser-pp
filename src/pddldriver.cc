#include "pddldriver.hh"
#include "pddlparser.tab.hh"

using namespace std;

PDDLDriver::PDDLDriver() : trace_scanning(false), trace_parsing(false)
{
}

PDDLDriver::~PDDLDriver ()
{
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

void
PDDLDriver::print_domain()
{
	cout << "domain: "  + domain << endl;
}

void
PDDLDriver::print_problem()
{
	cout << "domain: "  + domain << endl;
	cout << "problem: " + problem << endl;
}
