#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* GOOGLE SEARCH ****************************************#
#
printf "\n${cyan}*** ${yellow}Google SEO Check${cyan} ***${default}"
#
searchresults=$( 
	curl -s -X GET "https://www.googleapis.com/customsearch/v1?key=$googlekey&cx=$googlecx&q=site:$domain" |
	grep 'link\|title\|snippet'                                                                            |
	sed 's/"title"/\n\n/g'                                                                                 |
	awk -F': "' '{print $2}'                                                                               |
	tail -n +5                                                                                             |
	sed 's/",$//g'                                                                                         |
	sed 's/"$//g'                                                                                          |
	uniq
)
#
if [[ "$searchresults" = "" ]]; then

	printf "\n\n${magenta}There are no search results to show.${default}\n\n"
else

	printf "${magenta}$searchresults${default}\n\n" 2>/dev/null |
		sed "/Google Custom Search - site:$domain/d"            |
		sed '/Sitelock - Site Audit/d'                          |
		sed -e "s/^http.*$/\x1b${cyan}&\x1b${magenta}/"
fi