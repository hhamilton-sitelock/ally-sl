#******* SECURITY CHECK **************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* SMART ***********************************************#
#
printf "\n${cyan}*** ${yellow}SMART Scan${cyan} ***${default}\n\n"
#
printf "Scan Date               : ${cyan}$scandate${default}\n\n"
#
printf "Server                  : ${cyan}$smartserver${default}\n\n"
#
if [[ "$syncstatus" = "complete" ]]; then

	printf "Sync Status             : ${green}$syncstatus${default}\n\n"
elif [[ "$syncstatus" = "failed" ]]; then

	printf "Sync Status             : ${red}$syncstatus${default}\n\n"
else

	printf "Sync Status             : ${yellow}$syncstatus${default}\n\n"
fi
#
if [[ -n "$syncmsg_output" ]]; then

	printf "Sync Message            : ${yellow}$syncmsg${default}\n\n"
fi
#
if [[ -n "$syncmsg_output" ]]; then

	printf "Download Message        : ${yellow}$downloadmsg${default}\n\n"
fi
#
if [[ -n "$syncduration" ]]; then

	printf "Sync Duration           : ${cyan}$(( $syncduration / 60 )) minute(s) & $(( $syncduration % 60 )) seconds(s)${default}\n\n"
fi
#
if [[ -n "$scanduration" ]]; then

	printf "Scan Duration           : ${cyan}$(( $scanduration / 60 )) minute(s) & $(( $scanduration % 60 )) second(s)${default}\n\n"
fi
