#******* SECURITY CHECK **************************************#
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
if [ "${zipcheck[0]}" ]; then

	printf "\n${cyan}*** ${yellow}Zip Archives${cyan} ***${default}\n"

	for j in "${zipcheck[@]}"; do

		printf "${magenta}\n$j\n${default}"
	done

	printf "\n"
else

	printf "\n${magenta}There are no .zip files to show.${default}\n\n"
fi