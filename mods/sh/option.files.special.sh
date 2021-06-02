#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* SITEMAPS *********************************************#
#
printf "\n${cyan}*** ${yellow}Special Files${cyan} ***${default}\n\n"
#
printf "Archives                : ${cyan}$( echo $zipcount      | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n"
#
printf ".sql                    : ${cyan}$( echo $sqlcount      | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n"
#
printf ".xml ( > 500 B  )       : ${cyan}$( echo $xmlcount      | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n" 
#
printf ".ico ( > 100 B  )       : ${cyan}$( echo $icocount      | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n"
#
printf ".exe                    : ${cyan}$( echo $execount      | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n"
#
printf ".dmg                    : ${cyan}$( echo $dmgcount      | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n"
#
printf "robots.txt              : ${cyan}$( echo $robotscount   | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n"
#
printf ".htaccess               : ${cyan}$( echo $htaccesscount | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n"