CC = gcc
CXX = g++
COMMON_FLAGS = -g -Wall -D_BSD_SOURCE -static
CFLAGS = -std=c99 $(COMMON_FLAGS) #-DDEBUG_MALLOC
CXXFLAGS = $(COMMON_FLAGS)

TEST_SRCS := $(shell ls test*.c*)
TEST_EXES := $(patsubst %.c,%,$(patsubst %.cpp,%,$(TEST_SRCS)))

all: build tests 

build:
	find . -name "*~" -delete
	clear
	mkdir -p build

tests : $(TEST_EXES)

test% : test%.c
	$(CC) $(CFLAGS) -o build/test$* test$*.c -lm

test% : test%.cpp
	$(CXX) $(CXXFLAGS) -o build/test$* test$*.cpp -lm

runtests : all
	chmod +x runalltests.sh
	chmod +x runtest.sh
	./runalltests.sh  $(TEST_EXES)

clean :
	rm -r build
