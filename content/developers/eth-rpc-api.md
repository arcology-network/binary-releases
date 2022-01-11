## eth_getBlockByHash


## 4.4. Performance Comparison 

一个前端，一个可以直接从网页以 HTTP 方式的连接节点的 Ammolite，
1. 下载Monaco Installer
2. 修改安装脚本，配合具体使用场景
3. 安装 Monaco Network (单节点)
4. 打开Ammolite 网页版
5. 配置连接信息
6. 测试连接
7. 贴入代码
8. 编译
9. 部署
10. 运行
11. 错误信息
12. 运行结果显示
13. 统计信息显示

# 5. Ammolite

Ammolite is a universal client-end framework designed to help DApp developers to interactive with Arcology networks.  With Ammolite, developers can write python scripts to simulate various types of user behaviors for their DApps deployed on Arcology. It has the following features:

- Generating and sending huge amount of transactions to Arcology network
- Hosting multiple DApp clients
- Supporting complex DApp logics
- Multithreaded
- Simulating 1000 concurrent users per instance 
- Horizontal scaling
- Persisting user data in MongoDB 
It is easier to 

## 5.1 Interface Specification

<!-- Developers need to implement the following interfaces 
# Returns the DApp Name，uniquely identify different DApps hosted Ammolite
def name():

# Returns receipt subscription information in a map, keys can take 3 types of values: 
# “contract” – Subscribed to all calls to a particular address represented by the key
# “tx” - Subscribed to all calls made by the instance 
# “none” – No receipt subscribed
def subscribed_receipts():

# Returns MongoDB instance name, multiple Ammolite instances can share one MongoDB
def db_namespace():

# 在一个实例初始化时调用，传入参数包括：
# args - 该实例的启动参数，类型是map，其中包括以下字段：
# signer - 用于执行交易签名的函数句柄，参数为（tx，priv_key）,
# priv_key – 32-byte private key ；
# address – 20-byte address；
# balance – Account initial balance。
# 以及其他用户通过配置文件提供的自定义参数（这部分目前还没有实现）；
# context - 该实例的上下文，类型是map，同一脚本的不同实例具有独立的上下文；
# db - pymongo的Database句柄，用于用户脚本与数据库之间交互。
def init(args, context, db):

# 该函数在每一个新块产生后调用，前三个参数与init含义相同，receipts类型为map，key为交易哈希，value为receipt对象。
# 包含从上一次调用到本次调用之间产生的所有该应用订阅的receipts。
# 该函数的返回值为交易列表，类型为array，其中的每一个元素表示一个交易，交易的类型为map，包含以下字段：
# raw - 通过签名并进行RLP encode的raw transaction；
# hash - 交易哈希；
# to - 交易的接收方地址。
# 后两个字段并不是发起交易所必须的，这两个字段主要是提供给client-svc，用于receipts分发逻辑。否则client-svc就需要
# 对raw transaction进行RLP decode和签名验证后才能获取这些信息。 -->
def run(args, context, db, receipts):


## 5.2. RPC Connection

ammolite的GRPC连接设置，为了接收client-svc推送的receipts，
ammolite实现了一组GRPC接口。
server: {ip: localhost, port: 50001}

client-svc连接设置
clientsvc: localhost:50000

DApps设置，下列设置表示：为dapps路径下的transfer.py脚本启动2个
实例；为dapps/ecommerce路径下的platform.py脚本启动1个实例。
dapps: {dapps.transfer: 2, dapps.ecommerce.platform: 1}

ammolite使用的MongoDB连接设置。
mongo: {ip: localhost, port: 32768}

# 6. Running the Code

Arcology provides two ways to run smart contract on Arcology network
- An Arcology network with at least one node
- Tools to connect to a 

## 6.1 Deployment

To test run a smart contrast, developers must deploy a cluster network, At least of one node. On Arcology, a node is You must have at least on connect to one Arcology node. 

6.2	Installation

6.3	Running Code

6.4	Error Message


6.5	Configuration
客户端脚本一般存放在ammolite的dapps路径下，例如：

ammolite
  |-- dapps
        |-- transfer.py
        |-- ecommerce
              |-- platform.py
              |-- buyer.py
              |-- seller.py




6.6	Example 













