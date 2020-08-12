# Infinitefuture Public Chain

[![version](https://img.shields.io/github/tag/infinitefuturechain/infinitefuture.svg)](https://github.com/infinitefuturechain/infinitefuture/releases/latest)
[![Go](https://img.shields.io/badge/golang-%3E%3D1.13-green.svg?style=flat-square")](https://golang.org)
[![license](https://img.shields.io/github/license/infinitefuturechain/infinitefuture.svg)](https://github.com/infinitefuturechain/infinitefuture/blob/master/LICENSE)
[![Go Report Card](https://goreportcard.com/badge/github.com/infinitefuturechain/infinitefuture)](https://goreportcard.com/report/github.com/infinitefuturechain/infinitefuture)
[![CircleCI](https://circleci.com/gh/infinitefuturechain/infinitefuture/tree/master.svg?style=shield)](https://circleci.com/gh/infinitefuturechain/infinitefuture/tree/master)

Infinitefuture public chain is new generation digital finance public chain, based on [Infinitefuture-SDK](https://github.com/infinitefuturechain/infinitefuture-sdk) development.

## Required
[Go 1.13+](https://golang.org/dl/)

## Install
Please make sure have already installed `Go` correctly, and set environment variables : `$GOPATH`, `$GOBIN`, `$PATH`.

Put the Infinitefuture project in the specific path，switch to `master` branch，download related dependencies, then make install:
```
mkdir -p $HOME/go/bin
echo "export GOPATH=$HOME/go" >> ~/.bash_profile
echo "export GOBIN=\$GOPATH/bin" >> ~/.bash_profile
echo "export PATH=\$PATH:\$GOBIN" >> ~/.bash_profile
source ~/.bash_profile
```

Check if the installation is successful:
```
$infinitefutured --help
$infinitefuturecli --help
```

## Explorer
[infinitefuture explorer](https://explorer.infinitefuture.com)

## Wallet
[infinitefuture wallet](https://wallet.infinitefuture.com)

## Mainnet
[infinitefuture mainnet](https://github.com/infinitefuturechain/mainnet)
