#!/bin/bash  
# code from www.361way.com
  
BASE_DIR=~/javatest 
DBSERVICE_DIR=$BASE_DIR/services/db_service  
SERVER_NAME="db-service"  
PROCESS_NAME="com.dear.simpler.dbrpc.processor.MainProcessor"  
  
JAVA_HOME=/usr/local/jdk  
export JAVA=$JAVA_HOME/bin/java  
#add libs and service to classpath  
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$DBSERVICE_DIR/conf:$(ls $BASE_DIR/environments/libs/java/*.jar | tr '\n' :)$(ls *.jar | tr '\n' :)  
  
LOG_FILE=./db_ctl.log  
  
      
function running(){  
    count=`ps aux | grep java | grep $PROCESS_NAME | grep -v grep | wc -l`  
    if [ $count == 0 ];then  
        return 1  
    else  
        return 0  
    fi  
}  
  
function start_server(){  
    if running; then  
        echo "$SERVER_NAME is running."  
        exit 1  
    fi  
    echo $CLASSPATH >>$LOG_FILE  
    nohup $JAVA com.dear.simpler.dbrpc.processor.MainProcessor 2>&1 >>$LOG_FILE &  
    sleep 3  
    if running; then  
                echo "$SERVER_NAME start success"  
        else  
                echo "$SERVER_NAME start fail"  
    fi  
  
      
}  
  
function stop_server(){  
    if ! running; then  
        echo "$SERVER_NAME is not running."  
        exit 1  
    fi  
    pid=`ps aux | grep java | grep $PROCESS_NAME | grep -v grep | awk {'print$2'}`  
    kill  $pid  
    sleep 3  
    if ! running; then  
        echo "$SERVER_NAME stop success."  
    else  
        kill -9 $pid  
        sleep 3  
        if ! running; then  
            echo "$SERVER_NAME stop success."  
        else  
            echo "$SERVER_NAME stop fail."  
        fi  
    fi  
}  
  
function status(){    
    if running; then    
       echo "$SERVER_NAME is running."    
    else    
       echo "$SERVER_NAME was stopped."      
    fi    
}    
  
function help() {    
    echo "Usage: db_ctl {start|status|stop|restart}" >&2    
    echo "       start:             start the $SERVER_NAME server"    
    echo "       stop:              stop the $SERVER_NAME server"    
    echo "       restart:           restart the $SERVER_NAME server"    
    echo "       status:            get $SERVER_NAME current status,running or stopped."    
}    
  
command=$1  
shift 1  
case $command in  
        start)  
                start_server  
                ;;  
        stop)  
                stop_server  
                ;;  
        status)  
                status  
                ;;  
        restart)  
                $0 stop  
                $0 start  
                ;;  
        help)  
                help  
                ;;  
        *)  
                help  
                exit 1  
                ;;  
esac  

