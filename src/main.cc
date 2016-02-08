#include <iostream>
#include <string>
#include "pddldriver.hh"

using namespace std;

int
main (int argc, char *argv[])
{
    int res = 0;

    PDDLDriver driver;

    for (int i = 1; i < argc; ++i) {
        if (argv[i] == string ("-p")) {
            driver.trace_parsing = true;
        }
        else if (argv[i] == string ("-s")) {
            driver.trace_scanning = true;
        }
        else if (!driver.parse (argv[i])) {
            cout << *driver.domain;
        }
        else {
            res = 1;
        }
    }

    return res;
}
