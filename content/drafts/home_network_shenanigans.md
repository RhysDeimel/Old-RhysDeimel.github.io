Title: Home network shenanigans
Date: 2018-12-01
Category: HowTo
Tags: route table, network 
Summary: Playing with route tables so I can access ILO in a separate network
Status: draft

Situation: modem in a fucking retarded part of the house. No option for wired, so is a single wireless AP. Have given the Microserver a wireless card so it can participate, but that means I can't access ILO.

Created a separate wired network that has no internet connection. server is in it, as well as NAS and HTPC (has wireless card), and desktop (has wireless card).

Because there's two default gateways, computers will derp out because computers autocreate route rule sending `0.0.0.0` to both gateways, only one of which actually has internet.

So time to open up the commandline.

- Start, run, cmd (with admin permissions)
- let's check out the help for `route`
```
C:\WINDOWS\system32>route

Manipulates network routing tables.

ROUTE [-f] [-p] [-4|-6] command [destination]
                  [MASK netmask]  [gateway] [METRIC metric]  [IF interface]

  -f           Clears the routing tables of all gateway entries.  If this is
               used in conjunction with one of the commands, the tables are
               cleared prior to running the command.

  -p           When used with the ADD command, makes a route persistent across
               boots of the system. By default, routes are not preserved
               when the system is restarted. Ignored for all other commands,
               which always affect the appropriate persistent routes.

  -4           Force using IPv4.

  -6           Force using IPv6.

  command      One of these:
                 PRINT     Prints  a route
                 ADD       Adds    a route
                 DELETE    Deletes a route
                 CHANGE    Modifies an existing route
  destination  Specifies the host.
  MASK         Specifies that the next parameter is the 'netmask' value.
  netmask      Specifies a subnet mask value for this route entry.
               If not specified, it defaults to 255.255.255.255.
  gateway      Specifies gateway.
  interface    the interface number for the specified route.
  METRIC       specifies the metric, ie. cost for the destination.

All symbolic names used for destination are looked up in the network database
file NETWORKS. The symbolic names for gateway are looked up in the host name
database file HOSTS.

If the command is PRINT or DELETE. Destination or gateway can be a wildcard,
(wildcard is specified as a star '*'), or the gateway argument may be omitted.

If Dest contains a * or ?, it is treated as a shell pattern, and only
matching destination routes are printed. The '*' matches any string,
and '?' matches any one char. Examples: 157.*.1, 157.*, 127.*, *224*.

Pattern match is only allowed in PRINT command.
Diagnostic Notes:
    Invalid MASK generates an error, that is when (DEST & MASK) != DEST.
    Example> route ADD 157.0.0.0 MASK 155.0.0.0 157.55.80.1 IF 1
             The route addition failed: The specified mask parameter is invalid. (Destination & Mask) != Destination.

Examples:

    > route PRINT
    > route PRINT -4
    > route PRINT -6
    > route PRINT 157*          .... Only prints those matching 157*

    > route ADD 157.0.0.0 MASK 255.0.0.0  157.55.80.1 METRIC 3 IF 2
             destination^      ^mask      ^gateway     metric^    ^
                                                         Interface^
      If IF is not given, it tries to find the best interface for a given
      gateway.
    > route ADD 3ffe::/32 3ffe::1

    > route CHANGE 157.0.0.0 MASK 255.0.0.0 157.55.80.5 METRIC 2 IF 2

      CHANGE is used to modify gateway and/or metric only.

    > route DELETE 157.0.0.0
    > route DELETE 3ffe::/32
```

- Sick. Let's see what we've got `route print`

