# Arcology Overview

- [Arcology Overview](#arcology-overview)
  - [1. Background](#1-background)
  - [1.1. Solution Overview](#11-solution-overview)
  - [1.1. Parallel Processing](#11-parallel-processing)
  - [2. Sharding/Sidechains](#2-shardingsidechains)
    - [2.1. Example](#21-example)
  - [3. An Ideal Parallel Processing Model](#3-an-ideal-parallel-processing-model)
  - [4. Arcology](#4-arcology)
    - [4.1. Service Architecture](#41-service-architecture)
    - [4.2. Concurrency Framework](#42-concurrency-framework)
  - [5. Self-organizing(Intelligent Sharding)](#5-self-organizingintelligent-sharding)
  - [6. Other Features](#6-other-features)
    - [6.1. Commutative Variables](#61-commutative-variables)
    - [6.2. Heterogeneous VMs](#62-heterogeneous-vms)
    - [6.3. Parallel State DB](#63-parallel-state-db)
    - [6.4. Ethereum API Support](#64-ethereum-api-support)
    - [6.5. Consensus Algorithm](#65-consensus-algorithm)
    - [6.6. Multiple Links](#66-multiple-links)
  - [7. Benchmark](#7-benchmark)
  - [8. Conclusion](#8-conclusion)

## 1. Background

Scalability is the most imperative for the blockchain industry today. Cost is another major factor stops blockchain from mass adoption. Scalability and cost are intertwined issues in many cases and are very complicated. Over the years, we’ve seen many proposals, but few successes. This, we believe, is a result of deeply rooted design problems that haven’t been addressed. 

Arcology is a revolutionary blockchain infrastructure, specially targeting at scalability issue that many blockchain networks are facing today. A truly scalable blockchain infrastructure for the web3.0 era. It is significantly faster, cheaper to use, we believe it is the best blockchain network in the world.

## 1.1. Solution Overview
Lays at the core 

## 1.1. Parallel Processing

Parallel Processing has been proven the most effective way for scalability issues in the centralized world. Over the years, blockchain community has proposed a number of solutions for the scalability issue with very few successes, many of these solutions rely on some type of parallel processing, including sharding, sidechains and rollups.

## 2. Sharding/Sidechains

Currently, virtually all other scaling solutions are built on an assumption that the parallel transaction processing can only happen on semi-independent chains. This concept leads to many sidechain-based designs. In the best case, transactions can be processed by different sidechain in parallel, state data are stored independently.  But in reality, there are some major drawbacks.

These designs only work when sidechain rarely interact with each other. but one sidechain needs to access(read/write) some states stored on another one, things become really messy. Smart contract deployed on different sidechains are hardly composable.

Ever in the best-case scenario, all the sidechains are fully self-contained and there is no inter-chain communication at all, the overall throughput of each sidechain is still limited by the underlaying sequential blockchain architecture. The transactions calling the same smart contracts are still be placed in a serial order.  

### 2.1. Example

For instance, can we build a decentralized Twitter on a blockchain, even that chain is fully dedicated to the application only ?  It will still be way to slow. Sidechain based solutions only address the Inter-chain parallelism. There is no intra-chain parallelism, yet it is critically important for real-world applications.

In the decentralized twitter example, let’s say there were two transactions

- Alice liked a post
- Bob followed another user
  
There two transactions have absolutely nothing to do with each other, so they should be processed in parallel, but it is a totally impossible task with the current blockchain design. No sharding or any sidechain-based solution can help.

## 3. An Ideal Parallel Processing Model

Both inter-chain and intra-chain fall under the category of Parallel Processing and they share a lot of requirements in common. A native blockchain parallel  model should work for both
inter-chain and intra-chain scenarios, at least in principle. Below are some general requirments:

- Having Full parallel processing capability
  - Allowing concurrent calls to contracts as long as they don’t access any share states
  - **Allowing concurrent calls to the same contract (This is especially tricky)**
  - Ability to detect conflicts at runtime, if some states are accessed by more than one contract call unsafely
- Full Composability
- Completely transparent
- Language level support to help developers write concurrent code
  
## 4. Arcology

Arcology meets all the requirement listed above.

### 4.1. Service Architecture

In Arcology, all key modules are abstracted as services and they are inter-connected using message queues. There can be multiple instances of a single service running on different machine, for example, the EVM service. This refers to intra-node horizontal scaling.

In Arcology, a node is no longer a machine with one copy client software installed, user can choose to have a cluster machines working together to share the workload of a single node, something well called node cluster. In fact, there is no theorical limit as to how fast the system can possibly run, the max TPS is only a matter of sources available.

For example, all the transactions (including complex smart contract calls) are processed by multiple VM instances simultaneously on Arcology. These VM instances could either be on the same machine or multiple machines.

![alt text](./img/architecture-diagram.svg)

### 4.2. Concurrency Framework

Coordinating a groups of EVMs to process transactions in parallel is very tricky. **The real problem isn't whether or not multiple transactions can run in parallel. It's whether transactions are going to access some shared states unsafely.** In reality, it is impossible to know if multiple transactions are going to access some shared states in advance, this must be done in the run time.

In addition, if a conflict truly happens then the system must be able to handle it properly. Finally, there has to be a way to help developers to write conflict free code. **The whole process also has to be strictly deterministic.**

There is an underlying mechanism is called Arcology concurrency framework, which has a built-in conflict model and takes care of everything transparently so smart contract developers don’t have to know these details. The framework contains a number of important modules.  

- Adaptor to wrap EVM into an abstract transaction processing machine.
- Execution Scheduler
- Conflict Detection
- Language Level support in native Solidity

## 5. Self-organizing(Intelligent Sharding)

Arcology also has sharding solution called intelligent Sharding, which apply some important insights from the Concurrency framework.

## 6. Other Features
Arcology has a lot of other features.

### 6.1. Commutative Variables
There are some solutions trying to use **UTXO** to achieve some level of parallel processing. In Arcology, UTXO belongs a broader concept
called commutative variable. Another common type of Commutative variable is counter. For example, a visitor counter defined in a contract
is also a commutative variable.

### 6.2. Heterogeneous VMs
Arcology is capable of working with any type of VMs(through VM adaptors), we chose to incorporate EVM into our system first because of it is a de facto stand blockchain VM. It is possible 
to the different types of VM working together.

### 6.3. Parallel State DB
The Ethereum state DB is deeply coupled with the Patricia Merkle tree, which is huge performance bottleneck, Arcology decoupled these two for much better performance. No State explosion problem.

### 6.4. Ethereum API Support
Arcology also supports Ethereum json APIs as well. Ethereum Tools like  MetaMask, Truffle and Remix can work with Arcology seamlessly.

### 6.5. Consensus Algorithm
Arcology uses multifactor PoS consensus algorithm.  

### 6.6. Multiple Links
It is perfectly fine to have multiple p2p instances in a single node cluster to maximize the bandwidth. This feature is extrmemely helpful in the cloud environment.

## 7. Benchmark
There is no theorical limit on how fast the system can go, everything is a matter of resources. The overall throughput increases with the number of cores, 250~ 300 TPS / Core is a fair estimate.
There is a benchmark package containing about 5M transactions calling CryptoKitties, DSToken and Uniswap V2.  The TPS is around 15k ~ 20k on a testnet on AWS.

## 8. Conclusion
Arcology is the choice for large-scale applications like decentralized social network application and it can be a high performance sidechain for Ethereum as well.




