#include "domain.hh"

using namespace std;

Domain::Domain(const string &name) : _name(name)
{

}

Domain::~Domain()
{
	for (auto action : _actions) {
		delete action;
		action = nullptr;
	}
}

void
Domain::add_action(const Action *action)
{
	_actions.push_back(action);
}

std::ostream&
operator<<(std::ostream& os, const Domain& domain)
{
	os << ">> Domain(name:" << domain._name << ")" << endl;
	for (auto const& action : domain._actions) {
		os << *action;
	}
	return os;
}