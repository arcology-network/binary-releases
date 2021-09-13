# All in One Installation Guide (v1.1.0)

- [All in One Installation Guide (v1.1.0)](#all-in-one-installation-guide-v110)
  - [1. Getting Started](#1-getting-started)
  - [2. Download the Node Docker](#2-download-the-node-docker)
  - [3. Start the Node Docker](#3-start-the-node-docker)
  - [4. Download the Client Docker](#4-download-the-client-docker)
    - [4.1. Download the Transaction Data](#41-download-the-transaction-data)
    - [4.2. Start the Client Docker](#42-start-the-client-docker)
    - [4.3 Log in to the Client Docker](#43-log-in-to-the-client-docker)
  - [5. Uniswap Showcase](#5-uniswap-showcase)
    - [5.1. Deploy the Contracts](#51-deploy-the-contracts)
    - [5.2. Initialize the First Token](#52-initialize-the-first-token)
    - [5.3. Initialize the Second Token](#53-initialize-the-second-token)
    - [5.4. Approve the First Token](#54-approve-the-first-token)
    - [5.5. Approve the Second Token](#55-approve-the-second-token)
    - [5.6. Add to the Liquidity Pool](#56-add-to-the-liquidity-pool)
    - [5.7. Start Swap Tokens](#57-start-swap-tokens)


## 1. Getting Started

The package has virtually everything you need to start using Acology.It is the easiest way to set up an Arcology testnet. THe docker engine is probably the only thing you will need other than the docker images. There are three major components.

- A Node Docker image
- A Client Docker image
- Some Pregenerated transaction files

![alt text](./img/testnet/docker-relationship.svg)


## 2. Download the Node Docker

```sh
sudo docker pull cody0yang/cluster:latest
```

## 3. Start the Node Docker

```sh
sudo docker run --name allinone-cluster -p 8080:8080 -d cody0yang/cluster:latest /root/dstart.sh
```

## 4. Download the Client Docker

```sh
sudo docker pull cody0yang/ammolite:latest
```

### 4.1. Download the Transaction Data

You may download the transaction data file from [here](./data/pregen_tx.tar). Uncompress the data files into a local folder, you will need to access these files from the client docker container later.

### 4.2. Start the Client Docker

Ammolite is Arcology's network client package written in Python, so can interact with Arcology nodes through HTTP connections. Ammolite to Arcology is like web3.js to Ethereum. You don't to install the package manually as everything is already set up for you in the client docker container.

```sh
docker run --name ammo -p 32768:22 -v <your transaction file folder>:/root/data  -d cody0yang/ammolite /usr/sbin/sshd  -D
```

### 4.3 Log in to the Client Docker

You can log in to the docker contain with the credential below.

- Username: **root**
- Password: **frY6CvAy8c9E**

The testnet should be ready at this point. 

## 5. Uniswap Showcase

In the client docker container the following commands to test the all-in-one testnet. **Please replace the IP address http://192.168.1.103 below with the IP of your own Node Docker.**

### 5.1. Deploy the Contracts

```sh
cd uniswap
python deploy.py http://192.168.1.103:8080 134aea740081ac7e0e892ff8e5d0a763ec400fcd34bae70bcfe6dae3aceeb7f0
```

### 5.2. Initialize the First Token

```sh
python sendtxs.py http://192.168.1.103:8080 data/uniswap_v2/token1_mint_200.out
```

### 5.3. Initialize the Second Token

```sh
python sendtxs.py http://192.168.1.103:8080 data/uniswap_v2/token2_mint_200.out
```

### 5.4. Approve the First Token

```sh
python sendtxs.py http://192.168.1.103:8080 data/uniswap_v2/token1_approve_200.out
```

### 5.5. Approve the Second Token

```sh
python sendtxs.py http://192.168.1.103:8080 data/uniswap_v2/token2_approve_200.out
```

### 5.6. Add to the Liquidity Pool

```sh
python sendtxs.py http://192.168.1.103:8080 data/uniswap_v2/add_liquidity_200.out
```

### 5.7. Start Swap Tokens

```sh
python sendtxs.py http://192.168.1.103:8080 data/uniswap_v2/swap_200.out
```