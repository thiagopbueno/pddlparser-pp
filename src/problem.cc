#include "problem.hh"

using namespace std;

Problem::Problem(const string& name) : _name(name)
{

}

ostream&
operator<<(ostream& os, const Problem& problem)
{
	os << ">> Problem(name:" << problem._name << ")" << endl;
	return os;
}
