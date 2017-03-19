CC=g++
CXXFLAGS=-Wall -Wextra -pedantic -std=c++11 -O2

FLEXPATH=/usr/local/opt/flex
BISONPATH=/usr/local/opt/bison

FLEX=$(FLEXPATH)/bin/flex
BISON=$(BISONPATH)/bin/bison

INCLUDE=-Iinclude/ -Isrc/
OBJ=$(addprefix bin/, parser.o scanner.o driver.o action.o predicate.o domain.o problem.o main.o)

.PHONY: all check
all: pddl

pddl: $(OBJ)
	$(CC) -g $^ -o $@

bin/main.o: src/main.cc
	$(CC) $(CXXFLAGS) $(INCLUDE) -c $< -o $@

bin/domain.o: src/domain.cc
	$(CC) $(CXXFLAGS) $(INCLUDE) -c $< -o $@

bin/problem.o: src/problem.cc
	$(CC) $(CXXFLAGS) $(INCLUDE) -c $< -o $@

bin/action.o: src/action.cc
	$(CC) $(CXXFLAGS) $(INCLUDE) -c $< -o $@

bin/predicate.o: src/predicate.cc
	$(CC) $(CXXFLAGS) $(INCLUDE) -c $< -o $@

bin/driver.o: src/pddldriver.cc
	$(CC) $(CXXFLAGS) $(INCLUDE) -c $< -o $@

bin/parser.o: src/pddlparser.yy
	$(BISON) -d -o src/pddlparser.tab.cc -v $<
	$(CC) $(CXXFLAGS) $(INCLUDE) -c src/pddlparser.tab.cc -o $@
	mv src/*.hh include/

bin/scanner.o: src/pddlscanner.ll
	$(FLEX) --outfile=src/pddllex.yy.cc $<
	$(CC) $(CXXFLAGS) -Wno-macro-redefined $(INCLUDE) -c src/pddllex.yy.cc -o $@

check: pddl
	./pddl data/gripper.pddl data/gripper-4.pddl
	./pddl data/gripper-typed.pddl data/gripper-4.pddl

.PHONY: clean
clean:
	$(RM) -rfv pddl pddl.dSYM/ bin/*.o \
		include/position.hh include/location.hh include/stack.hh \
		src/pddlparser.tab.cc include/pddlparser.tab.hh src/pddlparser.output \
		src/pddllex.yy.cc
	find . -name *.DS_Store -type f -ls -delete