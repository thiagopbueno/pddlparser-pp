# pddlparser-pp

Domain and problem **PDDL parser** in C/C++ using **Flex & Bison**.

The parser uses the [BNF Description of PDDL3.0](http://zeus.ing.unibs.it/ipc-5/bnf.pdf) and currently supports the following ```:requirements``` :

* ```:strips```
* ```:typing```
* ```:equality```

## Usage

```
$ make clean && make
$ ./pddl

usage: ./pddl [-s] [-p] <domain.pddl> <problem.pddl>

Domain and problem PDDL parser in C/C++ using Flex & Bison.
https://github.com/thiagopbueno/pddlparser-pp

OPTIONS:
 -s	enable scanning trace.
 -p	enable parsing trace.
```

## Example

```
$ ./pddl data/gripper.pddl data/gripper-4.pddl

Parsing data/gripper.pddl... ok!
Parsing data/gripper-4.pddl... ok!

>> Domain(name:gripper)

Action(name:move)
>> params:[?x, ?y]
>> preconditions:[ROOM(?x), ROOM(?y), not =(?x,?y), at-robby(?x)]
>> effects:[at-robby(?y), not at-robby(?x)])

Action(name:pick-up)
>> params:[?x, ?y, ?z]
>> preconditions:[BALL(?x), ROOM(?y), GRIPPER(?z), at-ball(?x,?y), at-robby(?y), free(?z)]
>> effects:[carry(?z,?x), not at-ball(?x,?y), not free(?z)])

Action(name:drop)
>> params:[?x, ?y, ?z]
>> preconditions:[BALL(?x), ROOM(?y), GRIPPER(?z), carry(?z,?x), at-robby(?y)]
>> effects:[at-ball(?x,?y), free(?z), not carry(?z,?x)])


>> Problem(name:griper-4)
```

```
$ ./pddl data/gripper-typed.pddl data/gripper-4.pddl

Parsing data/gripper-typed.pddl... ok!
Parsing data/gripper-4.pddl... ok!

>> Domain(name:gripper-typed)

Action(name:move)
>> params:[?from - room, ?to - room]
>> preconditions:[at-robby(?from)]
>> effects:[at-robby(?to), not at-robby(?from)])

Action(name:pick)
>> params:[?gripper - gripper, ?obj - ball, ?room - room]
>> preconditions:[at(?obj,?room), at-robby(?room), free(?gripper)]
>> effects:[carry(?obj,?gripper), not at(?obj,?room), not free(?gripper)])

Action(name:drop)
>> params:[?gripper - gripper, ?obj - ball, ?room - room]
>> preconditions:[ball(?obj), room(?room), gripper(?gripper), carry(?obj,?gripper), at-robby(?room)]
>> effects:[at(?obj,?room), free(?gripper), not carry(?obj,?gripper)])


>> Problem(name:griper-4)
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
