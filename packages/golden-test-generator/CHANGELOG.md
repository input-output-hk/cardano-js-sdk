# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/golden-test-generator@0.4.2...@cardano-sdk/golden-test-generator@0.5.0) (2022-12-22)

### ⚠ BREAKING CHANGES

- - BlockSize is now an OpaqueNumber rather than a type alias for number

* BlockNo is now an OpaqueNumber rather than a type alias for number
* EpochNo is now an OpaqueNumber rather than a type alias for number
* Slot is now an OpaqueNumber rather than a type alias for number
* Percentage is now an OpaqueNumber rather than a type alias for number

- **golden-test-generator:** export core chain-sync events instead of ogmios
- **golden-test-generator:** preserve BigInts by replacing serializer to use toSerializableObj util
- **golden-test-generator:** add chain-sync support

### Features

- add opaque numeric types to core package ([9ead8bd](https://github.com/input-output-hk/cardano-js-sdk/commit/9ead8bdb34b7ffc57c32f9ab18a6c6ca14af3fda))
- **golden-test-generator:** add block range support to chain-sync ([66626a3](https://github.com/input-output-hk/cardano-js-sdk/commit/66626a35d4b947713c41492fecd031877165565e))
- **golden-test-generator:** add chain-sync support ([c69cdba](https://github.com/input-output-hk/cardano-js-sdk/commit/c69cdbaac6f3a1c12dce6d6d2ab9397c47314a18))
- **golden-test-generator:** export core chain-sync events instead of ogmios ([2df226c](https://github.com/input-output-hk/cardano-js-sdk/commit/2df226c5f10b3c8f66c6dd06e6d5b5d1588fd66c))

### Bug Fixes

- add sideEffects=false to package.json ([a1cb8f8](https://github.com/input-output-hk/cardano-js-sdk/commit/a1cb8f807e8d5947d0c512e0918713ff97d5d48e))
- **golden-test-generator:** correct path of package.json ([aa02fec](https://github.com/input-output-hk/cardano-js-sdk/commit/aa02fec0f4bcdc2b37695904304d27ebc7ff8150))
- **golden-test-generator:** preserve BigInts by replacing serializer to use toSerializableObj util ([d951df2](https://github.com/input-output-hk/cardano-js-sdk/commit/d951df2c2d852a66f1392b4903c0d588b3916b3b))

## [0.4.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/golden-test-generator@0.4.1...@cardano-sdk/golden-test-generator@0.4.2) (2022-11-04)

**Note:** Version bump only for package @cardano-sdk/golden-test-generator

## [0.4.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/golden-test-generator@0.4.0...@cardano-sdk/golden-test-generator@0.4.1) (2022-08-30)

### Features

- **golden-test-generator:** replace console logging with bunyan ([fcdeb6a](https://github.com/input-output-hk/cardano-js-sdk/commit/fcdeb6a89d778bf7e1101580bc7430a0c7469294))

## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/golden-test-generator@0.4.0) (2022-07-25)

### Bug Fixes

- **golden-test-generator:** add missing blockBody assignment if Alonzo block ([888e25b](https://github.com/input-output-hk/cardano-js-sdk/commit/888e25b681b370fe072d40728f8d71223a9b42fe))

## 0.3.0 (2022-06-24)

### 0.1.5 (2021-10-27)

### 0.1.3 (2021-10-05)

### 0.1.2 (2021-09-30)

### 0.1.1 (2021-09-30)

### Features

- add golden-test-generator package ([b1231b4](https://github.com/input-output-hk/cardano-js-sdk/commit/b1231b45e3d4e94052c05d41a9a3f5230bf02565))
- add metadata to file contents ([5118e4c](https://github.com/input-output-hk/cardano-js-sdk/commit/5118e4c61665704353a24b5bd282f0f1f7b13125))
- **cip-30:** create cip-30 package ([266e719](https://github.com/input-output-hk/cardano-js-sdk/commit/266e719d8c0b8550e05ff4d8da199a4575c0664e))
- filter CLI input to non empty strings ([6791fa2](https://github.com/input-output-hk/cardano-js-sdk/commit/6791fa2f2f38b18906f4d0b2da7c0749ad812321))
- golden-test-generator blocks command ([b8246ae](https://github.com/input-output-hk/cardano-js-sdk/commit/b8246aeb08c1b7f2076641bc6952145139d8085a))
- include assets in golden-test-generator account-balance command ([9b45acf](https://github.com/input-output-hk/cardano-js-sdk/commit/9b45acf7d73bdf5e1adbb86ca6ef0e5b09bb5810))
- support non-default Ogmios connections ([4221564](https://github.com/input-output-hk/cardano-js-sdk/commit/42215642a88f51a27fa96a780e1fc009f86e99a8))
- track transactions containing address outputs ([5f04f7c](https://github.com/input-output-hk/cardano-js-sdk/commit/5f04f7c155edfb65979a99878ee14fe36682396d))

### Bug Fixes

- add missing yarn script, and rename ([840135f](https://github.com/input-output-hk/cardano-js-sdk/commit/840135f7d100c9a00ff410147758ee7d02112897))
- getBlocks invalid return ([98f495d](https://github.com/input-output-hk/cardano-js-sdk/commit/98f495de0f5e6701b842eaa4567dc8b47d739b27))
