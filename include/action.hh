#ifndef _ACTION_HH_
#define _ACTION_HH_

#include <string>
#include <iostream>

class Action {
public:
	Action(const std::string &name);

	friend std::ostream &operator<<(std::ostream &os, const Action &action);
private:
	std::string _name;
};

#endif // _ACTION_HH_
