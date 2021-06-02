#******* SECURITY CHECK **************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* FTP **************************************************#
#
printf "\n${cyan}*** ${yellow}SMART Credentials${cyan} ***${magenta}\n\n"
#
read -e -p 'This will pull the SMART connection credentials. Are you sure? [y/n]: ' ans
#
printf "${default}\n"
#
if [[ "$ans" =~ [Yy] ]]; then

	if [ "$ftpcreds" ]; then

		true
	else 

		ftpcreds=$( sudo esgp --site_id="$siteid" )
	fi
	#
	printf "\n${magenta}"
	#
	echo -E "$ftpcreds"
	#
	printf "${default}\n\n"
fi