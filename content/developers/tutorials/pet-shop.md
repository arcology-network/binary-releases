# Pet Shop
- [Pet Shop](#pet-shop)
  - [1. Introduction](#1-introduction)
    - [1.2. Monaco](#12-monaco)
    - [1.3. Comparison Chart](#13-comparison-chart)
  - [2. How to Run](#2-how-to-run)
  - [3. Accounts](#3-accounts)
  - [4. Login](#4-login)

## 1. Introduction
There is a tutorial example in Truffle development document that you can find here https://trufflesuite.com/tutorial/index.html. The example walks you through the steps for building an Ethereum DApp.

### 1.2. Monaco
The only difference is that Arcology uses its own blockchain call Monaco AOI in place of [Ganache](https://trufflesuite.com/ganache/). Run the command below to download and start the test network docker container

```sh
docker run --name allinone-cluster -p 8080:8080 -p 7545:7545 -d cody0yang/cluster:1.13 /root/dstart.sh chainID:100 rpcPort:7545
```

### 1.3. Comparison Chart

|Platform|Development|Wallet|Blockchain|
|---|---|---|---|
|**Ethereum**|Truffle|MetaMask|Ganache|
|**Arcology**|Truffle|MetaMask|**`Monaco`**|

## 2. How to Run
Just follow steps in the tutorial. **You can run the example on Arcology network directly.** There is no need to change anything to the smart contracts or the backend code. 


## 3. Accounts
There are a list of pre-created accounts in the docker container that developers can use to initiate. transactions.

|Private Keys|Addresses|Balances|
|---|---|---|
|5bb1315c3ffa654c89f1f8b27f93cb4ef6b0474c4797cf2eb40d1bdd98dc26e7|0xaB01a3BfC5de6b5Fc481e18F274ADBdbA9B111f0|160000000000000000000
|2289ae919f03075448d567c9c4a22846ce3711731c895f1bea572cef25bb346f|0x21522c86A586e696961b68aa39632948D9F11170|329000000000000000000
|19c439237a1e2c86f87b2d31438e5476738dd67297bf92d752b16bdb4ff37aa2|0xa75Cd05BF16BbeA1759DE2A66c0472131BC5Bd8D|391000000000000000000
|236c7b430c2ea13f19add3920b0bb2795f35a969f8be617faa9629bc5f6201f1|0x2c7161284197e40E83B1b657e98B3bb8FF3C90ed|374000000000000000000
|c4fbe435d6297959b0e326e560fdfb680a59807d75e1dec04d873fcd5b36597b|0x57170608aE58b7d62dCdC3cbDb564C05dDBB7eee|850000000000000000000
|f91fcd0784d0b2e5f88ec3ba6fe57fa7ef4fbf2fe42a8fa0aaa22625d2147a7a|0x9F79316c20f3F83Fcf43deE8a1CeA185A47A5c45|427000000000000000000
|630549dc7564f9789eb4435098ca147424bcde3f1c14149a5ab18e826868f337|0x9f9E0F23aFd5404b34006678c900629183c9A25d|172000000000000000000
|2a31c00f193d4071adf4e45abaf76d7222d4af87ab30a7a4f7bae51e28aceb0a|0xd7cB260c7658589fe68789F2d678e1e85F7e4831|978000000000000000000
|a2ffe69115c1f2f145297a4607e188775a1e56907ca882b7c6def550f218fa84|0x230DCCC4660dcBeCb8A6AEA1C713eE7A04B35cAD|927000000000000000000
|d9815a0fa4f31172530f17a6ae64bf5f00a3a651f3d6476146d2c62ae5527dc4|x8aa62d370585e28fd2333325d3dbaef6112279Ce |701000000000000000000
|||

## 4. Login
In case you need to log in to the testnet docker container, please use the credential in [this document](../testnet/testnet-docker-allinone.md)
>Please don't change anything in the container unless you know what you are doing.

