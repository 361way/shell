#!/bin/bash
# itybku@139.com < www.361way.com >
# desc: get infomation about HP iLO

IP="192.168.1.10"
USER="admin"
PASSWORD="yourpassword"
DESTINATION="./log_directory"
WGET="wget --no-proxy --user=$USER --password=$PASSWORD --no-check-certificate"

cat > /tmp/hpoa.xml << EOF
<?xml version="1.0"?>
  <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:hpoa="hpoa.xsd">
    <SOAP-ENV:Body>
      <hpoa:userLogIn>
        <hpoa:username>$USER</hpoa:username>
        <hpoa:password>$PASSWORD</hpoa:password>
      </hpoa:userLogIn>
    </SOAP-ENV:Body>
  </SOAP-ENV:Envelope>
EOF

OASESSIONKEY=`curl --noproxy '*' --silent --data @/tmp/hpoa.xml --insecure https://$IP/hpoa | sed -n 's@.*<hpoa:oaSessionKey>\(.*\)</hpoa:oaSessionKey>.*@\1@p'`
curl --noproxy '*' --cookie "encLocalKey=$OASESSIONKEY; encLocalUser=$USER" --insecure https://$IP/cgi-bin/showAll -o $DESTINATION/$IP-showAll
curl --noproxy '*' --cookie "encLocalKey=$OASESSIONKEY; encLocalUser=$USER" --insecure https://$IP/cgi-bin/getConfigScript -o $DESTINATION/$IP-getConfigScript

$WGET https://$IP/xmldata?item=all -O $DESTINATION/$IP.xml
