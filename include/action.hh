#ifndef _ACTION_HH_
#define _ACTION_HH_

#include "predicate.hh"

#include <string>
#include <vector>
#include <map>
#include <iostream>

using StringList       = std::vector<std::string>;
using TypeDict         = std::map<std::string,std::string>;

using PredicateList    = std::vector<Predicate*>;
using ParameterList    = std::pair<StringList*,TypeDict*>;
using PreconditionList = std::vector<Predicate*>;
using EffectList       = std::vector<Predicate*>;

class Action {
public:
	Action(
		const std::string&      name,
		const ParameterList    *parameters,
		const PreconditionList *preconditions,
		const EffectList       *effects
	);

	virtual ~Action();

	friend std::ostream& operator<<(std::ostream& out, const Action& action);

private:
	std::string             _name;
	const StringList       *_parameters;
	const TypeDict         *_types;
	const PreconditionList *_preconditions;
	const EffectList       *_effects;
};

#endif // _ACTION_HH_
