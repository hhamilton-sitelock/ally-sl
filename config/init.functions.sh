#******* SECURITY CHECK **************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
source $configpath/init.security.sh
#
#
#******* FUNCTIONS ********************************************#
#
echo "First check for debugging."
echo "DEBUGGING: $debugging"
echo "Verbosity: $beverbose"
bug() {
  if $debugging; then
    echo "$1"
  fi
}

filechange() {

	sudo stat $1      |
		grep ^Change  |
		cut -d: -f2-4 |
		sed 's#^ ##'
}
#
confirmquit() {

	printf "\n"

    read -e -p 'Are you sure you want to quit? [y/n]: ' ans

    if [[ "$ans" =~ [Yy] ]]; then

    	if [ $uplodedtools ]; then

    		removetools
    	fi

    	clearcache

        printf "\n${cyan}Thank you for using ${default}$appname${cyan}. Quitting.${default}\n\n" |
			sed -e "s/Lock/\x1b${red}&\x1b${default}/g"

        exit 1
    else

    	printf "\n${cyan}Continue. If you were choosing an option you can now make your selection: ${default}"
    fi
}
#
multiedit() {

    for i in $@; do

    	i=$( echo $i | cut -f1 -d":" )

        if sudo test -f "$mirrorpath/$i"; then

	        if [[ $i =~ \ \+[0-9]+$ ]]; then

	            line="+[ $(echo $i |
	            	awk '{print $NF}') ]"

	            file=$mirrorpath/$(echo $i  |
		            awk '{$NF=""; print $0}'|
		            sed -e 's/[[:space:]]*$//')
	        else
	           
	            line=""
	           
	            file=$mirrorpath/$i
	        fi

	        pre_vim=$(
	        	filechange $file
	        )

	    	sudo vim "+syntax on" $line "$file"
	    
	        post_vim=$(
	        	filechange $file
	        )

	        if [ "$pre_vim" != "$post_vim" ]; then

	        	printf "${cyan}"
	        
	            read -rep "Submit signature? [y/n] " -n 1 ans
	    
	            if [[ "$ans" =~ [Yy] ]]; then

	            	printf "\n${cyan}Submitting signature and uploading file to the client's account. Stand by...${default}\n"
	    
	            	subsigfiles+=( "$i" )

	                sudo esfileup --path="$file" --force >/dev/null 2>&1

	                totsubsig=$(( $totsubsig + 1 ))
	            else

	            	printf "\n${cyan}Uploading to changed file to the client's account without submitting a signature. Stand by...${default}\n"
	    
	            	nosigfiles+=( "$i" )

	                sudo esfileup --path="$file" --force --no_log >/dev/null 2>&1

	                totnosig=$(( $totnosig + 1 ))
	            fi
	        fi
	    fi
    done
}
#
singleedit() {

	if [ "$1" ]; then

		file=$1
	else

		printf "\n\n"

		read -e -p 'Which file would you like to edit? Specify the file and path here: ' file
	fi

	file=${file//$mirrorpath/}

	if sudo test -f "$mirrorpath/$file"; then
			
			multiedit "$file"
	else 

		printf "${magenta}\nFile does not exist.${default}\n\n"
	fi
}
#
addtools() {

	printf "\n${magenta}Adding tools to the client's server. Stand by...${default}\n"

	uploadedurl=()

	if [ -d $usertools ]; then

		shopt -s nullglob

		allusertools=( $usertools/* )

		for i in "${allusertools[@]}"; do

			if [[ $i != "$usertools/.apikeys" ]]; then

				esupfile="$mirrorpath/$( basename $i )"

				cat $i |
					sudo tee "$esupfile" > /dev/null 2>&1

				sudo esfileup --path="$esupfile" --force --no_log >/dev/null 2>&1
				
				uploadedurl+=( "$domain/$( basename $i )" )
			fi	
		done

		uploadedtools="1"

		printf "\n${cyan}*** ${yellow}Tools Uploaded${cyan} ***${default}\n"

		for i in "${uploadedurl[@]}"; do


			printf "\n${magenta}http://$i${default}\n"
		done

		printf "\n"
	else

		printf "\n${magenta}You do not have tools to upload.${default}\n"
	fi
}
#
removetools() {
	return
	removetools="removetools-$siteid.php"

	printf "\n${magenta}Removing all tools from the client's server. Stand by...\n\nRemoval Script: http://$domain/$removetools${default}\n"

	rm -f "$userpath/$removetools" > /dev/null 2>&1

	sudo rm -f $mirrorpath/$removetools > /dev/null 2>&1

	if [ -d $usertools ]; then

		shopt -s nullglob

		allusertools=( $usertools/* )
	fi

	if [ $allusertools ]; then

		printf "<?php
	\$tools = array(" > $userpath/$removetools 
		
		for i in "${allusertools[@]}"; do

			toolname=$( basename $i )

			if [[ "${toolname::1}" != "." ]]; then

				printf "		'$toolname'," >> $userpath/$removetools
			fi
		done
		printf "
		'$checkfile',
		'$siteid.txt',
		'adminer.php',
		'$siteid-check.txt',
		'check.txt',
		'extract_db_$siteid.php',
		'fatt.php',
		'searchreplace.php',
		'wp-fatt.php'
	);" >> $userpath/$removetools 
	else
	
		printf "<?php
	\$tools = array(
		'$checkfile',
		'$siteid.txt',
		'adminer.php',
		'$siteid-check.txt',
		'check.txt',
		'dbclean.php', 
		'extract_db_$siteid.php',
		'fatt.php',
		'searchreplace.php',
		'wp-fatt.php',
		'wp-refresh.php'
	);" > $userpath/$removetools 
	fi
	
	printf '
	
	foreach( $tools as $tool ) {
	
		unlink( __DIR__ . "/" . $tool );
	}

	unlink( __FILE__ );
?>' >> $userpath/$removetools;

	cat $userpath/$removetools |
		sudo tee "$mirrorpath/$removetools" >/dev/null 2>&1

	sudo esfileup --path="$mirrorpath/$removetools" --force --no_log >/dev/null 2>&1

	clearcache

	wget -T 60 "$domain/$removetools" >/dev/null 2>&1
	
	uploadedtools=""

	printf "\n${magenta}Completed.${default}\n\n"
}
#
showhelp() {

	cat $abspath/readme.txt

	exit 1
}
#
parseoptions() {

	if [[ "$#" < 1 ]]; then

		showhelp

		printf "\n"
	else
		while getopts "hdvxt:a:s:" opt; do

			case "${opt}" in
				h)

					showhelp

					printf "\n"
					;;
				d)

					debugging='true'
					;;
				v)

					set -x
					;;
				x)

					testdata='true'
					;;
				t)

					ticketid=$OPTARG
					;;
				a)

					accountid=$OPTARG
					;;
				s)

					ids=( $OPTARG )
					;;
				?)

					showhelp

					printf "\n"
					;;
			esac
		done
	fi

	checkoptions

}
#
checkoptions() {
	local site_id
	local regex='^[0-9]+'

	for site_id in "${ids[@]}"; do
		if ! [[ $site_id =~ $regex ]]; then
			echo "Provided site ID ${site_id} is invalid."
			showhelp
		fi
	done
}
#
addcolor() {
	
	default=`tput sgr0`;

	red=`tput setaf 1`;

	green=`tput setaf 2`;

	yellow=`tput setaf 3`;

	blue=`tput setaf 4`;

	magenta=`tput setaf 5`;

	cyan=`tput setaf 6`;

	white=`tput setaf 7`;

	bold=`tput bold`;

	underline=`tput smul`;

	stopunderline=`tput rmul`;

	invert=`tput rev`;
}
#
resetfilemaps() {

	$(
		sudo find /opt/data/seccon/MultigrepsFilemaps/* -mtime +7 -exec rm {} \;
	)
}
#
displaygreeting() {

	printf "\n\n"

	clear

	printf "${green}* Welcome to ${default}$appname${green} | Version $version - $tagline *${default}\n" |
		sed -e "s/Lock/\x1b${red}&\x1b${default}/g"

	if [[ "$debugging" == "true" ]]; then

		printf "\nDebug Mode: ${green}ON${default}\n" 
	fi
}
#
process() {

	source $abspath/process.sh
}
#
security() {

	source $configpath/init.security.sh
}
#
smart911check() {

	smart911sites=$( 
		curl -s https://admin.sitelock.com/sys/api.cmp?action=smart_911 |
		sed -e 's/{\(.*\)}/\1/'                                         |
		sed -e 's/\[\(.*\)\]/\1/'                                       |
		sed 's/},{/\n/g'                                                |
		sed 's/":"/:/g'                                                 |
		sed 's/"//g'                                                    |
		sed 's/,/ /g'                                                   |
		awk '{ print $3 }'                                              |
		awk -F':' '{ print $2 }'                                        |
		grep -oh "$siteid"
	)

	if [[ -z "$smart911sites" ]]; then

		printf "\n${cyan}You must add all Site IDs being processed to SMART 911.\n\nLog in and add them here: https://admin.sitelock.com/sys/smart_911.cmp?add=1&site_id=$siteid${default}\n\n"

	    read -e -p "Is Site ID $siteid added to SMART 911? [y/n]: " ans

	    if  [[ "$ans" =~ [Yy] ]]; then

			true
	    else

	        printf "\n${red}Error: ${yellow}You must add the Site ID to SMART 911 before running ${appname}. Quitting.${default}\n\n"

	        exit 1
	    fi
	fi
}
#
processoptions() {
	
	if [ "$testdata" = 'true' ]; then

		ticketid="773626"

		ids=(7749451 14401176 14401177 14401179 14401180 14401181)
	fi
		
#	if [ -z "$ticketid" ]; then 
#
#		printf "\n"
#
#		read -e -p 'Please provide the Ticket ID you are working on: ' ticketid 
#	fi
	
#	if [ -z "$ticketid" ]; then
#
#		printf "\n${red}Error: ${yellow}In order to run ${default}${appname}${yellow} properly you will need to provide the Ticket number you are working on.${default}\n\n" |
#			sed -e "s/Lock/\x1b${red}&\x1b${default}/g"
#
#		exit 1
#	else
#
#		source $configpath/init.crm.sh >/dev/null 2>&1
#	fi
	
#	if [ -z "$accountid" ]; then 
#
#		printf "\n"
#
#		read -e -p "Please provide the associated Account ID for Ticket ${ticketid}: " accountid
#	fi
	
#	if [ -z "$accountid" ]; then 
#
#		printf "\n${red}Error: ${yellow}In order to run ${default}${appname}${yellow} properly you will need to provide the Accout ID for ticket:${default} $ticketid${yellow}.${default}\n\n" |
#			sed -e "s/Lock/\x1b${red}&\x1b${default}/g"
#
#		exit 1
#	fi
	
	if [ -z "$ids" ]; then 

		printf "\n"

#		read -e -p "Please provide the associated Site IDs for Ticket ${ticketid}
#
#For multiple Site IDs sperate them with a [ space ] and wrap all IDs in quotes \"\": " ids
		read -e -p "Please provide the associated Site IDs for this process

For multiple Site IDs separate them with a [ space ] and wrap all IDs in quotes \"\": " ids

	fi
	
	if [ -z "$ids" ]; then 

		printf "\n${red}Error: ${yellow}In order to run ${default}${appname}${yellow} properly you will need to provide the Site ID(s) for this process.${default}\n\n" |
			sed -e "s/Lock/\x1b${red}&\x1b${default}/g"

		exit 1
	fi
}
#
smartresults() {

	source $shmodspath/option.smart.sh
}
#
allyreport() {

	source $shmodspath/results.sh |
		more && reportoptions
}
#
clearcache() {

	source $shmodspath/action.01.cache.sh >/dev/null 2>&1
}
#
fileoptions() {

	printf "
${cyan}*** ${yellow}File Options${cyan} ***

${default}Choose a ${cyan}(  ${yellow}number${cyan}  )${default} associated with a ${yellow}List${default} option.${cyan}\n"

	printf "
;;
----------------------------;-------------;-------------
List         : Count;View;Edit
----------------------------;-------------;-------------
Not Clean    : $( echo $notcleanedcount   | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' );(  1  );(  2  )
;;
Suspicious   : $( echo $numsuspicious     | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' );(  3  );(  4  )
;;
.suspected   : $( echo $suspectedcount    | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' );(  5  );(  6  )
;;
SMART Cleaned: $( echo $numcleaned        | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' );(  7  );
;;
"                                                                        |
		column -t -s ';'                                                 |
		sed -e "s/  [0-9]+  /\x1b${yellow}&\x1b${cyan}/g"                |
		sed -e "s/  m  /\x1b${yellow}&\x1b${cyan}/g"                     |
		sed -e "s/List         : Count/\x1b${yellow}&\x1b${cyan}/g"      |
		sed -e "s/View/\x1b${yellow}&\x1b${cyan}/g"                      |
		sed -e "s/Edit/\x1b${yellow}&\x1b${cyan}/g"

	read -e -p "${default}Choose an option or press ${cyan}[  ${yellow}enter${cyan}  ]${default} when done: " displaysmartopt

	case $displaysmartopt in
		"7")

			( source $shmodspath/option.smart.cleaned.sh     |
				more )                                      &&
				fileoptions
		;;
		"5")

			( source $shmodspath/option.suspected.sh         |
				more )                                      &&
				fileoptions
		;;
		"6")

			editsuspectedfiles=()
		
			for i in "${suspectedfiles[@]}"; do

				editsuspectedfiles+=( $( printf "$i" | awk -F' : ' '{ print $3 }' ) )
			done
			
			multiedit "${editsuspectedfiles[@]}" && fileoptions
		;;
		"3")

			( source $shmodspath/option.smart.suspicious.sh  |
				more )                                      &&
				fileoptions
		;;
		"4")

			multiedit "${fuzzyprompts[@]}" && fileoptions
		;;
		"1")

			( source $shmodspath/option.smart.unclean.sh     |
				more )                                      &&
				fileoptions
		;;
		"2")

			multiedit "${notcleaned[@]}" && fileoptions
		;;
		* )

			printf "\n"
		
			reportoptions
		;;
	esac
}
#
specialfileoptions() {

	printf "
${cyan}*** ${yellow}Special File Options${cyan} ***

${default}Choose a ${cyan}(  ${yellow}number${cyan}  )${default} associated with a ${yellow}List${default} option.${cyan}\n"

	printf "
;;
----------------------------;-------------;-------------
List         : Count;View;Edit
----------------------------;-------------;-------------
Archives                : $( echo $zipcount      | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' );(  0  );
;;
.sql                    : $( echo $sqlcount      | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' );(  1  );
;;
.xml ( > 500 B  )       : $( echo $xmlcount      | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' );(  2  );
;;
.ico ( > 100 B  )       : $( echo $icocount      | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' );(  3  );
;;
.exe                    : $( echo $execount      | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' );(  4  );
;;
.dmg                    : $( echo $dmgcount      | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' );(  5  );
;;
robots.txt              : $( echo $robotscount   | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' );(  6  );(  7  )
;;
.htaccess               : $( echo $htaccesscount | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' );(  8  );(  9  )
;;
"                                                                        |
		column -t -s ';'                                                 |
		sed -e "s/  [0-9]+  /\x1b${yellow}&\x1b${cyan}/g"                |
		sed -e "s/  m  /\x1b${yellow}&\x1b${cyan}/g"                     |
		sed -e "s/List         : Count/\x1b${yellow}&\x1b${cyan}/g"      |
		sed -e "s/View/\x1b${yellow}&\x1b${cyan}/g"                      |
		sed -e "s/Edit/\x1b${yellow}&\x1b${cyan}/g"

	read -e -p "${default}Choose an option or press ${cyan}[  ${yellow}enter${cyan}  ]${default} when done: " specialfilesopt

	case $specialfilesopt in
		"0")
			(
				if [ "${zipcheck[0]}" ]; then

					printf "\n${cyan}*** ${yellow}Archives${cyan} ***${default}\n"

					for i in "${zipcheck[@]}"; do

						printf "${magenta}\n$i\n${default}"
					done

					printf "\n"
				else

					printf "\n${magenta}There are no archive files to show.${default}\n\n"
				fi
			)         | 
				more &&
				specialfileoptions
		;;
		"1")
			(
				if [ "${sqlcheck[0]}" ]; then

					printf "\n${cyan}*** ${yellow}.sql > 500 B${cyan} ***${default}\n"

					for i in "${sqlcheck[@]}"; do

						printf "${magenta}\n$i\n${default}"
					done

					printf "\n"
				else

					printf "\n${magenta}There are no large .sql files to show.${default}\n\n"
				fi
			)         | 
				more &&
				specialfileoptions
		;;
		"2")
			(
				if [ "${xmlcheck[0]}" ]; then

					printf "\n${cyan}*** ${yellow}.xml > 500 B${cyan} ***${default}\n"

					for i in "${xmlcheck[@]}"; do

						printf "${magenta}\n$i\n${default}"
					done

					printf "\n"
				else

					printf "\n${magenta}There are no large .xml files to show.${default}\n\n"
				fi
			)         | 
				more &&
				specialfileoptions
		;;
		"3")
			(
				if [ "${icocheck[0]}" ]; then

					printf "\n${cyan}*** ${yellow}.ico > 100 B${cyan} ***${default}\n"

					for i in "${icocheck[@]}"; do

						printf "${magenta}\n$i\n${default}"
					done

					printf "\n"
				else

					printf "\n${magenta}There are no large .ico files to show.${default}\n\n"
				fi
			)         | 
				more &&
				specialfileoptions
		;;
		"4")
			(
				if [ "${execheck[0]}" ]; then

					printf "\n${cyan}*** ${yellow}.exe${cyan} ***${default}\n"

					for i in "${execheck[@]}"; do

						printf "${magenta}\n$i\n${default}"
					done

					printf "\n"
				else

					printf "\n${magenta}There are no .exe files to show.${default}\n\n"
				fi
			)         | 
				more &&
				specialfileoptions
		;;
		"5")
			(
				if [ "${dmgcheck[0]}" ]; then

					printf "\n${cyan}*** ${yellow}.dmg${cyan} ***${default}\n"

					for i in "${dmgcheck[@]}"; do

						printf "${magenta}\n$i\n${default}"
					done

					printf "\n"
				else

					printf "\n${magenta}There are no .dmg files to show.${default}\n\n"
				fi
			)         | 
				more &&
				specialfileoptions
		;;
		"6")
			(
				if [ "${robotscheck[0]}" ]; then

					printf "\n${cyan}*** ${yellow}robots.txt${cyan} ***${default}\n"

					for i in "${robotscheck[@]}"; do

						printf "${magenta}\n$i\n${default}"
					done

					printf "\n"
				else

					printf "\n${magenta}There are no robots.txt files to show.${default}\n\n"
				fi
			)         | 
				more &&
				specialfileoptions
		;;
		"7")
			(

				if [ "${robotscheck[0]}" ]; then

					multiedit "${robotscheck[@]}"
				else

					printf "\n${magenta}There are no robots.txt files to edit.${default}\n\n"
				fi
			) &&
				specialfileoptions
		;;
		"8")
			(
				if [ "${htaccesscheck[0]}" ]; then

					printf "\n${cyan}*** ${yellow}.htaccess${cyan} ***${default}\n"

					for i in "${htaccesscheck[@]}"; do

						printf "${magenta}\n$i\n${default}"
					done

					printf "\n"
				else

					printf "\n${magenta}There are no .htaccess files to show.${default}\n\n"
				fi
			) &&
				specialfileoptions
		;;
		"9")
			(

				if [ "${htaccesscheck[0]}" ]; then

					multiedit "${htaccesscheck[@]}"
				else

					printf "\n${magenta}There are no .htaccess files to edit.${default}\n\n"
				fi
			) &&
				specialfileoptions
		;;
		*)
					
			printf "\n"
		
			reportoptions
		;;
	esac
}
#
scanoptions() {

	printf "${cyan}*** ${yellow}Scan Options${cyan} ***\n\n"

	printf "Results Found: ${yellow}${#@}${cyan}\n"

	printf "
;;
---------------------;---------------------
(  0  ) View Results; (  1  ) Edit Files
;;

"                                                      |
		column -t -s ';'                               | 
		sed -e "s/[0-9]\+/\x1b${yellow}&\x1b${cyan}/g"

	read -e -p "${default}Choose an option or press ${cyan}[  ${yellow}enter${cyan}  ]${default} when done: " scanopt

	case $scanopt in
		"0")
			(
				for j in "$@"; do

					printf "${magenta}\n$j\n${default}"
				done
			)     | 
			more &&
			scanoptions "$@"

			printf "\n"
		;;
		"1")

			multiedit "$@" &&
			scanoptions "$@"
		;;
		*)
			
			printf "\n"
		
			reportoptions
		;;
	esac
}
#
reportoptions() {

	printf "${cyan}*** ${yellow}Report Options${cyan} ***

${default}Choose a ${cyan}(  ${yellow}number${cyan}  )${default} associated with an option.${cyan}\n"
	
	printf "
;;
------------------------;------------------------;------------------------
(  1  ) Report;(  2  ) SMART Details;(  3  ) Quick Links
------------------------;------------------------;------------------------
(  4  ) Files Review;(  5  ) Special Files;(  6  ) Whois & DNS
------------------------;------------------------;------------------------
(  7  ) CMS Check;(  8  ) Mirror Search;(  9  ) Pull FTP Creds
------------------------;------------------------;------------------------
(  10  ) Tools
;;
"                                                      |
		column -t -s ';'                               | 
		sed -e "s/[0-9]\+/\x1b${yellow}&\x1b${cyan}/g" |
		sed -e "s/#/\x1b${yellow}&\x1b${cyan}/g"

	read -e -p "${default}Choose an option or press ${cyan}[  ${yellow}enter${cyan}  ]${default} when done: " displayopt

	case $displayopt in

		"1" )
			
			allyreport
			;;
		"2" )
			
			smartresults                                 &&
				reportoptions	
			;;
		"3" )
			
			source $shmodspath/option.links.sh           &&
				reportoptions
			;;
		"4" )
			
			( source $shmodspath/option.files.sh          |
				more )                                   &&
				fileoptions
			;;
		"5" )
			
			( source $shmodspath/option.files.special.sh  |
				more )                                   &&
				specialfileoptions
			;;
		"6" )
			
			( source $shmodspath/option.whois.dns.sh      |
				more )                                   &&
					reportoptions
			;; 
		"7" )
			
			( source $shmodspath/option.cms.sh            |
				more )                                   &&
					reportoptions
			;;
		"8" )
						
			source $shmodspath/option.mirror.search.sh   &&
				reportoptions
			;;
#		"9" )
#						
#			source $shmodspath/option.backup.sh          &&
#				reportoptions
#			;;
#		"10" )
#						
#			source $shmodspath/option.scan.heuristic.sh  &&
#				reportoptions
#			;;
		"9" )
						
			source $shmodspath/option.smart.creds.sh     &&
				reportoptions
			;;
		"clam" )
			if [ -e $userapikeys ]; then
		
				source $shmodspath/option.scan.clam.sh   &&
					reportoptions
			else

				printf "\n${red}You do not have the necessary credentials.${default}\n" && reportoptions	
			fi
			;;
		"hfix" )
			if [ -e $userapikeys ]; then
		
				source $shmodspath/option.header.fix.sh  &&
					reportoptions
			else

				printf "\n${red}You do not have the necessary credentials.${default}\n" && reportoptions	
			fi
			;;
		"restore" )
			if [ -e $userapikeys ]; then

				source $shmodspath/option.restore.sh     &&
					reportoptions
			else

				printf "\n${red}You do not have the necessary credentials.${default}\n" && reportoptions	
			fi
			;;
		"ccache" )
			
			if [ -e $userapikeys ]; then

				clearcache &&
					reportoptions
			else

				printf "\n${red}You do not have the necessary credentials.${default}\n" && reportoptions	
			fi
			;;
		"atools" )
			
			if [ -e $userapikeys ]; then

				addtools &&
					reportoptions
			else

				printf "\n${red}You do not have the necessary credentials.${default}\n" && reportoptions	
			fi
			;;
		"rtools" )
			
			if [ -e $userapikeys ]; then

				removetools &&
					reportoptions
			else

				printf "\n${red}You do not have the necessary credentials.${default}\n" && reportoptions	
			fi
			;;
		"gsearch" )

			if [ -e $userapikeys ]; then

				source $shmodspath/option.google.search.sh |
					more &&
						reportoptions	
			else

				printf "\n${red}You do not have the necessary credentials.${default}\n" && reportoptions	
			fi
			;;
		"vtotal" )

			if [ -e $userapikeys ]; then

				source $shmodspath/option.virustotal.sh    |
					more &&
						reportoptions
			else

				printf "\n${red}You do not have the necessary credentials.${default}\n" && reportoptions	
			fi
			;;
		"xss" )

			if [ -e $userapikeys ]; then

				source $shmodspath/option.xss.sh &&
					reportoptions
			else

				printf "\n${red}You do not have the necessary credentials.${default}\n" && reportoptions	
			fi
			;;
		"sql" )

			if [ -e $userapikeys ]; then
			
				source $shmodspath/option.sql.sh &&
					reportoptions
			else

				printf "\n${red}You do not have the necessary credentials.${default}\n" && reportoptions	
			fi
			;;
		"10" )
		    show_tools_menu
			reportoptions
			;;
		* )

			printf "\n"

		    read -rep $"${cyan}Are you sure you are done? [y/n]:${default} " -n 1 ans

		    if [[ "$ans" =~ [Yy] ]]; then

		    	clearcache
		    else
				
				printf "\n"

		    	reportoptions
		    fi
			;;
	esac

}
#
postprocess() {

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

	#clearcache

	if [ -n "$cachepurged" ]; then

		cache_output="${green}Yes${default}"
	else

		cache_output="${red}No${default}"
	fi

#	source $shmodspath/check.01.status.sh;

	if [[ "$sitestatus" = "200" ]] ||
	   [[ "$sitestatus" = "301" ]] ||
	   [[ "$sitestatus" = "302" ]] ; then

		if [ "$suspended" = "1" ]; then

			sitestatus_output="${red}Suspended.${default}"	
		elif [ "$fatalerror" = "1" ]; then

			sitestatus_output="${red}Fatal error detected.${default}"
		else
			
			if [ "$noticeerror" = "1" ]; then

				sitestatus_output="${red}Notice error detected.${default}"
			elif [ "$parseerror" = "1" ]; then

				sitestatus_output="${red}Parse error detected.${default}"
			elif [ "$phpwarning" = "1" ]; then

				sitestatus_output="${red}PHP warning detected.${default}"
			elif [ "$whitescreen" = "1" ]; then

	 			sitestatus_output="${red}White screen detected.${default}"
			else

				sitestatus_output="${green}Site loading fine.${default}"
			fi
		fi
	else

		sitestatus_output="${red}Site not loading.${default}"
	fi

	printf "
${cyan}*** ${yellow}Post-Clean Report For Site ID: ${default}$siteid${cyan} ***${default}
Site Backup             : ${yellow}$sitebackup_output${default}
Site Status             : ${yellow}$sitestatus_output${default}
Cache Purged            : $cache_output
SMART Cleaned           : ${yellow}$numcleaned${default}
Manually Cleaned        : ${yellow}$(( ${#subsigfiles[@]} + ${#nosigfiles[@]}))${default}
Signatures Submitted    : ${yellow}${#subsigfiles[@]}${default}

${cyan}*** ${yellow}Submitted Signature Files${cyan} ***${default}
"
	if [ "${subsigfiles[0]}" ]; then

		for i in "${subsigfiles[@]}"; do

			printf "$i\n"
		done
	else

		printf "No Signature were submitted.\n"
	fi
	
	printf "
${cyan}*** ${yellow}Edited Files No Signature Submitted${cyan} ***${default}
"
	if [ "${nosigfiles[0]}" ]; then

		for i in "${nosigfiles[@]}"; do

			printf "$i\n"
		done
	else

		printf "No files edited and not submitted.\n"
	fi

}
#
processcycle() {

	for siteid in "${ids[@]}"; do

		smart911check

#		printf "\n${cyan}Configuring process on ${yellow}Ticket: ${default}${ticketid}${cyan} for ${yellow}Account ID: ${default}${accountid}${cyan} currently processing ${yellow}Site ID: ${default}${siteid}${cyan}.
		printf "\n${cyan}Configuring process. Currently processing ${yellow}Site ID: ${default}${siteid}${cyan}.

Stand by...
${default}"

		SECONDS=0

		if [ $debugging = 'true' ]; then

			for f in $shconfigpath/process.*.sh; do
                                echo "Processing ${f}"
				source $f
			done
		else
			
			for f in $shconfigpath/process.*.sh; do

				source $f >/dev/null 2>&1
			done
		fi

		printf "\n${cyan}Process configured.${default}\n"

		printf "\n${cyan}Performing checks for ${default}${siteid} ${yellow}/${default} ${domain}${cyan}.

Stand by...
${default}"

		if [ $debugging = 'true' ]; then
			
			for f in $shmodspath/check.*.sh; do 
				echo "Processing ${f}"
				source $f
			done
		else
			
			for f in $shmodspath/check.*.sh; do

				source $f >/dev/null 2>&1
			done
		fi

		printf "\n${cyan}Checks completed.${default}\n"

		printf "\n${cyan}Performing actions for ${default}${siteid} ${yellow}/${default} ${domain}${cyan}.

Stand by...
${default}"	

		if [ $debugging = 'true' ]; then

			for f in $shmodspath/action.*.sh; do
				echo "Processing ${f}"
				source $f
			done
		else

			for f in $shmodspath/action.*.sh; do

				source $f >/dev/null 2>&1
			done
		fi

		printf "\n${cyan}Actions completed.${default}\n"

		duration=$SECONDS

		printf "\n${cyan}Displaying report for ${default}${siteid} ${yellow}/${default} ${domain}${cyan}.${default}\n"

		allyreport

		postprocess
	done
}
#
postclean() {

#		printf "
#${cyan}*** ${yellow}Post-Ticket Report For Ticket: ${default}$ticketid${cyan} ***${default}
               printf "
${cyan}*** ${yellow}Post-Process Report ***${default}
SMART Cleaned           : ${yellow}$totnumcleaned${default}
Manually Cleaned        : ${yellow}$(( $totsubsig + $totnosig))${default}
Signatures Submitted    : ${yellow}$totsubsig${default}
Edited Not Submitted    : ${yellow}$totnosig${default}

${cyan}*** ${yellow}Final Domain Count${cyan} ***${default}
${cyan}The total domain count for this process is: ${yellow}${domaintotal}${default}
"	
#${cyan}The total domain count for ${yellow}Ticket: ${default}${ticketid}${cyan} is: ${yellow}${domaintotal}${default}
}
#
processcomplete() {

	if [ $uplodedtools ]; then

		removetools
	fi

	postclean

	printf "
${cyan}Thank you for using ${default}${appname}${cyan}.${default}

"       |
		sed -e "s/Lock/\x1b${red}&\x1b${default}/g"
}

show_tools_menu() {
  local whichtool
  printf "\n1) Phisherman (by Adam: Search for Phishing Folders)\n"
  printf "2) Test Option\n"
  printf "3) Test Option\n"
  printf "4) Test Option\n"

  read -e -p "Enter an associated tool number or press enter to go back: " whichtool

  case $whichtool in
    "1")
	  #Run Adam's Phishing Script
      perl /home/logins/amorris/scripts/phishing/phisherman.pl -m ${filemap}
      ;;
    "2")
      echo "Test"
      ;;
  esac
}
