#include "predicate.hh"
using namespace std;

Predicate::Predicate(string name, vector<string> *args, bool negated) :
	_name(name), _args(args), _negated(negated)
{

}

Predicate::~Predicate()
{
	delete _args;
}

ostream&
operator<<(ostream& out, const Predicate& predicate)
{
	if (predicate._negated) {
		out << "not ";
	}
	out << predicate._name << "(";
	int i = 0;
	for (auto arg : *(predicate._args)) {
		if (i == 0) {
			out << arg;
		}
		else {
			out << "," << arg;
		}
		++i;
	}
	out << ")";
	return out;
}
