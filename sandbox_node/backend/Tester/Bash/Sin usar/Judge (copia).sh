#!/bin/bash



#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.


##################### Example Usage #####################
# judge.sh PROBLEMPATH FILENAME USER [OPTIONS]
# judge.sh 1010 problem.c manuel -log_ON=0
# In this example judge assumes that the file "problem.c" is located at:
# $USERS_DIR/$USER/submits/$PROBLEMID/problem.c
# And test cases are located at:
# $PROBLEMS_DIR/$PROBLEMID/inp  {input1.inp, input2.inp, ...}
# $PROBLEMS_DIR/$PROBLEMID/out {output1.out, output2.out, ...}


####################### Output #######################
# Output is just one line. One of these:
#   a number (score form 10000)
#   Compilation Error
#   Syntax Error
#   Invalid Tester Code
#   File Format Not Supported
#   Judge Error


####################### Options #######################
source Options.sh


#################### Initialization #####################
source Initialization.sh


########################################################################################################
############################################ COMPILING ############################################
########################################################################################################
source Java.sh
source CCPP.sh

shj_log "############# COMPILING ##############" 
shj_log "Compiling: $EXTENSION"
#ingresando al directorio 
cd $JAIL

if [ $EXTENSION = "java" ]; then
	compileJAVA
elif [ "$EXTENSION" = "c" ] || [ "$EXTENSION" = "cpp" ]; then
	compileCCPP
else
	shj_log "File Format Not Supported"
	cd $JUDGETEST_DIR/Bash
	rm -r $JAIL >/dev/null 2>/dev/null
	shj_finish "ERROR" "File Format Not Supported"
fi

#Saliendo del directorio
cd $JUDGETEST_DIR/Bash
########################################################################################################
################################################ TESTING ###############################################
########################################################################################################

shj_log "############# TESTING ##############"

source Testing.sh




