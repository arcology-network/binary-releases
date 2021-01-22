# Arcology Concurrency Framework

Scalability issue is the single biggest problem that blockchain networks face today. Among many contributing factors, low transaction processing capacity is a major one. Blockchain networks only use single thread to execute transactions.

## 1. Introduction

Concurrent programming and parallel computation are effective ways to solve large-scale problems. Apply the concept on blockchain will help solve the scalability issue.  More computational resources can be added to handle more workloads whenever needed. In addition, majority of programming languages today have some types of concurrent utilities allowing developers write code to utilize multiple threads and to distribute the workload to multiple server relatively easily.

### 1.1 Issues

This is still no blockchain network that allows intra-node concurrent transaction processing. The reason is because that blockchain networks have some unique features that need to be properly addressed to make concurrent processing possible. For example, different users make requests to same resources by runs the same piece of code with different input arguments. Usually this can be easily achieved by using some synchronization mechanism like locks. The threads get the lock is a random order.

Executing a set of transactions in different orders may generate completely different final state, which isn’t a problem for centralized systems.  but in a public blockchain environment,  all the transactions will be processed by multiple nodes and these nodes need to end up with the same final state anyway. Concurrency control mechanisms designed for centralized systems wouldn’t work directly for blockchain networks.

### 1.2. Concurrency Control Framework

For of issues mentioned above, there is a need for a blockchain focused concurrency control mechanism to coordinate the resources allocation, execution scheduling and conflict detection etc.  Arcology’s concurrency control mechanism is specially designed for blockchain with some specific emphasis.

* **Deterministic**
* **Easy to use**
* **VM neural**
* **High performance**
* **Flexible**
  
### 1.3 Document Focuses

This document is mainly focused on how to parallelize the existing code or write new application on Arcology platform from developer’s prospective. It also provides some conceptual explanations of design considerations and Arcology concurrency framework. 
All the examples are in Solidity, as it is the first smart contract language Arcology supports, more language support will be added in the future. 

## 2. Overview

Arcology concurrency framework solves the problem of concurrent smart contract execution. Multiple calls to the same smart contract can be executed parallelly by multiple VMs on multiple machines, equipping the smart contract processing with ability to scale horizontally. In theory, there is upper limit on how much could be added to Arcology network, speedup is only a matter of computational resources available.

### 2.1. Concurrent Execution

At the beginning of the execution cycle,  each concurrent VM will have an independent copy of the state store. Updates to the state will by cached and total invisible to other VM instances during execution.  When all the transactions are executed, records of cached accesses will be put together for the conflict detection. Transactions causing potential conflicts will be reverted afterwards. Generally, a smart contract must be processed in serial mode as long as it contains some serial-only logic, even if the serial part only accounts for a tiny proportion of the whole program.

