# Arcology Concurrent Programming Guide(v0.8)

- [Arcology Concurrent Programming Guide(v0.8)](#arcology-concurrent-programming-guidev08)
  - [1. Introduction](#1-introduction)
    - [1.1. Requirements](#11-requirements)
    - [1.2. Conventional Concurrency Control](#12-conventional-concurrency-control)
  - [2. Overview](#2-overview)
    - [2.1. Features](#21-features)
    - [2.2. Execution and Conflict](#22-execution-and-conflict)
    - [2.3. Conflict Models](#23-conflict-models)
    - [2.4. Guaranteed State Consistency](#24-guaranteed-state-consistency)
  - [3. Concurrency Tools](#3-concurrency-tools)
    - [3.1. Concurrent Data Structures](#31-concurrent-data-structures)
    - [2.3. Multi-phrase Execution](#23-multi-phrase-execution)
    - [3.3. Commutative Variables](#33-commutative-variables)
  - [4. Counter Examples](#4-counter-examples)
    - [4.1. A simple Counter](#41-a-simple-counter)
    - [4.2. Serial Execution](#42-serial-execution)
    - [4.3. Parallel Execution](#43-parallel-execution)
    - [4.4. Concurrent Counter](#44-concurrent-counter)
  - [5. Code Optimization](#5-code-optimization)
  - [6. Deployment](#6-deployment)
  - [7. Troubleshooting (TBD)](#7-troubleshooting-tbd)

## 1. Introduction

Scalability issue is the single biggest problem that blockchain networks face today. Among many contributing factors, low transaction processing capacity is a major one. Blockchain networks only use single thread to execute transactions. Concurrent programming and parallel computation are effective ways to solve large-scale problems in general.

Arcology supports cluster computation to parallelize transaction execution, the major benefits of this approach are performance and flexibility, computational resources can be added or removed to acommodate the workload. With this design, improving transaction execution is only a matter of adding more resources. In addition, Arcology also provides developers with conventient means to access and utilize the clustered computational power easily.

This document is mainly focused on how to parallelize the existing code or write new applications on Arcology platform from DApp developer’s prospective. It offers some conceptual explanations, code design considerations and some real-world examples. All the examples are in Solidity, as it is the first smart contract language Arcology supports, more language support will be added in the future.

### 1.1. Requirements

The blockchain networks have some unique requirements that need to be properly addressed to make parallel processing possible. On a public blockchain network, all the transactions will be processed by multiple nodes and these nodes need to end up with the same final state. In most blockchain systems with smart contrast support, transactions are initiaized by users in form of independent transactions and eventually executed in VMs. Permissionless blockchain networks are shared by at least throusands of nodes, each node may have very different hardware configuration. It is common that some node clusters may have significantly more cores than others, smart contract developers shouldn't have to explicitly modify their code logics to cope with hardware differences.

### 1.2. Conventional Concurrency Control

Conventional concurrency control mechanisms designed for centralized systems isn't well suited for blockchain networks without some serious rework for a fews reasons.
Usually, in concurrent execution environment, the shared resources can be easily protected using synchronization mechanism like locks. Whenever a transaction needs to access a shared resource, it places a lock on it and only release only when done. The transactions will get the lock in a random order, executing the same set of transactions may result in completely different final states. Therefore this method is non-deterministic, which isn’t a problem for centralized systems. Unfortunately, determinism is a key requirement for majority of permissionless blockchains.

In addition, for most blockchain systems with smart contrast support, transactions are initiaized by users in form of independent transactions and eventually executed in VMs. The concurrency control mechanism needs to work with multiple independent VM instances. There is no such blockchain-native solution existing today.

## 2. Overview

The best way to improve execution efficient is to allow mulitple transactions to execute in mutiple VM instance at the same time. This refers to as parallel transaction processing. Arcology concurrency framework is a specially designed and blockchain-native mechanism to work in combination with Arcology's microservice architecture to achieve maximum performance gain when processing huge volume of transactions. It has ability to orchestrate multiple VM instances working together to process transactions. The framework provides a set of smart contract level concurrent utilities enabling developers to write concurrent code to distribute the workload across all the processing cores avaialbe in a node cluster.

- Deterministic
- VM neural
- High performance
- Flexible
- Easy to use

### 2.1. Features

Arcology concurrency framework solves the problem of concurrent smart contract execution. Multiple calls to the same smart contract can be executed parallelly by multiple VMs on multiple machines, equipping the smart contract processing with ability to scale horizontally. In theory, there is upper limit on how many processsor cores could be added to Arcology network, speedup is only a matter of computational resources available.

In addition to the system architecture that enables intre-node scaling, the framework also offers a set of features working together to help developers to write concurrent code to fully exploit the Arcology's scalabilty advantage. Concurrency Tools are designed to help developers to avoid commonly-encountered conflict siturations. These include:

- [x] Concurrent data structres
- [x] Commucative variables
- [x] Multiphase execution
- [ ] Sychonization primatives

Arcology will support both Pessimistic and Optimistic concurrency control in long term. The tools within the current concurrency framework right now fall under the former in general.

### 2.2. Execution and Conflict

Before diving into programming details, it is worth spending some time understanding how Arcology concurrency framework works briefly. In Arcology,
two transactions are considered to be parallizable as long as they don't update the the same shared states during the execution process. In other words, only one transcaction can modify one shared state in the one concurrent execution process. When multiple transactions are trying to update a shared source, only one transaction execution will succeeded and others will be rolled back for re-execution. The whole the whole process is guaranteed to be deterministic.

For more details, please refer to ![alt text](https://github.com/arcology-network/benchmarking/blob/main/concurrency-framework/images/workflow.svg)

### 2.3. Conflict Models

Arcology concurrency framework determines conflict status based on the following conflict model.

| Operation | Conflict |
|---|---|
| {Read, Read}   |  **&check;** |
| {Read, Write}  |  **&cross;** |
| {Write, Write} |  **&cross;** |
||

In the best scenario, a fully parallelized program with no conflict point can lead to virtually unlimited speedup, it is only a matter of computational resources available. In the worst case, if all the transactions conflict with each, the design will be slower than serial execution. Thus, the key to achieve maximum parallelizability is to avoid conflicts wherever possible.

### 2.4. Guaranteed State Consistency

Deverlopers don't need to worry about concurrency related issues in Arcology. Arcology hides the whole process from contract developers. State consistency is always guaranteed by the system under any circumstance. In stead, they should be focused on producing conflict free code to achieve maximum performance.  

## 3. Concurrency Tools

In real world applications, writting conflict free code could be challenging. The concurrency tools are a set of libraries designed to help developers to avoid commonly-encountered conflict siturations and write conflict free smart contract easily. These tools include:

- Concurrent data structures
- Multi-phase execution
- Commutative variables
- Other tools

In the following sections, we will go through them followed by some simple examples.

### 3.1. Concurrent Data Structures

Concurrent container are specially designed to allow concurrent read and write within a concurrent execution environment. It provides a language neural, fine-grain and much less invasive way for Arcology concurrency framework to work with different types of VMs. Concurrent data structures are different form native data containers like map and array in Solidity. Data within the concurrent containers are handled directly by the Arcology concurrent framework outside VMs.

Many languages have implemented concurrent containers by employing some synchronization mechanisms behind the scenes, but theses containers are not necessarily deterministic. Arcology concurrent containers are strictly deterministic.

Concurrent data structures are deployed at some reserved address:

| Name| Address |Description |
|---|---|---|
| Concurrent Array |0x80 |  Fixed-length array allowing concurrent access |
| Concurrent Map  |0x81|   Hash map, allowing concurrent get/set operation|
| Concurrent Queue  |0x82|  Queue container, allowing concurrent push and sequential pop operation  |
| Concurrent variable  |0x83|  Single variable, concurrent access will be caught by the system  |
| UUID Generator | 0xa0| Unique ID generator, guananteed to be both unique and deterministic |
|Defer Call|0xa1| Inserting a post-processing transaction right after the parallel phase is completed  |
|||

There is no limit on number of concurrent containers declared as long as names are different. A concurrent containers must be declared first before use.

### 2.3. Multi-phrase Execution

Majority of programs have logics that will modify some shared states one way or another. They are composed of a mixture of parallizble and sequential-only logics. Generally, a smart contract must be processed in serial mode as long as it contains some serial-only logic, even if the serial part only accounts for a tiny proportion of the whole program.

Because of the reason above, executing these sequential only transaction in concurrent mode regardlessly will result in a lot of transactions to be rolled back, wasting time and resourece. It is a serious limitation on how widely concurrent execution could apply. To help developers to parallelize complex logics, Arcology provides another very useful concept called multi-phrase Execution. It separates the code into a parallel and serial phase and wrapped them in two set of linked transactions executed in sequential order. This is referred to as multi-phase execution.

![alt text](https://github.com/arcology-network/benchmarking/blob/main/concurrency-framework/images/two-phase-execution.svg)

Conceptionally, the fork/join model shares some similarities with multi-phase execution. In the multi-phase execution model, the parallel logics get executed first, followed by a serial phase called deferred execution. This design can help majority of smart contracts to gain dramatic performance speedup.

For example, a lot of smart contracts relay heavily on counters to maintaining internal logics. Some counters may only accept increments, others can go both up and down. As long as the counter value remains in a predefined range, concurrent counter manipulations are perfect fine. Developer can implement their own concurrent variables with the combination of concurrent container and deferred calls.

### 3.3. Commutative Variables

There are many cases where access to global variables are inevitable. Balance is one of them, on platforms like Ethereum, making a call to a deployed contract or transfer some tokens to another address will always incur some transaction fees to be taken from the caller’s account balance. Another example is when one account taking in payments from multiple users, the recipient's account balance is supposed to be updated after each payment. When processing multiple payments concurrently, the balance becomes is shared by multiple transactions. In this case, only one transaction will pass, the rest are going to be rolled back. Without special treatment, this type of variables will make parallel execution difficult to accomplish.

Arcology has a special variable type named commutative variable. For commutative variables, when applying a series of operations, the final result will always stay the same regardless the order of the operations being applied as long as non of these operations will cause the values to overflow or underflow at any point. Balance is a typical commutarive variable, which can accept two possible operations: debit and credit. In addition, the balance is insensitive to the order in which these debits and credits happen unless it falls below zero. The account balance is a built-in commutative variable that support concurrent debit and credit.

Smart contract developers may define their customized commutative variables using concurrent datastructure in combination with deferred calls.


## 4. Counter Examples

In the examples below, we are going to demonstrate how to use the tools introduced above to solve some problems that smart contract developers are commonly facing. We will analyze some key points and what roles they play in differnt execution models.

Many programs may need counters to count various types of events. One example is to implement a simple counter smart contract that can count number of visits. The smart contract only exposes one interface "Increment()". There is only one variable “counter”, which has an initial value of 0 and for each call to the interface “Increment()”, the counter increases by one.

Assume there were 4 calls to the "VisitCounter" contract. The calls were wrapped in 4 transactions *T0*, *T1*, *T2*, *T3*. The execution order is also *T0*, *T1*, *T2*, *T3*.

### 4.1. A simple Counter

 A simplest counter keeping track of number of calls to the smart contract may look just like this:

```js
pragma solidity ^0.5.0;

contract SequentialCounter {
    uint counter; 
    constructor() public {
      counter = 0;
   }

    function getCounter() public {
        emit CounterQuery(counter);
    }

   function Increment() public {
       // Do something else 
        counter += 1;
   }   
}
```

### 4.2. Serial Execution

This is the execution model used by platforms like Ethereum. The system will start a new instance of VM to process a transaction, every transaction is executed against the states after the previous one. During the execution, the contract retrives the counter value from the state DB and increases it by one, then save it back. The next transction will be able to see the counter value the prevoius just updated.  So, when *T1* reads the counter, the value it sees should be 1, becaues it has been increased by *T0* already. When all 4 transaction gets executed the final counter value is 4.

![alt txt](https://github.com/arcology-network/benchmarking/blob/main/concurrency-framework/images/serial-counter.svg)

The major draw back is the process speed. There is only one VM running to process one transaction at a time. This execution model has some serious performance issue when huge volume of transactions waiting to be processed.

### 4.3. Parallel Execution

Ideally, the system should be able to process all four transactions simultaneously. Sometimes it will require some restructuring of oringal smart contract to make parallelization possible. Executing sequential-only logic regardlessly only deteriorates overall performance.

In we mistakenly process the transactions concurrently, each VM only executes against the initial value of counter, which is 0. At the end of the execution cycle, the conflict detection module will spot that all 4 transactions have updated the the counter, which may result in state inconsistency. Thus, only 1 of 4 transactions will go through, others will be rollback for reprocessing. In any circustanmOnly non-conflicts transactions will be able to commit their state changes. Obvisouly, this type of parallelization only won't produce any performance gain.

![alt text](https://github.com/arcology-network/benchmarking/blob/main/concurrency-framework/images/counter-nonconflict.svg) 

### 4.4. Concurrent Counter

There needs to be a way to parallelize sequential code, at least partically. A Deferred call is a mechanism designed to link the parallel and serial phase logically together. A deferred call enforces a serial execution point after the parallel pharse. The function invoked in the deferred execution phase is called a deferred function. Below is an example using the concurrent queue together with a deferred call to implement a counter.

```Js
pragma solidity ^0.5.0;

import "./ConcurrentLibInterface.sol";

contract CoucurrentCounter {
    ConcurrentQueue constant queue = ConcurrentQueue(0x82);
    System constant system = System(0xa1);

    uint256 counter = 0;
    event CounterQuery(uint256 value);

    constructor() public {
        queue.create("counterUpdates", uint256(ConcurrentLib.DataType.uint256));
        system.createDefer("updateCounter", "updateCounter(string)");
    }

    function increment(uint256 value) public {
        queue.pushuint256("counterUpdates", value);
        system.callDefer("updateCounter");
    }

    function getCounter() public {
        emit CounterQuery(counter);
    }

    function updateCounter(string memory) public {
        uint256 len = queue.size("counterUpdates");
        for (uint256 i = 0; i < len; i++) {
            uint256 changes = queue.popuint256("counterUpdates");
            counter += changes;
        }
    }
}
```

To make the counter concurrently callable, the original code snippet is divided into two parts. The first part is wrapped in the function *“Increment()”*, which can take concurrent user calls and temporarily cache the changes in a concurrent queue for further processing.  The second part is in a deferred function called *“updateCounter()”* for the the post processing.

When the transactions are coming in, multiple VM instances call their own *"Increment()”* concurrently, but the value of *“counter”* remains unchanged in the process. The increments are temporarily stored in a concurrent queue called *"counterUpdates"*. Adding data concurrently to a concurrent queue wouldn’t cause any conflicts.  At the end of the function body, the system generate an internal transaction calling a deferred function *“CountVisits()”*, which means the deferred function *"updateCounter()"* will be invoked when all the transactions calling *"updateCounter()"* have completed. Eventually, the deferred function *"updateCounter()"* with in the system generated transaction will read the queue and add all the temporary increments together to set the final counter value.

![alt text](https://github.com/arcology-network/benchmarking/blob/main/concurrency-framework/images/counter-nonconflict.svg) 

## 5. Code Optimization

The key is to find out which part of the code could be parallelized and which has to be processed in sequential order. There is a case study to parallelized CryptoKittes using Arcology concurrent framework.
 
- [How to parallelize CryptoKitties](https://github.com/arcology-network/benchmarking/blob/main/How-to-Parallelize-CryptoKitties.md)
- [Parallelized Uniswap (TBD)](TBD)

## 6. Deployment

When deploy a contract, developers may specify the maxiumn concurrency allowed, which tells the system how many transactions calling the smart contract can run in parallel. The sytem will set a default concurrency value, in case of the value is absent.

## 7. Troubleshooting (TBD)