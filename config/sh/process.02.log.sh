#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* REPORT & FIND LOGS ***********************************#
#
# sudo -u root -g seccon echo $timestamp","$USER","$ticketid","$siteid","$domain |
# 	sudo tee -a /opt/data/seccon/ally.review.stats.txt > /dev/null
#
printf "\n${cyan}Timestamp: ${default}${timestamp}"
#
printf "\n${cyan}User:      ${default}${USER}"
#
printf "\n${cyan}Ticket ID: ${default}${ticketid}"
#
printf "\n${cyan}Site ID:   ${default}${siteid}"
#
printf "\n${cyan}Domain:    ${default}${domain}\n"