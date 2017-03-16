#ifndef __PREDICATE_HH__
#define __PREDICATE_HH__

#include <string>
#include <vector>
#include <map>
#include <iostream>

using StringList   = std::vector<std::string>;
using TypeDict     = std::map<std::string,std::string>;
using ArgumentList = std::pair<StringList*,TypeDict*>;

class Predicate {
public:
	Predicate(std::string name, ArgumentList *args, bool negated = false);
	virtual ~Predicate();

	inline void negate()           { _negated = true; };
	inline bool is_negated() const { return _negated; };

	friend std::ostream& operator<<(std::ostream& out, const Predicate& predicate);

private:
	std::string  _name;
	StringList  *_args;
	TypeDict    *_types;
	bool         _negated;
};

#endif
