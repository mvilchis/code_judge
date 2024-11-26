function execute
{
	local EXITCODE=$OK
	if [ "$EXTENSION" = "java" ]; then
		EXITCODE=$(executeJAVA)
	elif [ "$EXTENSION" = "cpp" ] || [ "$EXTENSION" = "c" ] || [ "$EXTENSION" = "cpp11" ]; then
		EXITCODE=$(executeCCPP11)
	fi
	echo "$EXITCODE"
}
