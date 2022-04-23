# zkSujiko

## Build Setup

```bash
# install dependencies
$ yarn install

# serve with hot reload at localhost:3000
$ yarn dev

```

## Circuits

Circuits folder contains 2 .circom files (sujiko.circom and sujiko62.circom) and a folder (circomlibs) with the circuits they uses as dependencies. These files are used to generate their respectives .wasm files (sujiko.wasm and sujiko62.wasm) and .zkey files (sujiko_0001.zkey and sujiko62_0001.zkey) also two solidity contracts (SujikoVerifier.sol and Sujiko62Verifier.sol).

## Static

This folder contains the previously generated .wasm and .zkey files.

## Contracts

Contracts folder contains 4 .sol files (Sujiko.sol, SujikoVerifier.sol, Sujiko62.sol and Sujiko62Verifier.sol)

## Utils

Contains the file DeployedContracts.json, which contains the addresses of both solidity contracts Sujiko.sol and Sujiko62.sol in the Harmony Testnet. Also 2 ABI files for these contracts (Sujiko.json and Sujiko62.json).

## zkutils

Contains 3 .js files (sujiko_prover.js, sujiko62_prover.js and zkproof.js) these are the core of zk-proofs generation and validation process.

## Remaining folders and files are related to Nuxt and Vue

They correspond to the front-end of the application.
