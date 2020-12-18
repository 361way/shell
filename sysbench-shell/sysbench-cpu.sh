#/bin/bash
# code by yangbk  < www.361way.com   itybku@139.com >


threads='16  32  64  128'
reqs='30000  60000'
primes='20000 50000'




echo 'threadsnum reqnum  primenum  totaltime  timemin  timemax timeavg'  > cputemp.txt
for thread in $threads
	do 
	for req in $reqs
		do 
		for prime in $primes
			do 
	                sysbench --num-threads=$thread  --max-requests=$req --cpu-max-prime=$prime --test=cpu  run > sysbenchcpu.txt
			
			totaltime=`grep 'total time:' sysbenchcpu.txt |awk '{print $NF}'`
			timemin=`grep 'min:' sysbenchcpu.txt |awk '{print $NF}'`
			timemax=`grep 'max:' sysbenchcpu.txt |awk '{print $NF}'`
			timeavg=`grep 'avg:' sysbenchcpu.txt |awk '{print $NF}'`
  
			echo "$thread $req  $prime  $totaltime  $timemin  $timemax $timeavg"  >> cputemp.txt
			
			done
		done
	done
cat cputemp.txt|column -t > cpu.txt
rm -rf cputemp.txt sysbenchcpu.txt
