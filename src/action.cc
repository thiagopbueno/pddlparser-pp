#include "action.hh"

using namespace std;

Action::Action(const string& name, const vector<string> *parameters) :
	_name(name), _parameters(parameters)
{

}

Action::~Action()
{
	delete _parameters;
}

ostream &
operator<<(ostream& out, const Action& action)
{
	out << "Action(name:" << action._name;
	out << ", params:[";
	auto size = action._parameters->size();
	for (decltype(size) i = 0; i < size; ++i) {
		if (i == 0) {
			out << (*action._parameters)[i];
		}
		else {
			out << ", " << (*action._parameters)[i];
		}
	}
	out << "]";
	out << ")" << endl;
	return out;
}
