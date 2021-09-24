# Showcases

- [Showcases](#showcases)
  - [1. Introduction](#1-introduction)
  - [2. Applications](#2-applications)
    - [2.1. Arcology Optimized](#21-arcology-optimized)
    - [2.2. Ethereum Original](#22-ethereum-original)
  - [3. Note](#3-note)

## 1. Introduction

There are a few showcase applications that are available on Arcology testnet. These cases are part of the client docker, so you may run the directly without having to install them manually.

## 2. Applications

There showcases have been divided into two categories. Arcology provides a concurrent library for developers to optimized their solidity smart contracts using using Arcology concurency library. Arcology also has mechanism to speed up the execution of the native Solidity smart contracts without using Arcology concurency framework.

### 2.1. Arcology Optimized

 After the optimization, the original smart contracts can be called concurrently without having any concurrency issues. This will dramatically improve the processing efficiency.

- [Parallel Kitties](https://github.com/arcology-network/parallel-kitties/blob/master/parallel-kitties-test-scripts.md)
- [Parallel Dstoken](https://github.com/arcology-network/parallel-dstoken/blob/master/parallel-dstoken-test-scripts.md)
- [Parallel Coin Transfer](https://github.com/arcology-network/benchmarking/parallel-coin-transfer.md)

### 2.2. Ethereum Original

 No changes have been made to the ones under Ethereum Original. You can download the project source code from their project repositories directly and then deploy them on Arcology using **[tools](https://github.com/arcology-network/ammolite)** where are already included in the **[Arcology client container.](./ammolite-client-docker.md)**

- [Uniswap v2](https://github.com/arcology-network/uniswap-testing/blob/master/uniswap-v2-test-scripts.md)

## 3. Note

Please wait for one script to complete before starting the next one. The best way to tell is by looking at the number of transactions contained in the lastest block. The system has processed all transactions once it drops to zero.