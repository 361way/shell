#/bin/bash
## author: yangbk
## site: www.361way.com
## mail: itybku@139.com
## desc: test loop for in and while 


df -hl|awk 'int($5) >30 ' > testfile
result=`df -hl|awk 'int($5) >30 '`

echo '******************* for testing *****************'
for i in $result;do 
        echo $i
done

echo '******************* while echo test *************'
echo $result | while read line
do
    echo $line
done

echo '****************** while testing ****************'
df -hl|awk 'int($5) >30 '|while read line
do
    echo $IP `hostname` $line 
done 

echo '****************** while read file **************'
while read line
do
    echo $IP `hostname` $line 
done < testfile
