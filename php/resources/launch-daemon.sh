#! /bin/bash

# Wait MySQL
/opt/wait-mysql.sh

runuser -u www-data -- php /var/www/html/bin/console akeneo:batch:job-queue-consumer-daemon --env=prod