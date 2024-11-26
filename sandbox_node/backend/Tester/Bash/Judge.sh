#!/bin/bash

source Paths.sh
source Reply.sh
source ./Languages/Java.sh
source ./Languages/CCPP11.sh
source Compile.sh
source Execute.sh

#Ruta en donde se encuentra el archivo a compilar
FILE_PATH=${1}
#Nombre del archivo a compilar
FILE_NAME=${2}
#Extension del archivo a compilar
EXTENSION=${3}
#JAIL directorio
JAIL=$TEMP_DIR/JAIL_$FILE_NAME
#Archivo de compilacion
COMPILE_FILE=$FILE_PATH/$FILE_NAME.compile
#Archivo de ejecucion
RUN_FILE=$FILE_PATH/$FILE_NAME.run
#Archivo de salida
OUTPUT_FILE=$FILE_PATH/$FILE_NAME.out
#Archivo de error
ERROR_FILE=$FILE_PATH/$FILE_NAME.error

if ! mkdir -p $JAIL;then
	echo "result: IE" > $ERROR_FILE
	echo "message: Folder $JAIL is not writable!" >> $ERROR_FILE
	EXITCODE=$IE
else
	EXITCODE=$(compile)
	if [ $EXITCODE -eq $OK ]; then
		rm -rf $COMPILE_FILE
		EXITCODE=$(execute)
		if [ $EXITCODE -eq $OK ]; then 
			echo "s"
		else
			rm -rf $OUTPUT_FILE
		fi
	fi
fi

echo "$EXITCODE"
