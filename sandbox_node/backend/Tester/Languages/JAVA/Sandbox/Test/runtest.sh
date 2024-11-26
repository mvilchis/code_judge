#! /bin/bash

testexe=$1
testname=`basename ${testexe}`

echo -e -n "Executing ${testexe}...\n"

input=inp/${testname}.in
output=/tmp/actual$$
error=/tmp/error$$
tmp=/tmp/tmp$$

wallclock=2
cpu=1
memory=8192
disk=1024

if [ ! -r $input ]; then
	# Test does not expect input
	java -Xms${memory}k -Xss256k -jar ../Sandbox.jar ./build ${testexe} ${wallclock} ${cpu} ${memory} ${disk} >${output} 2>${error}
else
	java -Xms${memory}k -Xss256k -jar ../Sandbox.jar ./build ${testexe} ${wallclock} ${cpu} ${memory} ${disk} <${input} >${output} 2>${error}
fi

expected_err="$(cat err/${testname}.err)"

#Si esta el error entonces procedemos
if grep -q "${expected_err}" $error; then
	if [ "${expected_err}" == "result: OK" ]; then
		expected_out=out/${testname}.out

		# Removing all newlines and whitespaces before diff
		tr -d ' \t\n\r\f' < ${expected_out} > ${tmp} && mv ${tmp} ${expected_out};
		tr -d ' \t\n\r\f' < ${output} > ${tmp} && mv ${tmp} ${output};

		diff ${output} ${expected_out} > /dev/null
		diff_rc=$?
	
		if [ $diff_rc != 0 ]; then
			echo "failed output mismatch, expected [`cat ${expected_out}`], got [`cat ${output}`])"
			exit 1
		fi
	fi
else
	echo "failed error mismatch, expected [${expected_err}], got [`cat ${error} | head -c 10`]"
	exit 1
fi

rm -f ${tmp}
rm -f ${output}
rm -f ${error}

echo "passed!"

exit 0
