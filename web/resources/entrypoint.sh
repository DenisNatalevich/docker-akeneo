#! /bin/bash

set -e

# Variables apache
. /etc/apache2/envvars

# Apache dirs
test -d ${APACHE_RUN_DIR} || mkdir ${APACHE_RUN_DIR}
test -d ${APACHE_LOCK_DIR} || mkdir ${APACHE_LOCK_DIR}
chown ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} ${APACHE_LOCK_DIR}

# Apache gets grumpy about PID files pre-existing
rm -f ${APACHE_PID_FILE}

exec "$@"