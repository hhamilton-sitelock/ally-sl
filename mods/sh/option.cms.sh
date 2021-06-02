#******* SECURITY CHECK **************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* CMS *************************************************#
#
if [ "${cmstype[0]}" ]; then

	printf "\n${cyan}*** ${yellow}CMS Installations${cyan} ***${default}\n"

	for i in "${cmstype[@]}"; do

		printf "${magenta}$i${default}"
	done
else

	printf "\n${magenta}There are no known CMS installations to show.\n\n"
fi