# Every five seconds, interate through switches with the supplied credentials,
# then downloads the Mac Address Table and appends it to a file.
#!/bin/bash
switchIPs=(
1
2
3
4
5
)
file=switchList-$(date --iso-8601).txt
# https://opensource.com/article/18/5/you-dont-know-bash-intro-bash-arrays
while : # https://linuxize.com/post/bash-while-loop/
do 
	echo -n "Starting time is $(date +%R)" >> $file
	for IP in ${switchIPs[@]}; do
		echo -e "\n$IP: $(curl --silent --user USER_NAME:PASSWORD http://10.000.000.$IP/setup.cgi?next_file=mac_table_en.html | grep '<input type="hidden" id="l2_mac_list" name="l2_mac_list" value="')" >> $file
		sleep 5s
	done
	sleep 60m
done 