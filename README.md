# zkSujiko

## Build Setup

```bash
# install dependencies
$ yarn install

# serve with hot reload at localhost:3000
$ yarn dev

```

## Circuits

Circuits folder contains 2 .circom files (sujiko.circom and sujiko62.circom). These files are used to generate their respectives .wasm files (sujiko.wasm and sujiko62.wasm) and .zkey files (sujiko_0001.zkey and sujiko62_0001.zkey).

## Static

This folder contains the previously generated .wasm and .zkey files. Also contains the file DeployedContracts.json, which contains the addresses of both solidity contracts Sujiko.sol and Sujiko62.sol in the Harmony Testnet.

## Contracts

Contracts folder contains 4 .sol files (Sujiko.sol, SujikoVerifier.sol, Sujiko62.sol Sujiko62Verifier.sol)
