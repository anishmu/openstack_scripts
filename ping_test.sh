# PING TEST FOR IPs listed in ips.txt file
awk '{print $1}' < ips.txt | while read ip; do ping -c1 $ip >/dev/null 2>&1 && echo $ip IS UP || echo $ip IS DOWN; done

# SSH TUNNELLING TO VIEW THE REMOTE WEB GUI LOCALLY
ssh -L 443:10.10.10.20:443 user@10.10.10.10
