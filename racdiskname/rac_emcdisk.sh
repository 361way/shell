#!/bin/bash
# author : write by yangbk < www.361way.com  >
# mail : itybku@139.com
# desc : gen file of change disk name

function emcmod(){

    while read line;do
        v1=`echo $line|awk '{print $'$1'}' ` 
        v2=`echo $line|awk '{print $'$2'}'`

        #echo $v1 $v2

        pre=${v2:8:1}
        suf=${v2:8:2}
        nv=emcpower${pre}${suf}

        if [ $v1 != $v2 ];then
            echo "emcpadm renamepseudo –s $v2 –t $nv"
        fi
    done < join.txt
}

function emcmod2(){

    while read line;do
        v1=`echo $line|awk '{print $'$1'}' ` 
        v2=`echo $line|awk '{print $'$2'}'`

        #echo $v1 $v2

        pre=${v2:8:1}
        suf=${v2:8:2}
        nv=emcpower${pre}${suf}

        if [ $v1 != $v2 ];then
            echo "emcpadm renamepseudo –s $nv –t $v1"
        fi
    done < join.txt
}

#result2=$(emcmod 2 3)
#echo $result2

echo '--------------------------------------'
echo '--------------------------------------'
emcmod 2 3
echo
echo '--------------------------------------'
emcmod2 2 3

echo -e "\n\n\n"
echo '--------------------------------------'
echo '--------------------------------------'
emcmod 2 4
echo
echo '--------------------------------------'
emcmod2 2 4
