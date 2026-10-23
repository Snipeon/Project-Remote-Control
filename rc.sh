#!/bin/bash

#~ Project Remote Control
#~ Name: 		Lam Bing Qing Andrew
#~ Student: 	s5
#~ Unit: 		CFC060524
#~ Trainer: 	Samson

#~ References: 
#~ https://devhints.io/bash
#~ https://cheatography.com/davechild/cheat-sheets/regular-expressions/
#~ the man command

#~ [#] Usage: run the script using bash rc.sh or ./rc.sh from the command line. 
#~ [#] Script has to be executed from its stored location.
#~ [!] Avoid using sudo when running the script, the script would still work, 
#~ [!] however it has been configured to store the scan results in the user's home folder.
#~ [!] Running the script with sudo would result in the scan results and nipe(if it is not installed) being saved to the /root/ folder.
#~ [#] Settings for the remote server has to be set up before you can execute the script.
#~ {#] Set up by running either bash rc.sh options or ./rc.sh options and following the prompts.
#~ [#] As said, scan results would be saved onto the home folder of the user used to run the script and remote server.
#~ [#] There would also be a log file saved to /var/logs/
#~ [#] The script would also generated a remote server details file during setup, in the same location as the script.
#~ [#] The script would also generate a nmap results file for the remote server for an instant, to save time and prevent having to nmap multiple times.
#~ [#] The script requires several packages to run, as such, besides NIPE, they would all be saved to the default location apt-get would install them to.
#~ [#] NIPE would be saved to the user's home folder.
#~ [#] This script requires the remote server to have its SSH and FTP services to be running.

#~ Function pcheck is called to check for whether the required packages are installed, and if they are not, 
#~ install them from apt-get. Only limited to packages available from apt-get.
function pcheck() 
{
	
	chkfor=$(whereis $1 | awk '{print $2}')
	
	if [ -z "$chkfor" ]
	then
	
		echo "[*] $2 is not installed, installing now..."
		echo
		sudo apt-get -qq install $2
		echo
		echo "[*] $2 installed."
		
	else
	
		echo "[#] $2 is already installed."
		
	fi
	
}

#~ Function uinput is called to get a user input and verify whether said input is valid.
#~ If not, uinput would continue asking for a valid input until one is given or the user force quits out of the script.
function uinput()
{
	
	read -p "[?] Specify a domain/IP address to scan: " input
	echo
	
	ipvalid="^(0*(1?[0-9]{1,2}|2([0-4][0-9]|5[0-5]))\.){3}(0*(1?[0-9]{1,2}|2([‌​0-4][0-9]|5[0-5])))$"
	domvalid="^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9])\.)+[a-zA-Z]{2,}$"
	
	if [[ $input =~ $ipvalid || $input =~ $domvalid ]]
	then
		
		echo "[*] Input accepted. Connecting to remote server:"
		
	else
	
		echo "[!] Not a valid domain or IP address! Please input a valid one."
		uinput
		
	fi
	
}

#~ Function servicechk checks that the remote server services are running. If not, it exits the script.
function servicechk()
{
	
	if [ -z $2 ]
	then
		
		echo
		echo "[!] Remote server $1 service is not running! Exiting..."
		exit
		
	fi
	
}

#~ Function sshp is used to run commands on the remote server.
#~ Only reason it exists is because I am lazy to type the same long command over and over.
function sshp()
{
	
	sshpass -p "$pass" ssh -o StrictHostKeyChecking=no -p "$sshport" "$user"@"$host" "$@"
	
}

#~ Function ftpp is used to grab the required files from the remote server.
#~ Only reason it exists is because I do not want the code to look too messy.
function ftpp()
{

	ftp -n -P "$ftpport" "$host" &> /dev/null <<EOF
	user "$user" "$pass"
	get "$@"
	bye
EOF

}

#~ Function scan is used to run the scans and save the scan results on both the remote server and local machine
#~ using both functions sshp and ftpp.
function scan()
{
	
	cd ~
	echo "[*] $1ing target's address: "
	sshp "$@ $input > $1_$input"
	ftpp "$1_$input"
	sudo echo "$(date): [*] $1 data collected for: $input" >> /var/log/rc.log
	sudo updatedb
	echo "[@] $1 data was saved into: $(locate $1_$input)"
	echo
	
}

#~ Actual script starts here. It starts with checking whether the remote server details has been set up.
#~ If not, the script tells you how to set up the details and exits. 
#~ The script would also only accept a valid IPv4 address as the remote server address.
#~ And yes, the script would write the remote server details into a file on the local machine. 
#~ Only way I can think of to get the script to remember the details between multiple executions.
#~ File is unencrypted, of course. Trying to make the file secure would result in the script taking too long to run every time.
#~ Not to mention the script's code is open for all to see. Only advice would be to secure your local machine.
if [ "$1" == "options" ]
then
	
	ipvalid="^(0*(1?[0-9]{1,2}|2([0-4][0-9]|5[0-5]))\.){3}(0*(1?[0-9]{1,2}|2([‌​0-4][0-9]|5[0-5])))$"
	read -p "[*] Please provide the remote server IP address: " rshost
	
	while [[ ! $rshost =~ $ipvalid ]]
	do
		
		echo "[!] Invalid IP address format!"
		read -p "[*] Please provide the remote server IP address(IPv4 only): " rshost 
	
	done
	
	echo $rshost > rs_details
	read -p "[*] Please provide the remote server username: " rsuser
	echo $rsuser >> rs_details
	read -p "[*] Please provide the remote server password: " rspass
	echo $rspass >> rs_details
	echo
	echo "[#] Remote server details set up! Please bash the script again without any arguments."
	exit
	
