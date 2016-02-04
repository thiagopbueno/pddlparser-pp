CC=g++
CXXFLAGS=-Wall -Wextra -ansi -pedantic -std=c++11 -g

FLEXPATH=/usr/local/opt/flex
BISONPATH=/usr/local/opt/bison

FLEX=$(FLEXPATH)/bin/flex
BISON=$(BISONPATH)/bin/bison

INCLUDE=-Iinclude/ -Isrc/
OBJ=bin/parser.o bin/scanner.o bin/driver.o bin/main.o

.PHONY: all
all: pddl

pddl: $(OBJ)
	$(CC) -g $^ -o $@

bin/main.o: src/main.cc
	$(CC) $(CXXFLAGS) $(INCLUDE) -c $< -o $@

bin/driver.o: src/pddldriver.cc
	$(CC) $(CXXFLAGS) $(INCLUDE) -c $< -o $@

bin/parser.o: src/pddlparser.yy
	$(BISON) -d -o src/pddlparser.tab.cc -v $<
	$(CC) $(CXXFLAGS) $(INCLUDE) -c src/pddlparser.tab.cc -o $@
	mv src/*.hh include/

bin/scanner.o: src/pddlscanner.ll
	$(FLEX) --outfile=src/pddllex.yy.cc $<
	$(CC) $(CXXFLAGS) $(INCLUDE) -c src/pddllex.yy.cc -o $@

.PHONY: clean
clean:
	rm -rfv pddl pddl.dSYM/ bin/*.o \
		include/position.hh include/location.hh include/stack.hh \
		src/pddlparser.tab.cc include/pddlparser.tab.hh src/pddlparser.output \
		src/pddllex.yy.cc