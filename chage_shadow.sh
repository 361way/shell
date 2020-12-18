#!/bin/sh

SHAWFILE="/etc/shadow"

harder_account_pwd_expire()
{
    echo "***** Starting modify users password expire *****"
    for I in "postgres" "oracle" "sybase"; do
        id "${I}" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
        FIND=`cat ${SHAWFILE} 2>/dev/null |grep "^${I}" |awk -F ':' '{ print $5 }'`
        if [ "${FIND}" = ""  -o  "${FIND}" -lt "180" ] ; then
            # wait for implement...
            chage -M 180 ${I} 2>/dev/null
            return $?
        fi
        fi
    done
}

harder_account_pwd_expire;
