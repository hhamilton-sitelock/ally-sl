#******* SECURITY CHECK **************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* SUSPECTED *******************************************#
#
if [ "${suspectedfiles[0]}" ]; then

	printf "\n${cyan}*** ${yellow}Suspected Files${cyan} ***${default}\n"

	for i in "${suspectedfiles[@]}"; do

		printf "${magenta}\n$i\n${default}"
	done
else

	printf "\n${magenta}There are no .suspected files to show.\n\n"
fi