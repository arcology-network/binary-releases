# Arcology Releases

**v2.0.0**
- Integrated Optimism Bridge: Enhanced interoperability with the Optimism network.
- Upgrade to Go 1.22: Updated to the latest version of Go for improved performance and security.
- Reconstructed Storage Structure and Process: Overhauled the storage architecture for better efficiency and scalability.
- Refactored Trade Execution Phase Process: Improved the trade execution process for increased reliability and speed.
- Refactored Scheduling Phase Process: Enhanced the scheduling phase for better resource management and performance.

**v1.9.0**
- Added Merkle-Proof Logic: Implemented Merkle-proof verification to enhance data integrity and security.

**v1.8.0**
- Implemented Ethereum API Logic: Added support for Ethereum API to enhance blockchain interaction capabilities.
- Upgrade to Go 1.20: Updated to Go 1.20 for better performance and security.
- Integrated BlockScout Monitoring: Added BlockScout for comprehensive blockchain monitoring and analysis.


**v1.7.1**
- Removed all other concurrent containers.
- Updated showcases accordingly.
- Disabled the object pool for univalue temporarily.
- Used new chain ID 16.
- Some performance optimization.
- Fixed a bug in fast sync.
- Do not ignore the last blockend message before the end of fast sync.
- Fixed a bug in receipt query.
- Added Peer connect exceptions handling.
- Added realtime tps to Explorer.
- Added optimization parameters.

**v1.6**
- Upgraded to GO v1.19.
- Refactored executor service to process multiple deferred functions at the same time.
- Refactored executor scheduling service.
- Transaction reaping based on nonce.  
- Some bug fixes.

**v1.5**
- Added transition syncing.
- Added full syncing mode.
- Added node restart workflow.

**v1.4**
- Added intra-process deployment mode.
- Performance optimization.

**v1.3**
- Added Ethereum standard RPC API support.
- Performance optimization.

**v1.2**
- Added block syncing.

**v1.1**
- Optimized and bug fixes in concurrenctUrl.
