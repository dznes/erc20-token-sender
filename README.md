# Starknet-Foundry template

# Starknet-Foundry template ![PRs Welcome](https://img.shields.io/badge/PRs-welcome-green.svg) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/amanusk/starknet-foundry-template/blob/main/LICENSE) ![example workflow](https://github.com/amanusk/starknet-foundry-template/actions/workflows/scarb.yml/badge.svg)

Simple template of a Cairo contract built using Starknet-Foundry
The example shows a simple multi-send contract, receiving an ERC20 address, and a list of recipients, and sends tokens to recipients according to the list

This repo requires `Scarb 2.6.3`
This repo requires `sn-foundery 0.22.0`

Install Scarb with:

```
asdf plugin add scarb
asdf install scarb latest
```

(See more instructions for [asdf-scarb](https://github.com/software-mansion/asdf-scarb) installation

Install Starknet-Foundry with:

```
asdf plugin add starknet-foundry
asdf install starknet-foundry latest

```

(More instructions for [snforge](https://github.com/foundry-rs/starknet-foundry))

### Disclaimer

This is just an example, more features will be added as the language is improved while keeping it minimal

## Building

```
scarb build
```

## Testing

```
snforge test
```

## Deployment

Deployment is handled by `sncast`. See `scripts.md` for examples

### Thanks

If you like it then you shoulda put a ⭐ on it



#### starkli

mkdir ~/.starkli-wallets
mkdir ~/.starkli-wallets/deploysendertoken

starkli signer keystore from-key ~/.starkli-wallets/deploysendertoken/user0_keystore.json

starkli account fetch 0x01121c686b331F5b9D19dAF25E56F023bee7F6AC129518154a05f3Dd2b1dC0Ba --rpc https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --output ~/.starkli-wallets/deploysendertoken/account0_account.json

## Deploy Token Sender

starkli declare target/dev/token_sender_TokenSender.contract_class.json --rpc https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --account ~/.starkli-wallets/deploysendertoken/account0_account.json --keystore ~/.starkli-wallets/deploysendertoken/user0_keystore.json

Sierra compiler version not specified. Attempting to automatically decide version to use...
Network detected: sepolia. Using the default compiler version for this network: 2.6.2. Use the --compiler-version flag to choose a different version.
Declaring Cairo 1 class: 0x0309367a4eeac95797cc4a75d25e5462cab1924c7758b14e4bc816fef1fb97b1
Compiling Sierra class to CASM with compiler version 2.6.2...
CASM class hash: 0x028638f0d4fea7fa010d4ce1e417fdb411ec96e4b6ca95a285e746e019c7b54e
Contract declaration transaction: 0x02cf300ca72fdb647896c657d3fc0cf57b5ca7e2d78b887eab78f79bbc0e8bd7
Class hash declared:
0x0309367a4eeac95797cc4a75d25e5462cab1924c7758b14e4bc816fef1fb97b1

starkli deploy 0x0309367a4eeac95797cc4a75d25e5462cab1924c7758b14e4bc816fef1fb97b1 --rpc https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --account ~/.starkli-wallets/deploysendertoken/account0_account.json --keystore ~/.starkli-wallets/deploysendertoken/user0_keystore.json

Deploying class 0x0309367a4eeac95797cc4a75d25e5462cab1924c7758b14e4bc816fef1fb97b1 with salt 0x074cd33ae6b53885a392f75bfd8e8307b40fc01a462e48f4107af6b1c5f1f7d6...
The contract will be deployed at address 0x01186011b49d6b7e19cb42ccf6d641dc4194f819ab99dd4cfe809ef7038319eb
Contract deployment transaction: 0x0341b8450ab41a2c87d2a1516d1cabeb0655d4ca73dfc9e88023af19c41456ee
Contract deployed:
0x01186011b49d6b7e19cb42ccf6d641dc4194f819ab99dd4cfe809ef7038319eb

## Deploy Mock ERC20 Token

starkli declare target/dev/token_sender_MockERC20.contract_class.json --rpc https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --account ~/.starkli-wallets/deploysendertoken/account0_account.json --keystore ~/.starkli-wallets/deploysendertoken/user0_keystore.json

Sierra compiler version not specified. Attempting to automatically decide version to use...
Network detected: sepolia. Using the default compiler version for this network: 2.6.2. Use the --compiler-version flag to choose a different version.
Declaring Cairo 1 class: 0x0631029fa51675ac4e0271911f1d5075154e663576010785b01f924bf9368401
Compiling Sierra class to CASM with compiler version 2.6.2...
CASM class hash: 0x0190887c98c6714aca44af168dd1ce44a683b3c380b2f86b2549d7aea653c6d2
Contract declaration transaction: 0x04310d8755f9abdb48244083c464a80cd1b4e04c6a2c963d2bb2e07fbe4f8c38
Class hash declared:
0x0631029fa51675ac4e0271911f1d5075154e663576010785b01f924bf9368401

starkli deploy 0x0631029fa51675ac4e0271911f1d5075154e663576010785b01f924bf9368401 u256:1000000000 0x01121c686b331F5b9D19dAF25E56F023bee7F6AC129518154a05f3Dd2b1dC0Ba --rpc https://starknet-sepolia.public.blastapi.io/rpc/v0_7 --account ~/.starkli-wallets/deploysendertoken/account0_account.json --keystore ~/.starkli-wallets/deploysendertoken/user0_keystore.json

Deploying class 0x0631029fa51675ac4e0271911f1d5075154e663576010785b01f924bf9368401 with salt 0x00bb7c44154e56eaab239a1159b85cecf4188aabf2b2da29c86c2faabf6cc8d9...
The contract will be deployed at address 0x03c2d1b14c81db30d0805fe5f5a41d9b092e98e9ea7b42602bf35ce8c1f24d5c
Contract deployment transaction: 0x055581c088e078883e8aa2e1f8bdd8bcdb364e13859f545333dddc59f27fec86
Contract deployed:
0x03c2d1b14c81db30d0805fe5f5a41d9b092e98e9ea7b42602bf35ce8c1f24d5c

Check Token Name:
starkli call 0x03c2d1b14c81db30d0805fe5f5a41d9b092e98e9ea7b42602bf35ce8c1f24d5c transfer 0x04c0C1eb4824693143C3a4fA10f464e1983E296D1f11C2E17C98D88EEA56359b u256:1000 --rpc https://starknet-sepolia.public.blastapi.io/rpc/v0_7
same for symbol...

Check Total Supply:
starkli call 0x03c2d1b14c81db30d0805fe5f5a41d9b092e98e9ea7b42602bf35ce8c1f24d5c total_supply --rpc https://starknet-sepolia.public.blastapi.io/rpc/v0_7


Mint:
starkli call 0x03c2d1b14c81db30d0805fe5f5a41d9b092e98e9ea7b42602bf35ce8c1f24d5c mint 0x01121c686b331F5b9D19dAF25E56F023bee7F6AC129518154a05f3Dd2b1dC0Ba u256:1000000  --rpc https://starknet-sepolia.public.blastapi.io/rpc/v0_7


Total Supply
starkli call 0x03c2d1b14c81db30d0805fe5f5a41d9b092e98e9ea7b42602bf35ce8c1f24d5c total_supply --rpc https://starknet-sepolia.public.blastapi.io/rpc/v0_7

Balance Of
starkli call 0x03c2d1b14c81db30d0805fe5f5a41d9b092e98e9ea7b42602bf35ce8c1f24d5c balance_of 0x01121c686b331F5b9D19dAF25E56F023bee7F6AC129518154a05f3Dd2b1dC0Ba --rpc https://starknet-sepolia.public.blastapi.io/rpc/v0_7