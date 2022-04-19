# Benchmarking

- [Benchmarking](#benchmarking)
  - [1. Introduction](#1-introduction)
  - [2. Preparation](#2-preparation)
    - [2.1.Check Testnet Status](#21check-testnet-status)
    - [2.2. Start the Ammolite Container](#22-start-the-ammolite-container)
    - [2.3. Log in to the Ammolite Container Image](#23-log-in-to-the-ammolite-container-image)
  - [3. Deployment Contracts](#3-deployment-contracts)
    - [3.1. deploy parallel_kitties](#31-deploy-parallel_kitties)
    - [3.2. deploy ds_token](#32-deploy-ds_token)
    - [3.3. Deploy uniswap_v2](#33-deploy-uniswap_v2)
  - [4. Send in Transactions](#4-send-in-transactions)
    - [4.1. Send 500k coin_transfer](#41-send-500k-coin_transfer)
    - [4.2. Send 1M parallel_kitties](#42-send-1m-parallel_kitties)
    - [4.3. Send 1M ds_token](#43-send-1m-ds_token)
    - [4.4. Send 600K uniswap_v2](#44-send-600k-uniswap_v2)

## 1. Introduction

This document explains how to run a benchmark test on an Arcology testnet. 

- A live testnet
- [An Ammolite container image](./ammolite-client-docker.md)
- [Transaction data files]()

The transaction data files are pregenerated transactions to facilite the test.They are part of the testnet installers, which need to be downloaded separately from **[here](https://github.com/arcology-network/benchmarking/releases)**

> The client container and Transaction data files are for performance benchmarking only. If you aren't interested in doing benchmarking at this time, simply
> download testnet container only.

## 2. Preparation

Please follow the steps below to get everything ready for the test.

### 2.1.Check Testnet Status

Make sure the testnet is up and running.

```sh
>python checkStatus.py 192.168.1.106:8080
```

> Replace `192.168.1.106` with the Ammolite node that your are connected to

### 2.2. Start the Ammolite Container

The Ammolite docker image has all the pre-generated transaction for the performance.

### 2.3. Log in to the Ammolite Container Image

```sh
>ssh -p 32768 root@localhost
```

> Replace `locahost` with your host IP of the Ammolite container.

- Username: root
- Password: frY6CvAy8c9E


## 3. Deployment Contracts

This first step is to deploy the smart contracts used in the tests.

### 3.1. deploy parallel_kitties

```sh
>cd parallel_kitties
>./deploy.sh http://192.168.1.106:8080
```

### 3.2. deploy ds_token

```sh
>cd ../ds_token
>./deploy.sh http://192.168.1.106:8080
```

### 3.3. Deploy uniswap_v2

```sh
>cd ../data/uniswap
>python deploy.py http://192.168.1.106:8080 134aea740081ac7e0e892ff8e5d0a763ec400fcd34bae70bcfe6dae3aceeb7f0
```

## 4. Send in Transactions

Once the deployment is completed, it is the time to start benchmarking.

### 4.1. Send 500k coin_transfer  

```sh
>cd
>python sendtxs.py http://192.168.1.106:8080 data/simple_transfer/simple_transfer_1m_01.dat
```

### 4.2. Send 1M parallel_kitties

```sh
>python sendtxs.py http://192.168.1.106:8080 data/pk_init_gen0/pk_init_gen0_2m_01.out
>python sendtxs.py http://192.168.1.106:8080 data/pk_kitty_transfer/pk_kitty_transfer_1m_01.dat
```

### 4.3. Send 1M ds_token

```sh
>python sendtxs.py http://192.168.1.106:8080 data/ds_token_mint/ds_token_mint_5m_1m.out
>python sendtxs.py http://192.168.1.106:8080 data/ds_token_transfer/ds_token_transfer_1m_01.out
```

### 4.4. Send 600K uniswap_v2

```sh
>cd data/uniswap
>python sendtxs.py http://192.168.1.106:8080 token1_mint_100k.out
>python sendtxs.py http://192.168.1.106:8080 token2_mint_100k.out
>python sendtxs.py http://192.168.1.106:8080 token1_approve_100k.out
>python sendtxs.py http://192.168.1.106:8080 token2_approve_100k.out
>python sendtxs.py http://192.168.1.106:8080 add_liquidity_100k.out
>python sendtxs.py http://192.168.1.106:8080 swap_100k.out
```
