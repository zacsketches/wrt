#WRT54GL
####July 2015 - I've been playing with a new [WRT54GL router](http://www.amazon.com/Linksys-WRT54GL-Wireless-G-Broadband-Router/dp/B000BTL0OA/ref=sr_1_1?s=electronics&ie=UTF8&qid=1436047039&sr=1-1&keywords=wrt54gl) for about a month and wanted to go back and make a list of the configuration lessons learned I've tracked down.  My primary references are this [book](http://www.amazon.com/Linksys-WRT54G-Ultimate-Hacking-Asadoorian/dp/1597491667/ref=sr_1_1?s=books&ie=UTF8&qid=1436045407&sr=1-1&keywords=wrt54g), and the OpenWrt [website](openwrt.org).  My examples are applicable with Mac OS X on the development machine.

##A few comments up front
1. The book is based on an older set of firmware (White Russian 0.8) that used a few deprecated techniques.  So much of the book is good for getting a general sense of how the router works, but not directly applicable to copy example source code.
2. The book jumps around from topic to topic a lot in the first 150 pages.  So I think the section below on the the basics is a much more linear progression through getting a router up and running.

##The basics
1. **Logging in** - The first thing I had to do was configure my computer to log into  the Linksys router.  The default IP on the router is 192.168.1.1. so I had to give my computer a manual IP on the same subnet. I chose 192.168.1.54.  In the systems preferences panel I selected to use "DHCP with manual IP".  With that completed just plug into any LAN port on the router and load the router address in a browser to get to the web interface.  The browser will prompt for username and password.  Both are set to the default value, `admin`.
2. **Wireless while connected directly** - Next I wanted to be able to browse the web while I'm working on this so I enabled my wifi card on my host Mac-Mini to link into the home wireless network.  The problem came up that whenever I was connected to both the WRT via ethernet and the wifi network I couldn't get web traffic to route to the wifi.  So again, open up network preferences and in the bottom left hit the little gear.  In there you can "Set Service Order.."  By dragging the wifi interface higher in the list it pushed traffic toward that interface first.
3. **Upgrading to third party firmware** - Straight out of the box the easiest way to upgrade to third party firmware is to use the Linksys web interface to move from the OEM firmware to my choice of open source firmware, OpenWRT.  
	* a. From [this page](http://wiki.openwrt.org/toh/linksys/wrt54g) on the OpenWrt website, it looks like a stable version to use with this hardware is 8.09.2.  So browse to the [downloads page](http://downloads.openwrt.org/kamikaze/8.09.2/brcm-2.4/) and click on it, or get is directly from your Mac host like this, `wget http://downloads.openwrt.org/kamikaze/8.09.2/brcm-2.4/openwrt-wrt54g-squashfs.bin`. 
	* b. Also download the `md5sums` file.  Then follow the the instructions on page 56 to verify the integrity of the downloaded file.  Simpler still use the `check_md5.sh` script in this repository to run the check.
	* c. Once the upgrade firmware is verified follow the upgrade instructions on page 57 at the Linksys *Administration* tab of the web interface.
4. **Change the root password** - As described on page 72 you can change the root password via the web interface or the command line.  Of course, I prefer the command line.  From the Mac host `telnet 192.168.1.1`.  Then run the `passwd` command.  After updating the password `exit` out of the telnet session, and attempt to telnet back in.  It **SHOULD** deny this connection.  So ssh is the only remote login available now.
5. **Set up PKI based ssh** - Password based login is weak protection even with SSH because it is vulnerable to brute force attack.  Set up PKI protection for the ssh root login as described on page 127, which I followed with the following modifications to get it working.
	* a. In order to use `scp` to move my public key over to the router I had to use use this command `scp ~/.ssh/id_dsa.pub root@192.168.1.1:/tmp/` because I have not set up the hosts file yet to call it by name.
	* b. Similarly, once the keys were in place I had to ssh like this `ssh root@192.168.1.1` for the same reason that my hosts file on the Mac is not set up.
4. **Reverting back to original firmware** - 

##Brick on Day 1
1. THE TRUTH...I screwed up my router the first day I played around with it. I got off the reservation and started messing around with the way the router was configured to my home network...at which point I managed to shut down the wireless and DHCP server and erased it's self-assigned IP. So I could not communicate with the router anymore. **THUS...I BRICKED IT ON THE FIRST DAY!**
2. So without the ability to communicate with my new router via any available interface I went to bed pissed off and woke up early to ponder the problem over a fresh cup of coffee.  My solution was to find a way to connect to the serial console provided on the PCB inside the router so I could directly control the linux processor.
3. There is a good discussion in chapter 7 of the book on building a serial cable to get access to the console via JP2 on the PCB.  The book version requires a level shifting IC to convert the signal level on the board to RS-232 power levels.  Then it connects this to an RS-232 serial connector.  I certainly don't have an RS-232 port on my Mac-Mini or my Macbook Air, so I need to use USB.
4. Using the book to understand the pin-out of JP2 on the PCB, I used an Adafruit [FTDI Friend](https://www.adafruit.com/products/284) to convert the serial signal to USB as follows: 
5. *Voltage mod* - The WRT54GL operates with 3.3V on the PCB, not 5V which is the default VCC Out on the FTDI Friend.  So you will need to cut the 5V trace and solder across the 3.3V jumper.
6. *Connector bill of materials* - Next we need to build the cable to plug into the FTDI Friend.  I get most of my hobby level stuff from [Sparkfun](sparkfun.com):
	* a. [2x5 pin male connector](https://www.sparkfun.com/products/8506)
	* b. [2x5 pin female crimp connector](https://www.sparkfun.com/products/10650)
	* c. [10 wire ribbon cable](https://www.sparkfun.com/products/10647)
	* d. [male headers](https://www.sparkfun.com/products/116)
	* e. [heat shrink](https://www.sparkfun.com/search/products?term=heat+shrink)
7. *Assemble the cable* - Solder the male connector to the PCB.  Then crimp the female ribbon wire onto the female connector.  Then break off a piece of the male headers that is 6 pins wide.  Cut off about 8 inches of ribbon cable then very carefully figure out which pins on the connector line up with the pin-out on the FTDI Friend.  Remember that TX0->FTDI-RX and RX0->FTDI-TX.  Then directly connect VCC and GND on the PCB to their corresponding pins on the FTDI friend.  The remaining six wires in the connector can be cut short and left disconnected from the male header strip.  Once everything is soldered use some heat shrink to protect and strengthen the connection to the headers stip.  Some photos of my cable are included below this set of instructions.
8. The FTDI Friend will also require a micro-USB cable to plug into the mac.
9. Once everything is soldered up, connected and reassembled, power the router up with the cable plugged in.  The FTDI will make the serial terminal from the router appear in the `/dev/` directory as something like `tty.usbserial-XXXXX`.  Use the `screen` utility to monitor the terminal.  From the book we know that the baud rate for the WRT54GL console is 115200 so this command will give access to the console, `screen <tty.usbserial-XXXX> 115200`.  Of course you will have to put the right file handle in.  I've written a script, `/bin/wrt_console.sh` that will search the `/dev/` folder and open the console automagically.
10. Finally, once you can log into the console go through the steps above to re-install OpenWrt or the OEM firmware.
![pin-out](images/wrt54gl_v11_serialport_.jpg)
![connector](images/connector.jpg)
![cable](images/cable.jpg)
![finished](images/finished.jpg)

