#!/bin/bash

DEV_OVERRIDES=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/dev-overrides.sh

cat > $DEV_OVERRIDES << EOF
USER_GID=$(id -g $USER)
USER_UID=$(id -u $USER)
EOF
chmod +x $DEV_OVERRIDES
