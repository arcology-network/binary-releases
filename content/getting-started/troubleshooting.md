# Troubleshooting
- [Troubleshooting](#troubleshooting)
  - [1.1. I Can't See All the Services](#11-i-cant-see-all-the-services)
  - [1.2. The Localhost Doesn't Work](#12-the-localhost-doesnt-work)
  - [1.3. Why Am I Receiving {"sysdbg":"block is nil"}](#13-why-am-i-receiving-sysdbgblock-is-nil)
  
## 1.1. I Can't See All the Services

The whole starting process may take a few minutes. If you only see some of the services running, that is usually because other services haven't been started yet, just can check back later.

## 1.2. The Localhost Doesn't Work

Don't use the localhost 127.0.0.1 when you try to connect to a testnet from the client docker, even if the testnet container is running on the same host machine with you client container.

## 1.3. Why Am I Receiving {"sysdbg":"block is nil"}

If you are receiving {"sysdbg":"block is nil"} in the brower window, while [checking the connectivity](#153-check-the-connectivity), please [remove the testnet docker](#18-remove-the-container) first and then [start the testnet again.](#14-start-the-testnet-container)