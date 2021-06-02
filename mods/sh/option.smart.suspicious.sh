#******* SECURITY CHECK **************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* SUSPICIOUS ******************************************#
#
if [ "${fuzzyprompts[0]}" ]; then

	printf "\n${cyan}*** ${yellow}Suspicious Files${cyan} ***${default}\n"

	for j in "${fuzzyprompts[@]}"; do

		printf "${magenta}\n$j\n${default}"
	done
else
	if [ "${fuzzypromptsraw[0]}" ]; then

		printf "\n${cyan}*** ${yellow}Suspicious Files${cyan} ***${default}\n"

		for j in "${fuzzypromptsraw[@]}"; do

			printf "${magenta}\n$j\n${default}"
		done
	else

		printf "\n${magenta}There are no supicious files to show.${default}\n\n"
	fi
fi