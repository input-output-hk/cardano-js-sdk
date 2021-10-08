<p align="center">
  <big><strong>Cardano JS SDK</strong></big>
</p>

<p align="center">
  <img width="200" src=".github/images/cardano-logo.png"/>
</p>

[![CI][img_src_ci]][workflow_ci]

<hr/>

## Overview

A suite of TypeScript packages suitable for both Node.js and browser-based development.

- [@cardano-sdk/core](./packages/core)
- [@cardano-sdk/cip2](./packages/cip2)
- [@cardano-sdk/cip30](./packages/cip30)
- [@cardano-sdk/wallet](./packages/wallet)
- [@cardano-sdk/util-dev](./packages/util-dev)

### Cardano Provider Implementations

- [@cardano-sdk/cardano-graphql-db-sync](packages/cardano-graphql-db-sync)
- [@cardano-sdk/blockfrost](packages/blockfrost)

:information_source: Looking to use a Cardano service not listed here? [Let us know!]

### Webpack

You may use the following config when bundling this SDK with Webpack:

```js
const { IgnorePlugin, ProvidePlugin } = require('webpack');
{
  resolve: {
    // For browser builds only
    fallback: {
      // May want to install readable-stream as an explicit dependency
      stream: require.resolve('readable-stream'),
    }
  },
  plugins: [
    new HtmlWebpackHarddiskPlugin(),
    // see https://www.npmjs.com/package/isomorphic-bip39 README
    new IgnorePlugin(/^\.\/wordlists\/(?!english)/, /bip39\/src$/),
  ],
  experiments: {
    asyncWebAssembly: true
  }
}
```

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

### Bump Version

```console
yarn bump-version
```

Then update the sibling dependencies manually.

### New package checklist

1. Extend packageMap in [.versionrc.js](./.versionrc.js)
2. Extend [pack.sh](./scripts/pack.sh)
3. Extend [publish.sh](./scripts/publish.sh)

<p align="center">
  <a href="https://input-output-hk.github.io/cardano-js-sdk">:book: Documentation</a>
</p>

[img_src_ci]: https://github.com/input-output-hk/cardano-js-sdk/actions/workflows/continuous-integration.yaml/badge.svg
[workflow_ci]: https://github.com/input-output-hk/cardano-js-sdk/actions/workflows/continuous-integration.yaml
[let us know!]: https://github.com/input-output-hk/cardano-graphql/discussions/new
