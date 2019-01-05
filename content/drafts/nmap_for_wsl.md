Title: Nmap and WSL
Date: 2019-01-13
Category: howto
Tags: nmap, windows, wsl
Summary: Getting Nmap to work with WSL
Status: ready

I needed WSL for playing around with a home networking project. Now, I could have booted into Linux, but I was already on my Win10 boot, and WSL _seemed_ like a quicker option.

So I tried `sudo apt-get install nmap`, but I was just greeted with a bunch of errors. Google to the rescue then!

I ended up coming across [this](https://medium.com/@the4rchangel/nmap-in-the-windows-bash-shell-64cadff1a689) Medium post that seemed to be the right fit. TLDR: Essentially you have to install nmap for windows, and then create an alias to the `.exe` in WSL.

Here's how I did it:

Head over to the nmap downloads page on their [website](https://nmap.org/download.html) and get the latest stable windows command-line zipfile. [7.70](https://nmap.org/dist/nmap-7.70-win32.zip) at time of writing.
Unzip it to a directory of your choosing. I chose `C:\Program Files (x86)\Nmap` for simplicity. Inside the unzipped directory, you should also find a `nmap_performance.reg` file. Apply that as well.

Nmap requires the Npcap packet capture library, but luckily, an `.exe` should have been included in the zip (`npcap-0.99-r2.exe` at time of writing).

If everything has gone to plan, all that's left is to start up bash and create an alias. Open up your `.bash_aliases` file and add `alias nmap='"/mnt/c/Program Files (x86)/Nmap/nmap.exe"'` to the end. 

Sanity check with `nmap -version` and you should be good to go.
