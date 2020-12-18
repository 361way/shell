#/bin/bash
# code by yangbk  < www.361way.com   itybku@139.com >


threads='16  32  64  128'
reqsizes='100G  200G'
modes='write read'




echo 'threadsnum  mode  reqsize performance speed totaltime  timemin  timemax timeavg'  > memtemp.txt
for thread in $threads
	do 
	for reqsize in $reqsizes
		do 
		for mode in $modes
			do
 
			sysbench --num-threads=$thread  --test=memory --memory-total-size=$reqsize --memory-oper=$mode run > sysbenchmem.txt		
			totaltime=`grep 'total time:' sysbenchmem.txt |awk '{print $NF}'`
			timemin=`grep 'min' sysbenchmem.txt |awk '{print $NF}'`
			timemax=`grep 'max' sysbenchmem.txt |awk '{print $NF}'`
			timeavg=`grep 'avg:' sysbenchmem.txt |awk '{print $NF}'`
   			performance=`grep 'performed:' sysbenchmem.txt |awk -F\( '{print $NF}'|sed 's/)\|[[:space:]]//g'`
   			speed=`grep 'transferred' sysbenchmem.txt |awk -F\( '{print $NF}'|sed 's/)\|[[:space:]]//g'`

			echo "$thread $mode $reqsize $performance $speed  $totaltime  $timemin  $timemax $timeavg"  >> memtemp.txt
			
			done
		done
	done
cat memtemp.txt|column -t > mem.txt
rm -rf memtemp.txt sysbenchmem.txt
