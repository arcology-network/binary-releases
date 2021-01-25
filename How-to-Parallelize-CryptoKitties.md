## Table of Contents

- [Table of Contents](#table-of-contents)
- [Introduction to CryptoKitties](#introduction-to-cryptokitties)
  - [Background](#background)
  - [Source code analysis](#source-code-analysis)
    - [KittyAccessControl](#kittyaccesscontrol)
    - [Kitty](#kitty)
    - [KittyBase](#kittybase)
    - [KittyOwnership](#kittyownership)
    - [KittyBreeding](#kittybreeding)
    - [KittyAuction](#kittyauction)
    - [KittyMinting](#kittyminting)
    - [KittyCore](#kittycore)
    - [Auction](#auction)
    - [ClockAuctionBase](#clockauctionbase)
    - [ClockAuction](#clockauction)
    - [SaleClockAuction](#saleclockauction)
    - [SiringClockAuction](#siringclockauction)
    - [GeneScienceInterface](#genescienceinterface)
- [Business logic analysis](#business-logic-analysis)
  - [The Benefits for parallelization](#the-benefits-for-parallelization)
  - [Feasibility Analysis](#feasibility-analysis)
    - [createSaleAuction](#createsaleauction)
    - [createSiringAuction](#createsiringauction)
    - [bid](#bid)
    - [bidOnSiringAuction](#bidonsiringauction)
    - [breedWithAuto](#breedwithauto)
    - [giveBirth](#givebirth)
- [ParallelKitties](#parallelkitties)
  - [ConcurrentLib.sol](#concurrentlibsol)
  - [KittyCore.sol](#kittycoresol)
  - [ClockAuction.sol](#clockauctionsol)
  - [SaleClockAuction.sol](#saleclockauctionsol)
  - [SiringClockAuction.sol](#siringclockauctionsol)
- [Test Goals](#test-goals)
  - [Test Setup](#test-setup)
  - [Data Preparation](#data-preparation)
  - [Test 1：Multithreaded processing on a single machine](#test-1multithreaded-processing-on-a-single-machine)
  - [Test 2：Horizontal scaling over multiple machines](#test-2horizontal-scaling-over-multiple-machines)
- [Conclusion](#conclusion)

## Introduction to CryptoKitties

### Background

> Referenced from [wiki](https://en.wikipedia.org/wiki/CryptoKitties)。

CryptoKitties is a virtual pet game based on the Ethereum platform in which gamers can buy, collect, raise and sell virtual pet cats. Each kitty has a unique gene and shows a different appearance through the gene. Because CryptoKitties was  developed based on    Ethereum's blockchain technology, every kitty in the game is a unique non-fungible token(NFT),which belongs to a unique owner and cannot be copied or transferred without the owner's consent.  

CryptoKitties is one of the pioneers of casual gaming applications on the Ethereum  platform and one of the most influential applications in Ethereum's history.  The beta version of CryptoKitties, released on October 19, 2017, was launched on the main network at the end  of November of the same year and quickly became the most popular app on the Ethereum platform, allowing Ethereum's pending transactions to grow six-fold in just a few days, accounting for https://www.bbc.com/news/technology-42237162 about 25% of Ethereum traffic and  https://venturebeat.com/2018/10/06/cryptokitties-explained-why-players-have-bred-over-a-million-blockchain-felines/. Its emergence not only gives an insight into the blockchain technology's  ability to function in a broader application scenario, but also raises concerns and discussions about the Ethereum platform's ability to scale.  

In October 2018, the number of Kitties in   CryptoKitties  games reached one million, resulting in 3.2 million  transactions. Although this is seen as a milestone for CryptoKitties,  the fact is that even on the day when trading volume peaked in   December    2017, it had only a daily living timeof 14914(https://www.theblockcrypto.com/linked/2606/cryptokitties-raises-15m-despite-low-daily-user-count) and iscurrently around 100   ](https://dappradar.com/app/3/cryptokitties)。 By contrast,    https://store.steampowered.com/stats/Steam-Game-and-Player-Statistics, a  well-known gaming platform, typically has about 10 million online users on its platform, compared with a peak of more than 15 million in the last 48 hours.  

In a sense, it was the processing power of the Ethereum platform that limits CryptoKitties' greater success: 

* Very low TPS and a large number of transactions that cannot be processed in a timely manner affect the user experience, challenging the user's patience and not sustaining the user's enthusiasm in the long term

* High transaction fees raise the user threshold, narrow the group of potential new users, and the game gradually loses its heat. 

Following  our in-depth analysis of cryptoKitties'  source code and rewriting  it using the Concurrency control mechanism  provided by the Arcology platform, we will demonstrate through analysis and testing that  Parallel Kitties,  which has been retrofitted in parallel and runs on the Arcology platform, can easily cope with the traffic spikes that once dragged down the Ethereum network, helping CryptoKitties and other more complex applications succeed on the Blockchain platform.  



### Source code analysis


CK consists of contracts deployed at four different addresses:

1. **KittyCore** - Most of  the data and business logic is implemented here, the source code is organized in the form of multi-layer inheritance, the different layers implement  a relatively separate set of functions, but also aggregate GeneScience International, SaleClockAuction and SiringClockAuction contract objects; 
2. **SaleClockAuction** - mainly contains sale auction-related implementations; 
3. **SiringClockAuction** - mainly contains siring auction-related implementations; 
4. **GeneScience International** - Implements genetic algorithms for breeding offspring, and this part of the contract is not open source and is a trade secret

The following UML class diagram shows the relationships between the classes in the CK source code, where the corresponding implementations of the four main contracts are shown in a thick black wireframe. Each class lists the public methods that the class contains, as well as important data members. The method name is expressed in bold, where the pure  or view method is represented in bold italics; Private methods are not listed because they do not help understand the business of CK.  

![](./parallel-kitties/CryptoKittiesUML.png)

The contracts are described below in a top-down order of inheritance structures:

#### KittyAccessControl

Includes major functions for operation 

* **setCEO** - Set the CEO account address
* **setCFO** - Set CFO account address 
* **setCOO** - Set the COO account address
* **withdrawBalance** - withdraw the balance from the contract address
* **pause** - Suspension of contract operations
* **unpause** - resume contract operations  

#### Kitty

Kitty's property information is stored in the data structure:

* **genes** - genetic information ;
* **birthTime** - birth time; 
*  **cooldown EndTime** - It takes a cooling time after mating between two kittys to mate again, and the cooling time is determined by cooldownIndex; 
* **matronId** - mother's id;
*  **sireId** - father's id;
*  **siringWithId** - When a kitty  becomes pregnant as matron, the property represents the father's id,and the other timethe property is 0;
*  **cooldownIndex** - Each mating cooldownIndex plus one, no increase after reaching 13.   The larger the cooldownIndex, the longer the cooling time, determined by a lookup table, with a minimum of 1 minute and a maximum of 7 days; 
*  **generation** - generation, equal to the parents of the generational value of the party.  

#### KittyBase

KittyCore's main storage structures are defined here, and there are also some private implementations aren't listed.

* **kitties** - Kitty type array,kitty index in array  as its id. Kitty is serially inserted in CK, so this data structure can be stored. However, such a storage structure does not support the creation of kitties in a synth;
* **kittyIndexToOwner** - Kitty index to its owner's mapping relationship;
* **ownershipTokenCount** - account address to the number of kitties owned by the mapping relationship ;
* **kittyIndexToApproved** - Kitty index map to an account address that has been approved. This information is recorded here if the owner of one kitty transfers his kitty to another account through the approve method. The receiver can then confirm receipt of kitty to its own name by calling  the transferFrom  method;
* **sireAllowedToAddress** - Kitty index map to another account address. If one kitty as  sire allows kitty in another account to mate with it, this information is recorded here. The mating can then be done with breedWith.   


#### KittyOwnership

Contains the implementation of the ERC721 protocol interface: 

* **implementsERC721** - read-only, fixed return true
* **totalSupply** - read-only, returning the current total number of kitties
* **balanceOf** - read-only, returning the number of kitties owned by the specified  account
* **ownerOf** - read-only, returning the owner account address of a  kitty 
* **approve** - The owner approves transfering his kitty through this method to another account, which receives it through transferFrom  
* **transferFrom** - See above
* **transfer** - The owner of the kitty completes the transfer directly, and if the receiver does not support the ERC721 protocol, the kitty may be permanently lost.  


#### KittyBreeding

Contains the implementation of kitty mating behavior: 

* **geneScience** - the contract address of the geneScience Interface implementation currently in use; 
* **setGeneScienceAddress** - Set geneScience;
* **approve Siring** - The owner allows kitty  to mate as sire with kitty in another account in this way; 
* **setAutoBirthFee** - Set up auto birth fees.  auto birth is a deamon program that listens to AutoBirth events and automatically calls the giveBirth method; 
* **IsReadyToBreed** - read-only, check whether a kitty is currently available for reproduction; 
* **canBreedWith** - read-only, check whether the two kitties meet the conditions for co-breeding; 
* **breedWith** - Trigger the breeding action of two cats, call breedWith after  two cats enter cooldown,cooldown time is over, you can get offspring through the giveBirth method; 
* **breedWithAuto** - features the same as breedWith, which triggers an additional AutoBirth event; 
* **giveBirth** - see breedWith. 


#### KittyAuction

Includes auction-related features, primarily through saleClockAuction  and SiringClockAuction:  

* **saleAuction** - Store the address of the SaleClockAuction contract; 
* **siringAuction** - Store the address of the SiringClockAuction contract; 
* **setSaleClockAuction** - Set saleAuction;
* **setSiringClockAuction** - Set siringAuction;
* **createSaleAuction** - launch a new sale auction;
* **createSiringAuctio**n - launch a new siring auction;
* **bidOnSiringAuction** - a auction of a siring  auction;
* **withdrawAuctionBalances** - Extract the commission for the auction.  


#### KittyMinting

Manages the creation of generation 0 and promotion kitties

* **promoCreatedCount** - The number of promotion cats that have been generated, up to a maximum of 5000;
* **gen0CreatedCount** - the number of generation 0 cats that have been generated, up to a maximum of 50,000;
* **createPromoKitty** - Build a new promotion cat ;
* **createGen0Auction** - Generate a new generation 0 cat and auction it, with the new generation 0 cat priced at a 50% premium to the average sale price of the previous five generations of cats. 


#### KittyCore

Entrance to the entire KittyCore contract.  

*  **getKitty** - read-only, query the properties of a kitty;  
*  **unpause** - resume contract operations.  


#### Auction

Store auction-related data:

*  **seller** - seller's address;
*  **startingPrice** - starting price; 
*  **endingPrice** - Highest price;
*  **duration** - It's not the time the auction lasts, it's the time when the sale price rises from starting Price to ending Price. If you trade  beyond duration,  endPrice is the trading price;
*  **startedAt** - Start time.  


#### ClockAuctionBase

This includes some of the underlying data structures that manage auction data:

*  **nonFungibleContract** - A contract address that implements the ERC721 interface and actually points to KittyCore's contract address.  ClockAuctionBase uses this interface to complete the transfer of kitty ownership when the auction is successful; 
*  **ownerCut** - Commission ratio, commission deducted from seller;
*  **tokenIdToAuction** - Kitty id to Auction map.  


#### ClockAuction

Implements some of the features that both SaleClockAuction and SiringClockAuction need to use: 

*  **withdrawBalance** - withdrawal of account balances; 
*  **createAuction** - Create an auction;
*  **bid** - bid for an auction;
*  **cancelAuction** - Undo an auction;
*  **cancelAuctionWhenPaused** - cancel an auction when the contract is in the pausestate;
*  **getAuction** - read-only, query an auction of information; 
*  **getCurrentPrice** - read-only, query the current price of an auction.  


#### SaleClockAuction

Manage the contract entry for sale auction, in addition to implementing auction-related methods, to record the closing records of 0 generations of cats and to price subsequent generations of cats: 

*  **gen0SaleCount** - record the number of 0 generations of cats sold; 
*  **lastGen0SalePrices** - record the recent five 0 generations of cats for sale price; 
*  **createAuction** - Create a sale auction;
*  **bid** - bid for a sale auction;
*  **averageGen0SalePrice** - Read-only, calculate the average of lastGen0SalePrices.   


#### SiringClockAuction

Manages the contract entry for the auction:  

*  **createAuction** - Create a siring auction;
*  **bid** - bid for a siring auction. 


#### GeneScienceInterface

This contract only gives an interface description, and implementation isn't available yet:

*  **isGeneScience** - read-only and should be returned true if this contract implements GeneScience  International;
*  **mixGenes** - The genes of a newborn cat are determined through the genes of both parents and a targetBlock.  This method is called in the giveBirth method, and the incoming parameter is cooldownEndTime-1. Some people who try to crack the genetic algorithm have experimentally demonstrated that the algorithm uses block hash to introduce randomness.  


## Business logic analysis

CK's primary business logic consists of the following parts: 

* **Transfer of ownership of the cat. There are generally two ways:**
  1. The cat's owner uses the ERC721 interface directly to complete the transfer. This approach requires matching offline transactions and is difficult to do between strangers;
  2. The transfer is completed in the form of a sale auction listing auction. In this way,the owner temporarily hosts his kitty  under the sale auction contract account while listing, and the auction succeeds before the sale auction  transfers the kitty to the buyer; 
* **Cat breeding. There are generally two ways:**
  1. Two kitties belonging to the same owner can reproduce offspring directly through mating; 
* One party, as sire, allows another user's kitty to mate with it to produce offspring. In the specific operation can be subdivided into two ways:
*  Kitty's owner calls approveSiring directly to authorize another account to mate with it, similar to a transfer, which may rarely occur in reality;
* Authorize another account to complete mating in the form of  a siring auction listing auction. In this way, similar to a transfer,the owner  needs to host kitty  under the  siring auction contract account, and after a successful auction, the buyer is granted the mating  rights by the siring auction, and the ownership of the kitty is returned to the original owner; 
* Generation 0 cat and promotion cat generation.  The upper limits for the number of generation 0 cats  and promotion  cats are 5000 and  50,000, respectively, so each generation 0 cat and promotion cat needs to count and check if the upper limit is exceeded at the time of generation. The total number and generation of common cats (which are included in the concept of 0  generation cats and promotion cats) are also  limited, 4294967295(maximumvalue of uint32)  and 65535(maximumvalue of uint16), respectively; 
* Functions related to the operational maintenance of the contract, including: 
* Withdrawal of balances in CK contract accounts, mainly from  the proceeds from the sale of  generation 0  cats and promotion cats, as well as commissions received at sale auction and siring auction;
Reset the account address of thecontractmanager(CEO,CFO, COO); 
* Reset  the addresses of GeneScienceInternational, SaleClockAuction,SiringClockAuction contracts; 
* Suspend or restart the operation of the contract, etc.  

Let's combine CK's source code and business logic to analyze the necessity and feasibility of parallelizing CK.  

### The Benefits for parallelization

By analyzing CK's business logic, you can see that not all functions need to be reimplemeted to allow parallelism. For example:

- The generation of generation 0 cats and promotion cats does not need to be parallelized, as in CK, a new generation 0 cat is generated every 15 minutes, while promotion cats are generated less frequently
  
- Operations-related features do not need to be parallelized, as they are limited to certain accounts and have limited in certain scenarios

In contrast to the above scenario, cat ownership transfer and reproduction functions are frequently used. In Ethereum, a maximum of 5 transactions per second from CK users can be processed, which is unacceptable for a popular application, if calculated based on 15tps and CK accounting for 30% of the network's traffic. It is precisely because of the ineulity of the Ethereum platform, so that projects like CK after attracting enough attention, growth eventually encountered bottlenecks, not to achieve greater success.

### Feasibility Analysis

The following provides an in-depth analysis of the logic of the original implementation of CK in the six most frequently used scenarios and provides a retrofit scenario. Through these analyses, we can seehow the infrastructure that Arcology provides for parallel processing will help CK achieve a qualitative leap in processing power.  

To improve the readability of the code, some adjustments have been made to the source code in the following code, for example, some functions are expanded at the call point, some of the legality judgment of the input parameters is ignored, but all read and write operations on storage are retained, so there is no effect on understanding the logical complexity of the source code.  


#### createSaleAuction

Create a sale auction。

```Solidity
// In KittyAuction:
function createSaleAuction(
    uint256 _kittyId,
    uint256 _startingPrice,
    uint256 _endingPrice,
    uint256 _duration
) 
    external
    whenNotPaused
{
    // Ensure the seller owns the kitty
    require(kittyIndexToOwner[_kittyId] == msg.sender);
    // Make sure the kitty isn't pregnant
    require(kitties[_kittyId].siringWithId == 0);
    // owner approves to entrust the kitty to saleAuction contract
    kittyIndexToApproved[_kittyId] = saleAuction;
    //Call the createAuction method of SaleAuctionClock contract。
    saleAuction.createAuction(
        _kittyId,
        _startingPrice,
        _endingPrice,
        _duration,
        msg.sender
    );
}

// In SaleClockAuction:
function createAuction(
    uint256 _tokenId,
    uint256 _startingPrice,
    uint256 _endingPrice,
    uint256 _duration,
    address _seller
)
    external
{
    // Make sure the owner has agreed to pass the kitty to the contract
    require(kittyIndexToApproved[_tokenId] == this);
    // Ensure the seller owns the kitty。
    require(kittyIndexToOwner[_tokenId] == _seller);
    // Increase ownership counter by 1。
    ownershipTokenCount[this]++;
    // Set the concurrent contract the new owner of the kitty
    kittyIndexToOwner[_tokenId] = this;
    // No need to clear data if the kitty is newly created
    if (_seller != address(0)) {
        // decrease seller's token ownership  by one。
        ownershipTokenCount[_seller]--;
        // if the kitty has been authorized to another account as the sire，but the mating hasn't been completed yet, cancel the authorization
        delete sireAllowedToAddress[_tokenId];
        // Delete seller approval record as the transfer has been completed
        delete kittyIndexToApproved[_tokenId];
    }
    // Create Auction，fill in basic information
    Auction memory auction = Auction(
        _seller,
        uint128(_startingPrice),
        uint128(_endingPrice),
        uint64(_duration),
        uint64(now)
    );
     // Add the auction to the auction list
    tokenIdToAuction[_tokenId] = auction;
}
```

Reading and writing operations made during the whole execution progress includes:

> ++ operation includes an read followed by a write. It is an R+W combination, so labelled as W

|Index|Contract|Data|R/W|
|-:|-|-|-|
|1|KittyCore|kittyIndexToOwner[_kittyId]|R|
|2|KittyCore|kitties[_kittyId]|R|
|3|KittyCore|kittyIndexToApproved[_kittyId]|W|
|4|KittyCore|kittyIndexToApproved[_kittyId]|R|
|5|KittyCore|kittyIndexToOwner[_kittyId]|R|
|6|KittyCore|ownershipTokenCount[saleAuction]|R+W|
|7|KittyCore|kittyIndexToOwner[_kittyId]|W|
|8|KittyCore|ownershipTokenCount[seller]|R+W|
|9|KittyCore|sireAllowedToAddress[_kittyId]|W|
|10|KittyCore|kittyIndexToApproved[_kittyId]|W|
|11|SaleClockAuction|tokenIdToAuction[_kittyId]|W|

Based on the analysis above, 3 accounts or contracts are involved in the process, they are: 

* The **seller**'s account：row No. 8；
* The **KittyCore** contract：row No. 1，2，3，4，5，7，9，10，11；
* The **SaleClockAuction** contract：row No. 6.

If we use the concurrent containers provided by Arcology to replace the corresponding data structures above, then all the operations on different sellers and kitty IDs of the same container can be processed in parallel. The only problem is on row No.6: every call on **createSaleAuction** needs to modify **ownershipTokenCount[saleAuction]**, which makes a confliction among all these transactions.

To deal with this problem, Arcology also provides concurrent counter as a part of the infrastructure. We could use a concurrent counter to save the token count of **saleAuction**. Changes on a concurrent counter can be accepted in parallel without any confliction.

> The complete code of parallelized CryptoKitties will be listed in the last section of this page.

#### createSiringAuction

Create a new siring auction.

```Solidity
// In KittyAuction:
function createSiringAuction(
    uint256 _kittyId,
    uint256 _startingPrice,
    uint256 _endingPrice,
    uint256 _duration,
)
    external
    whenNotPaused
{
    require(kittyIndexToOwner[_kittyId] == msg.sender);
    Kitty storage kit = kitties[_kittyId];
    // Ensure that the kitty is ready to breed.
    require(kit.siringWithId == 0 && kit.cooldownEndBlock <= uint64(block.Number));
    kittyIndexToApproved[_kittyId] = siringAuction;
    siringAuction.createAuction(
        _kittyId,
        _startingPrice,
        _endingPrice,
        _duration,
        msg.sender
    );
}

// In SiringClockAuction:
function createAuction(
    uint256 _tokenId,
    uint256 _startingPrice,
    uint256 _endingPrice,
    uint256 _duration,
    address _seller
)
    external
{
    require(kittyIndexToApproved[_tokenId] == this);
    require(kittyIndexToOwner[_tokenId] == _seller);
    ownershipTokenCount[this]++;
    kittyIndexToOwner[_tokenId] = this;
    if (_seller != address(0)) {
        ownershipTokenCount[_seller]--;
        delete sireAllowedToAddress[_tokenId];
        delete kittyIndexToApproved[_tokenId];
    }
    Auction memory auction = Auction(
        _seller,
        uint128(_startingPrice),
        uint128(_endingPrice),
        uint64(_duration),
        uint64(now)
    );
    tokenIdToAuction[_tokenId] = auction;
}
```

The implementation of **createSiringAuction** is almost the same as **createSaleAuction**, especially on the data operation point of view. So we won't repeat ourself to explain how to parallelize this function.

#### bid

Bid on a sale auction.

```Solodity
// In SaleClockAuction:
function bid(uint256 _tokenId)
    external
    payable
{
    // Get the address of seller.
    address seller = tokenIdToAuction[_tokenId].seller;
    // Call _bid function in ClockAuctionBase, msg.value is the input of this transaction.
    uint256 price = _bid(_tokenId, msg.value);
    // Begin of _transfer, refer to the comments in createSaleAuction above.
    require(kittyIndexToOwner[_tokenId] == saleAuction);
    ownershipTokenCount[msg.sender]++;
    kittyIndexToOwner[_tokenId] = msg.sender;
    if (saleAuction != address(0)) {
        ownershipTokenCount[saleAuction]--;
        delete sireAllowedToAddress[_tokenId];
        delete kittyIndexToApproved[_tokenId];
    }
    // End of _transfer.
    // If seller equals to the address of KittyCore contract, than this is a gen0 kitty.
    // The sale price of gen0 kitty needs to be remembered.
    if (seller == address(nonFungibleContract)) {
        lastGen0SalePrices[gen0SaleCount % 5] = price;
        // Update the counter of gen0 kitties.
        gen0SaleCount++;
    }
}

// In ClockAuctionBase:
function _bid(uint256 _tokenId, uint256 _bidAmount) 
    internal
    returns (uint256)
{
    // Fetch the information of this auction.
    Auction storage auction = tokenIdToAuction[_tokenId];
    // Ensure the auction exists.
    require(auction.startedAt > 0);
    // _currentPrice is a pure function used to calculate the sale price. 
    uint256 price = _currentPrice(auction);
    // Ensure the bidder provides enough coins.
    require(_bidAmount >= price);
    address seller = auction.seller;
    // Delete this auction.
    delete tokenIdToAuction[_tokenId];
    if (price > 0) {
        uint256 auctioneerCut = _computeCut(price);
        uint256 sellerProceeds = price - auctioneerCut;
        // Pay for the auction to the seller.
        seller.transfer(sellerProceeds);
    }
    // Give the change back to the bidder.
    uint256 bidExcess = _bidAmount - price;
    msg.sender.transfer(bidExcess);
    return price;
}
```

Operations on storage include:

|Index|Contract|Data|R/W|
|-:|-|-|-|
|1|SaleClockAuction|tokenIdToAuction[_tokenId]|R|
|2|SaleClockAuction|tokenIdToAuction[_tokenId]|W|
|3|KittyCore|kittyIndexToOwner[_tokenId]|R|
|4|KittyCore|ownershipTokenCount[buyer]|R+W|
|5|KittyCore|kittyIndexToOwner[_tokenId]|W|
|6|KittyCore|ownershipTokenCount[saleAuction]|R+W|
|7|KittyCore|sireAllowedToAddress[_tokenId]|W|
|8|KittyCore|kittyIndexToApproved[_tokenId]|W|
|9|SaleClockAuction|lastGen0SalePrices|W|
|10|SaleClockAuction|gen0SaleCount|W|

The operations involved 3 accounts or contracts, they are:

* The **bidder**'s account: row No. 4;
* The **KittyCore** contract: row No. 1, 2, 3, 5, 7, 8;
* The **SaleClockAuction** contract: row No. 6, 9, 10. 

The data operations on bidder and kitty can be parallelized by using concurrent containers. The solution of the **ownershipTokenCount[saleAuction]** problem has been covered in the discussions above. The modifications on **lastGen0SalePrices** and **gen0SaleCount** occur on bidding of gen0 kitties,which is rare. So it is not necessary to parallelize this part of code.

#### bidOnSiringAuction

Bid on a siring auction, bidder needs to provide a matron kitty to breed with the sire kitty he bidded on.

```Solidity
// In KittyAuction:
function bidOnSiringAuction(
    uint256 _sireId,
    uint256 _matronId
)
    external
    payable
    whenNotPaused
{
    // Ensure the matron kitty belongs to the bidder.
    require(kittyIndexToOwner[_matronId] == msg.sender);
    // Fetch the information of the matron kitty.
    Kitty storage kit = kitties[_matronId];
    // Check if the matron kitty is ready to breed.
    require(kit.siringWithId == 0 && kit.cooldownEndBlock <= uint64(block.number));
    // Begin to check if these two kitties can breed with each other.
    // Fetch the informations of sire and matron kitties. 
    Kitty storage matron = kitties[_matronId];
    Kitty storage sire = kitties[_sireId];
    // A kitty cannot breed with itself.
    require(_matronId != _sireId);
    // A kitty cannot breed with its parents.
    require(matron.matronId != _sireId && matron.sireId != _sireId);
    require(sire.matronId != _matronId && sire.sireId != _matronId);
    // A kitty cannot breed with its brothers or sisters.
    // Gen0 kitties have no brothers or sisters.
    if (sire.matronId != 0 && matron.matronId != 0) {
        require(sire.matronId != matron.matronId && sire.matronId != matron.sireId);
        require(sire.sireId != matron.matronId && sire.sireId != matron.sireId);
    }
    // End of checking.
    // Fetch the information of this auction.
    Auction storage auction = tokenIdToAuction[_sireId];
    // Check if the auction exists.
    require(auction.startedAt > 0);
    // Calculate the price of this auction, _currentPrice is a pure function.
    uint256 currentPrice = _currentPrice(auction);
    // Ensure the bidder provides enough money for this transaction.
    require(msg.value >= currentPrice + autoBirthFee);
    // Call SiringClockAuction's bid function.
    siringAuction.bid.value(msg.value - autoBirthFee)(_sireId);
    // Call KittyBreeding's _breedWith function.
    _breedWith(uint32(_matronId), uint32(_sireId));
}

// In SiringClockAuction:
function bid(uint256 _tokenId)
    external
    payable
{
    // Only KittyCore contract is allowed to call this function.
    require(msg.sender == address(nonFungibleContract));
    // Get the seller's address of the auction. 
    address seller = tokenIdToAuction[_tokenId].seller;
    // Call the _bid function, the implementation can be found in the bid section above.
    _bid(_tokenId, msg.value);
    // Begin of _transfer, see the comments in the bid section above.
    require(kittyIndexToOwner[_tokenId] == siringAuction);
    ownershipTokenCount[seller]++;
    kittyIndexToOwner[_tokenId] = seller;
    if (siringAuction != address(0)) {
        ownershipTokenCount[siringAuction]--;
        delete sireAllowedToAddress[_tokenId];
        delete kittyIndexToApproved[_tokenId];
    }
    // End of _transfer.
}

// In KittyBreeding:
function _breedWith(uint256 _matronId, uint256 _sireId) internal {
    // Fetch the informations of sire and matron.
    Kitty storage sire = kitties[_sireId];
    Kitty storage matron = kitties[_matronId];
    matron.siringWithId = uint32(_sireId);
    // Update cooldownEndBlock and cooldownIndex.
    sire.cooldownEndBlock = uint64((cooldowns[sire.cooldownIndex]/secondsPerBlock) + block.number);
    if sire.cooldownIndex < 13) {
        sire.cooldownIndex += 1;
    }
    matron.cooldownEndBlock = uint64((cooldowns[matron.cooldownIndex]/secondsPerBlock) + block.number);
    if matron.cooldownIndex < 13) {
        matron.cooldownIndex += 1;
    }
    // Delete any siring approval if exists.
    delete sireAllowedToAddress[_matronId];
    delete sireAllowedToAddress[_sireId];
    // Update the counter of pregnant kitties.
    pregnantKitties++;
}
```

Operations on storage include:

|Index|Contract|Data|R/W|
|-:|-|-|-|
|1|KittyCore|kittyIndexToOwner[_matronId]|R|
|2|KittyCore|kitties[_matronId]|R|
|3|KittyCore|kitties[_sireId]|R|
|4|SiringClockAuction|tokenIdToAuction[_sireId]|R+W|
|5|KittyCore|kittyIndexToOwner[_sireId]|R+W|
|6|KittyCore|ownershipTokenCount[seller]|R+W|
|7|KittyCore|ownershipTokenCount[siringAuction]|R+W|
|8|KittyCore|sireAllowedToAddress[_sireId]|W|
|9|KittyCore|kittyIndexToApproved[_sireId]|W|
|10|KittyCore|kitties[_matronId]|R+W|
|11|KittyCore|kitties[_sireId]|R+W|
|12|KittyCore|sireAllowedToAddress[_matronId]|W|
|13|KittyCore|sireAllowedToAddress[_sireId]|W|
|14|KittyCore|pregnantKitties|R+W|

These accounts or contracts are involved:

* The **seller**'s account: row No. 6;
* The **sire**'s data stored in KittyCore contract: row No. 3, 4, 5, 7, 8, 11, 13;
* The **matron**'s data stored in KittyCore contract: row No. 1, 2, 10, 12;
* The **SiringClockAuction** contract: row No. 7;
* The **KittyCore** contract: row No. 14.

The first three groups of operations can be parallelized by concurrent containers. The solution of the **ownershipTokenCount[siringAuction]** problem is the same as the **ownershipTokenCount[saleAuction]** problem covered before. **pregnantKitties** is a global counter, so it can be replace with a concurrent counter. 

#### breedWithAuto

The owner of the matron kitty call this function to breed with a sire kitty. The owner of the matron kitty owns the sire kitty as well, or he need to be approved by the owner of the sire kitty.

```Solidity
// In KittyBreeding:
function breedWithAuto(uint256 _matronId, uint256 _sireId)
    external
    payable
    whenNotPaused
{
    // The input value is at least equals to the autoBirthFee.
    require(msg.value >= autoBirthFee);
    // Check if the sender owns the matron.
    require(kittyIndexToOwner(_matronId) == msg.sender);
    address matronOwner = kittyIndexToOwner[_matronId];
    address sireOwner = kittyIndexToOwner[_sireId];
    // The sender owns the sire, or had been approved to breed with the sire kitty.
    require(matronOwner == sireOwner || sireAllowedToAddress[_sireId] == matronOwner);
    Kitty storage matron = kitties[_matronId];
    // The matron is ready to breed.
    require(matron.siringWithId == 0 && matron.cooldownEndBlock <= uint64(block.number));
    Kitty storage sire = kitties[_sireId];
    // The sire is ready to breed.
    require(sire.siringWithId == 0 && sire.cooldownEndBlock <= uint64(block.number));
    // Check if the sire and the matron are able to breed with each other, refer to the implementation explained in bidOnSiringAuction section above.
    require(_isValidMatingPair(matron, _matronId, sire, _sireId));
    // This function has been explained in bidOnSiringAuction section.
    _breedWith(_matronId, _sireId);
}
```

Operations on storage include:

|Index|Contract|Data|R/W|
|-:|-|-|-|
|1|KittyCore|kittyIndexToOwner[_matronId]|R|
|2|KittyCore|kittyIndexToOwner[_sireId]|R|
|3|KittyCore|sireAllowedToAddress[_sireId]|R|
|4|KittyCore|kitties[_matronId]|R|
|5|KittyCore|kitties[_sireId]|R|
|6|KittyCore|kitties[_matronId]|R+W|
|7|KittyCore|kitties[_sireId]|R+W|
|8|KittyCore|sireAllowedToAddress[_matronId]|W|
|9|KittyCore|sireAllowedToAddress[_sireId]|W|
|10|KittyCore|pregnantKitties|R+W|

The contracts involved are:

- The **matron**'s data stored in KittyCore: row No. 1, 4, 6, 8;
- The **sire**'s data stored in KittyCore: row No. 2, 3, 5, 7, 9;
- The **KittyCore** contract: row No. 10.

There's no new issue to discuss.

#### giveBirth

Any user could call this function on a pregnant matron kitty, the newly born kitty belongs to the owner of the matron kitty. The caller of this function gains the autoBirthFee.

```Solidity
// In KittyBreeding:
function giveBirth(uint256 _matronId)
    external
    whenNotPaused
    returns (uint256)
{
    // Get information of the matron.
    Kitty storage matron = kitties[_matronId];
    // Check if the matron exists.
    require(matron.birthTime != 0);
    // The matron is ready to give birth.
    require(matron.siringWith != 0 && matron.cooldownEndBlock <= uint64(block.number));
    // Get information of the sire.
    uint256 sireId = matron.siringWithId;
    Kitty storage sire = kitties[sireId];
    // Calculate the parents' generation, choose the bigger one.
    uint16 parentGen = matron.generation;
    if (sire.generation > matron.generation) {
        parentGen = sire.generation;
    }
    // Calculate the genes of the new kitty. This is a pure function.
    uint256 childGenes = geneScience.mixGenes(matron.genes, sire.genes, matron.cooldownEndBlock - 1);
    // Get the owner's address of the matron.
    address owner = kittyIndexToOwner[_matronId];
    // Call _createKitty, returns the kitty ID.
    uint256 kittenId = _createKitty(_matronId, matron.siringWithId, parentGen + 1, childGenes, owner);
    // Remove the pregnant state from matron.
    delete matron.siringWithId;
    // Update the count of pregnant kitties.
    pregnantKitties--;
    // Pay autoBirthFee to the caller.
    msg.sender.send(autoBirthFee);
    return kittenId;
}

// In KittyBase:
function _createKitty(
    uint256 _matronId,
    uint256 _sireId,
    uint256 _generation,
    uint256 _genes,
    address _owner
)
    internal
    returns (uint)
{
    // Check if the input parameters are in valid range.
    require(_matronId == uint256(uint32(_matronId)));
    require(_sireId == uint256(uint32(_sireId)));
    require(_generation == uint256(uint16(_generation)));
    // Ensure the cooldownIndex is less than or equal to 13.
    uint16 cooldownIndex = uint16(_generation / 2);
    if (cooldownIndex > 13) {
        cooldownIndex = 13;
    }
    // Create a new kitty.
    Kitty memory _kitty = Kitty({
        genes: _genes,
        birthTime: uint64(now),
        cooldownEndBlock: 0,
        matronId: uint32(_matronId),
        sireId: uint32(_sireId),
        siringWithId: 0,
        cooldownIndex: cooldownIndex,
        generation: uint16(_generation)
    });
    // Push the new kitty to the end of the kitties array.
    uint256 newKittenId = kitties.push(_kitty) - 1;
    // Check if the total count of kitties is less than or equal to max of uint32.
    require(newKittenId == uint256(uint32(newKittenId)));
    // Assign the new kitty to its owner.
    _transfer(0, _owner, newKittenId);
    return newKittenId;
}
```

The data operations include:

|Index|Contract|Data|R/W|
|-:|-|-|-|
|1|KittyCore|kitties[_matronId]|R|
|2|KittyCore|kitties[_sireId]|R|
|3|KittyCore|kittyIndexToOwner[_matronId]|R|
|4|KittyCore|kitties.push(_kitty)|W|
|5|KittyCore|kittyIndexToOwner[newKittenId]|W|
|6|KittyCore|ownershipTokenCount[_owner]|R+W|
|7|KittyCore|kitties[_matronId]|W|
|8|KittyCore|pregnantKitties|R+W|

The data entities involved are:

* The **matron** kitty: row No. 1, 3, 7;
* The **sire** kitty: row No. 2;
* The owner account of matron: row No. 6;
* The new born kitty: row No. 4, 5;
* The **KittyCore** contract: row No. 8.

A new problem introduced here: the new born kitty. In the original implementation of CryptoKitties, all the kitties are stored in an array. Since all the transactions are processed sequentially, every new born kitty is pushed into the end of the array, and the index of this kitty in the array is used as the ID of this kitty. But when such transactions are processed in parallel, more than 1 new kitties may be pushed into the end of the same array simultaneously, the index of each kitty cannot be determined and the total kitties' count cannot be controlled.

So in the parallel version of CryptoKitties, we use a concurrent hash map to replace the array. We use the kitty ID as the key of the hash map, and the **Kitty** object as the value. But where does the kitty ID come from? The answer is a deterministic UUID generator provided by the Arcology parallelism infrastructure. The UUID is a uint256, and the total kitties count will be controlled by a global concurrent counter.

## ParallelKitties

ParallelKitties is the parallelized version of CryptoKitties, in which many of the parallelism infrastructures provided by Arcology are used, including:

* Use **ConcurrentHashMap** instead of Ethereum built-in array and map. ConcurrentHashMap allows concurrent accesses on it, as long as by different keys;

* Use **ConcurrentCounter** instead of common global variables. ConcurrentCounter enabled concurrent increasing and decreasing operations on the same counter;

* Use **UUIDGenerator** as the ID generator of new born kitties.

> In the code listed below, all of the six scenarios analyzed above will be covered. Although the code is close enough to the real application, it hasn't been well optimized and cannot be compiled directly. Only the six functions mentioned above and the data structures they depend on are covered, not the complete CryptoKitties implementation. The purpose is to give offer a glimpse into how to write a parallel smart contract with the concurrency framework provided by Arcology. All the events, modifiers and some of the arguments checking logic in the original CryptoKitties are omitted.

> To make it easier to compare the differences between the original version and the parallel version, the code is structured in the same way as the orginal cryptoKitties. Most of the short functions were inlined, some of the long functions were not expanded to avoid duplication. Basically, we kept the name and reimpletemented these functions to support concurrency.

### ConcurrentLib.sol

Part of the declarations in ConcurrentLib.

```Solidity
contract ConcurrentHashMap {
    enum DataType {INVALID, ADDRESS, UINT256, BYTES}
    function create(string calldata id, int32 keyType, int32 valueType) external;
    function getAddress(string calldata id, uint256 key) external returns (address);
    function set(string calldata id, uint256 key, address value) external;
    function getUint256(string calldata id, uint256 key) external returns (uint256);
    function set(string calldata id, uint256 key, uint256 value) external;
    function getBytes(string calldata id, uint256 key) external returns (bytes memory);
    function set(string calldata id, uint256 key, bytes calldata value) external;
    function deleteKey(string calldata id, uint256 key) external;
    
    function getAddress(string calldata id, address key) external returns (address);
    function set(string calldata id, address key, address value) external;
    function getUint256(string calldata id, address key) external returns (uint256);
    function set(string calldata id, address key, uint256 value) external;
    function getBytes(string calldata id, address key) external returns (bytes memory);
    function set(string calldata id, address key, bytes calldata value) external;
    function deleteKey(string calldata id, address key) external;
}

contract ConcurrentCounter {
    function create(string calldata id) external;

    function increase(string calldata id) external;
    function decrease(string calldata id) external;
}

contract UUIDGenerator {
    function get() external returns (uint256);
}
```

### KittyCore.sol

```Solidity
contract KittyCore {
    struct Kitty {
        uint256 genes;
        uint64 birthTime;
        uint64 cooldownEndBlock;
        uint32 matronId;
        uint32 sireId;
        uint32 siringWithId;
        uint16 cooldownIndex;
        uint16 generation;
    }
    SaleClockAuction public saleAuction;
    SiringClockAuction public siringAuction;
    uint256 public autoBirthFee = 2 finney;
    uint32[14] public cooldowns = [
        uint32(1 minutes),
        uint32(2 minutes),
        uint32(5 minutes),
        uint32(10 minutes),
        uint32(30 minutes),
        uint32(1 hours),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(16 hours),
        uint32(1 days),
        uint32(2 days),
        uint32(4 days),
        uint32(7 days)
    ];
    uint256 public secondsPerBlock = 15;
    GeneScienceInterface public geneScience;
    
    // Initialize concurrent containers in constructor.
    constructor() public {
        // ConcurrentHashMap is binded to system reserved address 0x81.
        ConcurrentHashMap chm = ConcurrentHashMap(0x81);
        chm.create("kitties", int32(ConcurrentHashMap.DataType.UINT256), int32(ConcurrentHashMap.DataType.BYTES));
        chm.create("kittyIndexToOwner", int32(ConcurrentHashMap.DataType.UINT256), int32(ConcurrentHashMap.DataType.ADDRESS));
        chm.create("ownershipTokenCount", int32(ConcurrentHashMap.DataType.ADDRESS), int32(ConcurrentHashMap.DataType.UINT256));
        chm.create("kittyIndexToApproved", int32(ConcurrentHashMap.DataType.UINT256), int32(ConcurrentHashMap.DataType.ADDRESS));
        chm.create("sireAllowedToAddress", int32(ConcurrentHashMap.DataType.UINT256), int32(ConcurrentHashMap.DataType.ADDRESS));
        // ConcurrentCounter is binded to system reserved address 0x91.
        ConcurrentCounter cc = ConcurrentCounter(0x91);
        cc.create("saleAuctionTokenCount");
        cc.create("siringAuctionTokenCount");
        cc.create("pregnantKitties");
    }

    function createSaleAuction(
        uint256 _kittyId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    ) external {
        ConcurrentHashMap chm = ConcurrentHashMap(0x81);
        // msg.sender owns _kittyId.
        require(chm.getAddress("kittyIndexToOwner", _kittyId) == msg.sender);
        // _kittyId is not pregnant.
        // Load the serialized kitty data, deserialize it into object, then use it.
        bytes memory kittyBytes = chm.getBytes("kitties", _kittyId);
        Kitty memory kitty = bytesToKitty(kittyBytes);
        require(kitty.siringWithId == 0);
        // Approve _kittyId to transfer to saleAuction.
        chm.set("kittyIndexToApproved", _kittyId, address(saleAuction));
        saleAuction.createAuction(
            _kittyId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }
    
    function createSiringAuction(
        uint256 _kittyId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    ) external {
        ConcurrentHashMap chm = ConcurrentHashMap(0x81);
        // msg.sender owns _kittyId.
        require(chm.getAddress("kittyIndexToOwner", _kittyId) == msg.sender);
        // _kittyId is ready to breed.
        bytes memory kittyBytes = chm.getBytes("kitties", _kittyId);
        Kitty memory kitty = bytesToKitty(kittyBytes);
        require(kitty.siringWithId == 0 && kitty.cooldownEndBlock <= uint64(block.number));
        // Approve _kittyId to transfer to siringAuction.
        chm.set("kittyIndexToApproved", _kittyId, address(siringAuction));
        siringAuction.createAuction(
            _kittyId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }
    
    function bidOnSiringAuction(
        uint256 _sireId,
        uint256 _matronId
    ) external payable {
        ConcurrentHashMap chm = ConcurrentHashMap(0x81);
        // msg.sender owns _matronId.
        require(chm.getAddress("kittyIndexToOwner", _matronId) == msg.sender);
        // _matronId is ready to breed.
        bytes memory matronBytes = chm.getBytes("kitties", _matronId);
        Kitty memory matron = bytesToKitty(matronBytes);
        require(matron.siringWithId == 0 && matron.cooldownEndBlock <= uint64(block.number));
        // Sire and matron can breed with each other via auction.
        bytes memory sireBytes = chm.getBytes("kitties", _sireId);
        Kitty memory sire = bytesToKitty(sireBytes);
        require(_isValidMatingPair(matron, _matronId, sire, _sireId));
        // Input value is enough to pay.
        uint256 currentPrice = siringAuction.getCurrentPrice(_sireId);
        require(msg.value >= currentPrice + autoBirthFee);
        // Call SireClockAuction.bid.
        siringAuction.bid.value(msg.value - autoBirthFee)(_sireId);
        _breedWith(uint32(_matronId), uint32(_sireId));
    }
    
    function breedWithAuto(uint256 _matronId, uint256 _sireId) external payable {
        require(msg.value >= autoBirthFee);
        // Caller must own the matron.
        ConcurrentHashMap chm = ConcurrentHashMap(0x81);
        require(chm.getAddress("kittyIndexToOwner", _matronId) == msg.sender);
        // Check if a sire has authorized breeding with this matron.
        address matronOwner = chm.getAddress("kittyIndexToOwner", _matronId);
        address sireOwner = chm.getAddress("kittyIndexToOwner", _sireId);
        require(matronOwner == sireOwner || chm.getAddress("sireAllowedToAddress", _sireId) == matronOwner);
        // Check if matron is ready to breed.
        bytes memory matronBytes = chm.getBytes("kitties", _matronId);
        Kitty memory matron = bytesToKitty(matronBytes);
        require(matron.siringWithId == 0 && matron.cooldownEndBlock <= uint64(block.number));
        // Check if sire is ready to breed.
        bytes memory sireBytes = chm.getBytes("kitties", _sireId);
        Kitty memory sire = bytesToKitty(sireBytes);
        require(sire.siringWithId == 0 && sire.cooldownEndBlock <= uint64(block.number));
        require(_isValidMatingPair(matron, _matronId, sire, _sireId));
        _breedWith(_matronId, _sireId);
    }
    
    function giveBirth(uint256 _matronId) external returns (uint256) {
        ConcurrentHashMap chm = ConcurrentHashMap(0x81);
        // Check if the matron exists.
        bytes memory matronBytes = chm.getBytes("kitties", _matronId);
        Kitty memory matron = bytesToKitty(matronBytes);
        require(matron.birthTime != 0);
        // Check if matron is ready to give birth.
        require(matron.siringWithId != 0 && matron.cooldownEndBlock <= uint64(block.number));
        bytes memory sireBytes = chm.getBytes("kitties", matron.siringWithId);
        Kitty memory sire = bytesToKitty(sireBytes);
        // Determine the generation of kitten.
        uint16 parentGen = matron.generation;
        if (sire.generation > matron.generation) {
            parentGen = sire.generation;
        }
        // Gene science.
        uint256 childGenes = geneScience.mixGenes(matron.genes, sire.genes, matron.cooldownEndBlock - 1);
        // Owner of the kitten.
        address owner = chm.getAddress("kittyIndexToOwner", _matronId);
        // Create kitten.
        uint256 kittenId = _createKitty(_matronId, matron.siringWithId, parentGen + 1, childGenes, owner);
        // Update matron's info.
        matron.siringWithId = 0;
        matronBytes = kittyToBytes(matron);
        chm.set("kitties", _matronId, matronBytes);
        // Update counter.
        ConcurrentCounter cc = ConcurrentCounter(0x91);
        cc.decrease("pregnantKitties");
        msg.sender.send(autoBirthFee);
        return kittenId;
    }
    
    // Implement ERC721 interface begin.
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        ConcurrentHashMap chm = ConcurrentHashMap(0x81);
        require(chm.getAddress("kittyIndexToApproved", _tokenId) == msg.sender);
        require(chm.getAddress("kittyIndexToOwner", _tokenId) == _from);
        _transfer(_from, _to, _tokenId);
    }
    
    function transfer(address _to, uint256 _tokenId) external {
        ConcurrentHashMap chm = ConcurrentHashMap(0x81);
        require(chm.getAddress("kittyIndexToOwner", _tokenId) == msg.sender);
        _transfer(msg.sender, _to, _tokenId);
    }
    // Implement ERC721 interface end.
    
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        ConcurrentHashMap chm = ConcurrentHashMap(0x81);
        ConcurrentCounter cc = ConcurrentCounter(0x91);
        // Update counter for _to.
        if (_to == address(saleAuction)) {
            cc.increase("saleAuctionTokenCount");
        } else if (_to == address(siringAuction)) {
            cc.increase("siringAuctionTokenCount");
        } else {
            uint256 count = chm.getUint256("ownershipTokenCount", _to);
            count++;
            chm.set("ownershipTokenCount", _to, count);
        }
        // Give _tokenId to _to.
        chm.set("kittyIndexToOwner", _tokenId, _to);
        // If it is not gen0 kitty.
        if (_from != address(0)) {
            // Update counter for _from.
            if (_from == address(saleAuction)) {
                cc.decrease("saleAuctionTokenCount");
            } else if (_from == address(siringAuction)) {
                cc.decrease("siringAuctionTokenCount");
            } else {
                uint256 count = chm.getUint256("ownershipTokenCount", _from);
                count--;
                chm.set("ownershipTokenCount", _from, count);
            }
            // Clear permission.
            chm.deleteKey("sireAllowedToAddress", _tokenId);
            chm.deleteKey("kittyIndexToApproved", _tokenId);
        }
    }
    
    function _isValidMatingPair(
        Kitty memory _matron,
        uint256 _matronId,
        Kitty memory _sire,
        uint256 _sireId
    ) private view returns (bool) {
        if (_matronId == _sireId) {
            return false;
        }        
        if (_matron.matronId == _sireId || _matron.sireId == _sireId) {
            return false;
        }
        if (_sire.matronId == _matronId || _sire.sireId == _matronId) {
            return false;
        }
        if (_sire.matronId == 0 || _matron.matronId == 0) {
            return true;
        }
        if (_sire.matronId == _matron.matronId || _sire.matronId == _matron.sireId) {
            return false;
        }
        if (_sire.sireId == _matron.matronId || _sire.sireId == _matron.sireId) {
            return false;
        }
        return true;
    }
    
    function _breedWith(uint256 _matronId, uint256 _sireId) private {
        ConcurrentHashMap chm = ConcurrentHashMap(0x81);
        bytes memory sireBytes = chm.getBytes("kitties", _sireId);
        Kitty memory sire = bytesToKitty(sireBytes);
        bytes memory matronBytes = chm.getBytes("kitties", _matronId);
        Kitty memory matron = bytesToKitty(matronBytes);
        // Mark the matron as pregnant.
        matron.siringWithId = uint32(_sireId);
        // Trigger cooldown for both parents.
        matron.cooldownEndBlock = uint64((cooldowns[matron.cooldownIndex]/secondsPerBlock) + block.number);
        if (matron.cooldownIndex < 13) {
            matron.cooldownIndex += 1;
        }
        sire.cooldownEndBlock = uint64((cooldowns[sire.cooldownIndex]/secondsPerBlock) + block.number);
        if (sire.cooldownIndex < 13) {
            sire.cooldownIndex += 1;
        }
        // Write back to storage.
        sireBytes = kittyToBytes(sire);
        chm.set("kitties", _sireId, sireBytes);
        matronBytes = kittyToBytes(matron);
        chm.set("kitties", _matronId, matronBytes);
        // Clear siring permission for both parents.
        chm.deleteKey("sireAllowedToAddress", _matronId);
        chm.deleteKey("sireAllowedToAddress", _sireId);
        // Update counter.
        ConcurrentCounter cc = ConcurrentCounter(0x91);
        cc.increase("pregnantKitties");
    }
    
    function _createKitty(
        uint256 _matronId,
        uint256 _sireId,
        uint256 _generation,
        uint256 _genes,
        address _owner
    ) internal returns (uint) {
        uint16 cooldownIndex = uint16(_generation / 2);
        if (cooldownIndex > 13) {
            cooldownIndex = 13;
        }
        Kitty memory _kitty = Kitty({
            genes: _genes,
            birthTime: uint64(now),
            cooldownEndBlock: 0,
            matronId: uint32(_matronId),
            sireId: uint32(_sireId),
            siringWithId: 0,
            cooldownIndex: cooldownIndex,
            generation: uint16(_generation)
        });
        bytes memory kittyBytes = kittyToBytes(_kitty);
        // Generate UUID for kitten.
        UUIDGenerator ug = UUIDGenerator(0x92);
        uint256 newKittenId = ug.get();
        // Add new kitten to the set.
        ConcurrentHashMap chm = ConcurrentHashMap(0x81);
        chm.set("kitties", newKittenId, kittyBytes);
        // Transfer the kitten to _owner.
        _transfer(address(0), _owner, newKittenId);
        return newKittenId;
    }

    // Serialize and deserialize method for the Kitty structure, usable but not the best.
    function kittyToBytes(Kitty memory kitty) private pure returns (bytes memory) {
        uint size = 32 + 8 + 8 + 4 + 4 + 4 + 2 + 2;
        bytes memory data = new bytes(size);
        uint counter = 0;
        for (uint i = 0; i < 32; i++) {
            data[counter] = bytes32(kitty.genes)[i];
            counter++;
        }
        for (uint i = 0; i < 8; i++) {
            data[counter] = byte(uint8(kitty.birthTime >> (8 * i) & uint64(255)));
            counter++;
        }
        for (uint i = 0; i < 8; i++) {
            data[counter] = byte(uint8(kitty.cooldownEndBlock >> (8 * i) & uint64(255)));
            counter++;
        }
        for (uint i = 0; i < 4; i++) {
            data[counter] = byte(uint8(kitty.matronId >> (8 * i) & uint32(255)));
            counter++;
        }
        for (uint i = 0; i < 4; i++) {
            data[counter] = byte(uint8(kitty.sireId >> (8 * i) & uint32(255)));
            counter++;
        }
        for (uint i = 0; i < 4; i++) {
            data[counter] = byte(uint8(kitty.siringWithId >> (8 * i) & uint32(255)));
            counter++;
        }
        for (uint i = 0; i < 2; i++) {
            data[counter] = byte(uint8(kitty.cooldownIndex >> (8 * i) & uint16(255)));
            counter++;
        }
        for (uint i = 0; i < 2; i++) {
            data[counter] = byte(uint8(kitty.generation >> (8 * i) & uint16(255)));
            counter++;
        }
        return data;
    }

    function bytesToKitty(bytes memory data) private pure returns (Kitty memory) {
        Kitty memory kitty;
        uint counter = 0;
        for (uint i = 0; i < 32; i++) {
            uint256 temp = uint256(uint8(data[counter]));
            temp <<= 8 * i;
            kitty.genes ^= temp;
            counter++;
        }
        for (uint i = 0; i < 8; i++) {
            uint64 temp = uint64(uint8(data[counter]));
            temp <<= 8 * i;
            kitty.birthTime ^= temp;
            counter++;
        }
        for (uint i = 0; i < 8; i++) {
            uint64 temp = uint64(uint8(data[counter]));
            temp <<= 8 * i;
            kitty.cooldownEndBlock ^= temp;
            counter++;
        }
        for (uint i = 0; i < 4; i++) {
            uint32 temp = uint32(uint8(data[counter]));
            temp <<= 8 * i;
            kitty.matronId ^= temp;
            counter++;
        }
        for (uint i = 0; i < 4; i++) {
            uint32 temp = uint32(uint8(data[counter]));
            temp <<= 8 * i;
            kitty.sireId ^= temp;
            counter++;
        }
        for (uint i = 0; i < 4; i++) {
            uint32 temp = uint32(uint8(data[counter]));
            temp <<= 8 * i;
            kitty.siringWithId ^= temp;
            counter++;
        }
        for (uint i = 0; i < 2; i++) {
            uint16 temp = uint16(uint8(data[counter]));
            temp <<= 8 * i;
            kitty.cooldownIndex ^= temp;
            counter++;
        }
        for (uint i = 0; i < 2; i++) {
            uint16 temp = uint16(uint8(data[counter]));
            temp <<= 8 * i;
            kitty.generation ^= temp;
            counter++;
        }
        return kitty;
    }
}
```

### ClockAuction.sol

```Solidity
contract ClockAuction {
    struct Auction {
        address seller;
        uint128 startingPrice;
        uint128 endingPrice;
        uint64 duration;
        uint64 startedAt;
    }
    ERC721 public nonFungibleContract;
    
    constructor() public {
        ConcurrentHashMap chm = ConcurrentHashMap(0x81);
        chm.create("tokenIdToAuction", int32(ConcurrentHashMap.DataType.UINT256), int32(ConcurrentHashMap.DataType.BYTES));
    }
    
    function _bid(uint256 _tokenId, uint256 _bidAmount) internal returns (uint256) {
        ConcurrentHashMap chm = ConcurrentHashMap(0x81);
        bytes memory auctionBytes = chm.getBytes("tokenIdToAuction", _tokenId);
        Auction memory auction = bytesToAuction(auctionBytes);
        // Ensure the auction exists.
        require(auction.startedAt > 0);
        // Calculate current price based on auction.
        uint256 price = _currentPrice(auction);
        require(_bidAmount >= price);
        address payable seller = address(uint160(auction.seller));
        // Remove the auction.
        chm.deleteKey("tokenIdToAuction", _tokenId);
        if (price > 0) {
            uint256 auctioneerCut = _computeCut(price);
            uint256 sellerProceeds = price - auctioneerCut;
            seller.transfer(sellerProceeds);
        }
        uint256 bidExcess = _bidAmount - price;
        msg.sender.transfer(bidExcess);
        return price;
    } 
    
    // Serialize and deserialize method for the Auction structure.
    function auctionToBytes(Auction memory auction) internal pure returns (bytes memory) {
        uint size = 20 + 16 + 16 + 8 + 8;
        bytes memory data = new bytes(size);
        uint counter = 0;
        for (uint i = 0; i < 20; i++) {
            data[counter] = bytes20(auction.seller)[i];
            counter++;
        }
        for (uint i = 0; i < 16; i++) {
            data[counter] = byte(uint8(auction.startingPrice >> (8 * i) & uint128(255)));
            counter++;
        }
        for (uint i = 0; i < 16; i++) {
            data[counter] = byte(uint8(auction.endingPrice >> (8 * i) & uint128(255)));
            counter++;
        }
        for (uint i = 0; i < 8; i++) {
            data[counter] = byte(uint8(auction.duration >> (8 * i) & uint64(255)));
            counter++;
        }
        for (uint i = 0; i < 8; i++) {
            data[counter] = byte(uint8(auction.startedAt >> (8 * i) & uint64(255)));
            counter++;
        }
        return data;
    }

    function bytesToAuction(bytes memory data) internal pure returns (Auction memory) {
        Auction memory auction;
        uint counter = 0;
        uint160 seller = 0;
        for (uint i = 0; i < 20; i++) {
            seller = (seller << 8) + uint160(uint8(data[counter]));
            counter++;
        }
        auction.seller = address(seller);
        for (uint i = 0; i < 16; i++) {
            uint128 temp = uint128(uint8(data[counter]));
            temp <<= 8 * i;
            auction.startingPrice ^= temp;
            counter++;
        }
        for (uint i = 0; i < 16; i++) {
            uint128 temp = uint128(uint8(data[counter]));
            temp <<= 8 * i;
            auction.endingPrice ^= temp;
            counter++;
        }
        for (uint i = 0; i < 8; i++) {
            uint64 temp = uint64(uint8(data[counter]));
            temp <<= 8 * i;
            auction.duration ^= temp;
            counter++;
        }
        for (uint i = 0; i < 8; i++) {
            uint64 temp = uint64(uint8(data[counter]));
            temp <<= 8 * i;
            auction.startedAt ^= temp;
            counter++;
        }
        return auction;
    }
}
```

### SaleClockAuction.sol

```Solidity
contract SaleClockAuction is ClockAuction {
    uint256 public gen0SaleCount;
    uint256[5] public lastGen0SalePrices;
    
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    ) external {
        // Transfer _tokenId to SaleClockAuction.
        nonFungibleContract.transferFrom(_seller, address(this), _tokenId);
        // Ensure the call comes from KittyCore.
        require(msg.sender == address(nonFungibleContract));
        // Add auction to the list.
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        bytes memory auctionBytes = auctionToBytes(auction);
        ConcurrentHashMap chm = ConcurrentHashMap(0x81);
        chm.set("tokenIdToAuction", _tokenId, auctionBytes);
    }
    
    function bid(uint256 _tokenId) external payable {
        // Save the address of seller.
        ConcurrentHashMap chm = ConcurrentHashMap(0x81);
        bytes memory auctionBytes = chm.getBytes("tokenIdToAuction", _tokenId);
        Auction memory auction = bytesToAuction(auctionBytes);
        address seller = auction.seller;
        // Call ClockAuction._bid.
        uint256 price = _bid(_tokenId, msg.value);
        // Transfer _tokenId to msg.sender.
        nonFungibleContract.transfer(msg.sender, _tokenId);
        // If it is a gen0 auction.
        if (seller == address(nonFungibleContract)) {
            // Track gen0 sale prices.
            lastGen0SalePrices[gen0SaleCount % 5] = price;
            gen0SaleCount++;
        }
    }
}
```

### SiringClockAuction.sol

```Solidity
contract SiringClockAuction is ClockAuction {
    constructor() public {
        ConcurrentHashMap chm = ConcurrentHashMap(0x81);
        chm.create("tokenIdToAuction", int32(ConcurrentHashMap.DataType.UINT256), int32(ConcurrentHashMap.DataType.BYTES));
    }
    
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    ) external {
        // Transfer _tokenId to SiringClockAuction.
        nonFungibleContract.transferFrom(_seller, address(this), _tokenId);
        // Ensure the call comes from KittyCore.
        require(msg.sender == address(nonFungibleContract));
        // Add auction to the list.
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        bytes memory auctionBytes = auctionToBytes(auction);
        ConcurrentHashMap chm = ConcurrentHashMap(0x81);
        chm.set("tokenIdToAuction", _tokenId, auctionBytes);
    }
    
    function bid(uint256 _tokenId) external payable {
        // Ensure the call comes from KittyCore.
        require(msg.sender == address(nonFungibleContract));
        // Cache the seller address.
        ConcurrentHashMap chm = ConcurrentHashMap(0x81);
        bytes memory auctionBytes = chm.getBytes("tokenIdToAuction", _tokenId);
        Auction memory auction = bytesToAuction(auctionBytes);
        address seller = auction.seller;
        // Call ClockAuction._bid.
        _bid(_tokenId, msg.value);
        // Give tokenId back to the seller.
        nonFungibleContract.transfer(seller, _tokenId);
    }
    
    function getCurrentPrice(uint256 _tokenId) external returns (uint256) {
        ConcurrentHashMap chm = ConcurrentHashMap(0x81);
        bytes memory auctionBytes = chm.getBytes("tokenIdToAuction", _tokenId);
        Auction memory auction = bytesToAuction(auctionBytes);
        require(auction.startedAt > 0);
        return _currentPrice(auction);
    }
}
```

## Test Goals

The purpose of these tests is to see if:

* Multi threaded EVM on single machine can bring us reasonable performance improvements compare to the single thread EVM;
* By horizontal expansion, the performance improvements are directly proportional to the number of machines we use.

If the two goals can be achieved, then we can say that our design can utilize both the multi core processors in a single machine and the horizontal expansion which may gives us unlimited performance in theory.

### Test Setup

We used two different types of machines in the test they are:

* Configuration 1（C1）
    * CPU - AMD Ryzen Threadripper 2990WX 32-Core Processor, 32 physical cores, 64 logical cores;
    * Memory - 64GB in total, 4 x 16G DDR4 2133 MT/s;
* Configuration 2（C2）
    * CPU - Intel Core i3-8100, 4 physical cores, 4 logical cores;
    * Memory - 16GB in total, 1 x 16G DDR4 2133 MT/s.

Software Environment：

* OS - Ubuntu 18.04.3 LTS;
* Golang compile - go1.13 linux/amd64;
* Kafka - wurstmeister/kafka and wurstmeister/zookeeper docker images run in single broker mode;
* Others - GOGC = 300.

In all the tests blow, scheduler、arbitrator and Kafka service are all running on C2. 

### Data Preparation

1. Initialize 600,000 accounts and enough balance for them to pay the gas;
2. Deploy ParallelKitties;
3. Generate 1.2 millions of kitties which are not pregnant (we use half of the kitties in the tests, the other half of kitties are used as background data);
4. Prepare 600,000 transactions in scheduler, every transaction calls createSiringAuction once. The sender and input parameters of these transactions are different so every transaction will not conflict with the other transactions (Conflictions have no influence on performance, conflicted transactions will be marked as failed by arbitrator after execution);
5. Scheduler send these transactions to executor(s) via Kafka;
6. Executor(s) pulls transactions from Kafka and execute them until all the transactions are processed.

In the tests below, when we say 'execution time', we mean the time from the beginning of step 5 to the end of step 6.

### Test 1：Multithreaded processing on a single machine

In this case, the executor is running on C1. 

| Num of Threads | Execution Time (seconds) |   TPS | Improvement compare to single thread | Improvements compare to half of the threads |
|-------:|---------:|------:|---------------------:|-------------------------------:|
|      1 |      259 |  2317 |                    1 |                              - |
|      2 |      138 |  4348 |                 1.88 |                           1.88 |
|      4 |       75 |  8000 |                 3.45 |                           1.84 |
|      8 |       43 | 13953 |                 6.02 |                           1.74 |
|     16 |       26 | 23077 |                 9.96 |                           1.65 |
|     32 |       15 | 40000 |                17.27 |                           1.73 |

We can see that when the number of threads doubled, the total performance improvement is between x1.6 to x1.8.

### Test 2：Horizontal scaling over multiple machines

In this case, the executor(s) are running on 1 or more C2.

| Num of Machines | Num of Threads (on each machine) | Execution Time (seconds) | TPS | Improvement compare to 1 machine, single thread | Improvement compare to 1 machine, same number of threads |
|-------:|-------:|---------:|----:|---------------------------:|-------------------------------:|
|      1 |      1 |      232 | 2586|                          1 |                              1 |
|      2 |      1 |      116 | 5172|                          2 |                              2 |
|      4 |      1 |       58 |10345|                          4 |                              4 |
|      1 |      2 |      120 | 5000|                       1.93 |                              1 |
|      2 |      2 |       60 |10000|                       3.87 |                              2 |
|      4 |      2 |       30 |20000|                       7.73 |                              4 |
|      1 |      4 |       70 | 8571|                       3.31 |                              1 |
|      2 |      4 |       35 |17143|                       6.63 |                              2 |
|      4 |      4 |       18 |33333|                      12.89 |                              4 |

## Conclusion

- With horizontal expansion, the performance improvements are directly proportional to the number of machines we use;
- The performance of 4 machines with 4 physical cores on each is better than one 16 core machine (x12.89 vs x9.96).
