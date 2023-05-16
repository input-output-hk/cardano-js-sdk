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
- [@cardano-sdk/projection](./packages/projection)
- [@cardano-sdk/util-rxjs](./packages/util-rxjs)
- [@cardano-sdk/util](./packages/util)
- [@cardano-sdk/util-dev](./packages/util-dev)
- [@cardano-sdk/cardano-services](./packages/cardano-services)
- [@cardano-sdk/cardano-services-client](./packages/cardano-services-client)

### Supported Environments

Packages are distributed as both CommonJS and ESM modules.

- Node.js >=14.20.1
  - using with `type="module"` requires `--experimental-specifier-resolution=node` flag
- Browser via bundlers (see [example webpack config](./packages/e2e/test/web-extension/webpack.config.js))

### Getting Started
The [GETTING_STARTED](./GETTING_STARTED.md) guide provides a quick way to start experimenting.

### Testing

- [@cardano-sdk/golden-test-generator](./packages/golden-test-generator)

## Development

A Yarn Workspace maintaining a single version across all packages.

#### System Requirements

- [nvm](https://github.com/nvm-sh/nvm)
- [yarn](https://yarnpkg.com/getting-started/install)
- [Node.js](https://nodejs.org/en/download) 14 or later
- [Docker Desktop] 3.4 or later or a Docker installation that includes Compose V2

#### Clone
``` bash
git clone \
  https://github.com/input-output-hk/cardano-js-sdk.git \
  && cd cardano-js-sdk
```
#### Install and Build

```bash
nvm install && \
nvm use && \
yarn install && \
yarn build
```

#### Run Tests

```bash
yarn test
```

or

```bash
yarn test:debug
```

### Lint

```bash
yarn lint
yarn lint --fix
```

### Cleanup

```
yarn cleanup
```

### Update Cardano configuration subrepo

#### With `yarn`

Requires [git-subrepo](https://github.com/git-commands/git-subrepo) to be
installed.

```
yarn config:update
```

#### With `nix`

Requires [Nix](https://nixos.org/download.html), will install `git-subrepo`
for you.

```
nix run .#config-update
```

## Distribute

### Pack

```bash
./scripts/pack.sh
```

### Publish to npm.org

```bash
./scripts/publish.sh
```

### Generate Docs

```bash
yarn docs
```

<p align="center">
  <a href="https://input-output-hk.github.io/cardano-js-sdk">:book: Documentation</a>
</p>

[img_src_post-integration]: https://github.com/input-output-hk/cardano-js-sdk/actions/workflows/post_integration.yml/badge.svg
[workflow_post-integration]: https://github.com/input-output-hk/cardano-js-sdk/actions/workflows/post_integration.yml
[img_src_nightly]: https://github.com/input-output-hk/cardano-js-sdk/actions/workflows/nightly-test.yaml/badge.svg
[workflow_nightly]: https://github.com/input-output-hk/cardano-js-sdk/actions/workflows/nightly-test.yaml
[img_src_release]: https://github.com/input-output-hk/cardano-js-sdk/actions/workflows/release.yaml/badge.svg
[workflow_release]: https://github.com/input-output-hk/cardano-js-sdk/actions/workflows/release.yaml
[Docker Desktop]: https://docs.docker.com/desktop/
[let us know!]: https://github.com/input-output-hk/cardano-graphql/discussions/new
