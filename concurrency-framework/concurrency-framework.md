# Arcology Concurrency Framework (v 0.8)

> Arcology concurrnecy Framework orchestrate parallel blockchain transaction processing across multiple processor cores

- [Arcology Concurrency Framework (v 0.8)](#arcology-concurrency-framework-v-08)
  - [1. Introduction](#1-introduction)
    - [1.1. Issues](#11-issues)
    - [1.2. Overview](#12-overview)
    - [1.3. Features](#13-features)
    - [1.4. Execution and Conflict](#14-execution-and-conflict)
    - [1.5. Conflict Models](#15-conflict-models)
    - [1.6. State Consistency](#16-state-consistency)
  - [2. Concurrency Tools](#2-concurrency-tools)
    - [2.1. Concurrent Data Structures](#21-concurrent-data-structures)
    - [2.3. Multi-phrase Execution](#23-multi-phrase-execution)
    - [2.3. Commutative Variables](#23-commutative-variables)
  - [3. Counter Examples](#3-counter-examples)
    - [3.1. A simple Counter](#31-a-simple-counter)
    - [3.2. Serial Execution](#32-serial-execution)
    - [3.3. Parallel Execution](#33-parallel-execution)
    - [3.4. Concurrent Queue with Deferred calls](#34-concurrent-queue-with-deferred-calls)
  - [5. Code Optimization](#5-code-optimization)
  - [6. Deployment](#6-deployment)
  - [7. Troubleshooting](#7-troubleshooting)

## 1. Introduction

Scalability issue is the single biggest problem that blockchain networks face today. Among many contributing factors, low transaction processing capacity is a major one. Blockchain networks only use single thread to execute transactions. Concurrent programming and parallel computation are effective ways to solve large-scale problems.

Arcology supports cluster computation, the major benefits are performance and flexibility, computational resources can be added or removed to acommodate the workloads. In addition, developer must have conventient means to access and utilize the power easily. 

This document is mainly focused on how to parallelize the existing code or write new application on Arcology platform from DApp developer’s prospective. It also provides some conceptual explanations, design considerations and some real-world examples. All the examples are in Solidity, as it is the first smart contract language Arcology supports, more language support will be added in the future.

### 1.1. Issues

In concurrent execution environment, different users may assess the same shared resources simultaneously. This can be easily handled by using some synchronization mechanism like locks. When ever a thread needs to access a shared resource, it place a lock on it and only release when done. The threads get the lock in a random order, depending on which thread get the lock first. Thus, executing the same set of transactions may result in completely different states, which isn’t a problem for centralized systems.

The blockchain networks have some unique requirements that need to be properly addressed to make parallel processing possible. On a public blockchain network, all the transactions will be processed by multiple nodes and these nodes need to end up with the same final state, which is a part of fundermental design for permissionless networks. Concurrency control mechanisms designed for centralized systems isn't well suited for blockchain networks without some serious rework.

### 1.2. Overview

Arcology concurrency framework is designed to work in combination with Arcology's microservice architecture to achieve maximum performance gain when processing huge volume of transactions. The framework provides a set of smart contract level concurrent utilities enabling developers to write concurrent code to distribute the workload across all the processing cores avaialbe in a node cluster.

Arcology’s concurrency framework is a specially designed and blockchain native mechanism to coordinate the resources allocation, schedule execution and detect conflict detection etc.

- Deterministic
- VM neural
- High performance
- Flexible
- Easy to use

### 1.3. Features

Arcology concurrency framework solves the problem of concurrent smart contract execution. Multiple calls to the same smart contract can be executed parallelly by multiple VMs on multiple machines, equipping the smart contract processing with ability to scale horizontally. In theory, there is upper limit on how many processsor cores could be added to Arcology network, speedup is only a matter of computational resources available.

In addition to the system architecture that enables intre-node scaling, the framework also offers a set of designs working together to help developers write concurrent code to fully exploit the Arcology's scalabilty advantage. Concurrency Tools are designed to help developers to avoid commonly-encountered conflict siturations. These include:

- [x] Concurrent data structres
- [x] Commucative variables
- [x] Multiphase execution
- [ ] Sychonization primatives

Arcology will support both Pessimistic and Optimistic concurrency control in long term. The tools within the current concurrency framework right now fall under the former in general.

### 1.4. Execution and Conflict

Before diving into programming details, it is worth spending some time understanding how Arcology concurrency framework works briefly. In Arcology,
two transactions are considered to be parallizable as long as they don't update the the same shared states during the execution process. In other words, only one transcaction can modify one shared state in the one concurrent execution process. When multiple transactions are trying to update a shared source, only one transaction execution will succeeded and others will be rolled back for re-execution. The whole the whole process is guaranteed to be deterministic.

For more details, please refer to ![alt text](https://github.com/arcology-network/benchmarking/blob/main/concurrency-framework/images/workflow.svg)

### 1.5. Conflict Models

Arcology concurrency framework determines conflict status based on the following the following conflict model.

| Operation | Conflict |
|---|---|
| {Read, Read}   |  **&check;** |
| {Read, Write}  |  **&cross;** |
| {Write, Write} |  **&cross;** |
||

In the best scenario, a fully parallelized program with no conflict point can lead to virtually unlimited speedup, which is only a matter of computational resources available. In the worst case, if all the transactions conflict with each, the design will be slower than serial execution. Thus, in practice, the key to achieve maximum parallelizability is to avoid conflicts wherever possible.

### 1.6. State Consistency

The process decribed above is completely invisible to smart contract developers. Deverlopers don't need to worry about concurrency related issues in Arcology. State consistency is always guaranteed by the system under any circumstance. In stead, they should be focused on should be on producing conflict free code to achieve maximum performance.  

## 2. Concurrency Tools

In real world applications, writting conflict free code could be challenging. The concurrency tools are a set of libraries designed to help developers to avoid commonly-encountered conflict siturations and write conflict free smart contract easily. These tools include:

- Concurrent data structures
- Multi-phase execution
- Commutative variables
- Other tools

In the following sections, we will go through them followed by some simple examples.

### 2.1. Concurrent Data Structures

Concurrent container are specially designed data structures that allow concurrent read and write with in a concurrent execution environment. It provides a language neural, fine-grain and much less invasive way for Arcology concurrency framework to work with different types of VMs.

Concurrent data structures are specifically designed for concurrent use in Arcology. They are different form native data containers like map and array in Solidity. Data within the concurrent containers are handled directly by the concurrent framework. 

Unlike Many languages have implemented concurrent containers by employing some synchronizations behind the scenes to achieve atomicity, but theses containers are not necessarily deterministic. These concurrent contains correspond to Arcology’s synchronized containers except synchronized containers are strictly deterministic.


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

Majority of programs contain logics that would modify some shared states one way or another, which need to be handled in sequntial order. Generally, a smart contract must be processed in serial mode as long as it contains some serial-only logic, even if the serial part only accounts for a tiny proportion of the whole program.

Most programs are composed of a mixture of parallizble and sequential-only logics. Because of the reason above, executing these these programes in concurrent mode will result in a lot of transaction to be rolled back, wasting time and resourece. In the examples below, we are going demonstrate how to restruct the code logic to make concurrent execution possible. It is a serious limitation on how widely concurrent execution could apply.

To help developers to parallelize complex logics, Arcology provides another very useful concept called multi-phrase Execution. It separates the code into a parallel and serial phase and wrapped them in two set of linked transactions executed in sequential order. This is referred to as multi-phase execution. 

![alt text](https://github.com/arcology-network/benchmarking/blob/main/concurrency-framework/images/two-phase-execution.svg)

Conceptionally, the fork/join model shares some similarities with multi-phase execution. In the multi-phase execution model, the parallel logics get executed first, followed by a serial phase called deferred execution. This design can help majority of smart contracts to gain dramatic performance speedup.

For example, a lot of smart contracts relay heavily on counters to maintaining internal logics. Some counters may only accept increments, others can go both up and down. As long as the counter value remains in a predefined range, concurrent counter manipulations are perfect fine. Developer can implement their own concurrent variables with the combination of concurrent container and deferred calls.

### 2.3. Commutative Variables

There are many cases where access to global variables are inevitable. Balance is one of them, for example, on platforms like Ethereum, making a call to a deployed contract or transfer some tokens to another address will always incur some transaction fees to be taken from the caller’s account balance.Without special treatment, this type of variables will make parallel execution difficult to accomplish.

Arcology has a special variable type named commutative variable. For commutative variables, the final result will always stay the same regardless the order of the operations being applied to them as long as non of these operation will cause the values to overflow or underflow at any point.

Balance is a typical commutarive variable, which can accept two possible operations: debit and credit. In addition, the balance is insensitive to the order in which these debits and credits happen unless it falls below zero. A the moment, the account balance is a built-in concurrent variable that support concurrent debit and credit.

## 3. Counter Examples

In the examples below, we are going to demonstrate how to use the concepts and tools introduced above to solve some problems that smart contract developers are commonly facing. We will analyze some important considerations and what will happen in differnt execution modules.

Many programs may need counters to count various types of events. Our task is to implement a simple counter smart contract that can count number of visits. The smart contract only exposes one interface "Increment()". There is only one variable “counter”, which has an initial value of 0 and for each call to the interface “Increment()”, the counter increases by one.

Assume there are 4 calls to the "VisitCounter" contract. The calls are wrapped in 4 transactions *T0*, *T1*, *T2*, *T3*. The execution order is also *T0*, *T1*, *T2*, *T3*.

### 3.1. A simple Counter

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

### 3.2. Serial Execution

The system will start a new instance of VM to process a transaction, every transaction is executed against the states after the previous one. During the execution, the contract retrives the counter value from the state DB and increases it by one, then save it back. The next transction will be able to see the counter value the prevoius just updated.  So, when *T1* reads the counter, the value it sees should be 1, becaues it has been increased by *T0* already. When all 4 transaction gets executed the final counter value is 4.

![alt txt](https://github.com/arcology-network/benchmarking/blob/main/concurrency-framework/images/serial-counter.svg)

The only draw back is the process speed. There is only one VM running to process one transaction at a time. This execution model has serious performance issue when huge volume of transactions waiting to be processed..

### 3.3. Parallel Execution

Ideally, the system should be able to process all four transactions simultaneously. In Arcology, transactions processed in multiple VMs running in total isolation, the modifications made by one is completely invisible to others. In this example, each VM only executes against the initial value of counter, which is 0. At the end of each execution cycle, the conflict detection module will spot that all 4 transactions have updated the the counter, which may result in state inconsistency. Thus, only 1 of 4 transactions will go through, others will be rollback for reprocessing.

![alt text](https://github.com/arcology-network/benchmarking/blob/main/concurrency-framework/images/counter-nonconflict.svg) 

Obvisouly, this type of parallelization only won't produce any performance gain.

### 3.4. Concurrent Queue with Deferred calls

A Deferred call is a mechanism designed to link the parallel and serial phase logically together. A deferred call enforces a serial execution point after the parallel pharse. The function invoked in the deferred execution phase is called a deferred function. Below is an example using the concurrent queue together with a deferred call to implement a counter.

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

When the transactions are coming in, their VM instances call their own *"Increment()”*.  The increments will not take immediate effect after all transactions are executed. The increments are temporarily stored in a queue called *"counterUpdates"*. A post processing step will automatically add all the increments together and set the final counter value.

To make the counter concurrently callable, the original code snippet is divided into two parts. The first part is wrapped in the function *“Increment()”*, which can take concurrent user calls and temporarily cache the changes in a concurrent queue for further processing. Adding data concurrently to a concurrent queue wouldn’t cause any conflicts. The value of *“counter”* remains unchanged in the process. At the end of the function body, the system generate an internal transaction calling a deferred function *“CountVisits()”*. Eventually, the deferred function reads all the temporary increments stored in the queue and add them to the counter.  

![alt text](https://github.com/arcology-network/benchmarking/blob/main/concurrency-framework/images/counter-nonconflict.svg) 

## 5. Code Optimization

The key is to find out which part of the code could be parallelized, which part has to be processed in sequential order. There is a case study to parallelized CryptoKittes using Arcology concurrent framework.

[How to parallelize CryptoKitties](https://github.com/arcology-network/benchmarking/blob/main/How-to-Parallelize-CryptoKitties.md)


## 6. Deployment

When deploy a contract, developers may specify the maxiumn concurrency allowed, which tells the system how many transactions calling the smart contract can run in parallel. The sytem will set a default concurrency value, in case of the value is absent.

## 7. Troubleshooting