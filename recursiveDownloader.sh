#!/bin/bash
# Anthony/Rabiaza
# 2018-02-31

#wget parameters:
# -T 60: timeout of 60 sec	
# -nv: non verbose 
# -nc: skip downloads that would download to existing files
# --secure-protocol=TLSv1 --no-check-certificate: security related
wget_params="-T 60 -nv -nc --secure-protocol=TLSv1 --no-check-certificate"


function help() {
	echo "Please run this utility with the URL of the WSDL/XSD as argument"
	echo -e "\tFor instance:"
	echo -e "\t$0 http://192.168.0.96:8080/HelloWorld_WebServiceProject/wsdl/HelloWorld.wsdl"
}

function download() {
	export filename=${1##*/}
	if [ "$filename" == "" ];
	then
		echo -e "\tError for $1"
		echo -ne "\t\t"
		return -1
	fi
	echo -e "\tDownloading $filename"
	echo -en "\t\twget -> "
	wget $wget_params $1
	echo ""
}

function getDependencies() {
	export nbOccurrences=`grep -Po 'schemaLocation' $1 | wc -l`
	
	if [ $nbOccurrences -gt 0 ];
		then
			export dependencies=`grep -Po 'schemaLocation="\K.*?(?=")' $1`
			echo "$dependencies" | while read -r dependency
			do
				download $2/$dependency
				getDependencies $dependency $2
			done
		else
			echo -e "\t\tNo more dependencies for $1"
	fi

}

if [ $# -lt 1 ];
	then help
	exit -1
fi

currentDir="$PWD"

echo "Recursive Downloader"
echo "Command:    $0"
echo "Parameters: $*"
echo ""
echo "Creating output folder"

mkdir -p output
cd output

export filename=${1##*/}
export serverPath=${1%/*}

echo "File to download $filename on $serverPath"

download $1

getDependencies $filename $serverPath

cd "$currentDir"