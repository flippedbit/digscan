#!/bin/bash
# written by Michael Straughan
# 02/25/2012
# helps recon for pentesting network tries to find extra servers
declare -i MIN
declare -i CIDR
declare -i SIZE=0
declare -a IP
let CIDR=$2


function usage {
	echo Usage: ./digscan.sh [base ip] [CIDR]
	echo Example: ./digscan.sh 96.126.18.0 19
}

function A {
	let local subnet=$CIDR-8
	let local range=2**$subnet+$MIN
	for (( a=MIN; a<=range; a++ ))
	do
		for b in {0..255}
		do
			for c in {0..255}
			do
				host ${IP[1]}.$a.$b.$c |grep "pointer" | cut -d" " -f5 &
			done
		done
	done
}
function B {
	let local subnet=$CIDR-16
	let local range=2**$subnet+$MIN
	for (( b=MIN; b<=range; b++ ))
	do
		for c in {0..255}
		do
			host ${IP[1]}.${IP[2]}.$b.$c |grep "pointer" |cut -d" " -f5 &
		done
	done
}
function C {
	let local subnet=$CIDR-24
	let local range=2**$subnet+$MIN
	for (( c=MIN; c<=range; c++ ))
	do
		host ${IP[1]}.${IP[2]}.${IP[3]}.$c | grep "pointer" | cut -d" " -f5 &
	done
}

if [ $# -eq 2 ]; then
	for f in $(echo $1 | tr "." "\n"); do
		let SIZE=$SIZE+1
		IP[$SIZE]=$f
	done
	if [ ${#IP[@]} -eq 4 ]; then
		let MIN=${IP[4]}
	else
		if [ ${#IP[@]} -eq 3 ]; then
			let MIN=${IP[3]}
		else
			if [ ${#IP[@]} -eq 2 ]; then
				let MIN=${IP[2]}
			else
				if [ ${#IP[@]} -eq 1 ]; then
					let MIN=${IP[1]}
				else
					echo Improper IP size
				fi
			fi
		fi
	fi

	if [ $CIDR -gt 8 ]; then
		if [ $CIDR -gt 16 ]; then
			if [ $CIDR -gt 24 ]; then
				C
			else
				B
			fi
		else
			A
		fi
	fi
else
	usage
fi