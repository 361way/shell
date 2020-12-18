#/bin/bash
# code by yangbk  < www.361way.com   itybku@139.com >


threads='16  32  64  128'
modes='seqwr seqrewr seqrd rndrd rndwr rndrw'
filesizes='10G'
req='20000'

echo 'threadsnum mode reqnum filesize  speed  totaltime  timemin  timemax timeavg'  > fileiotemp.txt
for thread in $threads
	do 
	for mode in $modes
		do 
		for filesize in $filesizes
			do 
			echo $filesize
			sysbench --num-threads=$thread --max-requests=$req  --test=fileio --file-total-size=$filesize --file-test-mode=$mode prepare
			sysbench --num-threads=$thread --max-requests=$req  --test=fileio --file-total-size=$filesize --file-test-mode=$mode run  > sysbenchio.txt
			sysbench --num-threads=$thread --max-requests=$req  --test=fileio --file-total-size=$iflesize --file-test-mode=$mode cleanup		

			speed=`grep 'Total transferred' sysbenchio.txt |awk '{print $NF}'|sed 's/)\|(//g'`
			totaltime=`grep 'total time:' sysbenchio.txt |awk '{print $NF}'`
			timemin=`grep 'min:' sysbenchio.txt |awk '{print $NF}'`
			timemax=`grep 'max:' sysbenchio.txt |awk '{print $NF}'`
			timeavg=`grep 'avg:' sysbenchio.txt |awk '{print $NF}'`
  
			echo "$thread $mode  $req $filesize  $speed  $totaltime  $timemin  $timemax $timeavg"  >> fileiotemp.txt
			echo 3 > /proc/sys/vm/drop_caches
			done
		done
	done
cat fileiotemp.txt|column -t > fileio.txt
rm -rf sysbenchio.txt fileiotemp.txt  test_file.*
