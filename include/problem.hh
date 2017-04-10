#ifndef _PROBLEM_HH_
#define _PROBLEM_HH_

#include <string>
#include <iostream>
#include <vector>
#include <tuple>

#include "predicate.hh"

using StringList    = std::vector<std::string>;
using Literal       = std::pair<Predicate*,bool>;
using LiteralList   = std::vector<Literal*>;

class Problem {
public:
	Problem(const std::string& name, const std::string& domain);
	virtual ~Problem();

	void set_objects(StringList *objects);

	void set_init_state(LiteralList *init);
	void set_goal_state(LiteralList *goal);

	friend std::ostream &operator<<(std::ostream& out, const Problem& problem);

private:
	std::string _name;
	std::string _domain;

	StringList  *_objects;
	LiteralList *_init;
	LiteralList *_goal;
};

#endif // _PROBLEM_HH_
