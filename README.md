# pddlparser-pp

Domain and problem **PDDL parser** in C/C++ using **Flex & Bison**.

The parser uses the (BNF Description of PDDL3.0)[http://zeus.ing.unibs.it/ipc-5/bnf.pdf] and currently supports the following ```:requirements``` :

* ```:strips```
* ```:typing```
* ```equality```

## Usage

```
$ make clean && make
$ ./pddl <domain.pddl> <problem.pddl>
```

## LICENSE

Copyright (c) 2015-2016 Thiago Pereira Bueno
All Rights Reserved.

DBN is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

DBN is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with DBN.  If not, see <http://www.gnu.org/licenses/>.
