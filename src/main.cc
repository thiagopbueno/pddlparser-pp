#include <iostream>
#include <string>
#include "pddldriver.hh"

using namespace std;

void usage(char *filename);

int
main (int argc, char *argv[])
{
    if (argc < 3) {
        usage(argv[0]);
        return -1;
    }

    int result = 0;

    PDDLDriver driver;

    for (int i = 1; i < argc; ++i) {
        if (argv[i] == string ("-p")) {
            driver.trace_parsing = true;
        }
        else if (argv[i] == string ("-s")) {
            driver.trace_scanning = true;
        }
        else if (!driver.parse(argv[i])) {
            cout << "Parsing " << argv[i] << "... ";
            if (!result) cout << "ok!" << endl;
            else cout << "Error!" << endl;
        }
        else {
            result = -2;
            break;
        }
    }

    cout << endl;
    cout << *driver.domain << endl;
    cout << *driver.problem << endl;

    return result;
}

void
usage(char *filename)
{
    cout << "usage: " << filename << "[-s] [-p] <domain.pddl> <problem.pddl>" << endl;
}
