#!/usr/bin/env bash
#
# Copyright (c) 2017-2019 Takeshi Yonezu
# All Rights Reserved.
#

cp config/admin_test.priv key/admin@test.priv
cp config/admin_test.pub  key/admin@test.pub
cp config/test_test.priv  key/test@test.priv
cp config/test_test.pub   key/test@test.pub
cp config/alice_test.priv key/alice@test.priv
cp config/alice_test.pub  key/alice@test.pub
cp config/bob_test.priv   key/bob@test.priv
cp config/bob_test.pub    key/bob@test.pub

KEY=$(echo $KEY | cut -d'-' -f2)

IROHA_CONF=${IROHA_CONF:-iroha.conf}
IROHA_NODE=${IROHA_NODE:-node${KEY}}
IROHA_BLOCK=$(cat config/${IROHA_CONF} | grep block_store_path |
  sed -e 's/^.*: "//' -e 's/".*$//')

PG_HOST=$(cat config/${IROHA_CONF} | grep pg_opt | sed -e 's/^.*host=//' -e 's/ .*//')
PG_PORT=$(cat config/${IROHA_CONF} | grep pg_opt | sed -e 's/^.*port=//' -e 's/ .*//')

/opt/iroha/bin/wait-for-it.sh -h ${PG_HOST} -p ${PG_PORT} -t 60 -- true

# Raspberry Pi, Wait until PostgreSQL is stabilized
if [ "$(uname -m)" = "armv7l" ]; then
  sleep 30
fi

echo "$ /opt/iroha/bin/irohad --config config/${IROHA_CONF} --genesis_block config/genesis.block --keypair_name config/${IROHA_NODE}"

/opt/iroha/bin/irohad --config config/${IROHA_CONF} \
  --genesis_block config/genesis.block \
  --keypair_name config/${IROHA_NODE}
