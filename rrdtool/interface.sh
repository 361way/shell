#!/bin/bash
# interface.sh - Network usage stats
#
# Copyright 2010 Frode Petterson. All rights reserved.
# See README.rdoc for license. 

rrdtool=$(which rrdtool);
db0=/var/lib/rrd/eth0.rrd
db1=/var/lib/rrd/eth1.rrd
img=/var/www/stats

if [ ! -e $db0 ]
then 
	$rrdtool create $db0 \
		-s 5 \
		DS:in:DERIVE:600:0:12500000 \
		DS:out:DERIVE:600:0:12500000 \
		RRA:AVERAGE:0.5:1:576 \
		RRA:AVERAGE:0.5:6:672 \
		RRA:AVERAGE:0.5:24:732 \
		RRA:AVERAGE:0.5:144:1460
fi

if [ ! -e $db1 ]
then 
	$rrdtool create $db1 \
		-s 5 \
		DS:in:DERIVE:600:0:12500000 \
		DS:out:DERIVE:600:0:12500000 \
		RRA:AVERAGE:0.5:1:576 \
		RRA:AVERAGE:0.5:6:672 \
		RRA:AVERAGE:0.5:24:732 \
		RRA:AVERAGE:0.5:144:14
fi

in0=$(ifconfig eth0 | grep bytes | cut -d ":" -f2 | cut -d " " -f1)
out0=$(ifconfig eth0 | grep bytes | cut -d ":" -f3 | cut -d " " -f1)

in1=$(ifconfig eth1 | grep bytes | cut -d ":" -f2 | cut -d " " -f1)
out1=$(ifconfig eth1 | grep bytes | cut -d ":" -f3 | cut -d " " -f1)

$rrdtool updatev $db0 -t in:out N:$in0:$out0
$rrdtool updatev $db1 -t in:out N:$in1:$out1

for period in hour day week month year
do
	$rrdtool graph $img/eth0-$period.png -s -1$period \
		-t "Network Traffic on eth0" \
		--lazy \
		-l 0 -a PNG -v bytes/sec \
		DEF:in=$db0:in:AVERAGE \
		DEF:out=$db0:out:AVERAGE \
		CDEF:out_neg=out,-1,* \
		"AREA:in#32CD32:Incoming" \
		"LINE1:in#336600" \
		"GPRINT:in:MAX:  Max\\: %5.1lf %s" \
		"GPRINT:in:AVERAGE: Avg\\: %5.1lf %S" \
		"GPRINT:in:LAST: Current\\: %5.1lf %Sbytes/sec\\n" \
		"AREA:out_neg#4169E1:Outgoing" \
		"LINE1:out_neg#0033CC" \
		"GPRINT:out:MAX:  Max\\: %5.1lf %S" \
		"GPRINT:out:AVERAGE: Avg\\: %5.1lf %S" \
		"GPRINT:out:LAST: Current\\: %5.1lf %Sbytes/sec" \
		"HRULE:0#000000" \
        -h 134 -w 543 -l 0 -a PNG -v "B/s"  > /dev/null

	$rrdtool graph $img/eth1-$period.png -s -1$period \
		-t "Network Traffic on eth1" \
		--lazy \
		-l 0 -a PNG -v bytes/sec \
		DEF:in=$db1:in:AVERAGE \
		DEF:out=$db1:out:AVERAGE \
		CDEF:out_neg=out,-1,* \
		"AREA:in#32CD32:Incoming" \
		"LINE1:in#336600" \
		"GPRINT:in:MAX:  Max\\: %5.1lf %s" \
		"GPRINT:in:AVERAGE: Avg\\: %5.1lf %S" \
		"GPRINT:in:LAST: Current\\: %5.1lf %Sbytes/sec\\n" \
		"AREA:out_neg#4169E1:Outgoing" \
		"LINE1:out_neg#0033CC" \
		"GPRINT:out:MAX:  Max\\: %5.1lf %S" \
		"GPRINT:out:AVERAGE: Avg\\: %5.1lf %S" \
		"GPRINT:out:LAST: Current\\: %5.1lf %Sbytes/sec" \
		"HRULE:0#000000" \
        -h 134 -w 543 -l 0 -a PNG -v "B/s"  > /dev/null
done
