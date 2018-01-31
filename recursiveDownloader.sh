#!/bin/bash
# Anthony/Rabiaza
# 2018-02-31

#wget parameters,
# -nv: non verbose 
# -nc: skip downloads that would download to existing files
# --secure-protocol=TLSv1 --no-check-certificate: security related
wget_params="-nv -nc --secure-protocol=TLSv1 --no-check-certificate"


function help() {
	echo "Please run this utility with the URL of the WSDL/XSD as argument"
	echo -e "\tFor instance:"
	echo -e "\t$0 http://192.168.0.96:8080/HelloWorld_WebServiceProject/wsdl/HelloWorld.wsdl"
}

function download() {
	echo -e "\tDownloading ${1##*/}"
	echo -en "\t\twget -> "
	wget $wget_params $1
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

download $1

export filename=${1##*/}
export serverPath=${1%/*}

echo "File to download $filename on $serverPath"

getDependencies $filename $serverPath

cd "$currentDir"