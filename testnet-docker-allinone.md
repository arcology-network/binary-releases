# All-in-One Testnet Docker Guide (v1.1.0)

- [All-in-One Testnet Docker Guide (v1.1.0)](#all-in-one-testnet-docker-guide-v110)
  - [1. Getting Started](#1-getting-started)
    - [1.1. Contents](#11-contents)
    - [1.2. System Requirements](#12-system-requirements)
    - [1.3. **Download the Testnet Container**](#13-download-the-testnet-container)
    - [1.4. **Start the Testnet Container**](#14-start-the-testnet-container)
    - [1.5. **Check the Testnet**](#15-check-the-testnet)
      - [1.5.1. Log in to the Testnet Container](#151-log-in-to-the-testnet-container)
      - [1.5.2. Log in to the Testnet Docker](#152-log-in-to-the-testnet-docker)
  - [2. Interact with the Testnet](#2-interact-with-the-testnet)

## 1. Getting Started

The testnet docker container has virtually everything you need to get started. It is probably the easiest way to set up a testnet. THe docker engine is only thing you will need other than the docker images.

### 1.1. Contents

There are three major components in the docker container package.

- A Testnet container
- A Client container
- Transaction data files

The transaction data files are pregenerated transaction data to facilite the test. They are part of the testnet installers, which need to be downloaded separately from [here](https://github.com/arcology-network/benchmarking/releases)

![alt text](./img/testnet/testnet-container.svg)

### 1.2. System Requirements

- ubuntu 20.04
- Docker Engine

### 1.3. **Download the Testnet Container**

```sh
sudo docker pull cody0yang/cluster:latest
```

### 1.4. **Start the Testnet Container**

Use the the command below to start the testnet container and map the port `8080` to the host machine. You will need to use the host IP to access the docker container later. Remember, the host machine is the one on which your testnet docker is running.

```sh
sudo docker run --name allinone-cluster -p 8080:8080 -d cody0yang/cluster:latest /root/dstart.sh
```
> It will take some time for the services to start. Please wait for some time before proceeding to the next steps.

### 1.5. **Check the Testnet**

Your client docker should be listening on port 8080 and ready to be connected by know. The next step is to check the testnet status to see if everything is running properly.

#### 1.5.1. Log in to the Testnet Container

First, you will need to log in to the testnet container with the command below

```sh
sudo docker exec -it allinone-cluster /bin/sh
```

#### 1.5.2. Log in to the Testnet Docker

Then, use these commands to check the if all the Arcology services are running. You can simply copy and paste them into your console.

``` sh
ps -e | grep arbitrator-svc
ps -e | grep eshing-svc
ps -e | grep generic-hashing-svc
ps -e | grep ppt-svc
ps -e | grep scheduling-svc
ps -e | grep exec-svc
ps -e | grep core-svc
ps -e | grep consensus-svc
ps -e | grep storage-svc
ps -e | grep gateway-svc
ps -e | grep frontend-svc
ps -e | grep pool-svc
```

If everything is in order, you should be able to see a list of Arcology services running in the testnet container, which should look like this. 

![alt text](./img/testnet/allinone-testnet-docker-svclist.png)

**The whole starting process may take a few minutes. If you only see some of the services are running, that is usually because other services haven't been started yet.**

## 2. Interact with the Testnet

Now, a fully function Arcology testnet has been deployed. **[This document describes how to connect to a the testnet docker and send it transactions from a client container.](./ammolite-client-docker.md)**