#!/bin/bash

#
# Copyright (c) 2017-2019 Takeshi Yonezu
# All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

if [ $# -ge 1 ]; then
  INSTANCE_NO=$1
else
  INSTANCE_NO=${INSTANCE_NO:-4}
fi

if [ "$(uname -m)" = "armv7l" ]; then
  PROJECT=arm32v7
elif [ "$(uname -m)" = "aarch64" ]; then
  PROJECT=arm64v8
else
  PROJECT=hyperledger
fi

docker run -t --rm --name iroha-pi -v $(pwd):/opt/iroha/config \
  ${PROJECT}/iroha-pi bash -c "cd /opt/iroha/config; \
    for i in \$(seq ${INSTANCE_NO}) ; do
      /opt/iroha/bin/iroha-cli --new_account --name node\$((i-1)) \
      --pass_phrase magicseed\$((i-1)); \
    done"

exit 0
