## Interactive execution

Import necessary ammolite modules
```Python
>>> from ammolite import (Cli, HTTPProvider, Account)
```
Initialize a client object connecting to the frontend service of a node cluster
```Python
>>> cli = Cli(HTTPProvider('http://192.168.1.111:8080'))
```
Randomly pick an account from ～/accounts.txt as the sender and sign a transaction with its private key
```Python
>>> acc_from = Account('0aba7626ab7c2268c73b9108731ce319a29f648d5b97bd3e1530418cc20a6750')
```
Choose another account as the recipient
```Python
>>> address_to = 'Ebf0b4412cEf2bF1f03dd403e1619C9A812175ac'
```
Check the balances before the transaction
```Python
>>> cli.getBalance(acc_from.address())
317999999999999979000
>>> cli.getBalance(address_to)
82999999999999979000
```
Sign a transaction with the private key of "acc_from" 
* acc_from sends 1000000000 to address_to
* acc_from pays the transaction fee of 21000

```Python
>>> raw_tx, tx_hash = acc_from.sign({
...     'nonce': 1,
...     'value': 1000000000,
...     'gas': 21000,
...     'gasPrice': 1,
...     'data': b'',
...     'to': bytearray.fromhex(address_to)
... })
```
Send the transaction to the node
```Python
>>> cli.sendTransactions({tx_hash:raw_tx})
```
Batch query transaction receipts with the transaction hashes
```Python
>>> receipts = cli.getTransactionReceipts([tx_hash])
```
Check the receipts the receipts，status=1 represents the transaction has been successfully processed，gasUsed is the actual transaction fee paid 
```Python
>>> receipts
[{'status': 1, 'contractAddress': '0000000000000000000000000000000000000000', 'gasUsed': 21000, 'logs': None, 'executing logs': ''}]
```
Check the final balances after the transaction
* acc_from =  317999999999999979000 -1000000000 -21000，
* address_to = 82999999999999979000 + 1000000000
```Python
>>> cli.getBalance(acc_from.address())
317999999998999958000
>>> cli.getBalance(address_to)
83000000000999979000
>>> 
```

## Script
```Python
from ammolite import (Cli, HTTPProvider, Account)
import time

# Initialize a client object connecting to the frontend service of a node cluster
cli = Cli(HTTPProvider('http://192.168.1.111:8080'))

# Sender signs the transaction
acc_from = Account('562550332f390597b019e5cc750f905db544703ac45b817771e9b2e564aadcfd')

# Recipient address
to_address = 'd024a83F83394B90AA2db581250Bc00B0B0f414a'

# Check balances
origin_balance_from = cli.getBalance(acc_from.address())
origin_balance_to = cli.getBalance(to_address)

# Output initial balances
print('Before transfer:')
print(f'\tBalance of {acc_from.address()}: {origin_balance_from}')
print(f'\tBalance of {to_address}: {origin_balance_to}')

# Prepare a transaction
raw_tx, tx_hash = acc_from.sign({
    'nonce': 1,
    'value': 1000000000, # Transfer balance
    'gas': 21000, # gas required, same as Ethereum for now
    'gasPrice': 10, 
    'data': b'',
    'to': bytearray.fromhex(to_address) # convert recipient address from hex string to bytes
})
print(f'Transfer 1000000000 from {acc_from.address()} to {to_address}, pay 210000 for gas')

# Send to the node cluster
cli.sendTransactions({tx_hash: raw_tx})

# Wait till the transaction is processed 
while True:
    receipts = cli.getTransactionReceipts([tx_hash])
    if receipts is None or len(receipts) != 1:
        time.sleep(1)
        continue
    break

# Check balances after the transaction
new_balance_from = cli.getBalance(acc_from.address())
new_balance_to = cli.getBalance(to_address)

# Output balances
print('After transfer:')
print(f'\tBalance of {acc_from.address()}: {new_balance_from}')
print(f'\tBalance of {to_address}: {new_balance_to}')
```

### Expected output

```shell
# python simple_transfer_example.py
Before transfer:
        Balance of 0x0fcd17d7b02127a0687d5a071293ff357b387bc8: 51999999999999979000
        Balance of 0xd024a83F83394B90AA2db581250Bc00B0B0f414a: 411999999999999979000
Transfer 1000000000 from 0x0fcd17d7b02127a0687d5a071293ff357b387bc8 to 0xd024a83F83394B90AA2db581250Bc00B0B0f414a, pay 210000 for gas
After transfer:
        Balance of 0x0fcd17d7b02127a0687d5a071293ff357b387bc8: 51999999998999769000
        Balance of 0xd024a83F83394B90AA2db581250Bc00B0B0f414a: 412000000000999979000
```
