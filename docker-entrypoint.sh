#!/bin/bash
set -e

COMMANDS="adduser debug fg foreground help kill logreopen logtail reopen_transcript run show status stop wait"
START="console start restart"

#su-exec plone python /docker-initialize.py
python /docker-initialize.py


if [ -e "custom.cfg" ]; then
  if [ ! -e "bin/develop" ]; then
    echo custom.cfg
    buildout -c custom.cfg
    #chown -R plone:plone /plone
    #su-exec plone python /docker-initialize.py
    python /docker-initialize.py
  fi
fi

# ZEO Server
if [[ "$1" == "zeo"* ]]; then
  #exec su-exec plone bin/$1 fg
  echo zeo
  exec bin/$1 fg
fi

# Plone instance start
if [[ $START == *"$1"* ]]; then
  #exec su-exec plone bin/instance console
  echo start
  exec bin/instance console
fi

# Plone instance helpers
if [[ $COMMANDS == *"$1"* ]]; then
  #exec su-exec plone bin/instance "$@"
  echo helpers
  exec bin/instance "$@"

fi

# Custom
exec "$@"
