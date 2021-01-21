# Test Suite
The test suite is a package containing ready-developed python scripts to connect to a node cluster, send in simple and complex transactions and observer execution result and key performance information. It is easily enough for users with basic knowledge and some understanding in python and blockchain. The suite has some interactive and batch examples for performance benchmarking.

## What is the test suite
A user guide file and a Linux environment in a docker contains:
   *	Credentials to login into the environment. 
   *	Necessary script files
   *	Pre-generated transaction data files in the docker

The all the scripts files are in the home directory

|File / Directory |    Description|
|---|---|
|accounts.txt                |A csv file contains accounts information that users can test in an interactive environment, the first column is the private key, the second column is the address, the third column contains the initial balances|
|config.yaml                 |A configuration file for deployment scripts used Do not modify|
|contract                    |The source code folder for the Parallelized CryptoKitties|
|data                        |Pre-generated data file for performance benchmarking as generated large transaction data could be a lengthy process|
|deploy_pk.sh                |Deployment script for Parallelized CryptoKitties|
|deploy_v2.py                |A python script file called by deploy_pk.sh                 |
|double_spend_example.py     |An example to demonstrate how the system will detect and stop double spending in parallel mode. |
|send_init_txs.sh            |Initialization script for CryptoKitties. Performance benchmarking, call ./send_init_txs.sh directly|
|send_pk_transfer_txs.sh     |Scripts to  execute PK transfer, can only be used after Initialization|
|send_simple_transfer_txs.sh |Scripts for benchmarking coin transfer between 5M accounts|
|sendtxs.py                  |Loading in pre-generated transaction data and send into to a node cluster|
|simple_pk_example.py        |Interactive script for kitty transfer|
|simple_transfer_example.py  |Script file to test kitty transfer|
|tps.py                      |Python script file used by tps.sh|
|tps.sh                      |TPS observer|
|utils.py                    |Utility functions|    
|checkStatus.py              |Checking cluster status |


---
## Ammolite 
Ammolite is a collection of libraries implemented in Python that helps to interact with a full node through HTTP. Support for IPC or WebSocket will be added in the future. To start Ammolite, just start **python** and then import necessary Ammolite modules.

## API
The Ammolite API document is avaiable here [Ammolite API](https://github.com/arcology-network/documents/blob/main/ammolite-API)

## Login to the Monaco testnet 
SSH into the test node with the credentials provided
* **IP address**: xxx
* **Username**: xxx
* **Password**: xxx

## Check cluster status
```python
python ./checkStatus.py
```

## Start Ammolite
To start Ammolite, just start python and then import necessary Ammolite modules.
```shell
$ python
```

## Interactive examples
   1. [Simple Coin transfer case](https://github.com/arcology-network/documents/blob/main/Simple-Transfer-Example)
   2. [Double spending Prevention case](https://github.com/arcology-network/documents/blob/main/Double-Spend-Example-Prevention)

## Parallelized CryptoKitties 
   1. [What is CryptoKitties](https://en.wikipedia.org/wiki/CryptoKitties)
   2. [How to parallize CryptoKitties](https://github.com/arcology-network/documents/blob/main/Parallel-Kitties)
   3. [CryptoKitties transfer](https://github.com/arcology-network/documents/blob/main/Simple-PK-Example)
   
## Benchmarking
**1. Start the performance observer**
```shell
$ ./tps.sh
```

**2. Deploy ParallelKitties**
```shell
$ ./deploy_pk.sh
```

**3. Initialize test data**
```shell
$ ./send_init_txs.sh
```

**4. Test ParallelKitties' transfer function**
```shell
$ ./send_pk_transfer_txs.sh
```

**5. Test balance transfer between accounts**
```shell
$ ./send_simple_transfer_txs.sh
```

## Troubleshooting

In interactive mode, if you ran the code snippets provided in the documents and got unexpected results, the cause may be complicated. There are a couple of things you can do for a quick fix:
1.  Check if the account you used to sign transactions has enough balance to pay the gas by calling *Cli.getBalance(address)*
2.  Find another account from *~/accounts.txt* and try again.
