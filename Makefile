#!/usr/bin/make -f

PACKAGES_SIMTEST=$(shell go list ./... | grep '/simulation')
VERSION := $(shell echo $(shell git describe --tags) | sed 's/^v//')
COMMIT := $(shell git log -1 --format='%H')
LEDGER_ENABLED ?= true
SDK_PACK := $(shell go list -m github.com/infinitefuturechain/infinitefuture-sdk | sed  's/ /\@/g')

export GO111MODULE = on

# process build tags

build_tags = netgo
ifeq ($(LEDGER_ENABLED),true)
  ifeq ($(OS),Windows_NT)
    GCCEXE = $(shell where gcc.exe 2> NUL)
    ifeq ($(GCCEXE),)
      $(error gcc.exe not installed for ledger support, please install or set LEDGER_ENABLED=false)
    else
      build_tags += ledger
    endif
  else
    UNAME_S = $(shell uname -s)
    ifeq ($(UNAME_S),OpenBSD)
      $(warning OpenBSD detected, disabling ledger support (https://github.com/cosmos/cosmos-sdk/issues/1988))
    else
      GCC = $(shell command -v gcc 2> /dev/null)
      ifeq ($(GCC),)
        $(error gcc not installed for ledger support, please install or set LEDGER_ENABLED=false)
      else
        build_tags += ledger
      endif
    endif
  endif
endif

ifeq ($(WITH_CLEVELDB),yes)
  build_tags += gcc
endif
build_tags += $(BUILD_TAGS)
build_tags := $(strip $(build_tags))

whitespace :=
whitespace += $(whitespace)
comma := ,
build_tags_comma_sep := $(subst $(whitespace),$(comma),$(build_tags))

# process linker flags

ldflags = -X github.com/cosmos/cosmos-sdk/version.Name=infinitefuture \
		  -X github.com/cosmos/cosmos-sdk/version.ServerName=infinitefutured \
		  -X github.com/cosmos/cosmos-sdk/version.ClientName=infinitefuturecli \
		  -X github.com/cosmos/cosmos-sdk/version.Version=$(VERSION) \
		  -X github.com/cosmos/cosmos-sdk/version.Commit=$(COMMIT) \
		  -X "github.com/cosmos/cosmos-sdk/version.BuildTags=$(build_tags_comma_sep)"

ifeq ($(WITH_CLEVELDB),yes)
  ldflags += -X github.com/cosmos/cosmos-sdk/types.DBBackend=cleveldb
endif
ldflags += $(LDFLAGS)
ldflags := $(strip $(ldflags))

BUILD_FLAGS := -tags "$(build_tags)" -ldflags '-s -w $(ldflags)'

# The below include contains the tools target.
include contrib/devtools/Makefile

all: install lint check

build: go.sum
ifeq ($(OS),Windows_NT)
	go build -mod=readonly $(BUILD_FLAGS) -o build/infinitefutured.exe ./cmd/infinitefutured
	go build -mod=readonly $(BUILD_FLAGS) -o build/infinitefuturecli.exe ./cmd/infinitefuturecli
else
	go build -mod=readonly $(BUILD_FLAGS) -o build/infinitefutured ./cmd/infinitefutured
	go build -mod=readonly $(BUILD_FLAGS) -o build/infinitefuturecli ./cmd/infinitefuturecli
endif

build-linux: go.sum
	LEDGER_ENABLED=false GOOS=linux GOARCH=amd64 $(MAKE) build

build-contract-tests-hooks:
ifeq ($(OS),Windows_NT)
	go build -mod=readonly $(BUILD_FLAGS) -o build/contract_tests.exe ./cmd/contract_tests
else
	go build -mod=readonly $(BUILD_FLAGS) -o build/contract_tests ./cmd/contract_tests
endif

install: go.sum
	go install -mod=readonly $(BUILD_FLAGS) ./cmd/infinitefutured
	go install -mod=readonly $(BUILD_FLAGS) ./cmd/infinitefuturecli

install-debug: go.sum
	go install -mod=readonly $(BUILD_FLAGS) ./cmd/infinitefuturedebug

########################################
### Tools & dependencies

go-mod-cache: go.sum
	@echo "--> Download go modules to local cache"
	@go mod download

go.sum: go.mod
	@echo "--> Ensure dependencies have not been modified"
	@go mod verify

draw-deps:
	@# requires brew install graphviz or apt-get install graphviz
	go get github.com/RobotsAndPencils/goviz
	@goviz -i ./cmd/infinitefutured -d 2 | dot -Tpng -o dependency-graph.png

clean:
	rm -rf snapcraft-local.yaml build/

distclean: clean
	rm -rf vendor/

########################################
### Testing


test: test-unit test-build
test-all: check test-race test-cover

test-unit:
	@VERSION=$(VERSION) go test -mod=readonly -tags='ledger test_ledger_mock' ./...

test-race:
	@VERSION=$(VERSION) go test -mod=readonly -race -tags='ledger test_ledger_mock' ./...

test-cover:
	@go test -mod=readonly -timeout 30m -race -coverprofile=coverage.txt -covermode=atomic -tags='ledger test_ledger_mock' ./...

test-build: build
	@go test -mod=readonly -p 4 `go list ./cli_test/...` -tags=cli_test -v


lint: golangci-lint
	golangci-lint run
	find . -name '*.go' -type f -not -path "./vendor*" -not -path "*.git*" | xargs gofmt -d -s
	go mod verify

format:
	find . -name '*.go' -type f -not -path "./vendor*" -not -path "*.git*" -not -path "./client/lcd/statik/statik.go" | xargs gofmt -w -s
	find . -name '*.go' -type f -not -path "./vendor*" -not -path "*.git*" -not -path "./client/lcd/statik/statik.go" | xargs misspell -w
	find . -name '*.go' -type f -not -path "./vendor*" -not -path "*.git*" -not -path "./client/lcd/statik/statik.go" | xargs goimports -w -local github.com/cosmos/cosmos-sdk

benchmark:
	@go test -mod=readonly -bench=. ./...


########################################
### Local validator nodes using docker and docker-compose

build-docker-infinitefuturednode:
	$(MAKE) -C networks/local

# Run a 4-node testnet locally
localnet-start: build-linux localnet-stop
	@if ! [ -f build/node0/infinitefutured/config/genesis.json ]; then docker run --rm -v $(CURDIR)/build:/infinitefutured:Z tendermint/infinitefuturednode testnet --v 4 -o . --starting-ip-address 192.168.10.2 ; fi
	docker-compose up -d

# Stop testnet
localnet-stop:
	docker-compose down

setup-contract-tests-data:
	echo 'Prepare data for the contract tests'
	rm -rf /tmp/contract_tests ; \
	mkdir /tmp/contract_tests ; \
	cp "${GOPATH}/pkg/mod/${SDK_PACK}/client/lcd/swagger-ui/swagger.yaml" /tmp/contract_tests/swagger.yaml ; \
	./build/infinitefutured init --home /tmp/contract_tests/.infinitefutured --chain-id lcd contract-tests ; \
	tar -xzf lcd_test/testdata/state.tar.gz -C /tmp/contract_tests/

start-infinitefuture: setup-contract-tests-data
	./build/infinitefutured --home /tmp/contract_tests/.infinitefutured start &
	@sleep 2s

setup-transactions: start-infinitefuture
	@bash ./lcd_test/testdata/setup.sh

run-lcd-contract-tests:
	@echo "Running Infinitefuture LCD for contract tests"
	./build/infinitefuturecli rest-server --laddr tcp://0.0.0.0:8080 --home /tmp/contract_tests/.infinitefuturecli --node http://localhost:26657 --chain-id lcd --trust-node true

contract-tests: setup-transactions
	@echo "Running Infinitefuture LCD for contract tests"
	dredd && pkill infinitefutured

# include simulations
include sims.mk

.PHONY: all build-linux install install-debug \
	go-mod-cache draw-deps clean build \
	setup-transactions setup-contract-tests-data start-infinitefuture run-lcd-contract-tests contract-tests \
	test test-all test-build test-cover test-unit test-race
