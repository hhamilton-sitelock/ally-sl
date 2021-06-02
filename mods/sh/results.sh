#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* RESULTS **********************************************#
#
output_spacing="\n"
case "$sitestatus" in

	"200" )
	
		status_output="${green}$sitestatus${default}"
		;;
	"301" )
	
		status_output="${green}$sitestatus${default}"
		;;
	"302" )
	
		status_output="${green}$sitestatus${default}"
		;;
	* )

		status_output="${red}$sitestatus${default}"
		;;
esac
#
case "$ftpconnection" in

	"0" )
	
		ftpconnection_output="${red}Wrong site directory, suspended, redirecting or error.${default}"
		;;
	"1" )
	
		ftpconnection_output="${green}Live site.${default}"
		;;
	* )

		ftpconnection_output="${red}UNKNOWN ERROR${default}"
		;;
esac
#
case "$firewallcheck" in

	"0" )
	
		firewallcheck_output="${cyan}Not detected.${default}"
		;;
	"1" )
	
		firewallcheck_output="${green}Detected.${default}"
		;;
	* )

		firewallcheck_output="${red}ERROR${default}"
		;;
esac
#
case "$googlesafebrowsing" in

	"0" )
	
		googlesafebrowsing_output="${green}Not listed.${default}"
		;;
	"2" )

		googlesafebrowsing_output="${red}ERROR${default}"
		;;
	* )

		googlesafebrowsing_output="${red}$googlesafebrowsing${default}"
		;;
esac
#
case "$sitebackup" in

	"0" )
	
		sitebackup_output="${red}Site backup was not created.${default}"
		;;
	"1" )
	
		sitebackup_output="${green}Site backup created.${default}"
		;;
	* )

		sitebackup_output="${red}ERROR${default}"
		;;
esac
#
if [ -n "$cachepurged" ]; then

	cache_output="${green}Yes${default}"
else

	cache_output="${red}No${default}"
fi
#
printf "\n${cyan}*** ${yellow}Report${cyan} ***${default}${output_spacing}"
#
#printf "ES User                 : ${cyan}$USER${output_spacing}${default}"
#
#printf "Date                    : ${cyan}$tsdate${output_spacing}${default}"
#
#printf "Time                    : ${cyan}$tstime${output_spacing}${default}"
#
#printf "Process Time            : ${cyan}$(( $duration / 60 )) minute(s) & $(( $duration % 60 )) second(s)${output_spacing}${default}"
#
#printf "Ticket ID               : ${cyan}$ticketid${output_spacing}${default}"
#
#printf "Account ID              : ${cyan}$accountid${output_spacing}${default}"
#
#printf "Site ID                 : ${cyan}$siteid${output_spacing}${default}"
#
#printf "Domain                  : ${cyan}$domain_output${output_spacing}${default}"
#
printf "IP Address              : ${cyan}$ipaddress${output_spacing}${default}"
#
printf "Domain Count            : ${cyan}$( echo $domaincount | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${output_spacing}${default}"
#
printf "Site Backup             : ${cyan}$sitebackup_output${output_spacing}${default}"
#
printf "Files Scanned		: ${cyan}$numfiles${output_spacing}${default}"
printf "SMART Cleaned           : ${cyan}$numcleaned${output_spacing}${default}"
#printf "Review files            : ${cyan}$numreview${output_spacing}${default}"
printf "Review/Uncleaned files  : ${cyan}$notcleanedcount${output_spacing}${default}"
printf "Malware Scan Status     : ${malwarescanoutput}${output_spacing}${default}"
printf "\n"
for i in ${!cms_name[@]}; do
  wpapicheck=$( grep '"'"${cms_version[$i]}"'"' /opt/data/seccon/ally-data/wpstabilitycheck.json | grep -Eo '(latest|insecure|outdated)' )
  case $wpapicheck in
  latest) wpapicolor="${green}" ;;
  outdated) wpapicolor="${yellow}" ;;
  insecure) wpapicolor="${red}" ;;
  *) wpapicolor="${red}" wpapicheck="NONEXISTENT?" ;;
  esac
#  printf "${cyan}${cms_name[$i]}${default} version ${wpapicolor}${cms_version[$i]}${default} found in directory ${cyan}${cms_dir[$i]}${default}. WP API reports this version as ${wpapicolor}${wpapicheck}${output_spacing}${default}"
#  printf "%-47s %-59s %s\n" "${cyan}${cms_name[$i]}${default} version ${wpapicolor}${cms_version[$i]}${default}" "found. WP API reports this version as: ${wpapicolor}${wpapicheck}${default}" "Directory: ${cyan}${cms_dir[$i]}${default}"
  printf "${magenta}>${default} Found ${cyan}${cms_name[$i]}${default} version ${wpapicolor}${cms_version[$i]}${default}. WP API reports this version as: ${wpapicolor}${wpapicheck}${default} Directory: ${cyan}${cms_dir[$i]}${default}\n"
