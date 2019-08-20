#!/bin/bash
set -e

COMMANDS="adduser debug fg foreground help kill logreopen logtail reopen_transcript run show status stop wait"
START="console start restart"

#gosu plone python /initialize.py
python /initialize.py
cp -R /data/* /tmp

if [ -e "custom.cfg" ]; then
  if [ ! -e "bin/develop" ]; then
    buildout -c custom.cfg
    #chown -R plone:plone /plone
    #gosu plone python /initialize.py
    python /initialize.py
  fi
fi

# ZEO Server
if [[ "$1" == "zeo"* ]]; then
 # exec gosu plone bin/$1 fg
 exec bin/$1 fg
fi

# Plone instance start
if [[ $START == *"$1"* ]]; then
  # exec gosu plone bin/instance console
  exec bin/instance console
fi

# Plone instance helpers
if [[ $COMMANDS == *"$1"* ]]; then
  #exec gosu plone bin/instance "$@"
  exec bin/instance "$@"
fi

# Custom
exec "$@"
