<p align="center">
  <big><strong>Cardano JS SDK</strong></big>
</p>

<p align="center">
  <img width="200" src=".github/images/cardano-logo.png"/>
</p>

[![CI][img_src_CI]][workflow_CI]

<hr/>

## Overview

A Yarn Workspace containing packages to collectively form the SDK, written in TypeScript.

- [@cardano-sdk/cardano-graphql-provider](packages/cardano-graphql-provider)
- [@cardano-sdk/core](./packages/core)
- [@cardano-sdk/golden-test-generator](./packages/golden-test-generator)

## Development
#### System Requirements
- Docker `17.12.0`+
- Docker Compose

#### Install and Build
```console
yarn install && \
yarn build
```
#### Run Tests
```console
yarn testnet:up
```
_In another terminal_
```console
yarn test
```
### Lint
```console
yarn lint
```
### Cleanup
```
yarn cleanup
```
## Distribute

### Pack
```console
./scripts/pack.sh
```
### Publish to npm.org
```console
./scripts/publish.sh
```
### Generate Docs
```console
yarn docs
```

[img_src_CI]: https://github.com/input-output-hk/cardano-js-sdk/actions/workflows/continuous-integration.yaml/badge.svg
[workflow_CI]: https://github.com/input-output-hk/cardano-js-sdk/actions/workflows/continuous-integration.yaml