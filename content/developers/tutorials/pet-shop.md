# Pet Shop
- [Pet Shop](#pet-shop)
  - [1. Introduction](#1-introduction)
    - [1.2. Monaco](#12-monaco)
    - [1.3. Comparison Chart](#13-comparison-chart)
  - [**2. How to Run**](#2-how-to-run)
    - [2.1. Installation](#21-installation)
  - [3. Accounts](#3-accounts)

## 1. Introduction
There is a tutorial example in Truffle development document that you can find here https://trufflesuite.com/tutorial/index.html. The example walks you through the steps for building an Ethereum DApp.

### 1.2. Monaco
The only difference is that Arcology uses its own blockchain call Monaco AOI in place of [Ganache](https://trufflesuite.com/ganache/). Run the command below to download and start the test network docker container

```sh
docker run --name allinone-cluster -p 8080:8080 -p 7545:7545 -d cody0yang/cluster:1.13 /root/dstart.sh chainID:100 rpcPort:7545
```

### 1.3. Comparison Chart

|Platform|Development|Wallet|Environment|
|---|---|---|---|
|Ethereum|Truffle|MetaMask|Ganache|
|Arcology|Truffle|MetaMask|`Monaco`|

## **2. How to Run**
Just follow steps in the tutorial. **You can run the example on Arcology network directly.** There is no need to change anything to the smart contracts or the backend code.

### 2.1. Installation
* [Start AOI Docker Container](../testnet/testnet-docker-allinone.md)
* [Install Truffle Suite](https://trufflesuite.com/docs/truffle/getting-started/installation.html)
* [Install MetaMask](https://metamask.io/)
* [Run the tutorial example](https://trufflesuite.com/tutorial/index.html)

**When running the example, please make sure you are connected the AOI docker and use the accounts listed below.**

## 3. Accounts
[There are a list of pre-created accounts](./accounts.md) in the docker container with sufficient balanace that developers and can use to initiate transactions instead.

> In case you need to log in to the AIO docker container, please use the credential in [this document](../../getting-started/connect-).
>Don't change anything in the container unless you know what you are doing.

