############################################ Getting Arguments #####################################

# Get Current Time (in milliseconds)
START=$(($(date +%s%N)/1000000));

#Function to print a message to show usage
function echo_usage
{
	echo "Usage:   ./judge ProblemID User Filename [Options]..."
	echo "Example: ./judge 1010 manuel submit.c -log_ON=0"
	echo "Options:"
	echo -e "   -log_ON= \t\t For log purpose (default 0)"
	echo -e "   -Djava_exception= \t Show exceptions to students (default 1)"
}

#checking for necessary arguments
if [ "$#" -lt "3" ]; then
	echo_usage
	exit 1
fi



# problem id
PROBLEMID=${1}

# username
USER=${2}

# file name with extension
FILENAME=${3}



###############AUXILIARY vars
# File full path
FILE_DIR="$USERS_DIR/$USER/submits/$PROBLEMID"
#Directorio en donde se va a ejecutar
JAIL="$TEMP_DIR/jail-$RANDOM"
#Directorio de inputs
INPUTS_DIR="$PROBLEMS_DIR/$PROBLEMID/inp"
#Directorio de outpus
OUTPUTS_DIR="$PROBLEMS_DIR/$PROBLEMID/out"
# enable/disable judge log
LOG_ON=true
#enable/disable Display java exceptions
DISPLAY_JAVA_EXCEPTION_ON=true
#Numero de casos de prueba
TST="$(ls $INPUTS_DIR | wc -l)"  # Number of Test Cases

# detecting existence of perl
PERL_EXISTS=true
hash perl 2>/dev/null || PERL_EXISTS=false
if ! $PERL_EXISTS; then
	shj_log "Warning: perl not found. We continue without perl..."
fi

#Detectando la existencia de timeout
TIMEOUT_EXISTS=true
hash timeout 2>/dev/null || TIMEOUT_EXISTS=false
if ! $TIMEOUT_EXISTS; then
	shj_log "Warning: timeout not found. We continue without timeout..."
fi



function shj_finish
{
	if [ "$1" = "ERROR" ]; then
		if [ -d $JAIL ]; then
			rm -r $JAIL >/dev/null 2>/dev/null
		fi
		echo "ERROR: $2"
		exit 1
	else
		# Get Current Time (in milliseconds)
		local END=$(($(date +%s%N)/1000000));
		shj_log "\nTotal Execution Time: $((END-START)) ms"
		echo $@
		exit 0
	fi
}

#Funcion para obtener una propiedad del archivo settings
function get_setting
{
	local setting=$(grep $1 "$PROBLEMS_DIR/$PROBLEMID/settings.txt")
	echo "${setting#*=}"
}


if [ -f "$PROBLEMS_DIR/$PROBLEMID/settings.txt" ]; then
	# time limit in seconds
	TIMELIMIT=$(get_setting "TIME_LIMIT")
	# memory limit in kB
	MEMLIMIT=$(get_setting "MEMORY_LIMIT")
	# output size limit in Bytes
	OUTLIMIT=$(get_setting "OUTPUT_LIMIT")
	# diff tool (default: identical)
	# DIFF can also be "ignore" or "identical".
	# ignore: In this case, before diff command, all newlines and whitespaces will be removed from both files
	# identical: diff will compare files without ignoring anything. files must be identical to be accepted
	DIFF=$(get_setting "DIFF")
	#If DIFF is empty 
	if [ -z $DIFF ] || [ "$DIFF" != "identical" ] && [ "$DIFF" != "ignore" ]; then
		DIFF="identical"
	fi

	SANDBOX_ON=$(get_setting "SANDBOX")
	if [ -z $SANDBOX_ON ] || [ $SANDBOX_ON = "1" ]; then
		SANDBOX_ON=true
		JAVA_POLICY="-Djava.security.manager -Djava.security.policy=../Sandbox/java.policy"
	else
		SANDBOX_ON=false
		JAVA_POLICY=""
	fi

	SHIELD_ON=$(get_setting "SHIELD")
	if [ -z $SHIELD_ON ] || [ $SHIELD_ON = "1" ]; then
		SHIELD_ON=true
	else
		SHIELD_ON=false
	fi
else
	shj_finish "ERROR" "SETTINGS does not exist in $PROBLEMS_DIR/$PROBLEMID"
fi


#IF FILE exists
if [ -f  "$FILE_DIR/$FILENAME" ]; then
	# file extension
	EXTENSION="${FILENAME#*.}"
	#IF extension is empty
	if [ -z $EXTENSION ] || [ "$FILENAME" == "$EXTENSION" ]; then
		shj_finish "ERROR" "EXTENSION does not exist"
	else
		FILENAME="${FILENAME%%.*}"
	fi
else
	shj_finish "ERROR" "FILENAME Does not exist: $FILE_DIR/$FILENAME"
fi


#LOG for this problem and user.
LOG="$FILE_DIR/$FILENAME.log"

#Archivo de salida
RESULTFILE="$FILE_DIR/$FILENAME.result"

for i in "$@"
do
	case $i in
		-log_ON=*)
			if [ "${i#*=}" == "1" ]; then
				LOG_ON=true
			else
				LOG_ON=false
			fi
		;;
		-Djava_exception=*)
			if [ "${i#*=}" == "1" ]; then
				DISPLAY_JAVA_EXCEPTION_ON=true
			else
				DISPLAY_JAVA_EXCEPTION_ON=false
			fi
		;;
	esac
done

function shj_log
{
	if $LOG_ON; then
		if $CONSOLE_LOG_MODE; then
			echo -e "$@" 
		else
			echo -e "$@" >> $LOG
		fi
	fi
}


shj_log "############# ARGUMENTS ##############" 
shj_log "Date: $(date)"
shj_log "Language: $EXTENSION"
shj_log "Time Limit: $TIMELIMIT s"
shj_log "Memory Limit: $MEMLIMIT kB"
shj_log "Output size limit: $OUTLIMIT bytes"
shj_log "DIFF: $DIFF"
shj_log "Sandbox: $SANDBOX_ON"
shj_log "Shield: $SHIELD_ON"
if [[ $EXTENSION = "java" ]]; then
	shj_log "Java policy file: $JUDGETEST_DIR/SandboxJava/java.policy"
	shj_log "Display java excepcions: $DISPLAY_JAVA_EXCEPTION_ON"
fi
shj_log "Test cases found: $TST"


#Creando directorio temporal para ejecutar
if ! mkdir -p $JAIL; then
	shj_log "Error: Folder '$TEMP_DIR' is not writable! Exiting..."
	shj_finish "ERROR" "Judge Error"
fi

#copiando el archivo para limitar tiempo,memoria y salida
cp $JUDGETEST_DIR/Bash/timeout.pl $JAIL/timeout.pl
chmod +x $JAIL/timeout.pl

