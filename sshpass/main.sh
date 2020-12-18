#!/bin/bash
for host in `cat hosts`;do
	#echo $host mem:
	sshpass -p 'password' scp -o StrictHostKeyChecking=no  mem.sh amos@$host:/tmp/
	sshpass -p 'password' ssh  -o StrictHostKeyChecking=no  amos@$host "sh /tmp/mem.sh"
	sshpass -p 'password' ssh  -o StrictHostKeyChecking=no  amos@$host "rm -rf  /tmp/mem.sh"
done