```
C:\WINDOWS\system32>route print
===========================================================================
Interface List
 19...c6 15 d9 1e 40 61 ......Hyper-V Virtual Ethernet Adapter
  8...4c cc 6a b5 cc 80 ......Intel(R) Ethernet Connection (2) I219-V
  2...02 00 4c 4f 4f 50 ......Npcap Loopback Adapter
 30...00 ff b9 1d c5 32 ......TAP Adapter OAS NDIS 6.0
  3...2c fd a1 cd f8 ba ......ASUS PCE-AC88 802.11ac Network Adapter
  1...........................Software Loopback Interface 1
===========================================================================

IPv4 Route Table
===========================================================================
Active Routes:
Network Destination        Netmask          Gateway       Interface  Metric
          0.0.0.0          0.0.0.0      192.168.1.1    192.168.1.104     35
          0.0.0.0          0.0.0.0      192.168.0.1    192.168.0.100     25
        127.0.0.0        255.0.0.0         On-link         127.0.0.1    331
        127.0.0.1  255.255.255.255         On-link         127.0.0.1    331
  127.255.255.255  255.255.255.255         On-link         127.0.0.1    331
      169.254.0.0      255.255.0.0         On-link    169.254.68.100    281
   169.254.68.100  255.255.255.255         On-link    169.254.68.100    281
  169.254.255.255  255.255.255.255         On-link    169.254.68.100    281
   172.29.226.224  255.255.255.240         On-link    172.29.226.225    271
   172.29.226.225  255.255.255.255         On-link    172.29.226.225    271
   172.29.226.239  255.255.255.255         On-link    172.29.226.225    271
      192.168.0.0    255.255.255.0         On-link     192.168.0.100    281
    192.168.0.100  255.255.255.255         On-link     192.168.0.100    281
    192.168.0.255  255.255.255.255         On-link     192.168.0.100    281
      192.168.1.0    255.255.255.0         On-link     192.168.1.104    291
    192.168.1.104  255.255.255.255         On-link     192.168.1.104    291
    192.168.1.255  255.255.255.255         On-link     192.168.1.104    291
        224.0.0.0        240.0.0.0         On-link         127.0.0.1    331
        224.0.0.0        240.0.0.0         On-link     192.168.0.100    281
        224.0.0.0        240.0.0.0         On-link    169.254.68.100    281
        224.0.0.0        240.0.0.0         On-link    172.29.226.225    271
        224.0.0.0        240.0.0.0         On-link     192.168.1.104    291
  255.255.255.255  255.255.255.255         On-link         127.0.0.1    331
  255.255.255.255  255.255.255.255         On-link     192.168.0.100    281
  255.255.255.255  255.255.255.255         On-link    169.254.68.100    281
  255.255.255.255  255.255.255.255         On-link    172.29.226.225    271
  255.255.255.255  255.255.255.255         On-link     192.168.1.104    291
===========================================================================
Persistent Routes:
  Network Address          Netmask  Gateway Address  Metric
          0.0.0.0          0.0.0.0         25.0.0.1  Default
===========================================================================

IPv6 Route Table
===========================================================================
Active Routes:
 If Metric Network Destination      Gateway
  1    331 ::1/128                  On-link
  8    281 fe80::/64                On-link
  2    281 fe80::/64                On-link
 19    271 fe80::/64                On-link
  3    291 fe80::/64                On-link
 19    271 fe80::39e8:b5db:1fb:8d30/128
                                    On-link
  3    291 fe80::5cc5:250b:3684:d932/128
                                    On-link
  2    281 fe80::a130:8ea9:99f6:4464/128
                                    On-link
  8    281 fe80::cc4b:3d1f:5102:e123/128
                                    On-link
  1    331 ff00::/8                 On-link
  8    281 ff00::/8                 On-link
  2    281 ff00::/8                 On-link
 19    271 ff00::/8                 On-link
  3    291 ff00::/8                 On-link
===========================================================================
Persistent Routes:
  None
```

- delete both the 0.0.0.0 entries with `route delete`

```
C:\WINDOWS\system32>route delete 0.0.0.0
 OK!
```

- I want 0.0.0.0 traffic to be routed through the AP, it's address is `192.168.1.1`, so we use the following command (the -p flag makes it persistent between boots)
`IF 3` also sets only if wifi interface is detected. The `3` is the id of the interface, which is the first number in each row of the interfaces in the `Interface List` 
```
C:\WINDOWS\system32>route -p ADD 0.0.0.0 MASK 0.0.0.0 192.168.1.1 METRIC 1 IF 3 
 OK!
```

