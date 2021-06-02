#******* SECURITY CHECK **************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* 777 PERMISSIONS ************************************#
#
if [ "${allperms[0]}" ]; then

	printf "n${cyan}*** ${yellow}777 Permissions${cyan} ***${default}\n"

	for j in "${allperms[@]}"; do

		printf "${magenta}\n$j\n${default}"
	done

	printf "\n"
else

	printf "\n${magenta}There are no 777 permissions files to show.${default}\n\n"
fi