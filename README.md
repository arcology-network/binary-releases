# Arcology Testnet Guide

- [Arcology Testnet Guide](#arcology-testnet-guide)
  - [1. Introduction](#1-introduction)
    - [1.1. Architecture Overview](#11-architecture-overview)
    - [1.2. Release](#12-release)
    - [1.3. Tools](#13-tools)
  - [2. Getting Started](#2-getting-started)
    - [2.1. Installation Options](#21-installation-options)
    - [2.2. Prerequisites](#22-prerequisites)
  - [3. Arcology Client Container](#3-arcology-client-container)
  - [4. Applications](#4-applications)

## 1. Introduction

The client software consists of multiple network services that can be deployed on multiple machines to achieve optimal performance. The testnet suite is a package containing all the necessary librares, python scripts and binary installers to make deployment and testing process easiler.

The package is designed to facilitate the following tasks:

- Deploy a testnet
- Interact with the testnet

Users with knowledge of python and blockchain should be able to start a testnet and take test runs with little effort.

### 1.1. Architecture Overview

Arcology consists of a number of network services communicating through MQ and RPC. These services can be deployed on multiple machines to achieve better performance. The **[Architecture Overview](./arcology-overview/arcology-overview.md)** gives an overview of the features and design details of the system.

### 1.2. Release

You can find all the releases and installers from **[here](https://github.com/arcology-network/benchmarking/releases)**.

### 1.3. Tools

The **[deployment](https://github.com/arcology-network/deployments)** project contains a set of tools to automate the installation process.

## 2. Getting Started

<u>The easiest to way to start working on Arcology is to use the docker images come with the stardard Arcology releases. Just **[check this out](./testnet-docker-allinone.md)** for more information. You can skip the installation steps if you have decided to the all-in-one docker.</u>

### 2.1. Installation Options

Arcology also offers other testnet setup modes for you to choose. Please read through **[this document](./installation-comparison.md)**, before trying to start a testnet.

### 2.2. Prerequisites

- Ubuntu 20.04
- Docker Engine

## 3. Arcology Client Container

Once the client docker container is successfully connected to a working testnet, you will need a client docker to interact with the Arcology testnet. **[The client docker container has all the necessary module you will need to work with an Arcology testnet.](./ammolite-client-docker.md)**

## 4. Applications

The following Ethereum applications have been tested on Arcology. Please check out the links to learn more

- [Token transfer](https://github.com/arcology-network/parallel-coin-transfer)
- [Parallelized CryptoKitties](https://github.com/arcology-network/parallel-kitties)
- [Parallelized dstoken](https://github.com/arcology-network/parallel-dstoken)
- [Uniswap v2](https://github.com/arcology-network/uniswap-testing)
  

