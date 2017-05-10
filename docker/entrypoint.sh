#!/bin/bash -eu

export PGHOST=${PGHOST-localhost}
export PGPORT=${PGPORT-5432}
export PGUSER=${PGUSER-temboard}
PGPASSWORD=${PGPASSWORD-}
export PGDATABASE=${PGDATABASE-temboard}

echo "Generating temboard.conf" >&2

cat > /etc/temboard/temboard.conf <<EOF
# Generated by $0

[temboard]
home = /var/lib/temboard
address = 0.0.0.0
port = 8888
ssl_cert_file = ${TEMBOARD_SSL_CERT}
ssl_key_file = ${TEMBOARD_SSL_KEY}
ssl_ca_cert_file = ${TEMBOARD_SSL_CA}
cookie_secret = ${TEMBOARD_COOKIE_SECRET}

[repository]
host = ${PGHOST}
port = ${PGPORT}
dbname = ${PGDATABASE}
user = ${PGUSER}
password = ${PGPASSWORD}

[logging]
method = stderr
level = INFO
EOF

wait-for-it ${PGHOST}:${PGPORT}

cat > ~/.pgpass <<EOF
*:*:*:${PGUSER}:${PGPASSWORD}
EOF
chmod 0600 ~/.pgpass

DEV=1 bash /usr/local/share/temboard/create_repository.sh

set -x
exec ${*-temboard}
