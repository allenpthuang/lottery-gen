#!/bin/bash

readonly RAND_START=1
readonly RAND_END=49
readonly DEFAULT_SHAKES=2500
readonly DEFAULT_BETS=1

if [[ ! -z $1 ]] && [ $1 -eq $1 ] 2>/dev/null ; then
	bets=$1
elif [[ "$1" == "stats" ]] && [ $2 -eq $2 ] 2>/dev/null ; then
	mode="stats"
	if [[ ! -z $3 ]] && [ $3 -eq $3 ] 2>/dev/null ; then
		shakes=$3
	else
		shakes=$DEFAULT_SHAKES
	fi
elif [[ "$1" == "crazy" ]]; then
	mode="crazy"
	if [[ ! -z $3 ]] && [ $3 -eq $3 ] 2>/dev/null ; then
		shakes=$3
		bets=$2
	else
		shakes=$DEFAULT_SHAKES
		if [[ ! -z $2 ]] && [ $2 -eq $2 ] 2>/dev/null ; then
			bets=$2
		else
			bets=$DEFAULT_BETS
		fi
	fi
else
	bets=$DEFAULT_BETS
fi

function get_random() {
	echo $(( $(od -A n -t u -N 2 /dev/random) % $RAND_END + $RAND_START ))
}


function fill_stats() {
	for (( i = 0 ; i < $1 ; i++ )); do
		num=$(get_random $RAND_START $RAND_END)
		((ball_stats[$num]++))
	done
}

function marksix_by_rank() {
	local -a marksix_nums
	marksix_nums=($(print_stats $1 \
		| sort -t':' -k2 -n -r \
		| head -n 6 \
		| awk -F ':' '{print $1}' \
		| awk '{print $2}'))

	local -a sorted

	IFS=$'\n' sorted=($(sort -n <<<"${marksix_nums[*]}"))
	unset IFS

	for (( k = 0 ; k < 6 ; k++ )); do
		printf "%4s" ${sorted[$k]}
	done
}

function marksix() {
	local -a marksix_nums

	for (( i = 0 ; i < 6 ; i++ )); do
		marksix_nums[i]=$(get_random $RAND_START $RAND_END)
		for (( j = 0 ; j < $i ; j++ )); do
			if [[ ${marksix_nums[$i]} == ${marksix_nums[$j]} ]]; then
				i=$(($i-1))
				continue
			fi
		done
	done

	local -a sorted

	IFS=$'\n' sorted=($(sort -n <<<"${marksix_nums[*]}"))
	unset IFS

	for (( k = 0 ; k < 6 ; k++ )); do
		printf "%4s" ${sorted[$k]}
	done
}

function print_marksix() {
	printf "\n"
	for (( m = 0 ; m < $1 ; m++ )); do
		printf "\t---------------------------\n\t"

		if [[ $2 == "crazy" ]]; then
			marksix_by_rank $3
		else
			marksix
		fi

		printf "\n"
	done
	printf "\t---------------------------\n"
	printf "\t    Wish you good luck!\n\n"
}

function print_stats() {
	echo "Going $1 times..."

	fill_stats $1

	for (( i = 1 ; i <= 49 ; i++ )); do
		echo "Ball $i: ${ball_stats[$i]}"
	done
}

case $mode in
	stats)
		print_stats $shakes
		;;
	crazy)
		print_marksix $bets $mode $shakes
		;;
	*)
		print_marksix $bets
		;;
esac

