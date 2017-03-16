#include "action.hh"

using namespace std;

Action::Action(
	const string&        name,
	const ParameterList *parameters,
	const PredicateList *preconditions,
	const PredicateList *effects) :
		_name(name),
		_parameters(parameters->first), _types(parameters->second),
		_preconditions(preconditions), _effects(effects)
{

}

Action::~Action()
{
	if (_parameters) delete _parameters;
	if (_types)      delete _types;

	for (auto precondition : *_preconditions) {
		delete precondition;
	}
	if (_preconditions) delete _preconditions;

	for (auto effect : *_effects) {
		delete effect;
	}
	delete _effects;
}

ostream &
operator<<(ostream& out, const Action& action)
{
	out << "Action(name:" << action._name << ")" << endl;
	if (action._parameters) {
		out << ">> params:[";
		auto size = action._parameters->size();
		for (decltype(size) i = 0; i < size; ++i) {
			auto parameter = (*action._parameters)[i];
			if (i == 0) {
				out << parameter;
			}
			else {
				out << ", " << parameter;
			}
			if (action._types && action._types->find(parameter) != action._types->end()) {
				out << " - " << action._types->at(parameter);
			}
		}
		out << "]" << endl;
	}
	out << ">> preconditions:[";
	auto size = action._preconditions->size();
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
