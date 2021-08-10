# Uniswap V2
  
- [Uniswap V2](#uniswap-v2)
  - [1. Introduction](#1-introduction)
  - [2. Get the Source Code](#2-get-the-source-code)
    - [2.1 Create A Directory](#21-create-a-directory)
    - [2.2 Check out Uniswap v2 Core](#22-check-out-uniswap-v2-core)
    - [2.3 Check out Uniswap v2 Periphery](#23-check-out-uniswap-v2-periphery)
  - [3. Install Yarn](#3-install-yarn)
    - [3.1 Enable the Official Yarn Repository](#31-enable-the-official-yarn-repository)
    - [3.2. Install Yarn](#32-install-yarn)
  - [4. Compile Uniswap Source Code](#4-compile-uniswap-source-code)
    - [4.1 Install Yarn Dependencies](#41-install-yarn-dependencies)
    - [4.2. Compile Core](#42-compile-core)
    - [4.3. Compile Periphery](#43-compile-periphery)
    - [4.4. Check Files](#44-check-files)
    - [4.4. Copy the Files](#44-copy-the-files)
  - [5. Deployment](#5-deployment)
    - [5.1. Docker Container](#51-docker-container)
    - [5.2 Deploy the Contracts](#52-deploy-the-contracts)
  - [6. Send in Some Transactions](#6-send-in-some-transactions)
    - [6.1. Mint](#61-mint)
    - [6.2. Approve](#62-approve)
    - [6.3. liquidity Pool](#63-liquidity-pool)
    - [6.4. Swap](#64-swap)

## 1. Introduction

This document shows you how to compile, deploy and run [Uniswap V2](https://github.com/Uniswap) on an Arcology testnet.

## 2. Get the Source Code

### 2.1 Create A Directory

```sh
> mkdir tmp
```

### 2.2 Check out Uniswap v2 Core

```sh
> git clone https://github.com/Uniswap/uniswap-v2-core
```

### 2.3 Check out Uniswap v2 Periphery

```sh
> git clone https://github.com/Uniswap/uniswap-v2-periphery
```

## 3. Install Yarn

Yarn is a node.js package manager, please go to https://classic.yarnpkg.com/lang/en/ for more info.

### 3.1 Enable the Official Yarn Repository

```sh
> curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
> echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
```

### 3.2. Install Yarn

Update the package list, and then install Yarn.

```sh
> sudo apt update
> sudo apt install yarn
```

## 4. Compile Uniswap Source Code

### 4.1 Install Yarn Dependencies

Installing all the dependencies of project

```
> yarn
```

### 4.2. Compile Core

Under the uniswap core directory directory  

```sh
> yarn compile
```

![alt text](./img/uniswap/yarn-core-compile.png)

### 4.3. Compile Periphery

Under the uniswap periphery directory directory  

```sh
> yarn compile
```

![alt text](./img/uniswap/yarn-periphery-compile.png)

### 4.4. Check Files

Making sure the following files exist

```sh
> ls -l tmp/uniswap-v2-core/build/UniswapV2Factory.json
> ls -l tmp/uniswap-v2-periphery/build/UniswapV2Router02.json
```

### 4.4. Copy the Files

The installation scripts will automatically install a docker contain on the host machine. The container has all the client tools,
libraries and packages that users will need in order to interact with an Arcology node. The Docker is listen on port 32768 for incoming connections.

You need to copy the compiled contracts into the container, so they can be deployed on the testnet.

```sh
> scp tmp/uniswap-v2-core/build/UniswapV2Factory.json s9-hpis-monaco-testnet@192.168.1.109:/home/s9-hpis-monaco-testnet/txs
> scp tmp/uniswap-v2-core/build/UniswapV2Router02.json s9-hpis-monaco-testnet@192.168.1.109:/home/s9-hpis-monaco-testnet/txs
```

## 5. Deployment

### 5.1. Docker Container

If your host IP is 192.168.1.109 then use the command below to log in to the docker container. Please replace the IP address with yours.

- Username: root
- Password: frY6CvAy8c9E

```sh
> ssh -p 32768 root@192.168.1.109
```

### 5.2 Deploy the Contracts

If the Arcology testnet node's IP address is https://192.168.1.109, In the docker image, run the following command under the root direct to deploy the contracts to the testnet. The port 8080 on a Arcology node is reserved for communications with clients.

```sh
> cd uniswap
> sh deploy.sh http://192.168.1.109:8080 ../data/uniswap_v2/UniswapV2Factory.json ../data/uniswap_v2/UniswapV2Router02.json
```

You should see this if the deployment is successfuly completed.

![alt text](./img/uniswap/uniswap-deployment.png)

## 6. Send in Some Transactions

### 6.1. Mint

Mint the first token

```sh
> python sendtxs.py http://192.168.1.109:8080 ./data/uniswap_v2/token1_mint_200.out
```

![alt text](./img/uniswap/uniswap-token1-mint-200.png)

Mint the second token

```sh
> python sendtxs.py http://192.168.1.109:8080 ./data/uniswap_v2/token2_mint_200.out
```

![alt text](./img/uniswap/uniswap-token2-mint-200.png)

### 6.2. Approve

Approve the first token

```sh
> python sendtxs.py http://192.168.1.109:8080 ./data/uniswap_v2/token1_approve_200.out
```

Approve the second token

```sh
> python sendtxs.py http://192.168.1.109:8080 ./data/uniswap_v2/token2_approve_200.out
```

### 6.3. liquidity Pool

Add some liquidity to the pool

```sh
> python sendtxs.py http://192.168.1.109:8080 ./data/uniswap_v2/add_liquidity_200.out
```

### 6.4. Swap

Swap between two types of tokens

```sh
> python sendtxs.py http://192.168.1.109:8080 ./data/uniswap_v2/swap_200.out
```