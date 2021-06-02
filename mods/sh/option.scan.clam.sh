#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* CLAM SCAN ********************************************#
#
printf "\n${cyan}*** ${yellow}Clam Scan${cyan} ***${default}\n\n"
#
printf "${magenta}Performing scan. This may take some time...\n\n"
#
IFS=$'\n'
#
clamscanfiles=()
#
clamscanfiles+=( $( sudo clamscan -ir --no-summary "$mirrorpath" ) )
#
clamscanfiles+=( $( sudo slclamscan -ir --no-summary "$mirrorpath" ) )
#
if [ "${clamscanfiles[0]}" ]; then
	
	scanoptions "${clamscanfiles[@]}"
else

	printf "\n${magenta}There are no suspicious files to view or edit.\n\n"
fi
#
unset IFS