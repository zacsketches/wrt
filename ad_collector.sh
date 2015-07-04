#!/bin/sh
# Address to send ads to (the RPi)
piholeIP="127.0.0.1"

# Optionally, uncomment to automatically detect the local IP address.
#piholeIP=$(hostname -I)

# Config file to hold URL rules
blacklist=/etc/pihole/blacklist.txt
whitelist=/etc/pihole/whitelist.txt

#create a file to hold the list of domains
touch tmp_ad_list.txt
touch final_ad_list.txt

#build the list of domains
echo "Getting yoyo ad list..." # Approximately 2452 domains at the time of writing
curl -s -d mimetype=plaintext -d hostformat=unixhosts http://pgl.yoyo.org/adservers/serverlist.php? | sort > tmp_ad_list.txt
echo "Getting winhelp2002 ad list..." # 12985 domains
curl -s http://winhelp2002.mvps.org/hosts.txt | grep -v "#" | grep -v "127.0.0.1" | sed '/^$/d' | sed 's/\ /\\ /g' | awk '{print $2}' | sort >> tmp_ad_list.txt
echo "Getting adaway ad list..." # 445 domains
curl -s https://adaway.org/hosts.txt | grep -v "#" | grep -v "::1" | sed '/^$/d' | sed 's/\ /\\ /g' | awk '{print $2}' | grep -v '^\\' | grep -v '\\$' | sort >> tmp_ad_list.txt
echo "Getting hosts-file ad list..." # 28050 domains
curl -s http://hosts-file.net/.%5Cad_servers.txt | grep -v "#" | grep -v "::1" | sed '/^$/d' | sed 's/\ /\\ /g' | awk '{print $2}' | grep -v '^\\' | grep -v '\\$' | sort >> tmp_ad_list.txt
echo "Getting malwaredomainlist ad list..." # 1352 domains
curl -s http://www.malwaredomainlist.com/hostslist/hosts.txt | grep -v "#" | sed '/^$/d' | sed 's/\ /\\ /g' | awk '{print $3}' | grep -v '^\\' | grep -v '\\$' | sort >> tmp_ad_list.txt
echo "Getting adblock.gjtech ad list..." # 696 domains
curl -s http://adblock.gjtech.net/?format=unix-hosts | grep -v "#" | sed '/^$/d' | sed 's/\ /\\ /g' | awk '{print $2}' | grep -v '^\\' | grep -v '\\$' | sort >> tmp_ad_list.txt
echo "Getting someone who cares ad list..." # 10600
curl -s http://someonewhocares.org/hosts/hosts | grep -v "#" | sed '/^$/d' | sed 's/\ /\\ /g' | grep -v '^\\' | grep -v '\\$' | awk '{print $2}' | grep -v '^\\' | grep -v '\\$' | sort >> tmp_ad_list.txt
echo "Getting Mother of All Ad Blocks list..." # 102168 domains!! Thanks Kacy
curl -A 'Mozilla/5.0 (X11; Linux x86_64; rv:30.0) Gecko/20100101 Firefox/30.0' -e http://forum.xda-developers.com/ http://adblock.mahakala.is/ | grep -v "#" | awk '{print $2}' | sort >> tmp_ad_list.txt

# Add entries from the local blacklist file if it exists in /etc/pihole directory
if [[ -f $blacklist ]];then
echo "Getting the local blacklist from /etc/pihole directory"
cat $blacklist >> ad_list.txt
fi

# Sort the aggregated results and remove any duplicates
# Remove entries from the whitelist file if it exists at the root of the current user's home folder
if [[ -f $whitelist ]];then
echo "Removing duplicates, whitelisting, and formatting the list of domains..."
cat tmp_ad_list.txt | sed $'s/\r$//' | sort | uniq | sed '/^$/d' | grep -v -x -f $whitelist | awk -v "IP=$piholeIP" '{sub(/\r$/,""); print "address=/"$0"/"IP}' > final_ad_list.txt
numberOfSitesWhitelisted=$(cat $whitelist | wc -l | sed 's/^[ \t]*//')
echo "$numberOfSitesWhitelisted domains whitelisted."
else
echo "Removing duplicates and formatting the list of domains..."
cat tmp_ad_list.txt | sed $'s/\r$//' | sort | uniq | sed '/^$/d' | awk -v "IP=$piholeIP" '{sub(/\r$/,""); print "address=/"$0"/"IP}' > final_ad_list.txt
fi

# Count how many domains/whitelists were added so it can be displayed to the user
numberOfAdsBlocked=$(cat final_ad_list.txt | wc -l | sed 's/^[ \t]*//')
echo "$numberOfAdsBlocked ad domains blocked."
