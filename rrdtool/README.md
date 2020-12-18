## RRDtool BASH scripts
These are BASH scripts using RRDtool to generate the following graphs:
* Network interface usage
* Memory usage
* Nginx requests

## Crontab example
You could add this to your user's crontab.
 */5 * * * * /bin/bash /var/scripts/network.sh
 */5 * * * * /bin/bash /var/scripts/memory.sh
 */5 * * * * /bin/bash /var/scripts/requests.sh

## Nginx config example
Enables Nginx's status page
 location /status {
   stub_status on;
   access_log off;
   allow 127.0.0.1;
   deny all;
 }
