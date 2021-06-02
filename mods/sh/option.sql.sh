#******* SECURITY CHECK **************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* SQL **************************************************#
#
printf "\n${cyan}*** ${yellow}SQL Vulnerability${cyan} ***${magenta}\n\n"
#
read -e -p "Please provide the SQL vulnerable URL: " sqldomain
#
printf "\n"
#
if [ -z "$sqldomain" ]; then

	printf "${magenta}To check SQL vulnerabilities you will need to provide the vulnerable URL.${default}\n\n"
else
	
	sqlscan=$(
		sudo /usr/bin/python /opt/sqlmap/sqlmap/sqlmap.py -p add-to-cart --timeout=600 --threads=1 --user-agent='SiteLockSpider' --is-dba --flush-session --batch --url=\"$sqldomain\" |
		til -1                                           |
		awk '{print $3}'
	)

	if [ "$sqlscan" = '0,,0' ]; then

		sqlresult="${green}The URL is not vulnerable.${default}"

		printf "\n$sqlresult\n\n"
	else

		sqlresult="${cyan}Vulnerable parameter(s): ${red}$sqlscan{default}"

		printf "\n$sqlresult\n\n" |
			more
	fi
fi