#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* MIRROR SEARCH ****************************************#
#
printf "\n${cyan}*** ${yellow}Mirror Grep${cyan} ***${magenta}\n\n"
#
read -e -p 'Please provide the search term: ' searchterm
#
if [[ -n "$searchterm" ]]; then

	printf "\n${magenta}Searching the mirror: ${cyan}$mirrorpath\n\n${magenta}Stand by...${default}\n"

	IFS=$'\n'

	mirrorsearchresults=()
	
	if [[ "${searchterm:0:1}" == "/" ]] ; then


		mirrorsearchresults=( $( sudo grep -iIrnoE "${searchterm:1}" "$mirrorpath" ) )
	else

		mirrorsearchresults=( $( N=20; sudo grep -iIrnoP ".{0,$N}$searchterm.{0,$N}" "$mirrorpath" ) )
	fi

	unset IFS 

	if [ "${mirrorsearchresults[0]}" ]; then

		(
			for i in "${mirrorsearchresults[@]}"; do

				filematch=$(
					echo -E ${i//$mirrorpath/} | awk -F':' '{ print $1 }'
				)
				linematch=$(
					echo -E $i | awk -F':' '{ print $2 }'
				)
				samplematch=$(
					echo -E $i | awk -F':' '{ $1=$2=""; print $0 }'
				)

				printf "${magenta}
File   : ${cyan}$filematch${magenta}
Line   : ${yellow}$linematch${magenta}
Match  : ${yellow}$samplematch
${default}"
			done
		) | more
	else

		printf "\nNo matches found for search term: $searchterm\n\n"		
	fi
else

	printf "\nYou must provide a search term.\n\n"
fi