# Arcology Concurrency Framework (v 0.8)

> Arcology concurrnecy Framework orchestrate parallel blockchain transaction processing across multiple processor cores
>
- Arcology Concurrency Framework
  - [1. Introduction](#1-introduction)
    - [1.1. Issues](#11-issues)
    - [1.2. Overview](#12-overview)
    - [1.3. Features](#13-features)
    - [1.4. Execution and Conflict](#14-execution-and-conflict)
    - [1.5. Conflict Models](#15-conflict-models)
    - [1.5. State Consistency](#16-state-consistency)
  - [2. Concurrency Tools](#2-concurrency-tools)
    - [2.1. Concurrent Data Structures](#21-concurrent-data-structures)
    - [2.3. Multi-phrase execution](#23-multi-phrase-execution)
    - [2.3 Commutative Variables](#23-commutative-variables)
  - [3. Examples](#3-examples)
    - [3.1. Concurrent Counter](#31-concurrent-counter-example)
    - [3.2. Counting with Concurrent Variables](#32-counting-with-concurrent-variables)
    - [3.3. Serial Counter example](#33-serial-counter-example)
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

In the following sections, we will go through them follwed by some simple examples.

### 2.1. Concurrent Data Structures

Concurrent container are specially designed data structures that allow concurrent read and write with in a concurrent execution environment. It provides a language neural, fine-grain and much less invasive way for Arcology concurrency framework to work with different types of VMs.

Concurrent data structures are specifically designed for concurrent use in Arcology. They are different form native data containers like map and array in Solidity. Data within the concurrent containers are handled directly by the concurrent framework. 

Unlike Many languages have implemented concurrent containers by employing some synchronizations behind the scenes to achieve atomicity, but theses containers are not necessarily deterministic. These concurrent contains correspond to Arcology’s synchronized containers except synchronized containers are strictly deterministic.


| Name| Description |
|---|---|
| Concurrent Array  |  Fixed-length array allowing concurrent access |
| Concurrent Queue  |  Queue container, allowing concurrent push and sequential pop operation  |
| Concurrent Map  |   Hash map, allowing concurrent get/set operation|
| UUID Generator  | Unique ID generator, guananteed to be both unique and deterministic |
||| 

### 2.3. Multi-phrase Execution

Generally, a smart contract must be processed in serial mode as long as it contains some serial-only logic, even if the serial part only accounts for a tiny proportion of the whole program. An alternative way is to reconstruct the code to separate the parallel from serial logics and wrapped them in two linked transactions executed in sequential order. This is referred to as multi-phase execution.

![alt text](https://github.com/arcology-network/benchmarking/blob/main/concurrency-framework/images/two-phase-execution.svg)

In a multi-phase execution model, the parallel logics get executed first, followed by a serial phase called deferred execution. This design can help majority of smart contracts to gain dramatic performance speedup. A common example is a global [counter example](#31-concurrent-counter-example). 

### 2.3 Commutative Variables

There are many cases where access to global variables are inevitable. Balance is one of them, for example, on platforms like Ethereum, making a call to a deployed contract or transfer some tokens to another address will always incur some transaction fees to be taken from the caller’s account balance. Another example is a global counter to count number of calls made to a smart contract, the counter 

 Without special treatment, this type of variables will make parallel execution difficult to accomplish.

Arcology has a special variable type named commutative variable. For commutative variables, the final result will always stay the same regardless the order of the operations be applied to them as long as non of these operation will cause the values to overflow or underflow at any point. 

Balance is a typical commutarive variable, which can accepts two possible operations: debit and credit. In addition, the balance is insensitive to the order in which these debits and credits happen unless it falls below zero. The counters are another example. A lot of smart contracts relay heavily on  counters to maintaining internal logics. Some counters may only accept increments, others can go both up and down. As as as the counter value remains in a predefined range, concurrent counter manipulations are perfect fine.

A the moment, the account balance is a built-in concurrent variable that support concurrent debit and credit.  Developer can implement their own concurrent variables with concurrent container and another tool, called deferred call.


## 3. Examples

Programs usually have logics that could be executed in parallel and those that need to be handled in serial order.  Most programs are mixtures of both. Many programs contain logics that would modify some states one way or another. Executing these these programes in concurrent mode will result in a lot of already executed transaction to be rolled back, wasting time and resourece. In the examples below, we are going demonstrate how to restruct the code logic to make concurrent execution possible.

### 3.1 Counter Example

### 3.1.1. A simple Counter

Many programs may need counters to count various types of events. A simplest counter may only keep track of number of calls to the smart contract may look like this:

```js
pragma solidity ^0.5.0;

contract VisitCounter {
    uint counter; 
    constructor() public {
      counter = 0;
   }

   function Visit() public {
       // Do something else 
        counter += 1;
   }   
}
```

In the contract above, there is only one variable “counter”, which has an initial value of 0 and for each call to the interface “Visit()”, the counter increases by one.

In the examples below, The counter is given an initial value of 0. There are 4 calls to the "VisitCounter" contract. The calls are wrapped in 4 transactions T0, T1, T2, T3, each increases the counter by one. The execution order is T0, T1, T2, T3.

### 3.1.2. Serial Execution

In a sequential execution environmnet, the system will start a new instance of VM to process a transaction, every transaction is executed against the states after the previous one. During the execution, the contract retrives the counter value from the state DB and increases it by one, then save it back. When the next transction will should be able to see the counter value the prevoius just updated.  When T1 reads the counter, the value be get 1, becaues it has been increased by T0 already. Thus, the counter keeps increasingand it always has the correct value.

The only draw back is the process speed. Only one transaction get executed at a time, this execution model has serious performance issue.


### 3.1.2. Parallel Execution 

Ideally, the system should be able to process all four transactions simultaneously.
When execution 



A solution would be using multi-phase execution. To help developers parallelize handling complex logics, Arcology provides another very useful concept called deferred call that link multiple phases together.

#### 3.1.2 Concurrent Version

For concurrent calls in multiple VMs running in total isolation, the modifications made are invisible to others. Unless there are some synchronization mechanisms, each VM only executes against the initial value of counter, which is zero.  As these are concurrent updates to a shared variable, only one transaction would go through, others would be simply discarded.

With Arcology concurrency control framework, there are multiple ways to implement a concurrent counter or other shared variables.  This simplest way is to declare a variable as cumulative. The example below implemented a concurrent counter through cumulative variable.  First step is to import a library called “ConcurrentLibInterface.sol”. Arcology concurrency framework is deployed at a set of special smart contracts. “0x90” is reserved for Cumulative variables.

Create a counter of type UINT256 and an initial value of 0. Each cumulative variable is identified by a unique variable name. Call interface “Add()” to, the cumulative variable counter is only visible within the contract in which it is declared.  

When multiple calls come in, all VM instances call their own “Add()”.  The increments will not take immediate effect after calling “Add()” until all transactions are executed. A post processing step will automatically add all the increments together and set the final value.

The code snippet above is pretty self-explanatory. Cumulative variables are good for unconditionally increase or decrease a numeric value. However if some of code logics are dependent on the values of shared variables, cumulative variables are no longer a viable option.

![alt text](https://github.com/arcology-network/benchmarking/blob/main/concurrency-framework/images/counter-nonconflict.svg)

Create a counter of type UINT256 and an initial value of 0. Each cumulative variable is identified by a unique variable name. Call interface “Add()” to, the cumulative variable counter is only visible within the contract in which it is declared.  


```js
pragma solidity ^0.5.0;

import "./ConcurrentLibInterface.sol";

contract CoucurrentCounter {
    ConcurrentQueue constant queue = ConcurrentQueue(0x82);
    System constant system = System(0xa1);

    uint256 counter = 0;
    event CounterQuery(uint256 value);

    constructor() public {
        queue.create("counterUpdates", uint256(ConcurrentLib.DataType.UINT256));
        system.createDefer("updateCounter", "updateCounter(string)");
    }

    function increase(uint256 value) public {
        queue.pushUint256("counterUpdates", value);
        system.callDefer("updateCounter");
    }

    function getCounter() public {
        emit CounterQuery(counter);
    }

    function updateCounter(string memory) public {
        uint256 len = queue.size("counterUpdates");
        for (uint256 i = 0; i < len; i++) {
            uint256 changes = queue.popUint256("counterUpdates");
            counter += changes;
        }
    }
}
```


![alt text](https://github.com/arcology-network/benchmarking/blob/main/concurrency-framework/images/counter-conflict.svg)








### 3.4. Concurrent Queue with Deferred calls

A Deferred call is a mechanism designed to link the parallel and serial phase logically together. A deferred call enforces a serial execution point after parallel execution. A function called in the deferred execution phase is called a deferred function. Below is an example using the concurrent queue together with a deferred call to implement a counter. 

```Solidity
pragma solidity ^0.5.0;

import "./ConcurrentLibInterface.sol";

contract Defer {
    ConcurrentQueue constant queue = ConcurrentQueue(0x82);
    System constant system = System(0xa1);

    // The variable we want to update in defer function.
    uint256 counter = 0;
    event CounterQuery(uint256 value);

    constructor() public {
        // Declare concurrent queue and defer function.
        queue.create("counterUpdates", uint256(ConcurrentLib.DataType.UINT256));
        system.createDefer("updateCounter", "updateCounter(string)");
    }

    function increase(uint256 value) public {
        // Enqueue the increasing value.
        queue.pushUint256("counterUpdates", value);
        // Call the defer function.
        system.callDefer("updateCounter");
    }

    function getCounter() public {
        emit CounterQuery(counter);
    }

    function updateCounter(string memory) public {
        // Update the counter.
        uint256 len = queue.size("counterUpdates");
        for (uint256 i = 0; i < len; i++) {
            uint256 changes = queue.popUint256("counterUpdates");
            counter += changes;
        }
    }
}
```

In the example,  Address “0xa0” is reserved for the concurrent queue containers. There is no limit on number of queues declared as long as names are different. A concurrent containers must be declared first before use.

To make the counter concurrently callable, the original code snippet is divided into two parts. The first part is wrapped in the function “Visit()”, which takes in concurrent user calls and temporarily cache the changes in a concurrent queue for further processing. Adding data concurrently to a concurrent queue wouldn’t cause any conflicts. The value of “counter” remains unchanged in the process. At the end of the function body, a deferred function “CountVisits()” is called, which starts a shared instance of CountVisits() to execute against the state after the concurrent phase.

The second part is the serial phase, the function “CountVisits()” is called to retrieve all intermediate data generated by concurrently executed function “Visit()” and calculate the final counter value. In the serial phase, transactions are executed in sequential order.

[alt text](TBD)

It is a good practice to declare a deferred function as private as a public ones may cause performance issues. The fork/join model conceptually shares some similarities with multi-phase execution.

## 5. Code Optimization
The key is to find out which part of the code could be parallelized, which part has to be processed in sequential order. 
[How to parallelize CyptroKitties](https://github.com/arcology-network/benchmarking/blob/main/How-to-Parallelize-CryptoKitties.md)



## 6. Deployment
When deploy a contract, developers need to specify the maxiumn concurrency allowed, which tells the system how many transactions calling the smart contract can run in concurrent mode. The sytem will set a default concurrency value in stead,  in case of 

## 7. Troubleshooting