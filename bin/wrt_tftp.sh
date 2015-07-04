#!/bin/bash
# a script to automate connecting to the tftp server when
# uploading firmware on my WRT54GL router
echo "There are $# arguments"

if [[ $# -lt 1 ]]; then
	echo "USAGE: wrt_tftp.sh <wrt_firmware_filename.bin>"
	echo "This script will open a tftp session with 192.168.1.1 and"
	echo "upload the firmware if it can connect.  Sets timeout to 60"
	echo "seconds and retry rate to 1 sec."
	
	exit 1
fi

tftp <<- EOM
	connect 192.168.1.1
	bin
	trace
	timeout 60
	rexmt 1
	put $1
EOM
