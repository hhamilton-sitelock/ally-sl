#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******** SUSPECTED *******************************************#
#
IFS=$'\n'
#
suspectedfiles=( $( awk -F'[+-+]' '/\.suspected/{ print $3" B" " : "$5" : "$1 }' "$filemap" ) )
#
if [ "${suspectedfiles[0]}" ]; then

	suspectedcount=${#suspectedfiles[@]}
else

	suspectedcount="0"
fi
#
unset IFS
