# Connect to the AIO Image

- [Connect to the AIO Image](#connect-to-the-aio-image)
  - [1. Getting Started](#1-getting-started)
    - [1.2. Minimum Requirements](#12-minimum-requirements)
    - [1.3. Install the Docker Engine](#13-install-the-docker-engine)
    - [1.4. Download the Image](#14-download-the-image)
    - [1.5. Start the Image](#15-start-the-image)

## 1. Getting Started

The testnet docker container has virtually everything you need to get started. It is probably the easiest way to set up a testnet. 
Users can downlaod our [all-in-one testnet](../../testnet-docker-allinone.md) docker image and then start a one-node testnet localcally. 
The testnet is fully functional.

Once the testnet is running you can start interact with it through standard [Ethereum jason RPC API.](https://github.com/ethereum/execution-apis).
The docker engine is the only thing you will need other than the docker images.

### 1.2. Minimum Requirements

- 2 Cores**
- **16G RAM**
- Docker Engine

### 1.3. Install the Docker Engine

Download and install the docker engine from [here](https://www.docker.com/)

### 1.4. Download the Image

```sh
docker pull cody0yang/cluster:1.13
```

### 1.5. Start the Image

```sh
sudo docker run --name allinone-cluster -p 8080:8080 -p 7545:7545 -d cody0yang/cluster:1.13 /root/dstart.sh chainID:100 rpcPort:7545
```
