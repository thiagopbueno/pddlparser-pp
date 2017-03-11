#ifndef __PREDICATE_HH__
#define __PREDICATE_HH__

#include <iostream>
#include <vector>

class Predicate {
public:
	Predicate(std::string name, std::vector<std::string> *args, bool negated = false);
	virtual ~Predicate();

	inline void negate() { _negated = true; };
	inline bool is_negated() const { return _negated; };

	friend std::ostream& operator<<(std::ostream& out, const Predicate& predicate);

private:
	std::string               _name;
	std::vector<std::string> *_args;
	bool                      _negated;
};

#endif