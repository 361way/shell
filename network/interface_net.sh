#/bin/bash
# site: www.361way.com   
# mail: itybku@139.com
# Get all interface network flow ,refresh by 2 second define


inet_byte() {
    for i in `ls /sys/class/net/|grep -v bond`; do
        let "$i"_rx"$1"=`cat /sys/class/net/$i/statistics/rx_bytes`
        let "$i"_tx"$1"=`cat /sys/class/net/$i/statistics/tx_bytes`
        #eval echo '$'"$i"_rx"$1"
    done
}

eva() {
    a1=`eval echo '$'"$1"_rx1`
    a2=`eval echo '$'"$1"_rx2`
    b1=`eval echo '$'"$1"_tx1`
    b2=`eval echo '$'"$1"_tx2`
    tol1=$(($a1+$b1))
    tol2=$(($a2+$b2))
    #echo $1 $a1 $a2 $b1 $b2 $tol1 $tol2

    rxkB=$(echo $a2 $a1 | awk '{ printf "%0.2f" ,($1-$2)/1024 }')
    txkB=$(echo $b2 $b1 | awk '{ printf "%0.2f" ,($1-$2)/1024 }')
    TolkB=$(echo $tol2 $tol1 | awk '{ printf "%0.2f" ,($1-$2)/1024 }')
    echo -e "$1\t\t$rxkB\t$txkB\t$TolkB"
}

while true; do
    sleep 2
    clear
    
    awk 'BEGIN {print "interface\trxKB\ttxKB\tTotalKB\n==========================================";}'
    inet_byte 1
    sleep 1
    inet_byte 2
    for i in `ls /sys/class/net/|grep -v bond`; do
        eva $i
        #echo $i $a1 $a2 $b1 $b2 $tol1 $tol2
        #echo  "$i $a $b $c"
    done
done
