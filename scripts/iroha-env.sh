#!/bin/bash
#
# Copyright (c) 2019 Takeshi Yonezu
# All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

case $(uname -m) in
  x86_64)  IROHA_ARC=hyperledger;;
  armv7l)  IROHA_ARC=arm32v7;;
  aarch64) IROHA_ARC=arm64v8;;
  *) echo "This platform \"$(uname -s)/$(uname -m) \" is not supported.";
     exit 1;;
esac

for i in .env example/multi-node/.env example/node4/.env; do
  if [ "$(uname -s)" = "Darwin" ]; then
    sed -i '' "s/IROHA_ARC=.*/IROHA_ARC=${IROHA_ARC}/" ${i}
  else
    sed -i "s/IROHA_ARC=.*/IROHA_ARC=${IROHA_ARC}/" ${i}
  fi
done

echo ">>> Iroha container image set to \"${IROHA_ARC}/$(grep IROHA_IMG .env | sed 's/IROHA_IMG=//')\"."

exit 0
