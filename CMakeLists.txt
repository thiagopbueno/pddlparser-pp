project(pddl_parser_example)

cmake_minimum_required(VERSION 3.1)

find_package(BISON REQUIRED)
find_package(FLEX REQUIRED)

BISON_TARGET(pddlparser src/pddlparser.yy ${CMAKE_CURRENT_BINARY_DIR}/pddlparser.tab.cc)
FLEX_TARGET(pddlscanner src/pddlscanner.ll ${CMAKE_CURRENT_BINARY_DIR}/pddlscanner.yy.cc)
ADD_FLEX_BISON_DEPENDENCY(pddlscanner pddlparser)

include_directories(include ${CMAKE_CURRENT_BINARY_DIR})

add_library(domain src/domain.cc)
add_library(problem src/problem.cc)
add_library(action src/action.cc)
add_library(predicate src/predicate.cc)

add_executable(my_pddl_parser src/main.cc src/pddldriver.cc ${FLEX_pddlscanner_OUTPUTS} ${BISON_pddlparser_OUTPUTS})
target_link_libraries(my_pddl_parser domain problem action predicate)
