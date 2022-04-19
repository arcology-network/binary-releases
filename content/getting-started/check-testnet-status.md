# Check Network Status

- [Check Network Status](#check-network-status)
  - [1. Connect](#1-connect)
  - [2. Troubleshooting](#2-troubleshooting)
    - [2.1. Local docker testnet](#21-local-docker-testnet)
      - [2.1.1 Check your network](#211-check-your-network)
      - [2.1.2. Hardware Configuration](#212-hardware-configuration)
      - [2.1.3. Check the Container](#213-check-the-container)
    - [2.2. Other Issues](#22-other-issues)

## 1. Connect

To check if the network is reachable, paste the following line into your browser.

```sh
http://localhost:8080/blocks/latest?access_token=access_token&transactions=false
```

You should see somthing like the blow.

```json
{
  "block": {
      "height":41285,
      "hash":"b2858fbefc496e844e1a7e8a0d2ee23afb8c18492f1ce694b70160fe96db7c47",
      "coinbase":"0x971Df33B1EFe022ec4173E61f1113C3887c08b8E",
      "number":0,
      "transactions":null,
      "gasUsed":0,
      "elapsedTime":173000,
      "timestamp":1632962218
  }
}
```

>Replace the `localhost` with the node IP

## 2. Troubleshooting

If the network isn't responding, please refer to the section below.
 
### 2.1. Local docker testnet

In case you are using a local docker tesnet, please follow the steps below.

#### 2.1.1 Check your network

The testnet container should be listening on port 8080 of your host machine already.

- Your firewall must allow inbound connections to the designated port.
- The port 8080 of your docker image must be mapped to a corresponding port on your host machine.
- Check port forwarding settings on your hardware router.

#### 2.1.2. Hardware Configuration

Make sure that your machine meets the minimum hardware requirements.

#### 2.1.3. Check the Container

It is rarely that the container image has any issues, but it is still possible to [log in to the container image to make the services are running properly](./aio-login.md).

### 2.2. Other Issues

Please let us know if the problem persists.