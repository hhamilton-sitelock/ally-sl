#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******** FILES ***********************************************#
#
if [[ $allpermscount = "0" ]]; then

	allperms_output="${green}$( echo $allpermscount          | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}"
else

	allperms_output="${yellow}$( echo $allpermscount         | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}"
fi
#
if [[ $zeropermscount = "0" ]]; then

	zeroperms_output="${green}$( echo $zeropermscount        | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}"
else

	zeroperms_output="${yellow}$( echo $zeropermscount       | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}"
fi
#
if [[ $suspectpermscount = "0" ]]; then

	suspectperms_output="${green}$( echo $suspectpermscount  | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}"
else

	suspectperms_output="${yellow}$( echo $suspectpermscount | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}"
fi
#
if [[ $suspectedcount = "0" ]]; then

	suspected_output="${green}$( echo $suspectedcount        | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}"
else

	suspected_output="${yellow}$( echo $suspectedcount       | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}"
fi
#
printf "\n${cyan}*** ${yellow}Files${cyan} ***${default}\n\n"
#
printf "Directories             : ${cyan}Uncounted${default}\n\n"
#
printf "File Count              : ${cyan}$( echo $numfiles    | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n" 
#
printf "Files Changed           : ${cyan}${haschanges^}${default}\n\n"
#
printf "Added                   : ${cyan}$( echo $numadded    | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n"
#
printf "Modified                : ${cyan}$( echo $nummodified | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n"
#
printf "Deleted                 : ${cyan}$( echo $numdeleted  | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n"
#
if [[ $numreview = 0 ]]; then

	printf "In Review               : ${green}$( echo $numreview     | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n"
else

	printf "In Review               : ${yellow}$( echo $numreview    | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n"
fi
#
if [[ $nummalicious = 0 ]]; then

	printf "Malicious               : ${green}$( echo $nummalicious  | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n"
else

	printf "Malicious               : ${yellow}$( echo $nummalicious | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n"
fi
#
if [[ $numcleaned = 0 ]]; then

	printf "Cleaned                 : ${green}$( echo $numcleaned    | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n"
else

	printf "Cleaned                 : ${yellow}$( echo $numcleaned   | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n"
fi
#
printf "Archives                : ${cyan}$( echo $zipcount | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n"
#
printf "777                     : $allperms_output\n\n"
#
printf "000                     : $zeroperms_output\n\n"
#
printf "X644 ( NOT 644 )        : $suspectperms_output\n\n"
#
printf ".suspected              : $suspected_output\n\n"
#
if [[ $numsuspicious = 0 ]]; then

	printf "Suspicious              : ${green}$( echo $numsuspicious    | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n"
else

	printf "Suspicious              : ${yellow}$( echo $numsuspicious   | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n"
fi
#
if [[ $notcleanedcount = 0 ]]; then

	printf "Not Cleaned             : ${green}$( echo $notcleanedcount  | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n"
else

	printf "Not Cleaned             : ${yellow}$( echo $notcleanedcount | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta' )${default}\n\n"
fi
