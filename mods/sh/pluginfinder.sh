#!/bin/bash

#This script will search for plugins in a Wordpress directory.
#The script searches one CMS at a time.
#Arguments are the path to search, optional -f of a file mapping relative to the path we're searching, and optional -d of a relative dir inside this path.

#Default settings
printplugs=false
toscan=false
checkbl=false
site_reldir=""
if [[ -n "${abspath}" ]] && [[ -f "${abspath}/mods/py/findvulnplugs.py" ]]; then
  blcheckscript="${abspath}/mods/py/findvulnplugs.py"
else
  helper >&2
  exit 1  
fi
pluginfolders=
wp_plugindir=()
plugin_file=()
plugin_folder=()
plugin_name=()
plugin_version=()

# Initialize our own variables:
output_file=""
verbose=false

parse_args() {

  local OPTIND=1
  while getopts ":hf:snbd:" opt; do
      case $opt in
          h|\?)
              helper
              exit 0
              ;;
          f)  site_filemap="${OPTARG}"
              ;;
          n)  printplugs=true
              ;;
          s)  toscan=true
              ;;
          b)  checkbl=true
              ;;
          d)  site_reldir="${OPTARG}"
              ;;
          *)
              helper >&2
              exit 1
              ;;
      esac
  done
  shift "$((OPTIND-1))"   # Discard the options and sentinel --

  site_mirrorpath="${1:-}"

  if [[ "${checkbl}" == false ]] && [[ "${printplugs}" == false ]]; then
    helper >&2
    exit 1
  fi

  if [[ -z "${site_mirrorpath}" ]] || ! sudo test -d "${site_mirrorpath}"; then
    helper >&2
    exit 1
  fi

  if [[ -n "${site_filemap}" ]] && ! [[ -f "${site_filemap}" ]]; then
    printf "Given file map not found or inaccessible\n\n"
    helper >&2
    exit 1
  fi

  if [[ -n "${site_reldir}" ]] && [[ "${site_reldir}" != "/" ]]; then
    site_reldir="/${site_reldir#/}"
    site_reldir="${site_reldir%/}"
  fi

}

