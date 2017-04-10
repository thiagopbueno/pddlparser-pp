#include "domain.hh"

using namespace std;

Domain::Domain(const string &name) : _name(name)
{

}

Domain::~Domain()
{
	for (auto predicate : *_predicates) {
		delete predicate;
		predicate = nullptr;
	}
	delete _predicates;

	for (auto action : *_actions) {
		delete action;
		action = nullptr;
	}
	delete _actions;
}

void
Domain::set_requirements(std::vector<std::string>* requirements)
{
	_requirements = requirements;
}

void
Domain::set_predicates(std::vector<Predicate*>* predicates)
{
	_predicates = predicates;
}

void
Domain::set_actions(std::vector<Action*>* actions)
{
	_actions = actions;
}

std::ostream&
operator<<(std::ostream& out, const Domain& domain)
{
	out << ">> Domain(name:" << domain._name << ")" << endl;
	out << endl;
	out << "Requirements: [";
	for (auto const& requirement : *domain._requirements) {
		out << " " << requirement;
	}
	out << " ]" << endl;
	out << "Predicates: [";
	for (auto const& predicate : *domain._predicates) {
		out << " " << *predicate;
	}
	out << " ]" << endl;
	out << endl;
	for (auto const& action : *domain._actions) {
		out << *action;
		out << endl;
	}
	return out;
}
