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
if [ "${suspectperms[0]}" ]; then

	printf "\n${cyan}*** ${yellow}Not 644 Permissions${cyan} ***${default}\n"

	for j in "${suspectperms[@]}"; do

		printf "${magenta}\n$j\n${default}"
	done

	printf "\n"
else

	printf "\n${magenta}There are no files that do not have 644 permissions to show.${default}\n\n"
fi