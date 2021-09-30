<p align="center">
  <big><strong>Cardano JS SDK</strong></big>
</p>

<p align="center">
  <img width="200" src=".github/images/cardano-logo.png"/>
</p>

[![CI][img_src_CI]][workflow_CI]

<hr/>

## Overview
A suite of TypeScript packages suitable for both Node.js and browser-based development. 

- [@cardano-sdk/core](./packages/core)
- [@cardano-sdk/cip2](./packages/cip2)
- [@cardano-sdk/cip30](./packages/cip30)
- [@cardano-sdk/wallet](./packages/wallet)

### Cardano Provider Implementations
- [@cardano-sdk/cardano-graphql-db-sync](packages/cardano-graphql-db-sync)
- [@cardano-sdk/blockfrost](packages/blockfrost)

:information_source: Looking to use a Cardano service not listed here? [Let us know!]

### Testing
- [@cardano-sdk/golden-test-generator](./packages/golden-test-generator)

## Development

A Yarn Workspace maintaining a single version across all packages.

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
or

```console
yarn test:debug
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

## Maintenance

## Bump Version
```console
yarn bump-version
```

New package checklist:
1. Extend packageMap in [.versionrc.js](./.versionrc.js)
2. Extend [pack.sh](./scripts/pack.sh)
3. Extend [publish.sh](./scripts/publish.sh)

<p align="center">
  <a href="https://input-output-hk.github.io/cardano-js-sdk">:book: Documentation</a>
</p>

[img_src_CI]: https://github.com/input-output-hk/cardano-js-sdk/actions/workflows/continuous-integration.yaml/badge.svg
[workflow_CI]: https://github.com/input-output-hk/cardano-js-sdk/actions/workflows/continuous-integration.yaml
[Let us know!]: https://github.com/input-output-hk/cardano-graphql/discussions/new