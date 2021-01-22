### Interactive execution

```Python
>>> from ammolite import (Cli, HTTPProvider, Account)
>>> cli = Cli(HTTPProvider('http://192.168.1.111:8080'))
```
Randomly pick an address from ～/accounts.txt as the sender
```Python
>>> acc_from = Account('60adc6a616ecdb1cfb63842464a95caa75d123ecaca373b4b32a3ffbe3fbe517')
# Randomly pick another address from ～/accounts.txt as recipients, remove the '0x' prefix of address.
>>> address_to1 = 'CA29C9C657d1c111483b2d6A3242a8D851A5802a'
>>> address_to2 = '72450a903cfa2ABe5d90823465fC8d0e50c237C8'
```
Check initial balances
```Python
>>> cli.getBalance(acc_from.address())
683999999999999979000
>>> cli.getBalance(address_to1)
400999999999999979000
>>> cli.getBalance(address_to2)
502999999999999979000
```
Generate two separate transactions trying to send the whole balance excluding the transaction fee of 21000 to two recipients, which shouldn't succeed
```Python
>>> raw_tx1, tx_hash1 = acc_from.sign({
...     'nonce': 1,
...     'value': 683999999999999979000 - 21000,
...     'gas': 21000,
...     'gasPrice': 1,
...     'data': b'',
...     'to': bytearray.fromhex(address_to1),
... })
>>> raw_tx2, tx_hash2 = acc_from.sign({
...     'nonce': 2,
...     'value': 683999999999999979000 - 21000,
...     'gas': 21000,
...     'gasPrice': 1,
...     'data': b'',
...     'to': bytearray.fromhex(address_to2),
... })
```
Send the transactions to the node cluster
```Python
# Send the transactions to the node cluster
>>> cli.sendTransactions({tx_hash1:raw_tx1, tx_hash2:raw_tx2})
# Checking two transaction results，only one succeed（status=1，gasUsed=21000），another one failed（status=1，gasUsed=0）, indicating insufficient funds
>>> cli.getTransactionReceipts([tx_hash1,tx_hash2])
[{'status': 1, 'contractAddress': '0000000000000000000000000000000000000000', 'gasUsed': 0, 'logs': None, 'executing logs': ''}, {'status': 1, 'contractAddress': '0000000000000000000000000000000000000000', 'gasUsed': 21000, 'logs': None, 'executing logs': ''}]
```
Check balances after transaction
* Sender account balance 0
* Only succeeded with more balance added to the account, which equals to the initial balance of acc_from -21000；
* Another failed, balance unchanged

```Python
>>> cli.getBalance(acc_from.address())
0
>>> cli.getBalance(address_to1)
400999999999999979000
>>> cli.getBalance(address_to2)
1186999999999999937000
>>> 
```

### Script file

```Python
from ammolite import (Cli, HTTPProvider, Account)
import time

# Initial an client
cli = Cli(HTTPProvider('http://192.168.1.111:8080'))
# Initial sender account
acc_from = Account('316b4cb5409a7c8998c04ad81ffb5f771c70ae7305cbd976845c27320aa2fb36')
# Two recipient accounts
to_address1 = 'd024a83F83394B90AA2db581250Bc00B0B0f414a'
to_address2 = 'd7cB260c7658589fe68789F2d678e1e85F7e4831'

# Check initial account balances
origin_balance_from = cli.getBalance(acc_from.address())
origin_balance_to1 = cli.getBalance(to_address1)
origin_balance_to2 = cli.getBalance(to_address2)

# Check account status
print('Before transfer:')
print(f'\tBalance of {acc_from.address()}: {origin_balance_from}')
print(f'\tBalance of {to_address1}: {origin_balance_to1}')
print(f'\tBalance of {to_address2}: {origin_balance_to2}')

# Generate double spending transactions，sending all the balance excluding transaction fees to both recipients 
raw_tx1, tx_hash1 = acc_from.sign({
    'nonce': 1,
    'value': origin_balance_from - 21000,
    'gas': 21000,
    'gasPrice': 1,
    'data': b'',
    'to': bytearray.fromhex(to_address1)
})
raw_tx2, tx_hash2 = acc_from.sign({
    'nonce': 2,
    'value': origin_balance_from - 21000,
    'gas': 21000,
    'gasPrice': 1,
    'data': b'',
    'to': bytearray.fromhex(to_address2)
})
# Send two transactions to the node cluster
cli.sendTransactions({tx_hash1: raw_tx1, tx_hash2: raw_tx2})
# Wait till processing completed
while True:
    receipts = cli.getTransactionReceipts([tx_hash1, tx_hash2])
    if receipts is None or len(receipts) != 2:
        time.sleep(1)
        continue
    break

# Check final balances after transactions
new_balance_from = cli.getBalance(acc_from.address())
new_balance_to1 = cli.getBalance(to_address1)
new_balance_to2 = cli.getBalance(to_address2)
# Output account status
print('After transfer:')
print(f'\tBalance of {acc_from.address()}: {new_balance_from}')
print(f'\tBalance of {to_address1}: {new_balance_to1}')
print(f'\tBalance of {to_address2}: {new_balance_to2}')
```

### Output

```shell
# python double_spend_example.py 
Before transfer:
        Balance of 0xf6b8d34f8eb192381be02823f436212e34a7c679: 83999999999999979000
        Balance of d024a83F83394B90AA2db581250Bc00B0B0f414a: 412000000001999979000
        Balance of d7cB260c7658589fe68789F2d678e1e85F7e4831: 977999999999999936035
After transfer:
        Balance of 0xf6b8d34f8eb192381be02823f436212e34a7c679: 0
        Balance of d024a83F83394B90AA2db581250Bc00B0B0f414a: 412000000001999979000
        Balance of d7cB260c7658589fe68789F2d678e1e85F7e4831: 1061999999999999894035
```