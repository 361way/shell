#!/bin/bash
res1=$(printf "%.2f" `echo "scale=2;1/3"|bc`)
res2=$(printf "%.2f" `echo "scale=2;5/3"|bc`)

#v=$(echo $big $small | awk '{ printf "%0.2f\n" ,$1/$2}')
v1=$(echo 1 3 | awk '{ printf "%0.2f\n" ,$1/$2}')
v2=$(echo 5 3 | awk '{ printf "%0.2f\n" ,$1/$2}')


mem1=`echo "scale=2; a=1/3; if (length(a)==scale(a)) print 0;print a "|bc`
mem2=`echo "scale=2; a=5/3; if (length(a)==scale(a)) print 0;print a "|bc`


echo res1 is $res1
echo res2 is $res2
echo v1 is $v1
echo v2 is $v2
echo mem1 is $mem1
echo mem2 is $mem2
