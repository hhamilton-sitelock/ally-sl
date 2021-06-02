# #******* SECURITY CHECK ***************************************#
# #
if [ -z $configpath ]; then

	exit 1
fi
#
security
#
#
#******* CMS **************************************************#
#
cmsverfiles=("wp-includes\/version\.php" "CHANGELOG\.txt" "joomla\/version\.php" "cms\/version\/version.php" "\/includes\/version\.php" "access\.cnf" "include\/settings.inc.php" "catalog\/admin\/includes\/configure.php" "catalog\/includes\/configure.php" "includes\/configure.php" "includes\/configphp" "app\/etc\/local.xml" "store\/includes\/configure.php" "admin\/config.php" "core\/config\/config.inc.php");
#
cmsarr=()
cms_name=()
cms_version=()
cms_dir=()
#
IFS=$'\n'
#
for i in "${cmsverfiles[@]}"; do

	cmsarr+=( 
		$(
			awk "/$i/{ print $1 }" "$filemap" |
				awk -F'[+-+]' '{ print $1 }'
		)
	)
done
#
unset IFS
#
domaincount=${#cmsarr[@]}
#
if [[ $domaincount < 1 ]]; then

	domaincount="1"
fi
#
domaintotal=$(
	expr $domaintotal + $domaincount
)
#
cmstype=()
#
for i in "${cmsarr[@]}"; do

	mirrorfile="$mirrorpath/$i"

	if sudo test -f $mirrorfile; then

		if echo "$mirrorfile" | grep -q "wp-includes"; then
			
			version=$(
				sudo grep "wp_version =" $mirrorfile
			)
			
			wpconfig=${mirrorfile/wp-includes\/version.php/wp-config.php}

			dbname=$(
				sudo grep "'DB_NAME'" $wpconfig     |
					awk -F"'" '{ print $4 }'
			)

			dbuser=$(
				sudo grep "'DB_USER'" $wpconfig     |
					awk -F"'" '{ print $4 }'
			)

			dbpass=$(
				sudo grep "'DB_PASSWORD'" $wpconfig |
					awk -F"'" '{ print $4 }'
			)

			dbhost=$(
				sudo grep "'DB_HOST'" $wpconfig     |
					awk -F"'" '{ print $4 }'
			)

			dbpref=$(
				sudo grep "table_prefix" $wpconfig     |
					awk -F"'" '{ print $2 }'
			)

			cmstype+=(
"
${default}WordPress${magenta} - $version | ${cyan}${mirrorfile//$mirrorpath}${magenta}
	Database Credentials
		Name     : ${yellow}$dbname${magenta}
		Host     : ${yellow}$dbhost${magenta}
		Prefix   : ${yellow}$dbpref${magenta}
		User     : ${yellow}$dbuser${magenta}
		Password : ${yellow}$dbpass${magenta}
" 
			)
		elif echo "$mirrorfile" | grep -q "CHANGELOG.txt"; then

			version=$( 
				sudo grep "Drupal" $mirrorfile |
				head -n 1
			)
			
			if [[ -z $version ]]; then

				version="Older Than Drupal 4"
			fi

			cmstype+=( "DRUPAL - $version | $mirrorfile" )
		elif echo "$mirrorfile" | grep -q "joomla/version.php"; then
		
			version=$(
				sudo grep "\$RELEASE" $mirrorfile |
				sed 's/ //g'                      |
				sed 's/public \$//g'              |
				sed 's/var \$//g'
			)
			
			cmstype+=( "
${default}Joomla${magenta} - $version | ${cyan}${mirrorfile//$mirrorpath}${magenta}
			" )
		elif echo "$mirrorfile" | grep -q "cms/version/version.php"; then
		
			version=$(
				sudo grep "\$RELEASE" $mirrorfile |
				sed 's/ //g'                      |
				sed 's/public \$//g'              |
				sed 's/var \$//g'
			)
			
			cmstype+=( "
${default}Joomla${magenta} - $version | ${cyan}${mirrorfile//$mirrorpath}${magenta}
			" )
		elif echo "$mirrorfile" | grep -q "/includes/version.php"; then
		
			version=$(
				sudo grep "\$RELEASE" $mirrorfile |
				sed 's/ //g'                      |
				sed 's/public \$//g'              |
				sed 's/var \$//g' 
			)
			
			cmstype+=( "
${default}Joomla${magenta} - $version | ${cyan}${mirrorfile//$mirrorpath}${magenta}
			" )
		elif echo "$mirrorfile" | grep -q "access.cnf"; then

			version="Not Supported By Microsoft"

			cmstype+=( "
${default}Frontpage${magenta} - $version | ${cyan}${mirrorfile//$mirrorpath}${magenta}
			" )
		elif echo "$mirrorfile" | grep -q "include/settings.inc.php"; then

			version=""

			cmstype+=( "
${default}Prestashop${magenta} - $version | ${cyan}${mirrorfile//$mirrorpath}${magenta}
			" )
		elif echo "$mirrorfile" | grep -q "include/settings.inc.php"; then

			version=""

			cmstype+=( "
${default}Prestashop${magenta} - $version | ${cyan}${mirrorfile//$mirrorpath}${magenta}
			" )
		elif echo "$mirrorfile" | grep -q "catalog/admin/includes/configure.php"; then

			version=""

			cmstype+=( "
${default}Prestashop${magenta} - $version | ${cyan}${mirrorfile//$mirrorpath}${magenta}
			" )
		else

			cmstype+=( "
${default}Custom${magenta} - Unknown | ${cyan}${mirrorfile//$mirrorpath}${magenta}
			" )
		fi
	fi
done

#Primary issue moving forward with finding files/folders on the mirror is that we can't access 750 directories due to different user perms. We will sudo for these commands.
#It's not ideal, but we don't have a choice.
find_wordpress() {

  local IFS=$'\n'
  local _versionfiles=$( grep -oE "^(.*/)?wp-includes/version\.php" ${filemap} )
  local regex='^(.*/)?wp-includes/version\.php'
  local wpcontentdir=
  local cmsdir=
  for i in ${_versionfiles[@]}; do

    if [[ "${i}" =~ $regex ]]; then
      
      cmsdir="${BASH_REMATCH[1]}"
      wpcontentdir="${mirrorpath}/${cmsdir}wp-content"
      if sudo test -d "${wpcontentdir}" && sudo test -f "${mirrorpath}/${i}"; then

        if process_wp_version_file "${mirrorpath}/${i}"; then
            cms_dir+=( "/${cmsdir}" )   
        fi

      fi

    fi

  done

}

process_wp_version_file() {

  local _wpverfile="${1:-}"
  local _wpversion=$( sudo grep '^$wp_version' "${_wpverfile}" )
  if [[ -z ${_wpversion} ]]; then
    echo "Could not find version file"
    false
    return
  fi
  local _myregex="'(.*)'"
  if [[ "${_wpversion}" =~ $_myregex ]]; then
    cms_name+=( "Wordpress" )
    cms_version+=( "${BASH_REMATCH[1]}" )
  else
    bug "Found Wordpress version file ${i} but could not extract version from it."
  fi

}

find_wordpress