#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* BACKUP ***********************************************#
#
printf "\n${cyan}*** ${yellow}Backup${cyan} ***${default}\n\n"
#
printf "\n${magenta}Creating Backup...${default}\n\n"
#
sudo esbackup --site_id="$siteid" <<< "2" &>/dev/null &
#
sitebackup="1"