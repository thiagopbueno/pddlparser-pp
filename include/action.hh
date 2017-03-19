#ifndef _ACTION_HH_
#define _ACTION_HH_

#include "predicate.hh"

#include <string>
#include <vector>
#include <tuple>
#include <map>
#include <iostream>

using StringList       = std::vector<std::string>;
using TypeDict         = std::map<std::string,std::string>;

using PredicateList    = std::vector<Predicate*>;
using ParameterList    = std::pair<StringList*,TypeDict*>;
using PreconditionList = std::vector<std::pair<Predicate*,bool>*>;
using EffectList       = std::vector<std::pair<Predicate*,bool>*>;

class Action {
public:
	Action(
		const std::string&      name,
		const ParameterList    *params,
		const PreconditionList *precond,
		const EffectList       *effects
	);

	virtual ~Action();

	friend std::ostream& operator<<(std::ostream& out, const Action& action);

private:
	std::string             _name;
	const StringList       *_params;
	const TypeDict         *_types;
	const PreconditionList *_precond;
	const EffectList       *_effects;
};

#endif // _ACTION_HH_
