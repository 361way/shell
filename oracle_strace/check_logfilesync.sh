sqlplus -s / as sysdba <<EOF
set head off
set echo off
select count(*)  from v\$session where event = 'log file sync';
exit
EOF
