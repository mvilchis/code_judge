function compile
{
	#Marca el inicio de compilacion
	local COMPILE_BEGIN_TIME=$(($(date +%s%N)/1000000));
	local EXITCODE=$OK

	if [ "$EXTENSION" = "java" ]; then
		EXITCODE=$(compileJAVA)
	elif [ "$EXTENSION" = "cpp" ] || [ "$EXTENSION" = "c" ] || [ "$EXTENSION" = "cpp11" ]; then
		EXITCODE=$(compileCCPP11)
	fi

	#Marca el final de compilacion
	local COMPILE_END_TIME=$(($(date +%s%N)/1000000));
	echo "Execution Time: $((COMPILE_END_TIME-COMPILE_BEGIN_TIME)) ms" >> $COMPILE_FILE
	echo "$EXITCODE"
}
