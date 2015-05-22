#!/bin/bash

# generate-config-file.sh
# Author: Michael Stealey <michael.j.stealey@gmail.com>

CONFIG_FILE=$1

echo "IDROP_CONFIG_PRESET_HOST: localhost" > $CONFIG_FILE
echo "IDROP_CONFIG_PRESET_PORT: 1247" >> $CONFIG_FILE
echo "IDROP_CONFIG_PRESET_ZONE: tempZone" >> $CONFIG_FILE
echo "IDROP_CONFIG_PRESET_RESOURCE: demoResc" >> $CONFIG_FILE

exit;