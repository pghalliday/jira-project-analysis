#!/bin/bash

DEV_OVERRIDES=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/dev-overrides.sh

if [ -f $DEV_OVERRIDES ];
then
  . $DEV_OVERRIDES
  echo "Applying overrides: GID: $USER_GID: UID: $USER_UID"
  groupadd -r -g $USER_GID $1
  useradd -r -m -g $1 -u $USER_UID $1
else
  useradd -r -m $1
fi
echo $(id $1)
