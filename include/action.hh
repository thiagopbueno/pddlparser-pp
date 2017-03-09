#ifndef _ACTION_HH_
#define _ACTION_HH_

#include <string>
#include <vector>
#include <iostream>

class Action {
public:
	Action(const std::string& name, const std::vector<std::string> *parameters);
	~Action();

	friend std::ostream& operator<<(std::ostream& out, const Action& action);
private:
	std::string _name;
	const std::vector<std::string> *_parameters;
};

#endif // _ACTION_HH_
