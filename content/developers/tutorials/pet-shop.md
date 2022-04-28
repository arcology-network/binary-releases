# Pet Shop
- [Pet Shop](#pet-shop)
  - [1. Introduction](#1-introduction)
    - [1.1. Example](#11-example)
    - [1.2. Connection Information](#12-connection-information)
  - [2. How to Run](#2-how-to-run)
    - [2.1. Installation](#21-installation)
    - [2.2. Check Connection](#22-check-connection)
    - [2.3. Accounts](#23-accounts)

## 1. Introduction

There is a tutorial example in Truffle development document that you can find here https://trufflesuite.com/tutorial/index.html. The example walks you through the steps for building an Ethereum DApp.

### 1.1. Example

 **You can run the example on Arcology network directly.** There is no need to make any changes to the smart contracts or the backend code.The only difference is that Arcology uses its own blockchain in place of [Ganache](https://trufflesuite.com/ganache/). 

### 1.2. Connection Information

Use the information in this [document](../tutorials/network-info.md) to connect to an Arcology testnet.


|Platform|Development|Wallet|Environment|
|---|---|---|---|
|Ethereum|Truffle|MetaMask|Ganache|
|Arcology|Truffle|MetaMask|`Monaco`|

## 2. How to Run

Simply install the packages listed below and follow steps in the orginal Ethereum tutorial. 

### 2.1. Installation

* [Install Testnet docker image](https://github.com/arcology-network/benchmarking/blob/main/content/getting-started/connect-aio-docker.md)
* [Install MetaMask](https://metamask.io/)
* [Install Truffle Suite](https://trufflesuite.com/docs/truffle/getting-started/installation.html)
* [Run the tutorial example](https://trufflesuite.com/tutorial/index.html)

### 2.2. Check Connection

Before you start, please make sure you are [connected the AOI docker](https://github.com/arcology-network/benchmarking/blob/main/content/getting-started/check-testnet-status.md). 

### 2.3. Accounts

[There are a list of pre-created accounts](./accounts.md)with sufficient balanace in the docker container that you can use to initiate transactions.










