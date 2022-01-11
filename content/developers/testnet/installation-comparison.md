# Installation Comparison

- [Installation Comparison](#installation-comparison)
  - [1. Introduction](#1-introduction)
  - [2. Installation Options](#2-installation-options)
    - [2.1. Docker Images](#21-docker-images)
    - [2.2. Single Machine Installation](#22-single-machine-installation)
    - [2.3. Multiple Machine Installation](#23-multiple-machine-installation)
    - [2.4. Cloud Hosts](#24-cloud-hosts)

## 1. Introduction

Arcology is a very powerful and sophisticated system. For other blockchain networks, everything has to run on the same machine. Arcology support horizontal scaling, you can horizontally scale many key modules like transaction execution and data storage. Basically, users can tune their clusters based on applications and budgets. 

Arcology is highly configurable. For example, you may have 12 machines in total and you want 6 of them to run multiple EVM instances for transaction processing, 4 others for storage and 2 for other services, or just you could have only 2 machines running EVMs and 8 machine running storage and 2 for other services.

This document tries to explore different installation options and pros and cons associated with them. The goal is to help Arcology users set up they Arcology testnets more effortlessly and smoothly. Users can find detailed installation guides in different sections below.

## 2. Installation Options

Below are the installation options users can choose from.

| Complexity   | Testnet Docker|Single machine on premise| Multiple Machines on Premise| Single Machine on Cloud|Multiple Machines on Cloud|
|---|---|---|---|---|---|
| Need to Configure the Cluster            |&cross; |&cross; |&check;| &cross;  |&check;  |
| Need to Configure the Services           |&cross; |&cross; |&check;| &cross;  |&check;  |
| Deal with Dynamic IPs                    |&cross; |&cross; |&cross;| &check;  |&check;  |
| Flexibility                              |Very Low|Low     |Medium | Low      |Very High|
| Scalability                              |Very Low|Low     |High   | Low      |Very High|
| Installation Complexity                  |Very Low|Low     |High   | Low      |Very High|       
|

### 2.1. Docker Images

Using the docker images come with Arcology releases is probably the easist way to start with. These all-in-one dockers are functionally identical to larger clusters with dozens of machines. Everything is readily available out of the box.

The main focus here is to help users get familiar with Arcology. So if you are new to Arcology or developing smart contracts on Arcology platform, we strongly suggest you to try the docker version first before moving to full-scale setups

[This link explains how to use Arcology docker containers](./allinone-node-docker.md)

### 2.2. Single Machine Installation

Some users may prefer to use their own physical / virtual machine to host an Arcology testnet. With this installtion choice, users will have to go through the whole installation process. But it is still easier then setting up a full-scale cluster because users don't have to deal with mutiple machines, their IPs and network connections, etc.

### 2.3. Multiple Machine Installation

If you happen to have a bunch of spare machines and necessary network equipments then it is possible to set up a local Arcology testnet. The procedures involved in setting up a

First, you will need the IP and login credential of each machine. Then you will need to manually update IPs to credential in the configuration file. The installation configuration tells the Arcology installer what services will be installed on which machines and how many instances you would like to have.

### 2.4. Cloud Hosts

Cloud computation platforms like AWS are flexible and highly scalable. But maintaining a live cluster on amazon 24x7 can be expensive. The testnet package equips the users with the ability to start a testnet on demand. However, for the regular users, every time a new testnet is started, the AWS will assign some new machines with random IP addresses.

Users can either write down these random IPs and log in to every single host machine to install everything or they can use some tools to automate the process. Because the size of the Arcology testnets, users probaby don't want to configure these machines manually, it is a tedious and time-consuming process and may become impractical in some cases.

Some type of installation tools can help a lot but these tools must be smart and flexible encough. They need to  automatically extract the IP addresses and use the login credentials to complete the installlation on the host machines. There are a few tools written in python to help with the whole process.

Please refer to [this document](https://github.com/arcology-network/aws-ansible) on how to start a testnet on AWS.



