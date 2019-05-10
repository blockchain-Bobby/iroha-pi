#!/bin/bash

#
# Copyright (c) 2017-2019 Takeshi Yonezu
# All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

if [ "$(uname -m)" = "armv7l" ]; then
  PROJECT=arm32v7
elif [ "$(uname -m)" = "aarch64" ]; then
  PROJECT=arm64v8
else
  PROJECT=hyperledger
fi

docker run -t --rm --name iroha-pi -v $(pwd):/opt/iroha/config \
  ${PROJECT}/iroha-pi bash -c "cd /opt/iroha/config; \
    /opt/iroha/bin/iroha-cli --new_account --account_name node0 \
      --pass_phrase magicseed0; \
    /opt/iroha/bin/iroha-cli --new_account --account_name node1 \
      --pass_phrase magicseed1; \
    /opt/iroha/bin/iroha-cli --new_account --account_name node2 \
      --pass_phrase magicseed2; \
    /opt/iroha/bin/iroha-cli --new_account --account_name node3 \
      --pass_phrase magicseed3 \
    /opt/iroha/bin/iroha-cli --new_account --account_name node4 \
      --pass_phrase magicseed4 \
  "

exit 0