- Next, I need to make my computer aware of the offline network, and send all traffic bound for it to the offline router `192.168.0.1`. DHCP is set to assign ips between `192.168.1.100` & `192.168.1.200`, so if we assign a subnet mask of `255.255.255.0`, that should be more than enough to cover it. 

```
C:\WINDOWS\system32>route -p ADD 192.168.0.0 MASK 255.255.255.0 192.168.0.1 IF 8
 OK!
```

- and a final check to make sure it's all there:
```
C:\WINDOWS\system32>route print
===========================================================================
Interface List
 19...c6 15 d9 1e 40 61 ......Hyper-V Virtual Ethernet Adapter
  8...4c cc 6a b5 cc 80 ......Intel(R) Ethernet Connection (2) I219-V
  2...02 00 4c 4f 4f 50 ......Npcap Loopback Adapter
 30...00 ff b9 1d c5 32 ......TAP Adapter OAS NDIS 6.0
  3...2c fd a1 cd f8 ba ......ASUS PCE-AC88 802.11ac Network Adapter
  1...........................Software Loopback Interface 1
===========================================================================

IPv4 Route Table
===========================================================================
Active Routes:
Network Destination        Netmask          Gateway       Interface  Metric
          0.0.0.0          0.0.0.0      192.168.1.1    192.168.1.104     36
        127.0.0.0        255.0.0.0         On-link         127.0.0.1    331
        127.0.0.1  255.255.255.255         On-link         127.0.0.1    331
  127.255.255.255  255.255.255.255         On-link         127.0.0.1    331
      169.254.0.0      255.255.0.0         On-link    169.254.68.100    281
   169.254.68.100  255.255.255.255         On-link    169.254.68.100    281
  169.254.255.255  255.255.255.255         On-link    169.254.68.100    281
   172.29.226.224  255.255.255.240         On-link    172.29.226.225    271
   172.29.226.225  255.255.255.255         On-link    172.29.226.225    271
   172.29.226.239  255.255.255.255         On-link    172.29.226.225    271
      192.168.0.0    255.255.255.0         On-link     192.168.0.100    281
      192.168.0.0    255.255.255.0      192.168.0.1    192.168.0.100     26
    192.168.0.100  255.255.255.255         On-link     192.168.0.100    281
    192.168.0.255  255.255.255.255         On-link     192.168.0.100    281
      192.168.1.0    255.255.255.0         On-link     192.168.1.104    291
    192.168.1.104  255.255.255.255         On-link     192.168.1.104    291
    192.168.1.255  255.255.255.255         On-link     192.168.1.104    291
        224.0.0.0        240.0.0.0         On-link         127.0.0.1    331
        224.0.0.0        240.0.0.0         On-link     192.168.0.100    281
        224.0.0.0        240.0.0.0         On-link    169.254.68.100    281
        224.0.0.0        240.0.0.0         On-link    172.29.226.225    271
        224.0.0.0        240.0.0.0         On-link     192.168.1.104    291
  255.255.255.255  255.255.255.255         On-link         127.0.0.1    331
  255.255.255.255  255.255.255.255         On-link     192.168.0.100    281
  255.255.255.255  255.255.255.255         On-link    169.254.68.100    281
  255.255.255.255  255.255.255.255         On-link    172.29.226.225    271
  255.255.255.255  255.255.255.255         On-link     192.168.1.104    291
===========================================================================
Persistent Routes:
  Network Address          Netmask  Gateway Address  Metric
          0.0.0.0          0.0.0.0      192.168.1.1       1
      192.168.0.0    255.255.255.0      192.168.0.1       1
===========================================================================

IPv6 Route Table
===========================================================================
Active Routes:
 If Metric Network Destination      Gateway
  1    331 ::1/128                  On-link
  8    281 fe80::/64                On-link
  2    281 fe80::/64                On-link
 19    271 fe80::/64                On-link
  3    291 fe80::/64                On-link
 19    271 fe80::39e8:b5db:1fb:8d30/128
                                    On-link
  3    291 fe80::5cc5:250b:3684:d932/128
                                    On-link
  2    281 fe80::a130:8ea9:99f6:4464/128
                                    On-link
  8    281 fe80::cc4b:3d1f:5102:e123/128
                                    On-link
  1    331 ff00::/8                 On-link
  8    281 ff00::/8                 On-link
  2    281 ff00::/8                 On-link
 19    271 ff00::/8                 On-link
  3    291 ff00::/8                 On-link
===========================================================================
Persistent Routes:
  None
```



