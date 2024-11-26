
function compileCCPP11
{
	local CMP_TEMP="$JAIL/$FILE_NAME.cerr"
	local COMPILER="gcc"
	local FLAGS="-O2 -lm -w -D_BSD_SOURCE -static"
	local EXT="c"
	if [ "$EXTENSION" = "cpp" ] || [ "$EXTENSION" = "cpp11" ]; then
		EXT="cpp"
		COMPILER="g++"
	fi

	if [ "$EXTENSION" = "cpp11" ]; then
		FLAGS="$FLAGS -std=c++11"
	fi

	cp $FILE_PATH/$FILE_NAME.$EXT $JAIL/$FILE_NAME.$EXT
	$COMPILER $FLAGS $JAIL/$FILE_NAME.$EXT -o $JAIL/$FILE_NAME > /dev/null 2>$CMP_TEMP
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
}

function executeCCPP11
{
	python $JUDGELANG_DIR/C_C++/Sandbox/sample2.py $JAIL/$FILE_NAME 30 1 8192 1024 > $OUTPUT_FILE 2>$RUN_FILE
	local SALIDA=$(cat $RUN_FILE | head -1)
	local arr=("PD" "OK" "RF" "ML" "OL" "TL" "RT" "AT" "IE" "BP" "CE")
	SALIDA="${SALIDA//result: }"
	local EXITCODE=0
	while( [ "${arr[$EXITCODE]}" != "$SALIDA" ] )
	do
		((EXITCODE++))
	done
	echo "$EXITCODE"
}
