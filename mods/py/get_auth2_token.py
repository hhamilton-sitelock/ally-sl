#!/usr/bin/python
import os.path
import sys
import getopt
import subprocess
from pprint import pprint
sys.path.insert(0, '/home/logins/dhiggins/.local/lib/python2.7/site-packages')
import httplib2
import json
import logging
from apiclient import errors
from apiclient.discovery import build
from oauth2client.client import OAuth2WebServerFlow
from oauth2client.file import Storage
logging.basicConfig(filename='gdebug.log',level=logging.DEBUG)
logging.getLogger('googleapiclient.discovery_cache').setLevel(logging.ERROR)
global railroad
railroad=False
global maps
maps=False

def usage():
	print "Google Verification script.\nIf run without arguments, gives you a list of options to add a domain to Google Webmaster tools, verify it, or test it against the safe browsing list.\nArguments that can be used:\n-s or --site: uses the site ID to find the domain, checks the safe browsing list, and attempts to upload the google site verification file, then attempts to verify.\n-d or --domain: checks the safe browsing list, attempts to add the site to Google webmaster tools, but will NOT attempt to upload the verification file."

def authme():
	# Copy your credentials from the console
	CLIENT_ID = "998567987017-hdblr8r5l1n963d2c1sttomf583cfgq4.apps.googleusercontent.com"
	CLIENT_SECRET = "WHlPJeiiacDeh1uEpC7F0DuN"

	# Check https://developers.google.com/webmaster-tools/search-console-api-original/v3/ for all available scopes
	OAUTH_SCOPE = "https://www.googleapis.com/auth/webmasters https://www.googleapis.com/auth/siteverification"

	# Redirect URI for installed apps
	REDIRECT_URI = "urn:ietf:wg:oauth:2.0:oob"
	# Run through the OAuth flow and retrieve credentials
	flow = OAuth2WebServerFlow(CLIENT_ID, CLIENT_SECRET, OAUTH_SCOPE, REDIRECT_URI)
	flow.params["access_type"] = "offline"
	authorize_url = flow.step1_get_authorize_url()
	print "Go to the following link in your browser: " + authorize_url
	code = raw_input("Enter verification code: ").strip()
	credentials = flow.step2_exchange(code)
	return credentials

def addsite(site_url="tmp"):
	if(site_url=="tmp"):
		site_url=raw_input("Please paste the site URL:\n").strip()
	webmasters_service.sites().add(siteUrl=site_url).execute()
	try:
		verification_service.webResource().get(id=site_url).execute()
		verified(site_url)	
	except:
		print("Site not verified, attempting to verify using a file\n")
		verifysite(site_url)

def verified(site_url):
	print("\nSite Verified, Go to:\nhttps://search.google.com/search-console/security-issues?hl=en&resource_id=http://"+site_url+"\nto submit to Google\n")
	getsitemaps(site_url)

def getsitemaps(site_url="tmp"):
	if(site_url=="tmp"):
		site_url=raw_input("Please paste the site URL:\n").strip()
	sitemaps = webmasters_service.sitemaps().list(siteUrl=site_url).execute()
	if 'sitemap' in sitemaps:
		print "Listing sitemaps:"
	    	for s in sitemaps['sitemap']:
			print s['path']
			sinfo = webmasters_service.sitemaps().get(siteUrl=site_url,feedpath=s['path']).execute()
			print(sinfo.get('errors')+" errors in this sitemap")
			print(sinfo.get('contents')[0]['submitted']+" urls submitted")
			print(sinfo.get('contents')[0]['indexed']+" urls indexed")
			return
	else:
		return

def dnsverify(site_url="tmp"):
	if site_url=="tmp":
		site_url=raw_input("Please paste the site URL:\n").strip()
	site_url=site_url.replace("http://","")
	site_url=site_url.replace("https://","")
	pbody={"site": { "type" : "INET_DOMAIN", "identifier": site_url}, "verificationMethod": "DNS"}
	vtoken=verification_service.webResource().getToken(body=pbody).execute()
	raw_input("You will need to add the following TXT record to the DNS for:"+site_url+"\n"+vtoken["token"]+"\nplease press enter/return when ready to proceed").strip()
	try:
		verification_service.webResource().insert(verificationMethod="DNS", body=pbody).execute()
		verified(site_url)	
	except:
		tagain=raw_input("Looks like that didn't work. Check propagation. Press 1 to try again, 2 to quit\n").strip()
		if tagain ==1:
			dnsverify(site_url)	
		else:
			return

