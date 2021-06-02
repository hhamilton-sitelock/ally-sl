import json
import sys
import os
from distutils.version import LooseVersion, StrictVersion
import re

#Our input is in the format path~@~version~@~name per argument, each argument being a plugin.
#For each 
def build_vulnerable_plugins(vulns):
  if len(sys.argv) < 2:
    sys.exit()
  p = []
  for x in sys.argv[1:]:
    if not x:
      continue
    fpath, fversion, fname = x.split("~@~") + ['Empty Value'] * (3 - len(x))
    fslug = os.path.basename(fpath)
    for v in vulns['vulnerable']:
      if v['slug'] == fslug or v['name'] == fname:
        p.append({"name": fname, "version": fversion, "path": fpath, "slug": fslug, "vuln": v})
  return p

def print_output(x, ver=False):
  if ver:
    print "  \033[5;31m!\033[00m Found present vulnerability in plugin: " + x['name'] + " (" + x['slug'] +") version " + x['version'] + ". Path: " + x['path']
    print "  \033[5;31m!\033[00m Vulnerable version: " + x['vuln']['version']
    print "  \033[5;31m!\033[00m Info: " + x['vuln']['descr']
  else:
    print "  \033[35m?\033[00m Found past vulnerability in plugin: " + x['name'] + " (" + x['slug'] +") version " + x['version'] + ". Path: " + x['path']
    print "  \033[35m?\033[00m Please note plugins reported here are not CURRENTLY vulnerable but may have been exploited previously."
    print "  \033[35m?\033[00m Vulnerable version: " + x['vuln']['version']
    print "  \033[35m?\033[00m Info: " + x['vuln']['descr']

def check_versions(plugs):
  if not plugs:
    print "  \033[32m\xE2\x9C\x94\033[00m No vulnerable plugins from the Sitelock internal 0-day tracker found."
    return
  for x in plugs:
    if ver_is_vuln(x['version'], x['vuln']['version']):
      print_output(x, True)
    else:
      print_output(x)

def ver_is_vuln(one, two):
  if two == "All":
    return True
  m = re.match('^(<=?)', two)
  if not m:
    return False
  q = re.sub(r'^(<=?)', '', two)
  if m.group(0):
    if m.group(0) == "<":
      return LooseVersion(one) < LooseVersion(q)
    elif m.group(0) == "<=":
      return LooseVersion(one) <= LooseVersion(q)

def main():
  with open('/opt/data/seccon/ally-data/plugins.json') as jfile:
    data = json.load(jfile)
  vulnplugs = build_vulnerable_plugins(data)
  check_versions(vulnplugs)

main()
