#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* LINKS ************************************************#
#
printf "\n${cyan}*** ${yellow}Quick Links${cyan} ***${default}\n\n"
#
printf "Client Dashboard        : ${cyan}https://admin.sitelock.com/sales/sell/index/$accountid//$siteid/jump\n\n${default}"
#
printf "Screenshot              : ${cyan}https://snapito.com/screenshots/$domain.html?size=800x0&screen=1024x768&cache=2592000&delay=-1&url=$domain\n\n${default}"
#
printf "SEO Bot Render          : ${cyan}http://www.browseo.net/?url=$domain\n\n${default}"
#
printf "Site Archive            : ${cyan}https://web.archive.org/web/$domain\n${default}\n"