helper() {

#  echo "Usage: findplugins.sh /path/to/search [/path/to/filemap (optional)]"
  cat << EOF
Usage: ${0##*/} [-h] -bn [-f FILE_MAPPING] [-d RELATIVEDIR] DIRECTORY...
Scan for Wordpress plugins in given directory. Optionally provide a filemap.

    -h         this help file
    -b	       check for blacklisting
    -n         print plugin list
    -d DIR     relative directory to scan
    -f FILEMAP path to map of files in given directory
EOF
} 

use_filemap() {

  if [[ -n "${site_filemap}" ]] && [[ -f "${site_filemap}" ]]; then
    true
    return
  fi

  if [[ -n "${site_filemap}" ]] && [[ ! -f "${site_filemap}" ]]; then
    echo "FATAL ERROR: Lost access to filemap during plugin scanner. Exiting."
    helper 2>&1
    exit 1
  fi

  false
  return

}

#Find plugin folders. Using a filemap is much quicker.
#Checking for an empty array without expanding it via -n isn't really ideal but works fine here because we don't expect any empty indexes.
#For now we've removed recursive plugin folder checking. This currently just looks in the expected directory assuming we are given a Wordpress CMS on input.
find_plugin_folders() {

  local IFS=$'\n'

  if sudo test -d "${site_mirrorpath}${site_reldir}/wp-content/plugins"; then
    if [[ "${site_reldir}" == "/" ]]; then
      wp_plugindir=( "wp-content/plugins" )
    else
      wp_plugindir=( "${site_reldir#/}/wp-content/plugins" )
    fi
  else
    echo "Could not access plugin folder at ${site_mirrorpath}${site_reldir}/wp-content/plugins."
    echo "Either the folder does not exist or there is an issue accessing it on the mirror (working on a fix for this). Exiting."
    exit 1
  fi

#  if use_filemap; then
#    wp_plugindir=( $( grep -Eo "^${site_reldir#/}(.*/)?wp-content/plugins" "${site_filemap}" | uniq ) )
#  else
#    wp_plugindir=( $( find "${site_mirrorpath}${site_reldir}" -type d -name "plugins" -printf "%P\n" | grep -E "wp-content/plugins$" ) )
#  fi

}

#We will try to find all .php files inside of the plugins folder, also searching one extra folder down. 
#We could potentially recursively grep for these, however it's pointless 
find_plugin_files() {

  local IFS=$'\n'

  for i in "${wp_plugindir[@]}"; do

    if use_filemap; then
#      plugin_file+=( $( grep -Po "^(.*/)?wp-content/plugins/([^/]*?/)?[^/]*\.php" ${site_filemap} | xargs printf "${site_mirrorpath}/%s\n" | xargs grep -lm1 "Plugin Name:" ) )
#      echo "DEBUG: SENDING ${i}"
      plugin_file+=( $( grep -Po "^${i}/([^/]*?/)?[^/]*\.php(?=\+)" "${site_filemap}" | xargs printf "${site_mirrorpath}/%s\n" | xargs sudo grep -lm1 "Plugin Name:" ) )
    else
      plugin_file+=( $( find "${site_mirrorpath}${site_reldir}/${i}" -maxdepth 2 -name "*.php" | xargs sudo grep -lm1 "Plugin Name:" ) )
    fi

  done

  plugins_parse_data

}

plugins_parse_data() {

local i

  for i in ${!plugin_file[@]}; do
    if ! sudo test -f "${plugin_file[i]}"; then
      unset plugin_file[i]
      continue
    fi
    plugin_folder[i]=$( dirname "${plugin_file[i]}" )
    plugin_name[i]=$( sudo perl -ne 'print "$1" and last if /Plugin Name:\s+(.*?)(\s+)?\Z$/' "${plugin_file[i]}" )
    plugin_version[i]=$( sudo perl -ne 'print "$1" and last if /Version:\s+(.*?)(\s+)?\Z$/' "${plugin_file[i]}" )
  done

}

plugin_print_data() {

  local _column="%-60s %-40s %-20s\n"
  local _plugfolder
  local _plugversion
  local _plugname
  printf "${_column}" "Plugin Name" "Folder Name" "Version"
  printf "${_column}" "#######################################################" "########################################" "####################"
  for i in ${!plugin_file[@]}; do
    _plugname="${plugin_name[i]}"
    _plugfolder=$( basename "${plugin_folder[i]}" )
    _plugversion="${plugin_version[i]}"
    if [[ "${#_plugname}" -gt "60" ]]; then
      _plugname="${_plugname:0:57}..."
    fi
    _tempvar=${#_plugfolder}
    if [[ "${#_plugfolder}" -gt "40" ]]; then
      _plugfolder="${_plugfolder:0:37}..."
    fi
    printf "${_column}" "${_plugname}" "${_plugfolder}" "${_plugversion}"
  done

}

plugins_check_blacklist() {

  local _blplugins
  local _plugfolder
  local i

  readarray -t _blplugins < testlist.txt
  #We want to compare the list of plugins we have vs. a list of vulnerable plugins to find matches.
  #This process would be such simpler in a real language where we can search for array intersections.
  for i in ${!plugin_file[@]}; do

    _plugfolder=$( basename "${plugin_folder[i]}" )

    if [[ "${_plugfolder}" == "plugins" ]]; then
      continue
    fi

    if is_plugin_blacklisted "${_plugfolder}"; then
      echo "Found blacklisted plugin ${_plugfolder} at location ${plugin_folder[i]}. Version ${plugin_version[i]}."
    else
      echo "Plugin not blacklisted: ${_plugfolder}"
    fi
  
  done

}

plugs_check_blacklist() {

local _plugfolder
local out_args=()
local i=

  for i in ${!plugin_file[@]}; do

    _plugfolder=$( basename "${plugin_folder[i]}" )
    out_args+=( "${plugin_folder[i]#${site_mirrorpath}}~@~${plugin_version[i]}~@~${plugin_name[i]}" )

  done 

  python "${blcheckscript}" "${out_args[@]}"

}

#Arguments: plugin name we're checking
is_plugin_blacklisted() {
 
  local _pluginfolder="${1:-}"
  local i

  for i in "${_blplugins[@]}"; do
    if [[ "${i}" == "${_plugfolder}" ]]; then
      true
      return
    fi
  done 

  false
  return

}


main() {
  local args=$@
  parse_args ${args[@]}
  find_plugin_folders "${site_mirrorpath}"
  find_plugin_files "${site_mirrorpath}"
  if [[ "$printplugs" == true ]]; then
    plugin_print_data
  fi
  if [[ "$checkbl" == true ]]; then
    plugs_check_blacklist
  fi
}

main $@
