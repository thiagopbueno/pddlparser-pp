# pddlparser-pp

Domain and problem **PDDL parser** in C/C++ using **Flex & Bison**.

The parser uses the [BNF Description of PDDL3.0](http://zeus.ing.unibs.it/ipc-5/bnf.pdf) and currently supports the following ```:requirements``` :

* ```:strips```
* ```:typing```
* ```:equality```

## Usage

```
$ make clean && make
$ ./pddl [-p] [-s] <domain.pddl> <problem.pddl>
```

## File Description

* pddldriver.hh/pddldriver.cc: implements the client interface;
* pddlscanner.ll: defines the scanner rules for lexical analysis;
* pddlparser.hh: defines the parser rules for syntactical analysis;
* main.cc: defines the tracing level and starts the parsing process.

## LICENSE

Copyright (c) 2015-2017 Thiago Pereira Bueno
All Rights Reserved.

pddl-parser is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

pddl-parser is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with pddl-parser. If not, see <http://www.gnu.org/licenses/>.
