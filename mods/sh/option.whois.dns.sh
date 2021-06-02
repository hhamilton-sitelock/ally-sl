#******* SECURITY CHECK **************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* WHOIS & DNS ****************************************#
#
printf "\n${cyan}*** ${yellow}WHOIS${cyan} ***${default}\n\n"
#
if [ "$whoisinfo" ]; then
	
	printf "${cyan}$whoisinfo${default}\n\n"
else
	
	printf "${cyan}Whois information is unavailable on ES02.${default}\n\n"
fi
#
printf "${cyan}*** ${yellow}DNS${cyan} ***${default}\n"
#
printf "${cyan}$alldns${default}\n\n"
#
printf "Propagation:             ${cyan}https://www.whatsmydns.net/?utm_source=whatsmydns.com&utm_medium=redirect#NS/$domain\n\n${default}"
#
printf "History:                 ${cyan}https://securitytrails.com/domain/$domain/history/a\n${default}"