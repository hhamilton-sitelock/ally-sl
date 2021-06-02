#******* SECURITY CHECK **************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* UNCLEAN *********************************************#
#
if [ "${notcleaned[0]}" ]; then

	printf "\n${cyan}*** ${yellow}Not Cleaned${cyan} ***${default}\n"

	for j in "${notcleaned[@]}"; do

		printf "${magenta}\n$j\n${default}"
	done

	printf "\n"
else
	if [ "${notcleanedraw[0]}" ]; then

		printf "\n${cyan}*** ${yellow}Not Cleaned${cyan} ***${default}\n"

		for j in "${notcleanedraw[@]}"; do

			printf "${magenta}\n$j\n${default}"
		done
	else

		printf "\n${magenta}There are no unclean files to show.${default}\n\n"
	fi
fi