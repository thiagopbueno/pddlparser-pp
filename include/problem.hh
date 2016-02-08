#ifndef _PROBLEM_HH_
#define _PROBLEM_HH_

#include <string>
#include <iostream>

class Problem {
public:
	Problem(const std::string &name);

	friend std::ostream &operator<<(std::ostream &os, const Problem &problem);

private:
	std::string _name;
};

#endif // _PROBLEM_HH_
