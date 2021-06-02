#******* SECURITY CHECK **************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* 000 PERMISSIONS ************************************#
#
if [ "${zeroperms[0]}" ]; then

	printf "\n${cyan}*** ${yellow}000 Permissions${cyan} ***${default}\n"

	for j in "${zeroperms[@]}"; do

		printf "${magenta}\n$j\n${default}"
	done

	printf "\n"
else

	printf "\n${magenta}There are no 000 permissions files to show.${default}\n\n"
fi