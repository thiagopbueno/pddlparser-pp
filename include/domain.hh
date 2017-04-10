#ifndef _DOMAIN_HH_
#define _DOMAIN_HH_

#include <string>
#include <vector>
#include <memory>
#include <iostream>

#include "action.hh"

class Domain {
public:
	Domain(const std::string &name);
	virtual ~Domain();

	void set_requirements(std::vector<std::string>* requirements);
	void set_predicates(std::vector<Predicate*>* predicates);
	void set_actions(std::vector<Action*>* actions);

	friend std::ostream &operator<<(std::ostream &os, const Domain &domain);

private:
	std::string               _name;
	std::vector<std::string> *_requirements;
	std::vector<Predicate*>  *_predicates;
	std::vector<Action*>     *_actions;
};

#endif // _DOMAIN_HH_
