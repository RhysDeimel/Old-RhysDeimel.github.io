Want to build images for current homelab setup of single esxi machine.

Have it all building locally, but can not get it to export to packer because I was trying to use the post provisioners, and they actually require vSphere. I don't have vCentre installed yet, and want to hold off a bit for learning.

Reading through the packer builder, it looks like you can [upload straight to ESXi](https://www.packer.io/docs/builders/vmware-iso.html#building-on-a-remote-vsphere-hypervisor), but you have to do a few pre-configuration steps first.

1) enable SSH
	Manage -> Services -> search for SSH to find the `TSM-SSH` option and start it. SSH is now enabled.

2) GuestIPHack
	You'll need to ssh onto the host and run the following command `esxcli system settings advanced set -o /Net/GuestIPHack -i 1`
	This allows Packer to infer the guest IP from ESXi, without the VM needing to report it itself.

3) Packer also requires VNC to issue boot commands during a build
	You might find that you aren't able to edit the file:
	```
	[root@192-168-1-113:~] ls -al /etc/vmware/firewall/service.xml
	-r--r--r--    1 root     root         21220 Mar  8  2018 /etc/vmware/firewall/service.xml
	```
	Fix that with:
	`chmod 644 /etc/vmware/firewall/service.xml` <- gives `-rw-r--r--`
	The [documentation](https://kb.vmware.com/s/article/2008226) also recommends setting the sticky bit with `chmod +t /etc/vmware/firewall/service.xml` which prevents anyone other than the file owner, directory owner, or the root from renaming, deleting, or changing permissions. It also makes the rule perist after a reboot in this case.
	Next, we need to insert the following at the bottom of `/etc/vmware/firewall/service.xml`, just before the closing `</ConfigRoot>`
	```
	<service id="1000">
	  <id>packer-vnc</id>
	  <rule id="0000">
	    <direction>inbound</direction>
	    <protocol>tcp</protocol>
	    <porttype>dst</porttype>
	    <port>
	      <begin>5900</begin>
	      <end>6000</end>
	    </port>
	  </rule>
	  <enabled>true</enabled>
	  <required>true</required>
	</service>
	```
	Lastly, restore the permissions back to `-r--r--r--` with `chmod 444 /etc/vmware/firewall/service.xml` and refresh the firewall with `esxcli network firewall refresh`. 
	You can confirm your rule change with `esxcli network firewall ruleset list`. You should be able to see `packer-vnc` at the end of the list the rule was entered correctly.

	Feel free to quit the session after this.


### Notes
- the default adapter (e1000) didn't work. Tried using `vmxnet3`. It works
- had to add `"ethernet0.networkName": "VM Network"` to `vmx_data` because it wasn't connecting to the network