#EDIT
Some issues. Whenever IP is refreshed, windows 10 automatically re-adds the following line
```
===========================================================================
Active Routes:
Network Destination        Netmask          Gateway       Interface  Metric
0.0.0.0          0.0.0.0      192.168.0.1    192.168.0.100     25
```
and this fucks with the persistent route.

Going to make an attempt at changing the priority of the NIC's.

Start up powershell as admin
- enter `Get-NetIPInterface`
```
PS C:\WINDOWS\system32> Get-NetIPInterface

ifIndex InterfaceAlias                  AddressFamily NlMtu(Bytes) InterfaceMetric Dhcp     ConnectionState PolicyStore
------- --------------                  ------------- ------------ --------------- ----     --------------- -----------
3       WiFi 7                          IPv6                  1500              35 Enabled  Connected       ActiveStore
2       Npcap Loopback Adapter          IPv6                  1500              25 Enabled  Connected       ActiveStore
30      Ethernet 2                      IPv6                  1500              35 Enabled  Disconnected    ActiveStore
19      vEthernet (Default Switch)      IPv6                  1500              15 Enabled  Connected       ActiveStore
1       Loopback Pseudo-Interface 1     IPv6            4294967295              75 Disabled Connected       ActiveStore
8       Ethernet                        IPv6                  1500              25 Enabled  Connected       ActiveStore
3       WiFi 7                          IPv4                  1500              35 Enabled  Connected       ActiveStore
2       Npcap Loopback Adapter          IPv4                  1500              25 Enabled  Connected       ActiveStore
30      Ethernet 2                      IPv4                  1500              35 Enabled  Disconnected    ActiveStore
19      vEthernet (Default Switch)      IPv4                  1500              15 Enabled  Connected       ActiveStore
1       Loopback Pseudo-Interface 1     IPv4            4294967295              75 Disabled Connected       ActiveStore
8       Ethernet                        IPv4                  1500              25 Enabled  Connected       ActiveStore
```

- We want interface 8 and 3. It looks like ethernet (8) has more priority than the wifi card. So let's fix that.
` Set-NetIPInterface -InterfaceIndex 3 -InterfaceMetric 10`

and checking for sanity:
```
PS C:\WINDOWS\system32> Get-NetIPInterface

ifIndex InterfaceAlias                  AddressFamily NlMtu(Bytes) InterfaceMetric Dhcp     ConnectionState PolicyStore
------- --------------                  ------------- ------------ --------------- ----     --------------- -----------
3       WiFi 7                          IPv6                  1500              10 Enabled  Connected       ActiveStore
2       Npcap Loopback Adapter          IPv6                  1500              25 Enabled  Connected       ActiveStore
30      Ethernet 2                      IPv6                  1500              35 Enabled  Disconnected    ActiveStore
19      vEthernet (Default Switch)      IPv6                  1500              15 Enabled  Connected       ActiveStore
1       Loopback Pseudo-Interface 1     IPv6            4294967295              75 Disabled Connected       ActiveStore
8       Ethernet                        IPv6                  1500              25 Enabled  Connected       ActiveStore
3       WiFi 7                          IPv4                  1500              10 Enabled  Connected       ActiveStore
2       Npcap Loopback Adapter          IPv4                  1500              25 Enabled  Connected       ActiveStore
30      Ethernet 2                      IPv4                  1500              35 Enabled  Disconnected    ActiveStore
19      vEthernet (Default Switch)      IPv4                  1500              15 Enabled  Connected       ActiveStore
1       Loopback Pseudo-Interface 1     IPv4            4294967295              75 Disabled Connected       ActiveStore
8       Ethernet                        IPv4                  1500              25 Enabled  Connected       ActiveStore
```

This _should_ fix it, even when the dynamic issue pops up again
EDIT - Can confirm that it works