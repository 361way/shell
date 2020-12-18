#!/bin/bash
## author: yangbk
## site: www.361way.com
## mail: itybku@139.com
## desc: read a big file ,test use time for and while 

FILENAME="$1"
TIMEFILE="/tmp/loopfile.out" > $TIMEFILE 
SCRIPT=$(basename $0)

function usage(){
    echo -e "\nUSAGE: $SCRIPT file \n"
    exit 1
}

function while_read_bottm(){
    while read LINE
    do
        echo $LINE
    done < $FILENAME
}

function while_read_line(){
    cat $FILENAME | while read LINE
    do
        echo $LINE
    done
}

function while_read_line_fd(){
    exec 3<&0
    exec 0< $FILENAME
    while read LINE
    do 
        echo $LINE
    done
    exec 0<&3
}

function for_in_file(){
    for i in  `cat $FILENAME`
    do
        echo $i
    done
}

if [ $# -lt 1 ] ; then
    usage
fi
echo -e " \n starting file processing of each method\n"
echo -e "method 1:"
echo -e "function while_read_bottm"
time while_read_bottm >> $TIMEFILE
echo -e "\n"

echo -e "method 2:"
echo -e "function while_read_line "
time while_read_line >> $TIMEFILE

echo -e "\n"
echo -e "method 3:"
echo "function while_read_line_fd"
time while_read_line_fd >>$TIMEFILE

echo -e "\n"
echo -e "method 4:"
echo -e "function  for_in_file"
time  for_in_file >> $TIMEFILE
