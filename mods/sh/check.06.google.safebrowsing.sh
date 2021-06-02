#******* SECURITY CHECK ***************************************#
#
if [ -z $configpath ]; then

    exit 1
fi
#
security
#
#
#******* GOOGLE SAFE BROWSING *********************************#
#
post_data () {
#	
cat <<EOF
{
  "client": {
    "clientId":      "$googleapp",
    "clientVersion": "1.5.2"
  },
  "threatInfo": {
    "threatTypes":      ["THREAT_TYPE_UNSPECIFIED", "UNWANTED_SOFTWARE", "POTENTIALLY_HARMFUL_APPLICATION", "MALWARE", "SOCIAL_ENGINEERING"],
    "platformTypes":    ["ANY_PLATFORM"],
    "threatEntryTypes": ["URL"],
    "threatEntries": [
      {"url": "$domain"},
    ]
  }
}
EOF
}
#
safebrowsingresult=$(curl -s -H "Content-Type: application/json" --data "$(post_data)" https://safebrowsing.googleapis.com/v4/threatMatches:find?key=$googlekey)
#
if [[ "$safebrowsingresult" = "{}" ]]; then

    googlesafebrowsing="0"
else

    googlesafebrowsing=$(
      echo $safebrowsingresult   |
      grep -ohP "threatType.*?," |
      cut -d: -f2                |
      cut -d\" -f2
    )
    
    if [[ -z $googlesafebrowsing ]]; then

        googlesafebrowsing="2"
    fi
fi