def verifysite(site_url="tmp"):
	if site_url=="tmp":
		site_url=raw_input("Please paste the site URL:\n").strip()
	pbody={"site":{"type":"SITE", "identifier":site_url}, "verificationMethod": "FILE"}
	vfile=verification_service.webResource().getToken(body=pbody).execute()
	vtoken= vfile.get("token")
	if (railroad=="sflow"):
		subprocess.call("bash ${abspath}/mods/sh/googleupload.sh -s %(sid)s -v %(vtk)s" % {'sid':sid, "vtk":vtoken}, shell=True)		
	try:
		verification_service.webResource().insert(verificationMethod="FILE", fields="site", body=pbody).execute()
		verified(site_url)
	except:
		select=input("Verification using uploaded file unsuccessful. Press 1 to retry, 2 to attempt DNS-based verification, or 3 to quit\n")
		if select ==1:
			verifysite(site_url)
		if select ==2:
			dnsverify(site_url)
		if selection ==3:
			print "quitting"
		return

def removesite():
	site_url=raw_input("Please input the site URL to remove:\n").strip()
	webmasters_service.sites().delete(siteUrl=site_url).execute()
	print("Site removed")

def safebrowse(site_url="tmp"):
	sbk="AIzaSyAfu9v0WPw6KcTie5ge6zp-PFejvwjTWB0"
	if(site_url=="tmp"):
		site_url=raw_input("Please input the site URL to check:\n").strip()
	pbody={"client": { "clientId": "SLGetsafebrowse"}, "threatInfo": { "threatTypes":["MALWARE", "SOCIAL_ENGINEERING", "THREAT_TYPE_UNSPECIFIED", "POTENTIALLY_HARMFUL_APPLICATION"], "platformTypes": ["ANY_PLATFORM"], "threatEntryTypes": ["URL"], "threatEntries": [ {"url": site_url}]}}
	pbody=json.dumps(pbody)
	result,content=authed.request("https://safebrowsing.googleapis.com/v4/threatMatches:find?key="+sbk,method="POST",body=pbody,headers={"Content-Type":"application/json"})
	matches=json.loads(content)
	try:
		if (matches["matches"][0]):
			print "Site appears to be blacklisted: "+matches["matches"][0]["threatType"]
	except:
		print "Site isn't listed in Safe browsing\n"
	addselect=raw_input("Attempt to add site to Google Webmaster tools and verify(y/n)?\n").strip()
	if addselect.lower()=="y":
		addsite(site_url)
	elif addselect.lower()=="n":
		return()

def getdomain(site_id):
	print "Getting domain from site ID\n"
	with open("/var/ftp_scan/"+site_id+"/domain.data") as domain_data_file:
		domain_data=json.load(domain_data_file)
		site_url=domain_data["domain"]
		global sid
		sid=domain_data["id"]
		print site_url+"\n"
		safebrowse(site_url)

def select():
	selection = input("Select 1 to add a site to Webmaster tools, 2 to verify, 3 to remove, or 4 to check safe browsing status, 5 to view sitemaps, or 6 to quit:\n")
	if selection == 1:
		addsite()
	elif selection ==2:
		verifysite()
	elif selection ==3:
		removesite()
	elif selection ==4:
		safebrowse()
	elif selection ==5:
		getsitemaps()
	elif selection ==6:
		print "quitting"
		return
	else:
		print "invalid input, try again"
		select()
def main():
	if (len(sys.argv) <= 1):
		select()
	else:
		try:
			opts, args = getopt.getopt(sys.argv[1:], "d:s:mh", ["domain=", "site=", "sitemaps", "help"])
		except getopt.GetoptError:
			usage()
			sys.exit(2)
		for opt, arg in opts:
			if opt in ("-h", "--help"):
				usage()
				sys.exit(0)
			elif opt in ("-m", "--sitemaps"):
				global maps
				maps=True
			elif opt in ("-d", "--domain"):
				site_url=arg
				global railroad
				railroad="dflow"
				safebrowse(site_url)		
			elif opt in ("-s", "--site"):
				site_id=arg
				railroad="sflow"
				getdomain(site_id)	

storage=Storage(os.environ['HOME']+"/gverifytk")
credentials=storage.get()
if not credentials:
	credentials=authme()
	storage.put(credentials)
http = httplib2.Http()
authed = credentials.authorize(http)
webmasters_service = build("webmasters", "v3", http=authed)
verification_service = build("siteVerification", "v1", http=authed)
main()
