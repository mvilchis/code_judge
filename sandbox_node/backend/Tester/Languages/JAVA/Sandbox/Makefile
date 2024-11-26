JC = javac
BUILD_DIR = build
JCFLAGS= -d $(BUILD_DIR)

all: build jar

build:
	mkdir -p $(BUILD_DIR)

Sandbox: Sandbox.java
	javac $(JCFLAGS) Sandbox.java 

jar: Sandbox
	echo "Main-Class: Sandbox" > Manifest.txt
	jar -cfm Sandbox.jar Manifest.txt -C $(BUILD_DIR) .	
	rm Manifest.txt

clean:
	rm -r $(BUILD_DIR)
	rm -f Sandbox.jar

#Esto solo es para debugear. No ejecutar si no se realizan pruebas. 
run:
	java -Xmx8192k -Xss256k -jar Sandbox.jar ./ Test02 2 1 8192 1024 >out 2>err


