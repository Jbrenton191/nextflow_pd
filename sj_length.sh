#!/bin/bash

limits=$1
limits=`wc $limits | awk '{print $1}'`
limits=`echo "$limits * 1.2" | bc -l`
limits=`printf "%.0f\n" $limits`

if [ $limits -lt 1000000 ]; then
	limits=1000000
else
	limits=$limits
fi

echo "$limits"
