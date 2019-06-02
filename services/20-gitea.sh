#!/bin/bash

set -e

if [ "${DEBUG}" = true ]; then
  set -x
fi

function waitAandInitializeGitea()
{
  sleep 4
  date
  echo "Waiting for Gitea Server to come up ..."

  while read LINE; \
  do \
    if [[ $LINE =~ .*Listen.* ]]; then \
      echo "Gitea Server is up"; \
      break; \
    fi \
  done < <(tail -f /var/log/gitea/gitea.log)

  echo "Configuring Gitea ...."
  export GITEA_WORK_DIR=/var/lib/gitea
  cd /home/git
  /sbin/setuser git /usr/local/bin/gitea admin create-user -c /etc/gitea/app.ini --name root --password ${GITEA_ROOT_PASSWORD} --email ${GITEA_ROOT_EMAIL} --admin
  echo "Configuring Gitea Done"
  date
  exit 0
}

DISABLE_GITEA=${DISABLE_GITEA:-0}

GITEA_DB_TYPE=${GITEA_DB_TYPE:-postgres}
GITEA_DB_HOST=${GITEA_DB_HOST:-${POSTGRESQL_PORT_5432_TCP_ADDR}}
if [ ${GITEA_DB_PORT} =~ ^[-0-9]+$ ]; then
  GITEA_DB_PORT=${POSTGRESQL_PORT}
else
  GITEA_DB_PORT=${POSTGRESQL_PORT_5432_TCP_PORT}
fi
GITEA_DB_NAME=${GITEA_DB_NAME:-$POSTGRESQL_ENV_POSTGRESQL_DATABASE}
GITEA_DB_USER=${GITEA_DB_USER:-$POSTGRESQL_ENV_POSTGRESQL_USERNAME}
GITEA_DB_PASS=${GITEA_DB_PASS:-$POSTGRESQL_ENV_POSTGRESQL_PASSWORD}

GITEA_PROTOCOL=${GITEA_PROTOCOL:-http}
GITEA_DOMAIN=${GITEA_DOMAIN:-localhost}

DEF_GITEA_SMTP_HOST=$(ip route | grep default | awk '{print$3}')
GITEA_SMTP_HOST=${GITEA_SMTP_HOST:-$DEF_GITEA_SMTP_HOST}
GITEA_SMTP_PORT=${GITEA_SMTP_PORT:-25}
GITEA_SMTP_FROM=${GITEA_SMTP_FROM:-gitea@localhost}
GITEA_SMTP_USER=${GITEA_SMTP_USER:-}
GITEA_SMTP_PASS=${GITEA_SMTP_USER:-}

GITEA_REGISTRATION_DISABLE=${GITEA_REGISTRATION_DISABLE:-false}
GITEA_RECAPTCHA_SECRET=${GITEA_RECAPTCHA_SECRET}
GITEA_RECAPTCHA_KEY=${GITEA_RECAPTCHA_KEY}

GITEA_INSTALL_LOCK=${GITEA_INSTALL_LOCK:-false}
GITEA_SECRET_KEY=${GITEA_SECRET_KEY:-}
GITEA_JWT_SECRET=${GITEA_JWT_SECRET:-}

GITEA_ROOT_EMAIL=${GITEA_ROOT_EMAIL:-root@localhost}
GITEA_ROOT_PASSWORD=${GITEA_ROOT_PASSWORD:-Git3aPa55}

GITEA_SMTP_ENABLE=${GITEA_SMTP_HOST:+true}
GITEA_RECAPTCHA_ENABLE=${GITEA_RECAPTCHA_SECRET:+true}

mkdir -p /var/lib/gitea/{custom,data,tmp,static}
mkdir -p /etc/gitea
mkdir -p /var/log/gitea


if [ ! "${DISABLE_GITEA}" -eq 0 ]; then
  touch /etc/service/gitea/down
else
  rm -f /etc/service/gitea/down
fi

if [ -f /etc/gitea/app.ini ]; then
  echo "Gitea config 'app.ini' already exists"
  export GITEA_DB_TYPE GITEA_DB_HOST GITEA_DB_NAME GITEA_DB_USER GITEA_DB_PASS
  export GITEA_SMTP_ENABLE GITEA_SMTP_HOST GITEA_SMTP_PORT GITEA_SMTP_FROM GITEA_SMTP_USER GITEA_SMTP_PASS
  export GITEA_RECAPTCHA_ENABLE GITEA_RECAPTCHA_SECRET GITEA_RECAPTCHA_KEY GITEA_REGISTRATION_DISABLE
  perl -p -i -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' /etc/gitea/app.ini
else
  cp /config/etc/gitea/app.ini /etc/gitea/app.ini
  export GITEA_DB_TYPE GITEA_DB_HOST GITEA_DB_NAME GITEA_DB_USER GITEA_DB_PASS
  export GITEA_PROTOCOL GITEA_DOMAIN 
  export GITEA_SMTP_ENABLE GITEA_SMTP_HOST GITEA_SMTP_PORT GITEA_SMTP_FROM GITEA_SMTP_USER GITEA_SMTP_PASS
  export GITEA_RECAPTCHA_ENABLE GITEA_RECAPTCHA_SECRET GITEA_RECAPTCHA_KEY GITEA_REGISTRATION_DISABLE
  export GITEA_INSTALL_LOCK GITEA_SECRET_KEY
  perl -p -i -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' /etc/gitea/app.ini
 
  #Background the function call
  waitAandInitializeGitea &
fi

mkdir -p /var/lib/gitea/custom/templates

if [ -f /var/lib/gitea/custom/templates/home.tmpl ]; then
  echo "Gitea templates already exists"
else
  cp -r /config/templates/* /var/lib/gitea/custom/templates
fi

chown -R git:git /var/lib/gitea/
chmod -R 750 /var/lib/gitea/
chown -R root:git /etc/gitea
chmod -R 770 /etc/gitea
chown -R root:git /var/log/gitea
chmod -R 770 /var/log/gitea



