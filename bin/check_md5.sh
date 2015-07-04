#!/bin/bash
# a shell script to check that the md5 of the downloaded 
# software matches the md5 in the sums folder

# check usage
if [[ $# -lt 3 ]]; then
	cat <<- EOM
		USAGE: $1 -f <file to check> -s <md5 sums file>
		
		This script checks to make sure that the md5 checksum of
		the passed file matches the md5 for that file in 
		the md5 sums file.
	EOM
	exit 1
fi

while getopts :f:s: option; do
	case $option in
		f) file=$OPTARG;;
		s) sum=$OPTARG;;
		?) echo "Unfamiliar option, $OPTARG."; exit 1;;
	esac
done

ref_md5=$(cat $sum | grep $file | awk '{print $1}')

src_md5=$(md5 -q $file)

echo "src md5: $src_md5"
echo "ref md5: $ref_md5"

if [[ $src_md5 = $ref_md5 ]]; then
	echo "The source and reference match"
else
	echo "The source and reference do not match!!"
fi
