#******* SECURITY CHECK **************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* CLEANED *********************************************#
#
if [ "${cleaned[0]}" ]; then

	printf "\n${cyan}*** ${yellow}SMART CLEANED${cyan} ***${default}\n"

	for i in "${cleaned[@]}"; do

		printf "${magenta}\n$i\n${default}"
	done
else
	if [ "${cleanedraw[0]}" ]; then

		printf "\n${cyan}*** ${yellow}SMART CLEANED${cyan} ***${default}\n"

		for i in "${cleanedraw[@]}"; do

			printf "${magenta}\n$i\n${default}"
		done
	else

		printf "\n${magenta}There are no cleaned files to show.${default}\n\n"
	fi
fi