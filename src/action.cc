#include "action.hh"

using namespace std;

Action::Action(
	const string& name,
	const vector<string> *parameters,
	const std::vector<Predicate*> *preconditions,
	const std::vector<Predicate*> *effects) :
		_name(name),_parameters(parameters),
		_preconditions(preconditions), _effects(effects)
{

}

Action::~Action()
{
	delete _parameters;

	for (auto precondition : *_preconditions) {
		delete precondition;
	}
	delete _preconditions;

	for (auto effect : *_effects) {
		delete effect;
	}
	delete _effects;
}

ostream &
operator<<(ostream& out, const Action& action)
{
	out << "Action(name:" << action._name << ")" << endl;
	out << ">> params:[";
	auto size = action._parameters->size();
	for (decltype(size) i = 0; i < size; ++i) {
		if (i == 0) {
			out << (*action._parameters)[i];
		}
		else {
			out << ", " << (*action._parameters)[i];
		}
	}
	out << "]" << endl;
	out << ">> preconditions:[";
	size = action._preconditions->size();
	for (decltype(size) i = 0; i < size; ++i) {
		if (i == 0) {
			out << *(*action._preconditions)[i];
		}
		else {
			out << ", " << *(*action._preconditions)[i];
		}
	}
	out << "]" << endl;
	size = action._effects->size();
	out << ">> effects:[";
	for (decltype(size) i = 0; i < size; ++i) {
		if (i == 0) {
			out << *(*action._effects)[i];
		}
		else {
			out << ", " << *(*action._effects)[i];
		}
	}
	out << "])" << endl;
	return out;
}
