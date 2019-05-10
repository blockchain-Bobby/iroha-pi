#---------------------------------------------------------------
# This makefile defines the following targets
#
# - all (default) - buid iroha-build container, and build iroha
# - docker        - build iroha runtime container
# - up            - running iroha container by docker-compose
# - down          - stop and remove iroha container by docker-compose
# - testup        - running iroha for test container by docker-compose
# - test          - exec all test commands
# - logs          - show logs of iroha_node_1 container
# - up4           - running iroha container by docker-compose 4 nodes
# - down4         - stop and remove iroha container by docker-compose 4 ndoes
# - logs4         - show logs of iroha-node[1-4] containers
# - clean         - cleaning protobuf schemas and build directory
# - version       - show labels in container
#
# - iroha-dev     - build iroha-dev container
# - iroha-bld     - build iroha binaries
# - iroha-rel     - extract binaries, libraries from iroha build
# - iroha         - build iroha runtime container
#
# - iroha-up      - running iroha container by docker-compose
# - iroha-down    - stop and remove iroha container by docker-compose
#---------------------------------------------------------------
# Copyright (c) 2017-2019 Takeshi Yonezu
# All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

.PHONY: all help docker up dwon testup test clean version

BUILD_HOME := $(PWD)/../iroha
IROHA_HOME := /opt/iroha
IROHA_IMG := $(shell grep IROHA_IMG .env | cut -d"=" -f2)
COMPOSE_PROJECT_NAME := $(shell grep COMPOSE_PROJECT_NAME .env | cut -d'=' -f2)

BUILD_DATE := $(shell echo "`env LC_ALL=C date`")
BUILD_HOST := $(shell hostname)

