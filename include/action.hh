#ifndef _ACTION_HH_
#define _ACTION_HH_

#include <string>
#include <vector>
#include <iostream>
#include "predicate.hh"

class Action {
public:
	Action(
		const std::string& name,
		const std::vector<std::string> *parameters,
		const std::vector<Predicate*>  *preconditions,
		const std::vector<Predicate*>  *effects
	);
	virtual ~Action();

	friend std::ostream& operator<<(std::ostream& out, const Action& action);

private:
	std::string                     _name;
	const std::vector<std::string> *_parameters;
	const std::vector<Predicate*>  *_preconditions;
	const std::vector<Predicate*>  *_effects;
};

#endif // _ACTION_HH_
