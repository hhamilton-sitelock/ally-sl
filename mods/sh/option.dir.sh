#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* DIRECTORY ****************************************#
#
printf "\n${magenta}This functionality has temporarily been removed.${default}\n\n"
#if [ "${smartdirview[0]}" ]; then
#
#	printf "\n${cyan}*** ${yellow}Directories${cyan} ***${default}\n"
#
#	for j in "${smartdirview[@]}"; do
#
#		printf "${magenta}\n${j//$mirrorpath}/\n${default}"
#	done
#
#	printf "\n"
#else
#
#	printf "\n${magenta}There are no directories to show.${default}\n\n"
#fi
