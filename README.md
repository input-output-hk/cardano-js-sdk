<p align="center">
  <big><strong>Cardano JS SDK</strong></big>
</p>

<p align="center">
  <img width="200" src=".github/images/cardano-logo.png"/>
</p>

[![PostIntegration][img_src_post-integration]][workflow_post-integration]
[![Nightly][img_src_nightly]][workflow_nightly]
[![Release][img_src_release]][workflow_release]

<hr/>

## Overview

A suite of TypeScript packages suitable for both Node.js and browser-based development.

- [@cardano-sdk/core](./packages/core)
- [@cardano-sdk/input-selection](./packages/input-selection)
- [@cardano-sdk/dapp-connector](./packages/dapp-connector)
- [@cardano-sdk/governance](./packages/governance)
- [@cardano-sdk/key-management](./packages/key-management)
- [@cardano-sdk/web-extension](./packages/web-extension)
- [@cardano-sdk/wallet](./packages/wallet)
- [@cardano-sdk/util-rxjs](./packages/util-rxjs)
- [@cardano-sdk/util](./packages/util)
- [@cardano-sdk/util-dev](./packages/util-dev)
- [@cardano-sdk/cardano-services](./packages/cardano-services)
- [@cardano-sdk/cardano-services-client](./packages/cardano-services-client)

### External Provider Implementations
- [@cardano-sdk/blockfrost](packages/blockfrost)

### Supported Environments

Packages are distributed as both CommonJS and ESM modules.

- Node.js >=14.15.0 <15.0.0
  - using with `type="module"` requires `--experimental-specifier-resolution=node` flag
- Browser via bundlers (see [example webpack config](./packages/web-extension/e2e/webpack.config.js))

### Testing

- [@cardano-sdk/golden-test-generator](./packages/golden-test-generator)

## Development

A Yarn Workspace maintaining a single version across all packages.

#### System Requirements

- [nvm](https://github.com/nvm-sh/nvm)
- [yarn](https://classic.yarnpkg.com/lang/en/docs/install)

#### Clone
``` console
git clone \
  --recurse-submodules \
  https://github.com/input-output-hk/cardano-js-sdk.git \
  && cd cardano-js-sdk
```
#### Install and Build

```console
nvm install && \
nvm use && \
yarn install && \
yarn build
```

#### Run Tests

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
yarn lint --fix
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

<p align="center">
  <a href="https://input-output-hk.github.io/cardano-js-sdk">:book: Documentation</a>
</p>

[img_src_post-integration]: https://github.com/input-output-hk/cardano-js-sdk/actions/workflows/post_integration.yml/badge.svg
[workflow_post-integration]: https://github.com/input-output-hk/cardano-js-sdk/actions/workflows/post_integration.yml
[img_src_nightly]: https://github.com/input-output-hk/cardano-js-sdk/actions/workflows/nightly.yaml/badge.svg
[workflow_nightly]: https://github.com/input-output-hk/cardano-js-sdk/actions/workflows/nightly.yaml
[img_src_release]: https://github.com/input-output-hk/cardano-js-sdk/actions/workflows/release.yaml/badge.svg
[workflow_release]: https://github.com/input-output-hk/cardano-js-sdk/actions/workflows/release.yaml
[let us know!]: https://github.com/input-output-hk/cardano-graphql/discussions/new
