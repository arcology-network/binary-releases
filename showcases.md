# Showcases

- [Showcases](#showcases)
  - [1. Introduction](#1-introduction)
  - [2. Applications](#2-applications)
    - [2.1.Arcology Optimized](#21arcology-optimized)
      - [2.1.1. Parallel Kitties](#211-parallel-kitties)
      - [2.1.2. Parallel Dstoken](#212-parallel-dstoken)
      - [2.1.3. Parallel Coin Transfer](#213-parallel-coin-transfer)
    - [Ethereum Original](#ethereum-original)
      - [2.3. Uniswap v2](#23-uniswap-v2)
  - [3. Note](#3-note)

## 1. Introduction

There are a few applications that are available on Arcology testnet. These cases are part of the client docker, so you may run the directly without having to install them manually.


## 2. Applications

Arcology provides a concurrent library for developers to optimized their solidity smart contracts using using Arcology concurency library. After the optimization the original smart contracts can be called concurrently without having any concurrency issues. This will dramatically improve the processing efficiency. The optimization will be platform specific, which mean the developers will have to modify their original smart contracts and after the that their smart contracts will only work on Arcology.

Arcology also has another mechanism to speed up the execution of the native Solidity smart contracts without using Arcology concurency framework. Here the showcase have been devided into two categories. The smart contracts utilized Arcology concurency framework are under Arcology Optimized category. No changes have been made to the ones under Ethereum Original, you can even download the project source code from their project repositories directly and then deploy them on Arcology.

### 2.1.Arcology Optimized

#### 2.1.1. [Parallel Kitties](https://github.com/arcology-network/parallel-kitties/blob/master/parallel-kitties-test-scripts.md)

#### 2.1.2. [Parallel Dstoken](https://github.com/arcology-network/parallel-dstoken/blob/master/parallel-dstoken-test-scripts.md)

#### 2.1.3. Parallel Coin Transfer

```sh
python sendtxs.py http://192.138.1.103:8080 data/coin_transfer/simple_transfer_100.out
```

### Ethereum Original

#### 2.3. [Uniswap v2](https://github.com/arcology-network/uniswap-testing/blob/master/uniswap-v2-test-scripts.md)

## 3. Note

Please wait for one script to complete before starting the next one. The best way to tell is by looking at the number of transactions contained in the lastest block. The system has processed all transactions once it drops to zero(not rising from zero which shows the system is picking up speed.