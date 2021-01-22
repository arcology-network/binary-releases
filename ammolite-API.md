### Providers

Provider wraps up the interfaces to access the frontend service, support HTTP for now, more will be added in the future.

**ammolite.HTTPProvider(url)**

Manages all the connection with the *url* specified

```Python
>>> import ammolite
>>> provider = ammolite.HTTPProvider('http://192.168.1.111:8080')
```

### Cli

**ammolite.Cli(provider)**

Module to support common user interactions with a node cluster, connected through *provider*
```Python
>>> cli = ammolite.Cli(provider)
```

**Cli.getBlock(height)**

Get block information at a given *height*

```Python
>>> cli.getBlock('latest')
{'height': 52100, 'hash': '0711c9aa21ae6da3d4abd8779fbbfdbcb92262a97d6173973bd8a4c0e4fbe09d', 'coinbase': '0xF97c7082918E26ea7cf00b81784136E22EFDd5a3', 'number': 0, 'transactions': None, 'gasUsed': 0, 'elapsedTime': 332532, 'timestamp': 1610679907}
>>> cli.getBlock(52099)
{'height': 52099, 'hash': '5e4c8619ea6b14f8ba4a75a74732f68ab64c22afedcb89559bef6fdb0addc199', 'coinbase': '0xF97c7082918E26ea7cf00b81784136E22EFDd5a3', 'number': 0, 'transactions': None, 'gasUsed': 0, 'elapsedTime': 300576, 'timestamp': 1610679906}
```

**Cli.getBalance(account, height=None)**

Get *account* balance at a particular *height*, get the latest balance by default 

```Python
>>> cli.getBalance('aB01a3BfC5de6b5Fc481e18F274ADBdbA9B111f0')
160000000000000000000
>>> cli.getBalance('aB01a3BfC5de6b5Fc481e18F274ADBdbA9B111f0', height = 'latest')
160000000000000000000
>>> cli.getBalance('aB01a3BfC5de6b5Fc481e18F274ADBdbA9B111f0', height = 52100)
160000000000000000000
```

**Cli.sendTransactions(txs)**

Send *txs* to the node cluster

```Python
>>> acc = ammolite.Account('40d498d6f97ba977abc04632f56a0fc956612296539dc39c47da0a22488d8d5b')
>>> raw_tx, tx_hash = acc.sign({'nonce': 1, 'value': 10000, 'gas': 21000, 'gasPrice': 1, 'to': bytearray.fromhex('230DCCC4660dcBeCb8A6AEA1C713eE7A04B35cAD'), 'data': b''})
>>> cli.sendTransactions({tx_hash: raw_tx})
```

**Cli.getTransactionReceipts(hashes)**

Query corresponding receipts with *hashes*

```Python
>>> cli.getTransactionReceipts([tx_hash])
[{'status': 1, 'contractAddress': '0000000000000000000000000000000000000000', 'gasUsed': 21000, 'logs': None, 'executing logs': ''}]
```

### Eth

**cli.eth**

Shortcut to access *ammolite.eth.Eth*

**Eth.contract(abi=None, bytecode=None, address=None) -> Contract**

Use *abi*、*bytecode*、*address* information contained in a contract to initialize a *Contract* object to conveniently call functions in the contract

```Python
>>> source = '''
... pragma solidity ^0.5.0;
... contract Example {
...     uint256 value = 0;
...     constructor(uint256 n) public {
...         value = n;
...     }
...     event SetN(uint256 n);
...     function set(uint256 n) public {
...         value = n;
...         emit SetN(value);
...     }
... }'''
>>> from solcx import compile_source
>>> compiled_sol = compile_source(source)
>>> _, contract_interface = compiled_sol.popitem()
>>> example_contract = cli.eth.contract(abi = contract_interface['abi'], bytecode = contract_interface['bin'])
```

### Contract

**Contract.constructor().buildTransaction()**

Create a transaction to deploy contracts

```Python
>>> raw_tx, tx_hash = acc.sign(example_contract.constructor(1).buildTransaction({'nonce': 2, 'gas': 1000000, 'gasPrice': 1}))
>>> cli.sendTransactions({tx_hash: raw_tx})
```

**Contract.setAddress(address)**

Deploy the contract at *address*。

```Python
>>> receipts = cli.getTransactionReceipts([tx_hash])
>>> receipts
[{'status': 1, 'contractAddress': 'e969da398451ad10daa05763b309ef20ce47ec98', 'gasUsed': 139643, 'logs': None, 'executing logs': ''}]
>>> example_contract.setAddress('e969da398451ad10daa05763b309ef20ce47ec98')
```

**Contract.functions.\<method\>.buildTransaction()**

Create a transaction to call the *method*

```Python
>>> raw_tx, tx_hash = acc.sign(example_contract.functions.set(2).buildTransaction({'nonce': 3, 'gas': 1000000, 'gasPrice': 1}))
>>> cli.sendTransactions({tx_hash: raw_tx})
```

**Contract.processReceipt(receipt)**

Parse events in the *receipt*

```Python
>>> receipts = cli.getTransactionReceipts([tx_hash])
>>> receipts
[{'status': 1, 'contractAddress': '0000000000000000000000000000000000000000', 'gasUsed': 27962, 'logs': [{'address': 'e969da398451ad10daa05763b309ef20ce47ec98', 'topics': ['284769010a3a23e1f2b4a8c1e10d15110c1a1860ad87816edc4adeb73de7f7c7'], 'data': '0000000000000000000000000000000000000000000000000000000000000002', 'blockNumber': 2425, 'transactionHash': '0000000000000000000000000000000000000000000000000000000000000000', 'transactionIndex': 0, 'blockHash': '0000000000000000000000000000000000000000000000000000000000000000', 'logIndex': 0}], 'executing logs': ''}]
>>> events = example_contract.processReceipt(receipts[0])
>>> events
{'SetN': {'n': '0000000000000000000000000000000000000000000000000000000000000002'}}
```
