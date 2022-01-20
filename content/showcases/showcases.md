# Showcases

- [Showcases](#showcases)
  - [1. Introduction](#1-introduction)
  - [2. Applications](#2-applications)
    - [2.1. NTF](#21-ntf)
    - [2.2. Others](#22-others)
    - [2.3. Ethereum Original](#23-ethereum-original)

## 1. Introduction

There are a few showcase applications that are available on Arcology testnet. These cases are part of the client docker, so you may run the directly without having to install them manually.

## 2. Applications

There showcases have been divided into two categories. Arcology provides a concurrent library for developers to optimized their solidity smart contracts using using Arcology concurency library. Arcology also has mechanism to speed up the execution of the native Solidity smart contracts without using Arcology concurency framework.

### 2.1. NTF

NFT applications make a sizeable proportion of popular DApps today. NFT applications aren’t something brand-new, the first well-know NFT game is CryptoKitties. First launched in 2017, CryptoKitties is still the largest nonfinancial DApp on Ethereum. It was so popular that caused serious network congestion on Ethereum blockchain soon after its launch.  

The solution is also general purpose, it works with arbitrary smart contract logics. We parallelized the famous CryptoKitties and achieved some astonishing results.
- [Parallelized CryptoKitties](https://github.com/arcology-network/parallel-kitties)

### 2.2. Others

 Using Arcology tools to the optimize existing smart contracts, the original ones can be called simultaneously without having any concurrency issues. This will dramatically improve the processing efficiency.

- [Parallel Dstoken](https://github.com/arcology-network/parallel-dstoken/blob/master/parallel-dstoken-test-scripts.md)
- [Parallel Coin Transfer](https://github.com/arcology-network/benchmarking/parallel-coin-transfer.md)

### 2.3. Ethereum Original

No changes have been made to the ones under Ethereum Original. You can download the project source code from their project repositories directly and then deploy them on Arcology using stand Ethereum tool chains.

- [Uniswap v2](https://github.com/arcology-network/uniswap-testing/blob/master/uniswap-v2-test-scripts.md)