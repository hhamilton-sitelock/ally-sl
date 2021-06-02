#******* SECURITY CHECK **************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* XSS **************************************************#
#
printf "\n${cyan}*** ${yellow}XSS Vulnerability${cyan} ***${magenta}\n\n"
#
read -e -p "Please provide the XSS vulnerable URL: " xssdomain
#
printf "\n"
#
if [ "$xssdomain" ]; then

	xssscan=$(
		sudo es_test_xss "$xssdomain" >/dev/null 2>&1 | awk '{ print $3 }'
	)

	if [ "$xssscan" = "0" ]; then

		xssresult="
${green}The URL is not vulnerable.${default}
"

		printf "$xssresult"
	else

		xssvars=$( ( php $phpmodspath/test_xss.php "$xssdomain" ) | awk -F':' '{ print $2 }' )

		xssdomain=$( printf $xssdomain | awk -F'?' '{ print $1 }' )

		xssvararr=( "${xssvars//,/ }" )

		for i in "${xssvararr[@]}"; do

			xssasp+="\nServer.HTMLEncode($i);\n"
		done

		for i in "${xssvararr[@]}"; do

			xsscgi+="\nencode_entities($i);\n"
		done
		
		xssresult="${cyan}Vulnerable URL        : $xssdomain

Vulnerable Parameters :${red}$xssvars${cyan}

XSS PHP Patch             :${magenta}

//SITELOCK XSS FILTERING CODE
	foreach ( array($xssvars ) as \$vuln ) {
		isset( \$_REQUEST[ \$vuln ] ) and \$_REQUEST[ \$vuln ] = htmlentities( \$_REQUEST[ \$vuln ] );
		isset( \$_GET[ \$vuln ] )     and \$_GET[ \$vuln ]     = htmlentities( \$_GET[ \$vuln ] );
		isset( \$_POST[ \$vuln ] )    and \$_POST[ \$vuln ]    = htmlentities( \$_POST[ \$vuln ] );
	}
//END SITELOCK FILTERING CODE
${cyan}
XSS ASP Patch             :${magenta}
$xssasp${default}${cyan}
XSS CGI Patch             :${magenta}
$xsscgi${default}
"

		printf "$xssresult"
	fi
else

	printf "\n${yellow}To check XSS vulnerabilities you will need to provide the vulnerable URL.${default}\n\n"
fi