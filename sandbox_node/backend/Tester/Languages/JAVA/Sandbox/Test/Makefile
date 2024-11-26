JC = javac
JFLAGS = -g

TEST_SRCS := $(shell ls Test*.java)
TEST_EXES := $(patsubst %.java,%,$(TEST_SRCS))

all: build tests 

build:
	find . -name "*~" -delete
	clear
	mkdir -p build

tests : $(TEST_EXES)

Test% : Test%.java
	$(JC) $(JFLAGS) Test$*.java -d ./build

runtests : all
	chmod +x runalltests.sh
	chmod +x runtest.sh
	./runalltests.sh  $(TEST_EXES)

clean :
	rm -r build
