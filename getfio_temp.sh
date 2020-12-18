#!/bin/bash
# by yangbaoku  www.361way.com
# This script can get the fusionio card temperature.

fio_time()
{

fio='fioa  fiob fioc'
time=`date +%F\ %T`

>fio_time.txt

for i in $fio ;do
        echo "$time $i" >>fio_time.txt
done
}


while true;do
        sleep 300
        fio_time
        fio-status.bak|grep temper > fio_temp.txt
        paste  fio_time.txt fio_temp.txt >>tempdata_fio
done
