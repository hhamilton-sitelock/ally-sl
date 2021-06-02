#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* XML **************************************************#
#
#
IFS=$'\n'
#
allperms=( $( awk -F'[+-+]' '{ if( $5=="777" || $5=="0777" ) print $3" B" " : "$5" : "$1 }' "$filemap" ) )
#
if [ "${allperms[0]}" ]; then

	allpermscount=${#allperms[@]}
else

	allpermscount="0"
fi
#
zeroperms=( $( awk -F'[+-+]' '{ if( $5=="000" || $5=="0000" ) print $3" B" " : "$5" : "$1 }' "$filemap" ) )
#
if [ "${zeroperms[0]}" ]; then

	zeropermscount=${#zeroperms[@]}
else

	zeropermscount="0"
fi
#
suspectperms=( $( awk -F'[+-+]' '{ if( $5!="0644" && $5!="644" ) print $3" B" " : "$5" : "$1 }' "$filemap" ) )
#
if [ "${suspectperms[0]}" ]; then

	suspectpermscount=${#suspectperms[@]}
else

	suspectpermscount="0"
fi
#
unset IFS