else

	if [ $(cat rs_details 2> /dev/null | wc -l) -ne 3 ]
	then
		
		echo "[!] Setup not complete!"
		echo "[!] Please provide remote server details by running: bash rc.sh options or ./rc.sh options"
		
		exit
	fi
	
fi

#~ Grabbing remote server details from file.
host=$(cat rs_details | awk 'NR==1')
user=$(cat rs_details | awk 'NR==2')
pass=$(cat rs_details | awk 'NR==3')

#~ Do not try to cheat and change the remote server IP address details afterwards...
#~ The script can see it...
ipvalid="^(0*(1?[0-9]{1,2}|2([0-4][0-9]|5[0-5]))\.){3}(0*(1?[0-9]{1,2}|2([‌​0-4][0-9]|5[0-5])))$"

if [[ ! $host =~ $ipvalid ]]
then
	
	echo "[!] Remote server IP address is invalid! Exiting..."
	exit
	
fi

#~ Making updates to the local apt-get index files so apt-get can actually find the required packages.
sudo apt-get -qq update

#~ Here is where the script checks and/or installs the required packages.
pcheck geoiplookup geoip-bin
pcheck sshpass sshpass
pcheck cpanm cpanminus

#~ Updating the file index so locate results are accurate.
sudo updatedb

#~ Checking if NIPE exists on the local machine. If it does not, install it.
nipechk=$(locate -w nipe.pl)

if [ -z "$nipechk" ]
then
	
	echo "[*] nipe is not installed, installing now..."
	echo
	
	cd ~
	git clone https://github.com/htrgouvea/nipe && cd nipe
	sudo cpanm --installdeps .
	yes | sudo cpan install Switch JSON LWP::UserAgent Config::Simple
	sudo perl nipe.pl install
	
	nipeloc=$(pwd)
	
	echo
	echo "[*] nipe is installed."
	sleep 10
	
else
	
	echo "[#] nipe is already installed."
	nipeloc=$(echo $nipechk | awk -F/ '{$NF=""}1' | tr " " "/")

fi

#~ Preparations to run NIPE
echo
cd $nipeloc

#~ NIPE likes to fail, especially after it has just been installed. 
#~ As such, starting NIPE would be retried a maximum of 5 times to try and prevent needless exits.
for retry in {0..5}
do

	sudo perl nipe.pl restart
	nipestart=$(sudo perl nipe.pl status | head -n 2 | tail -n 1 | awk '{print $3}')
	
	if [ "$nipestart" == "true" ]
	then
	
		break
		
	fi
	
	sleep 1
	
done

#~ If NIPE still refuses to connect after the retries, exit the script as user is not anonymous.
if [ "$nipestart" != "true" ]
then

	echo "[!] nipe failed to start! You are not anonymous. Exiting..."
	exit
	
else

	echo "[*] You are anonymous. Proceeding with next steps..."
	
fi

#~ Displaying the spoofed IP address and country from NIPE.
spoofip=$(sudo perl nipe.pl status | tail -n 2 | head -n 1 | awk '{print $3}')
spoofloc=$(geoiplookup $spoofip | awk -F: '{print $2}' | awk '{$1=""}1')
echo "[#] Your spoofed IP address is: $spoofip, country: $spoofloc "

#~ Asking for user input for domain/IP address to scan. Limited to IPv4 addresses and valid domain names.
uinput

#~ Checking that the remote server services are actually running, and which ports they are on.
nmap $host -Pn -sV -p- > nmapresult
sshport=$(cat nmapresult | grep ssh | awk -F/ '{print $1}')
ftpport=$(cat nmapresult | grep ftp | awk -F/ '{print $1}')
rm nmapresult

servicechk SSH $sshport
servicechk FTP $ftpport

#~ Checking that we are able to connect to the remote server using the provided details. If not, exit the script.
upchk=$(sshp exit 2>&1 | grep denied)

if [ -n "$upchk" ]
then
	
	echo
	echo "[!] Remote server IP address, username and/or password is wrong!"
	echo "[!] Please correct by running: bash rc.sh options or ./rc.sh options!"
	echo "[!] Exiting..."
	exit
	
fi

#~ Connecting to remote server and displaying its details.
rsuptime=$(sshp uptime)
rsip=$(sshp curl -s ifconfig.io)
rscountry=$(sshp geoiplookup $rsip | awk -F: '{print $2}' | awk '{$1=""}1')

echo "Uptime: $rsuptime"
echo "IP address: $rsip"
echo "Country: $rscountry"
echo

#~ Checking for the existence of the log file. If it does not exist, create and configure one.
if [ -z $(locate /var/log/rc.log) ]
then
	
	sudo touch /var/log/rc.log
	sudo chmod 666 /var/log/rc.log
	
fi

#~ Using the remote server to scan the domain/IP address provided by the user and saving the results on both the remote server and local machine.
#~ Also logs the scan into the log file.
scan whois
scan nmap -Pn -sV -F

#~ Informing the user the scans were logged.
echo "Scan attempts were logged onto /var/log/rc.log"
