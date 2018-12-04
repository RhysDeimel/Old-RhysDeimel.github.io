trying to get the server to work without a direct internet connection.

Installed squid on windows and set it up as a proxy

set env vars `http_proxy` and `https_proxy` on the ubuntu18 instance to be http(s)://192.168.0.100:3128

also created file `/etc/apt/apt.conf.d/proxy.con` that contains:
```
Acquire::http::Proxy "http://192.168.0.100:3128/";
Acquire::https::Proxy "http://192.168.0.100:3128/";
```

`apt-update` kinda worked, but it was slow and coming back with errors. `sudo apt-get clean` fixed it.


Also, for a good generic speed test:
`wget --output-document=/dev/null http://speedtest.wdc01.softlayer.com/downloads/test500.zip`


and for a good internet test:
`curl wttr.in`

also https://www.serverlab.ca seem to have some good tutorials



- Holy shitballs
so, looks like wireless card is disabled by default, and drivers seem to be supported?
```
~$ lshw -C network
WARNING: you should run this program as super-user.
  *-network DISABLED
       description: Wireless interface
       product: RTL8192EE PCIe Wireless Network Adapter
       vendor: Realtek Semiconductor Co., Ltd.
       physical id: 0
       bus info: pci@0000:03:00.0
       logical name: wls160
       version: 00
       serial: 50:3e:aa:8e:56:3b
       width: 64 bits
       clock: 33MHz
       capabilities: bus_master cap_list ethernet physical wireless
       configuration: broadcast=yes driver=rtl8192ee driverversion=4.15.0-29-generic firmware=N/A latency=64 link=no multicast=yes wireless=IEEE 802.11
       resources: irq:62 ioport:4000(size=256) memory:fd4fc000-fd4fffff
  *-network
       description: Ethernet interface
       product: VMXNET3 Ethernet Controller
       vendor: VMware
       physical id: 0
       bus info: pci@0000:0b:00.0
       logical name: ens192
       version: 01
       serial: 00:0c:29:d8:4e:81
       size: 10Gbit/s
       capacity: 10Gbit/s
       width: 32 bits
       clock: 33MHz
       capabilities: bus_master cap_list rom ethernet physical logical tp 1000bt-fd 10000bt-fd
       configuration: autonegotiation=off broadcast=yes driver=vmxnet3 driverversion=1.4.14.0-k-NAPI duplex=full ip=192.168.0.104 latency=0 link=yes multicast=yes port=twisted pair speed=10Gbit/s
       resources: irq:19 memory:fd3fc000-fd3fcfff memory:fd3fd000-fd3fdfff memory:fd3fe000-fd3fffff ioport:5000(size=16) memory:fd300000-fd30ffff
  *-network DISABLED
       description: Wireless interface
       physical id: 1
       bus info: usb@1:1
       logical name: wlx9cefd5fdab2a
       serial: 9c:ef:d5:fd:ab:2a
       capabilities: ethernet physical wireless
       configuration: broadcast=yes driver=rt2800usb driverversion=4.15.0-29-generic firmware=N/A link=no multicast=yes wireless=IEEE 802.11
WARNING: output may be incomplete or inaccurate, you should run this program as super-user.
```

So, both wireless interfaces are disabled (one pcie, the other a USB stick)
Taking the logical name, we can run the following command: `~$ sudo ifconfig wls160 up` and hey presto, it now shows up in ifconfig
```
~$ ifconfig
ens192: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.0.104  netmask 255.255.255.0  broadcast 192.168.0.255
        inet6 fe80::20c:29ff:fed8:4e81  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:d8:4e:81  txqueuelen 1000  (Ethernet)
        RX packets 129408  bytes 135894385 (135.8 MB)
        RX errors 0  dropped 7354  overruns 0  frame 0
        TX packets 70437  bytes 4837052 (4.8 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 6889  bytes 416947 (416.9 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 6889  bytes 416947 (416.9 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

wls160: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        ether 50:3e:aa:8e:56:3b  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

- now to connect it. Lets install `sudo apt-get install nmcli`

- to see a list of wifis `nmcli d wifi list`






=====================
we're almost there. Just need to set routes
https://askubuntu.com/questions/1062902/ubuntu-18-04-netplan-static-routes


Set the following with netplan (`/etc/netplan/50-cloud-init.yaml`):
```
network:
    version: 2
    ethernets:
        ens192:
            addresses: []
            dhcp4: true
            routes:
            - to: 192.168.0.0/24
              via: 192.168.0.1

    wifis:
        wls160:
            addresses: []
            dhcp4: true
            optional: true
            gateway4: 192.168.1.1
            access-points:
                 "myssid":
                    password: "mypass"
            routes:
            - to: 0.0.0.0/0
              via: 192.168.1.1
              metric: 50
