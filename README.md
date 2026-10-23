# Project-Remote-Control
First thing that happened when re-reading this script: I laughed. 
Second thing to come out of my mouth: "Wow, I am a lazy fuck." Still am, by the way. 

Also I still hate trying to read regex. Gives me a hell of a time decoding it, even though I wrote it. 
Still won't stop me from abusing the hell outta it. It's useful.

Anyways, small talk aside, here's what the script does:
You provide a IP address for a remote server. Give creds. Don't do crime. lol.
The script updates/installs packages it needs.
Spoofs your IP address and location with NIPE. (NIPE is still horrible by the way. Why do you keep failing.)
Nmaps the target server.
Connects to the target server using the provided credentials. Don't do crime. lol. I sound like a robot.
Then runs a bunch of dodgy commands. Including but not limited to:
1. Checking server uptime
2. Checking server IP address
3. Checking server location
4. Then uses the remote server to whois and nmap a target IP that was provided beforehand.
5. Saves the logs to /var/log/rc.log on both the remote server and local machine.

Is it pointless? Yes. Did I learn anything? Yes. Mostly regex though. lol.
