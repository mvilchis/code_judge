JC = javac
BUILD_DIR = build
JCFLAGS= -d $(BUILD_DIR)

all: build jar

build:
	mkdir -p $(BUILD_DIR)

CustomJavaCompiler: CustomJavaCompiler.java
	javac $(JCFLAGS) CustomJavaCompiler.java 

jar: CustomJavaCompiler
	echo "Main-Class: CustomJavaCompiler" > Manifest.txt
	jar -cfm CustomJavaCompiler.jar Manifest.txt -C $(BUILD_DIR) .	
	rm Manifest.txt

clean:
	rm -r $(BUILD_DIR)
	rm -f CustomJavaCompiler.jar