ifeq ("$(wildcard $(BUILD_HOME))","")
  $(error $(BUILD_HOME) does'nt exist. Please clone it.)
endif

ifeq ("$(wildcard .buildno)","")
  $(shell echo "1000" >.buildno)
endif

BUILD_NO := $(shell echo "Build `cat .buildno`")

GITLOG := $(shell [ -d $(BUILD_HOME) ] && scripts/iroha-gitlog.sh $(BUILD_HOME))

NUMCORE := $(shell scripts/numcore.sh)

UKERNEL := $(shell uname -s)
UMACHINE := $(shell uname -m)
URELEASE := $(shell uname -r)

ifeq ($(UKERNEL),Linux)
  ifeq ($(UMACHINE),x86_64)
    PROJECT := hyperledger
    DOCKER := Dockerfile
    COMPOSE_TEST := docker-compose-test.yml
  endif
  ifeq ($(UMACHINE),armv7l)
    PROJECT := arm32v7
    DOCKER := Dockerfile
  endif
  ifeq ($(UMACHINE),aarch64)
    PROJECT := arm64v8
    DOCKER := Dockerfile
  endif
endif

ifeq ($(UKERNEL),Darwin)
  PROJECT := hyperledger
  DOCKER := Dockerfile
  COMPOSE_TEST := docker-compose-test.yml
endif

ifeq ($(DOCKER), )
$(error This platform "$(UKERNEL)/$(UMACHINE)" is not supported.)
endif

TESTING := ON

ifeq ($(UKERNEL),Darwin)
  TESTING := OFF
else
  ifneq ($(UMACHINE),x86_64)
    TESTING := OFF
  else
    PRODUCT_NAME := $(shell sudo dmidecode -s system-product-name 2>/dev/null)

    ifeq ($(PRODUCT_NAME),VirtualBox)
      TESTING := OFF
    endif
    ifeq ($(PRODUCT_NAME),)
      TESTING := OFF
    endif
  endif
endif

all: iroha-dev iroha-bld iroha-rel iroha

help:
	@echo "help          - show make targets"
	@echo "all (default) - buid iroha-dev container, and build iroha"
	@echo "docker        - build iroha runtime container"
	@echo "up            - running iroha container by docker-compose"
	@echo "down          - stop and remove iroha container by docker-compose"
ifneq ($(UMACHINE),armv7l)
	@echo "testup        - running iroha for test container by docker-compose"
	@echo "test          - exec all test commands"
endif
	@echo "logs          - show logs of iroha_node_1 container"
	@echo "up4           - running iroha container by docker-compose 4 nodes"
	@echo "down4         - stop and remove iroha container by docker-compose 4 ndoes"
	@echo "logs4         - show logs of iroha-node[1-4] containers"
	@echo "clean         - cleaning protobuf schemas and build directory"
	@echo "version       - show labels in container"

docker: iroha-rel iroha

up: iroha-up

down: iroha-down

ifeq ($(UMACHINE),x86_64)
testup: iroha-testup
endif

iroha-dev:
	cd docker/dev && docker build --rm --build-arg NUMCORE=$(NUMCORE) -t $(PROJECT)/$(IROHA_IMG)-dev .

iroha-bld:
	sudo rsync -av scripts $(BUILD_HOME)
	docker run -t --rm --name iroha-bld -v $(BUILD_HOME):/opt/iroha $(PROJECT)/$(IROHA_IMG)-dev /opt/iroha/scripts/iroha-bld.sh $(NUMCORE) $(TESTING)

iroha-rel:
	docker run -t --rm --name iroha-rel -v $(BUILD_HOME):/opt/iroha -w /opt/iroha $(PROJECT)/$(IROHA_IMG)-dev /opt/iroha/scripts/iroha-rel.sh
	sudo rsync -av ${BUILD_HOME}/docker/iroha docker/rel
	sudo rm -fr ${BUILD_HOME}/docker/iroha

iroha:
	cd docker/rel; docker build --rm --build-arg GITLOG="$(GITLOG)" --build-arg BUILD_DATE="$(BUILD_DATE)" --build-arg BUILD_NO="$(BUILD_NO)" --build-arg BUILD_HOST="$(BUILD_HOST)" -t $(PROJECT)/$(IROHA_IMG) .
	@scripts/build-no.sh

iroha-up:
	docker-compose -p $(COMPOSE_PROJECT_NAME) up -d

iroha-down:
	docker-compose -p $(COMPOSE_PROJECT_NAME) down
	docker volume prune -f

up4:
	@cd example/node4; if ! test -d block_store1; then for i in $$(seq 4); do mkdir block_store$$((i-1)); sudo chown $(id -u):$(id -g) block_store$$((i-1)); done; fi
ifeq ($(UMACHINE),armv7l)
	cd example/node4; COMPOSE_HTTP_TIMEOUT=120 docker-compose -p $(COMPOSE_PROJECT_NAME) up -d
else
	cd example/node4; docker-compose -p $(COMPOSE_PROJECT_NAME) up -d
endif

down4:
	cd example/node4; docker-compose -p $(COMPOSE_PROJECT_NAME) down
	docker volume prune -f

ifeq ($(UMACHINE),x86_64)
iroha-testup:
	docker-compose -p $(COMPOSE_PROJECT_NAME) -f $(COMPOSE_TEST) up -d

test:
	cd scripts && bash iroha-test.sh
endif

logs:
	docker logs -f iroha_node_1

logs4:
	cd example/node4; bash logs4.sh

clean:
	-sudo rm -fr docker/rel/iroha
ifneq ("$(wildcard $(BUILD_HOME)/scripts/numcore.sh)","")
	-sudo rm $(BUILD_HOME)/scripts/iroha*.sh
	-sudo rm $(BUILD_HOME)/scripts/build-no.sh
	-sudo rm $(BUILD_HOME)/scripts/iroha-test.lst
	-sudo rm $(BUILD_HOME)/scripts/numcore.sh
endif
	-sudo rm -fr $(BUILD_HOME)/external
	-sudo rm -fr $(BUILD_HOME)/build
	-sudo rm -fr $(BUILD_HOME)/cmake-build-debug

version:
	docker inspect -f {{.Config.Labels}} $(PROJECT)/$(IROHA_IMG)