#  echo "DEBUG: Sent pluginfinder.sh -b -f ${filemap} -d ${cms_dir[i]} ${mirrorpath}"
  bash ${shmodspath}/pluginfinder.sh -b -f "${filemap}" -d "${cms_dir[i]}" "${mirrorpath}"
done
#printf "Cache Purged            : $cache_output${output_spacing}${default}"
#
#printf "${cyan}*** ${yellow}Ticket Details${cyan} ***${default}${output_spacing}"
#
#printf "Name                    : ${cyan}$ticketname${default}${output_spacing}"
#
#printf "Date Entered            : ${cyan}$ticketdateentered${default}${output_spacing}"
#
#printf "Creted By               : ${cyan}$ticketcreatedby${default}${output_spacing}"
#
#printf "Status                  : ${cyan}${ticketstatus//_/ }${default}${output_spacing}"
#
#printf "Type                    : ${cyan}$tickettype${default}${output_spacing}"
#
#if [ "$ticketworkflow" = "" ]; then

#	ticketworkflow="No work flow specified."
#fi
#
#printf "Work Flow               : ${cyan}$ticketworkflow${default}${output_spacing}"
#
#printf "Assigned To             : ${cyan}$ticketassignedto${default}${output_spacing}"
#
#printf "Acount Owner            : ${cyan}$ticketaccountname${default}${output_spacing}"
#
#if [ "$ticketrequest" = "" ]; then
#
#	ticketrequest="No special request."
#fi
#
#if [ "$ticketsymptoms" = "" ]; then
#
#	ticketsymptoms="No symptoms listed."
#fi
#
#printf "Special Request         : ${cyan}$ticketrequest${default}${output_spacing}"
#
#printf "Symptoms                : ${cyan}$ticketsymptoms${default}${output_spacing}"
#
#printf "SLA (hrs)               : ${cyan}$ticketsla${default}${output_spacing}"
#
#printf "SLA Elapsed ( hrs / %% ) : ${cyan}$ticketslaelapsed / $ticketslapercent%% ${default}${output_spacing}"
#
printf "\n${cyan}*** ${yellow}Site Status${cyan} ***${default}${output_spacing}"
#
printf "Status Code             : $status_output${output_spacing}"
#
if [[ "$sitestatus" = "200" ]] ||
   [[ "$sitestatus" = "301" ]] ||
   [[ "$sitestatus" = "302" ]] ; then

	if [ "$suspended" = "1" ]; then

		printf "Site Status             : ${red}Suspended.${default}${output_spacing}"	
	elif [ "$fatalerror" = "1" ]; then

		printf "Site Status             : ${red}Fatal error detected.${default}${output_spacing}"
	else
		
		if [ "$noticeerror" = "1" ]; then

			printf "Site Status             : ${red}Notice error detected.${default}${output_spacing}"
		elif [ "$parseerror" = "1" ]; then

			printf "Site Status             : ${red}Parse error detected.${default}${output_spacing}"
		elif [ "$phpwarning" = "1" ]; then

			printf "Site Status             : ${red}PHP warning detected.${default}${output_spacing}"
		elif [ "$whitescreen" = "1" ]; then

 			printf "Site Status             : ${red}White screen detected.${default}${output_spacing}"
		else

			printf "Site Status             : ${green}Site loading fine.${default}${output_spacing}"
		fi

		printf "Site Connection         : $ftpconnection_output${output_spacing}"
	fi
else

	printf "Site Status             : ${red}Site not loading.${default}${output_spacing}"
fi
#
printf "Firewall Service        : ${firewallcheck_output}${output_spacing}"
#
printf "Google Safe Browsing    : ${googlesafebrowsing_output}${output_spacing}"
#
#printf "\n${cyan}*** ${yellow}SMART Results${cyan} ***${default}${output_spacing}"
#printf "SMART Cleaned		: $numcleaned${output_spacing}"
#printf "Review files		: $numreview${output_spacing}"
printf "\n"
printf "Mirror Path             : ${cyan}${mirrorpath}${default}${output_spacing}"
printf "Backup Path             : ${cyan}${backupdirectory}${default}${output_spacing}"
printf "\n"
