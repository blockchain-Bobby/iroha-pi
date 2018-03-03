#!/bin/bash
#
# Copyright Takeshi Yonezu. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

UKERNEL=$(uname -s)
UMACHINE=$(uname -m)

if [ "${UKERNEL}" = "Linux" ]; then
  # Linux/x86_64
  if [ "${UMACHINE}" = "x86_64" ]; then
    NUMCORE=$(grep processor /proc/cpuinfo | wc -l)

    # Intel(R) Atom(TM)
    CPU_MODEL=$(grep "^model name" /proc/cpuinfo |
      sed 1q | sed 's/^model name.*: //' | awk '{ print $1 " " $2 }')

    if [ "${CPU_MODEL}" = "Intel(R) Atom(TM)" ]; then
      if [ ${NUM_CORE} -gt 2 ]; then
        NUM_CORE=2
      fi
    fi
  # Linux/armv7l (Raspberry Pi3)
  elif [ "${UMACHINE}" = "armv7l" ]; then
    NUMCORE=2
  else
    NUMCORE=1
  fi
elif [ "${UKERNEL}" = "Darwin" ]; then
  # MacOS (Intel)
  if [ "${UMACHINE}" = "x86_64" ]; then
    NUMCORE=$(system_profiler SPHardwareDataType | grep Cores |
      sed 's/^.*Cores: //')

    # MacOS (Intel i7 support HyperThreading)
    if [ "$(system_profiler SPHardwareDataType | grep "Processor Name:" |
      sed 's/^.*Name: //')" = "Intel Core i7" ]; then
      NUMCORE=$((NUMCORE*=2))
    fi
  else
    NUMCORE=1
  fi
else
  NUMCORE=1
fi

echo ${NUMCORE}
