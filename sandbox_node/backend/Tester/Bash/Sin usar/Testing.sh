########################################################################################################
################################################ TESTING ###############################################
########################################################################################################

function compileTesterFile
{
	if [ -f "$PROBLEMS_DIR/$PROBLEMID/tester.cpp" ] && [ ! -f "$PROBLEMS_DIR/$PROBLEMID/tester.executable" ]; then
		shj_log "Tester file found. Compiling tester..."
		local TST_COMPILE_BEGIN_TIME=$(($(date +%s%N)/1000000));
		g++ $PROBLEMS_DIR/$PROBLEMID/tester.cpp -lm -O2 -o $PROBLEMS_DIR/$PROBLEMID/tester.executable
		local EC=$?
		local TST_COMPILE_END_TIME=$(($(date +%s%N)/1000000));
		if [ $EC -ne 0 ]; then
			shj_log "Compiling tester failed."
			cd $JUDGETEST_DIR/Bash
			rm -r $JAIL >/dev/null 2>/dev/null
			shj_finish "ERROR" "Invalid Tester Code"
		else
			shj_log "Tester compiled. Execution Time: $((TST_COMPILE_END_TIME-TST_COMPILE_BEGIN_TIME)) ms"
		fi
	fi

	if [ -f "$PROBLEMS_DIR/$PROBLEMID/tester.executable" ]; then
		shj_log "Copying tester executable to current directory"
		cp $PROBLEMS_DIR/$PROBLEMID/tester.executable ./shj_tester
		chmod +x shj_tester
	fi
}


shj_log "Testing: $TST test cases "
compileTesterFile
#Para limpiar el archivo si existe
echo "" > $RESULTFILE


#ingresando al directorio 
cd $JAIL

for((i=1;i<=TST;i++)); do
	shj_log "=== TEST $i ==="
	echo "Test $i" >> $RESULTFILE
	
	touch err

	if [ "$EXTENSION" = "java" ]; then
		EXITCODE=$(runJAVA $INPUTS_DIR/input$i.inp)

		#Comprabando errores de memoria, restricted funcion y runtime
		if grep -iq -m 1 "Too small initial heap" out; then
			shj_log "Too small initial heap"
			echo "Too small initial heap" >>$RESULTFILE
			continue
		elif grep -q -m 1 "java.lang.OutOfMemoryError" err; then
			shj_log "Memory Limit Exceeded"
			echo "Memory Limit Exceeded" >>$RESULTFILE
			continue
		elif grep -q -m 1 "java.security.AccessControlException" err; then
			shj_log "Restricted Function"
			echo "Restricted Function" >>$RESULTFILE
			continue
		elif grep -q -m 1 "Exception in" err; then # show Exception
			javaexceptionname=`grep -m 1 "Exception in" err | grep -m 1 -oE 'java\.[a-zA-Z\.]*' | head -1 | head -c 80`
			javaexceptionplace=`grep -m 1 "Main.java" err | head -1 | head -c 80`
			shj_log "Exception: $javaexceptionname\nMaybe at:$javaexceptionplace"
			if $DISPLAY_JAVA_EXCEPTION_ON; then
				echo "Runtime Error ($javaexceptionname)" >>$RESULTFILE
			else
				echo "Runtime Error" >>$RESULTFILE
			fi
			continue
		fi

	elif [ "$EXTENSION" = "c" ] || [ "$EXTENSION" = "cpp" ]; then
		EXITCODE=$(runCCPP $INPUTS_DIR/input$i.inp)
	fi

	shj_log "Exit Code = $EXITCODE"

	if [ $EXITCODE -eq 137 ]; then
		shj_log "Killed"
		echo "Killed" >>$RESULTFILE
		continue
	elif [ $EXITCODE -ne 0 ]; then
		shj_log "Runtime Error"
		echo "Runtime Error" >>$RESULTFILE
		continue
	fi

	if ! grep -q "FINISHED" err; then
		if grep -q "SHJ_TIME" err; then
			t=`grep "SHJ_TIME" err|cut -d" " -f3`
			shj_log "Time Limit Exceeded ($t s)"
			echo "Time Limit Exceeded" >> $RESULTFILE
			continue
		elif grep -q "SHJ_MEM" err; then
			shj_log "Memory Limit Exceeded"
			echo "Memory Limit Exceeded" >>$RESULTFILE
			continue
		elif grep -q "SHJ_HANGUP" err; then
			shj_log "Hang Up"
			echo "Process hanged up" >>$RESULTFILE
			continue
		elif grep -q "SHJ_SIGNAL" err; then
			shj_log "Killed by a signal"
			echo "Killed by a signal" >>$RESULTFILE
			continue
		elif grep -q "SHJ_OUTSIZE" err; then
			shj_log "Output Size Limit Exceeded"
			echo "Output Size Limit Exceeded" >>$RESULTFILE
			continue
		fi
	else
		t=`grep "FINISHED" err|cut -d" " -f3`
		shj_log "Time: $t s"
		echo "Time: $t s" >>$RESULTFILE
	fi

	

	shj_log "checking correctness.."

	# checking correctness of output
	ACCEPTED=0
	if [ -f shj_tester ]; then
		./shj_tester $INPUTS_DIR/input$i.inp $OUTPUTS_DIR/output$i.out out
		EC=$?
		if [ $EC -eq 0 ]; then
			ACCEPTED=1
		fi
	else
		cp $OUTPUTS_DIR/output$i.out correctout

		# Removing all newlines and whitespaces before diff
		tr -d ' \t\n\r\f' <correctout > correctout_ignore;
		tr -d ' \t\n\r\f' <out > out_ignore;
		# Add a newline at the end of both files
		echo "" >> out_ignore
		echo "" >> correctout_ignore
	
		if [ "$DIFF" = "ignore" ]; then
			if diff -q -bB out_ignore correctout_ignore >/dev/null 2>/dev/null; then
				ACCEPTED=1
			else
				ACCEPTED=0
			fi
		else
			if diff -q -bB out correctout >/dev/null 2>/dev/null; then
				ACCEPTED=1
			elif diff -q -bB out_ignore correctout_ignore >/dev/null 2>/dev/null; then
				ACCEPTED=2
			else
				ACCEPTED=0
			fi
		fi

		if [ "$ACCEPTED" = "1" ]; then
			shj_log "ACCEPTED"
			echo "ACCEPTED" >>$RESULTFILE
			((PASSEDTESTS=PASSEDTESTS+1))
		elif [ "$ACCEPTED" = "0" ]; then
			shj_log "WRONG ANSWER"
			echo "WRONG ANSWER" >>$RESULTFILE
		else
			shj_log "PRESENTATION ERROR"
			echo "PRESENTATION ERROR" >> $RESULTFILE
		fi
	fi
done

#Saliendo del directorio
cd $JUDGETEST_DIR/Bash
