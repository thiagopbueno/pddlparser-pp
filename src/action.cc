#include "action.hh"

using namespace std;

Action::Action(const string &name) : _name(name)
{

}

ostream &
operator<<(ostream &os, const Action &action)
{
	os << "Action(name:" << action._name << ")" << endl;
	return os;
}
