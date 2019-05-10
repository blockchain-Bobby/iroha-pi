# Copyright (c) 2017-2019 Takeshi Yonezu
# All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

FROM ubuntu:16.04

ARG GITLOG="${GITLOG}"
ARG BUILD_DATE="${BUILD_DATE}"
ARG BUILD_NO="${BUILD_NO}"
ARG BUILD_HOST="${BUILD_HOST}"

LABEL GITLOG="${GITLOG}"
LABEL BUILD_DATE="${BUILD_DATE}"
LABEL BUILD_NO="${BUILD_NO}"
LABEL BUILD_HOST="${BUILD_HOST}"

ENV IROHA_HOME=/opt/iroha
ENV LD_LIBRARY_PATH=${IROHA_HOME}/lib
ENV PATH PATH=${PATH}:${IROHA_HOME}/bin

COPY iroha ${IROHA_HOME}

RUN apt update \
 && apt upgrade -y \
 && useradd -ms /bin/bash iroha \
 && mkdir ${IROHA_HOME}/key \
 && chown -R iroha:iroha ${IROHA_HOME}

RUN groupadd -g 998 vboxsf \
 && usermod -aG vboxsf iroha

USER iroha

WORKDIR /opt/iroha/config

COPY entrypoint.sh wait-for-it.sh ${IROHA_HOME}/bin/

ENTRYPOINT ["/opt/iroha/bin/entrypoint.sh"]