```

But default gateway route still exists and fucks with life:
```
~$ route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         192.168.0.1     0.0.0.0         UG    100    0        0 ens192
0.0.0.0         192.168.1.1     0.0.0.0         UG    600    0        0 wls160
192.168.0.0     0.0.0.0         255.255.255.0   U     0      0        0 ens192
192.168.0.1     0.0.0.0         255.255.255.255 UH    100    0        0 ens192
192.168.1.0     0.0.0.0         255.255.255.0   U     0      0        0 wls160
192.168.1.0     0.0.0.0         255.255.255.0   U     600    0        0 wls160
192.168.1.1     0.0.0.0         255.255.255.255 UH    600    0        0 wls160
```

so delete it with `sudo route del default`

and recheck routes:
```
~$ route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         192.168.1.1     0.0.0.0         UG    600    0        0 wls160
192.168.0.0     0.0.0.0         255.255.255.0   U     0      0        0 ens192
192.168.0.1     0.0.0.0         255.255.255.255 UH    100    0        0 ens192
192.168.1.0     0.0.0.0         255.255.255.0   U     0      0        0 wls160
192.168.1.0     0.0.0.0         255.255.255.0   U     600    0        0 wls160
192.168.1.1     0.0.0.0         255.255.255.255 UH    600    0        0 wls160
```

HEY PRESTO, WE HAVE INTERNET
```
~$ curl wttr.in
Weather report: Sydney, Australia

    \  /       Partly cloudy
  _ /"".-.     20 °C
    \_(   ).   ↑ 43 km/h
    /(___(__)  10 km
               0.0 mm
                                                       ┌─────────────┐
┌──────────────────────────────┬───────────────────────┤  Sun 02 Dec ├───────────────────────┬──────────────────────────────┐
│            Morning           │             Noon      └──────┬──────┘     Evening           │             Night            │
├──────────────────────────────┼──────────────────────────────┼──────────────────────────────┼──────────────────────────────┤
│    \  /       Partly cloudy  │    \  /       Partly cloudy  │    \  /       Partly cloudy  │    \  /       Partly cloudy  │
│  _ /"".-.     26-27 °C       │  _ /"".-.     31-32 °C       │  _ /"".-.     26-28 °C       │  _ /"".-.     22 °C          │
│    \_(   ).   ↘ 17-31 km/h   │    \_(   ).   → 27-50 km/h   │    \_(   ).   ↑ 31-44 km/h   │    \_(   ).   ↖ 27-37 km/h   │
│    /(___(__)  10 km          │    /(___(__)  16 km          │    /(___(__)  20 km          │    /(___(__)  20 km          │
│               0.0 mm | 0%    │               0.0 mm | 0%    │               0.0 mm | 0%    │               0.0 mm | 0%    │
└──────────────────────────────┴──────────────────────────────┴──────────────────────────────┴──────────────────────────────┘
                                                       ┌─────────────┐
┌──────────────────────────────┬───────────────────────┤  Mon 03 Dec ├───────────────────────┬──────────────────────────────┐
│            Morning           │             Noon      └──────┬──────┘     Evening           │             Night            │
├──────────────────────────────┼──────────────────────────────┼──────────────────────────────┼──────────────────────────────┤
│    \  /       Partly cloudy  │     \   /     Sunny          │    \  /       Partly cloudy  │    \  /       Partly cloudy  │
│  _ /"".-.     21 °C          │      .-.      25-26 °C       │  _ /"".-.     24-25 °C       │  _ /"".-.     22-25 °C       │
│    \_(   ).   → 9-10 km/h    │   ― (   ) ―   ↘ 7-8 km/h     │    \_(   ).   ↗ 5-8 km/h     │    \_(   ).   → 7-13 km/h    │
│    /(___(__)  20 km          │      `-’      20 km          │    /(___(__)  20 km          │    /(___(__)  20 km          │
│               0.0 mm | 0%    │     /   \     0.0 mm | 0%    │               0.0 mm | 0%    │               0.0 mm | 0%    │
└──────────────────────────────┴──────────────────────────────┴──────────────────────────────┴──────────────────────────────┘
                                                       ┌─────────────┐
┌──────────────────────────────┬───────────────────────┤  Tue 04 Dec ├───────────────────────┬──────────────────────────────┐
│            Morning           │             Noon      └──────┬──────┘     Evening           │             Night            │
├──────────────────────────────┼──────────────────────────────┼──────────────────────────────┼──────────────────────────────┤
│     \   /     Sunny          │               Cloudy         │    \  /       Partly cloudy  │    \  /       Partly cloudy  │
│      .-.      21 °C          │      .--.     21 °C          │  _ /"".-.     19 °C          │  _ /"".-.     19 °C          │
│   ― (   ) ―   ↖ 19-23 km/h   │   .-(    ).   ↖ 22-26 km/h   │    \_(   ).   ↖ 20-26 km/h   │    \_(   ).   ↖ 18-25 km/h   │
│      `-’      20 km          │  (___.__)__)  20 km          │    /(___(__)  20 km          │    /(___(__)  20 km          │
│     /   \     0.0 mm | 0%    │               0.0 mm | 0%    │               0.0 mm | 0%    │               0.0 mm | 0%    │
└──────────────────────────────┴──────────────────────────────┴──────────────────────────────┴──────────────────────────────┘

Follow @igor_chubin for wttr.in updates
```



BUT, default route is added back in on boot. FML.
Round #2

`ip route show` gives
```
$ ip route show
default via 192.168.0.1 dev ens192 proto dhcp src 192.168.0.104 metric 100
default via 192.168.1.1 dev wls160 proto dhcp src 192.168.1.106 metric 600
192.168.0.0/24 dev ens192 proto kernel scope link src 192.168.0.104
192.168.0.1 dev ens192 proto dhcp scope link src 192.168.0.104 metric 100
192.168.1.0/24 dev wls160 proto kernel scope link src 192.168.1.106
192.168.1.1 dev wls160 proto dhcp scope link src 192.168.1.106 metric 600
```

Let's delete the default `$ sudo ip route del default via 192.168.0.1 dev ens192`:
```
$ ip route show
default via 192.168.1.1 dev wls160 proto dhcp src 192.168.1.106 metric 600
192.168.0.0/24 dev ens192 proto kernel scope link src 192.168.0.104
192.168.0.1 dev ens192 proto dhcp scope link src 192.168.0.104 metric 100
192.168.1.0/24 dev wls160 proto kernel scope link src 192.168.1.106
192.168.1.1 dev wls160 proto dhcp scope link src 192.168.1.106 metric 600
```

That worked. Can hit internet. But same boot issue. As of 2/12/2018, looks like setting the route metric is not an option (which is what's causing the issue here). Seems netplan has an ongoing PR to sort it out.

ALSO:
    - don't forget to delete `/etc/apt/apt.conf.d/proxy.con` otherwise apt will try smash it


# FAILURE
The above only works temporarily. Default route is re-added eventually. Time to rollback to ubuntu16 I guess. `¯\_(ツ)_/¯`



# Try 2
Search for packages: https://launchpad.net/ubuntu/xenial
- scp
    - wpasupplicant
    - libpcsclite1

<!--     - libtinfo6
    - libreadline7
    - libc6
    - libssl1.1 -->

https://wiki.archlinux.org/index.php/WPA_supplicant
https://serverfault.com/questions/286768/linux-ubuntu-two-nics-separate-lan