![alt text](https://github.com/arcology-network/benchmarking/blob/main/concurrency-framework/images/workflow.png)

In the best scenario, a fully parallelized program with no contention point can lead to virtually unlimited speedup, which is only a matter of computational resources available. In the worst case, if all the transactions conflict with each, the design will be slower than serial execution. In practice, the key to achieve maximum parallelizability is to avoid contentions wherever possible.


### 2.2. Concurrency Tools

There are many cases where access to global variables are inevitable.  On platforms like Ethereum, making a call to a deployed contract will always incur some transaction fees to be taken from the caller’s account balance. Another example is some sort of global counters. A lot of smart contract relay heavily on using counters to maintaining internal logics.

In addition to an effective mechanism to prevent potential state conflicts, the framework offers a set of designs working together to help developers write concurrent code with no contention points easily. These include:

* **Concurrent data structures** 
* **Cumulative variables**
* **Multi-phase execution**

## 3. Concurrent data structures

Concurrent container are specially designed data structures that allow concurrent read and write from concurrent VMs. It provides a language neural, fine-grain and much less invasive way for Arcology concurrency framework to work with different types of VMs.

Many languages have implemented concurrent containers by employing some synchronizations behind the scenes to achieve atomicity, but theses containers are not necessarily deterministic. These concurrent contains correspond to Arcology’s synchronized containers except synchronized containers are strictly deterministic.

Concurrent data structures are specifically designed for concurrent user. They are different form native data containers like map and array in Solidity. Data in the containers are explicitly handled by the concurrent framework. Below are two simple examples demonstrating how to optimize code with shared variables to handle concurrent calls. 

### 3.1. Counter Example

Many programs may need for a counter to count various type of events. For example, a simplest counter keeping track of number of calls to the smart contract may look like this:

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

In the contract above,  there is only one variable “counter”, which has an initial value of 0 and for each call to the interface “Visit”, the counter increases by one. This design is fine for serial execution but problematic for executing transactions in concurrent VMs.

For concurrent calls in multiple VMs running in total isolation, the modifications made are invisible to others. Unless there are some synchronization mechanisms, each VM only executes against the initial value of counter, which is zero.  As these are concurrent updates to a shared variable, only one transaction would go through, others would be simply discarded.

![alt text](https://github.com/arcology-network/benchmarking/blob/main/concurrency-framework/images/counter.png)

### 3.2. Counting with Concurrent Variables

With Arcology concurrency control framework, there are multiple ways to implement a concurrent counter or other shared variables.  This simplest way is to declare a variable as cumulative. The example below implemented a concurrent counter through cumulative variable.  First step is to import a library called “ConcurrentLibInterface.sol”. Arcology concurrency framework is deployed at a set of special smart contracts. “0x90” is reserved for Cumulative variables.

Create a counter of type UINT256 and an initial value of 0. Each cumulative variable is identified by a unique variable name. Call interface “Add()” to, the cumulative variable counter is only visible within the contract in which it is declared.  

```js
pragma solidity ^0.5.0;
import "./ConcurrentLibInterface.sol";
contract ConcurrentVisitCounter {
Cumulative constant cumulative = Cumulative(0x90);
    constructor() public {
        cumulative.Create("counter", int32(ConcurrentLib.DataType.UINT256), 0);
    }
    function Visit() public {
    cumulative.AddUint256("counter", 1);
    }   
}
```

When multiple calls come in, all VM instances call their own “Add()”.  The increments will not take immediate effect after calling “Add()” until all transactions are executed. A post processing step will automatically add all the increments together and set the final value.

The code snippet above is pretty self-explanatory. Cumulative variables are good for unconditionally increase or decrease a numeric value. However if some of code logics are dependent on the values of shared variables, cumulative variables are no longer a viable option.

![alt text](https://github.com/arcology-network/benchmarking/blob/main/concurrency-framework/images/counter2.png)

## 4. Multi-phrase execution

Generally, a smart contract must be processed in serial mode as long as it contains some serial-only logic, even if the serial part only accounts for a tiny proportion of the whole program. While simple  parallelization isn’t always achievable. An alternative way is to reconstruct the code to separate the parallel from serial logics and wrapped them in two linked transactions executed in sequential order. This is referred to as multi-phase execution.

![alt text](.\images\two-phase-execution.png)

In a multi-phase execution model, the parallel logics get executed first,  followed by a serial phase called deferred execution. The end state from the parallel phase is cached for serial part to continue the execution.  This design can help majority of smart contracts to gain dramatic performance speedup.


## 4.1 Serial Counter example

Programs usually have logics that could be executed in parallel and those that need to be handled in serial order.  Most programs are mixtures of both. A lot of programs contain logics that would modify some shared values one way or another.  
In the example below, instead of adding an increment to the counter, the counter itself would trigger an action to reset itself every 1024 calls. 

```js
pragma solidity ^0.5.0;
contract VisitCounter {
    uint counter; 
    constructor() public {
      counter = 0;
    }

    function Visit() public {
        if(counter == 1024) {
            counter = 0;
        }
        counter += 1;
    }   
}
```

A simple cumulative variable illustrated in the previous example lacks the ability to handle any customized action in the adding process. The above example couldn’t be called concurrently by simply declaring the counter as cumulative. In many cases, code couldn’t be simply parallelized by replacing some share variables. Parallelizing more complex cases would need more sophisticated tools.

A solution would be using multi-phase execution. To help developers parallelize handling complex logics, Arcology provides another very useful concept called deferred call that link multiple phases together.


## 4.2. Concurrent Queue with Deferred calls

A Deferred call is a mechanism designed to link the parallel and serial phase logically together. A deferred call enforces a serial execution point after parallel execution. A function called in the deferred execution phase is called a deferred function. Below is an example using the concurrent queue together with a deferred call to implement a counter. 

```js
pragma solidity ^0.5.0;
import "./ConcurrentLibInterface.sol";
contract ConcurrentVisitCounter {
uint counter; 
ConcurrentQueue constant queue = ConcurrentQueue(0xa0); // queue manager
    constructor() public {
        counter = 0;
        //system.createDefer("concurrentCounter", "CountVisits(string)");
        queue.create("cache", int32(ConcurrentLib.DataType.UINT256)); // declare a queue
    }

    function Visit() public {
        cache.pushUint256("cache", 1); 
        system.callDefer(CountVisits, "");  
    }

    function CountVisits(string memory callerName) internal {
        uint256 length = queue.size("cache"); // get number of iterations
        for (uint256 n = 0; n < length; n++) {
            if (counter == 1024) {
        counter = 0
            } 
        uint256 delta = queue.popUint256("cache"); // pop from cache
            counter += delta;
        }
    }   
}
```

In the example,  Address “0xa0” is reserved for the concurrent queue containers. There is no limit on number of queues declared as long as names are different. A concurrent containers must be declared first before use.

To make the counter concurrently callable, the original code snippet is divided into two parts. The first part is wrapped in the function “Visit()”, which takes in concurrent user calls and temporarily cache the changes in a concurrent queue for further processing. Adding data concurrently to a concurrent queue wouldn’t cause any conflicts. The value of “counter” remains unchanged in the process. At the end of the function body, a deferred function “CountVisits()” is called, which starts a shared instance of CountVisits() to execute against the state after the concurrent phase.

The second part is the serial phase, the function “CountVisits()” is called to retrieve all intermediate data generated by concurrently executed function “Visit()” and calculate the final counter value. In the serial phase, transactions are executed in sequential order.

[alt text](TBD)

It is a good practice to declare a deferred function as private as a public ones may cause performance issues. The fork/join model conceptually shares some similarities with multi-phase execution.

## 4.3. Code Optimization (TBD)


