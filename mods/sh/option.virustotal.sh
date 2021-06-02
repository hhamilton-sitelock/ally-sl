#******* SECURITY CHECK **************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* VIRUSTOTAL ******************************************#
#
curl -s --request POST --url 'https://www.virustotal.com/vtapi/v2/url/scan' --data "apikey=$virustotalkey" --data "url=$domain" > /dev/null 2>&1;
#
sleep 3
#
virustotalresults=$(
	curl -s --request GET --url "https://www.virustotal.com/vtapi/v2/url/report?apikey=$virustotalkey&resource=$domain&scan=1" |
	python -m json.tool
)
#
vtreporturl=$(
	printf "$virustotalresults" |
	grep 'permalink'            |
	sed 's/    "permalink"://g' |
	tr -d ','                   |
	tr -d '"' 
)
#
vtpositives=$( 
	printf "$virustotalresults" |
	grep 'positives'            |
	sed 's/    "positives"://g' |
	tr -d ','                   |
	sed -e "s/[0-9]+/\x1b${yellow}&\x1b${magenta}/" 
)
#
vtscans=$(
	printf "$virustotalresults"                            |
	grep '        "'                                       |
	sed '/detected/d'                                      |
	sed '/detail/d'                                        |
	sed 's/"//g'                                           |
	sed 's/ site//g'                                       |
	sed 's/: {//g'                                         |
	sed 's/},//g'                                          |
	sed 's/        //g'                                    |
	tr -d ','                                              |
	sed -e "s/suspicious$/\x1b${yellow}&\x1b${magenta}\n/" |
	sed -e "s/spam$/\x1b${yellow}&\x1b${magenta}\n/"       |
	sed -e "s/phishing$/\x1b${red}&\x1b${magenta}\n/"      |
	sed -e "s/malicious$/\x1b${red}&\x1b${magenta}\n/"     |
	sed -e "s/malware$/\x1b${red}&\x1b${magenta}\n/"       |
	sed -e "s/phishing$/\x1b${red}&\x1b${magenta}\n/"      |
	sed -e "s/clean$/\x1b${green}&\x1b${magenta}\n/"       |
	sed -e "s/unrated$/\x1b${white}&\x1b${magenta}\n/"
)
#
printf "\n${cyan}*** ${yellow}VirustTotal Results${cyan} ***${default}\n\n${magenta}Report URL: ${cyan}$vtreporturl${magenta}\n\nPositives: $vtpositives\n\n${cyan}*** ${yellow}SCANS***\n\n${magenta}$vtscans${default}\n\n"