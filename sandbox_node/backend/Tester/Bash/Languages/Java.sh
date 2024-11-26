
function compileJAVA
{
	local CMP_TEMP="$JAIL/$FILE_NAME.cerr"
	local JAVA_COMPILER="$JUDGELANG_DIR/JAVA/Compiler/CustomJavaCompiler.jar"
	if [ ! -f  $JAVA_COMPILER ]; then
		echo "result: IE" >> $ERROR_FILE
		echo "message: CustomJavaCompiler does not exists" >> $ERROR_FILE
		echo "$IE"
	else
		cp $FILE_PATH/$FILE_NAME.$EXTENSION $JAIL/Main.java		
		java -jar $JAVA_COMPILER "$JAIL/Main.java" > /dev/null 2>$CMP_TEMP
		local EXITCODE=$?
		if [ $EXITCODE -eq 0 ]; then
			echo "result: OK" > $COMPILE_FILE
			echo "message: Successful compilation" >> $COMPILE_FILE
			echo "$OK"
		else
			echo "result: CE" > $COMPILE_FILE
			local ERROR=$(cat $CMP_TEMP)
			local CAD="$JAIL/"
			echo "message: ${ERROR//$CAD}" >> $COMPILE_FILE
			echo "$CE"
		fi
	fi
}

function executeJAVA
{
	local JAVA_SANDBOX="$JUDGELANG_DIR/JAVA/Sandbox/Sandbox.jar"
	if [ ! -f  $JAVA_SANDBOX ]; then
		echo "result: IE" >> $ERROR_FILE
		echo "message: JavaSandbox does not exists" >> $ERROR_FILE
		echo "$IE"
	else
		java -Xms8192k -Xss256k -jar $JAVA_SANDBOX $JAIL Main 30 1 8192 1024 > $OUTPUT_FILE 2>$RUN_FILE
		local EXITCODE=$?
		echo "$EXITCODE"
	fi
}
