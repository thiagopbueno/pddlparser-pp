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
	~Domain();

	void add_action(const Action *action);

	friend std::ostream &operator<<(std::ostream &os, const Domain &domain);

private:
	std::string _name;
	std::vector<const Action*> _actions;
};

#endif // _DOMAIN_HH_