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

Requirements: [ :strips :equality ]
Predicates: [ ROOM(?x) BALL(?x) GRIPPER(?x) at-robby(?x) at-ball(?x,?y) free(?x) carry(?x,?y) ]

Action(name:move)
>> params:[?x, ?y]
>> precond:[ROOM(?x), ROOM(?y), NOT =(?x,?y), at-robby(?x)]
>> effects:[at-robby(?y), NOT at-robby(?x)])

Action(name:pick-up)
>> params:[?x, ?y, ?z]
>> precond:[BALL(?x), ROOM(?y), GRIPPER(?z), at-ball(?x,?y), at-robby(?y), free(?z)]
>> effects:[carry(?z,?x), NOT at-ball(?x,?y), NOT free(?z)])

Action(name:drop)
>> params:[?x, ?y, ?z]
>> precond:[BALL(?x), ROOM(?y), GRIPPER(?z), carry(?z,?x), at-robby(?y)]
>> effects:[at-ball(?x,?y), free(?z), NOT carry(?z,?x)])


>> Problem(name:griper-4, domain:gripper)

Objects: [ rooma roomb ball1 ball2 ball3 ball4 left right ]

Init: [
  ROOM(rooma)
  ROOM(roomb)
  BALL(ball1)
  BALL(ball2)
  BALL(ball3)
  BALL(ball4)
  GRIPPER(left)
  GRIPPER(right)
  free(left)
  free(right)
  at-robby(rooma)
  at-ball(ball1,rooma)
  at-ball(ball2,rooma)
  at-ball(ball3,rooma)
  at-ball(ball4,rooma)
]

Goal: [
  at-ball(ball1,roomb)
  at-ball(ball2,roomb)
  at-ball(ball3,roomb)
  at-ball(ball4,roomb)
]
```

```
$ ./pddl data/gripper-typed.pddl data/gripper-4.pddl

Parsing data/gripper-typed.pddl... ok!
Parsing data/gripper-4.pddl... ok!

>> Domain(name:gripper-typed)

Requirements: [ :strips :typing ]
Predicates: [ at-robby(?r) at(?b,?r) free(?g) carry(?g,?o) ]

Action(name:move)
>> params:[?from - room, ?to - room]
>> precond:[at-robby(?from)]
>> effects:[at-robby(?to), NOT at-robby(?from)])

Action(name:pick)
>> params:[?gripper - gripper, ?obj - ball, ?room - room]
>> precond:[at(?obj,?room), at-robby(?room), free(?gripper)]
>> effects:[carry(?obj,?gripper), NOT at(?obj,?room), NOT free(?gripper)])

Action(name:drop)
>> params:[?gripper - gripper, ?obj - ball, ?room - room]
>> precond:[ball(?obj), room(?room), gripper(?gripper), carry(?obj,?gripper), at-robby(?room)]
>> effects:[at(?obj,?room), free(?gripper), NOT carry(?obj,?gripper)])


>> Problem(name:griper-4, domain:gripper)

Objects: [ rooma roomb ball1 ball2 ball3 ball4 left right ]

Init: [
  ROOM(rooma)
  ROOM(roomb)
  BALL(ball1)
  BALL(ball2)
  BALL(ball3)
  BALL(ball4)
  GRIPPER(left)
  GRIPPER(right)
  free(left)
  free(right)
  at-robby(rooma)
  at-ball(ball1,rooma)
  at-ball(ball2,rooma)
  at-ball(ball3,rooma)
  at-ball(ball4,rooma)
]

Goal: [
  at-ball(ball1,roomb)
  at-ball(ball2,roomb)
  at-ball(ball3,roomb)
  at-ball(ball4,roomb)
]
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
