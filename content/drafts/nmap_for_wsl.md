Installed nmap on WSL.

It doesn't work normally under WSL because, I'm assuming, it can't access that part of the windows network layer.

Came across this medium post: https://medium.com/@the4rchangel/nmap-in-the-windows-bash-shell-64cadff1a689

Essentially you have to install nmap for windows, and then create an alias to the .exe in wsl

So, I downloaded the Windows nmap CLI, and unzipped it into `C:\Program Files (x86)\Nmap`
Then I installed the `nmap_performance.reg`, and also the `npcap-0.99-r2.exe`.
After that, I added `alias nmap='"/mnt/c/Program Files (x86)/Nmap/nmap.exe"'` to my `.bash_aliases` file, and it works perfectly.

