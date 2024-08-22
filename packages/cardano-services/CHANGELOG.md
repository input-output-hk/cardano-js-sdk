# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.29.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.29.5...@cardano-sdk/cardano-services@0.29.6) (2024-08-22)

### Bug Fixes

* **cardano-services:** correctly load Mapper.withGovernanceActions ([855a057](https://github.com/input-output-hk/cardano-js-sdk/commit/855a05716f28e4354228c245935fb254f09ecbdf))

## [0.29.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.29.4...@cardano-sdk/cardano-services@0.29.5) (2024-08-21)

### Features

* add parameters update projection ([d007d7f](https://github.com/input-output-hk/cardano-js-sdk/commit/d007d7fc0551b553e4d98b368c937742a1c316f9))

## [0.29.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.29.3...@cardano-sdk/cardano-services@0.29.4) (2024-08-20)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.29.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.29.2...@cardano-sdk/cardano-services@0.29.3) (2024-08-07)

### Bug Fixes

* add timeout to TypeormService withDataSource/withQueryRunner ([d5faa15](https://github.com/input-output-hk/cardano-js-sdk/commit/d5faa1571c5ee54598aa4ec08c6fd810a58c6845))
* do not run schema migrations when starting pgboss worker ([172fe30](https://github.com/input-output-hk/cardano-js-sdk/commit/172fe3083e4863e7575fc86380078e26cc93e38e))
* remove redundant, uninitialized logger from TypeormService ([02a9502](https://github.com/input-output-hk/cardano-js-sdk/commit/02a9502c48843e28a8af18067356aaeb6aba8e72))

## [0.29.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.29.1...@cardano-sdk/cardano-services@0.29.2) (2024-08-01)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.29.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.29.0...@cardano-sdk/cardano-services@0.29.1) (2024-07-31)

### Features

* **cardano-services:** add distinction between committe with or without scaript ([01c3990](https://github.com/input-output-hk/cardano-js-sdk/commit/01c399023a0adf92c90525c32a9f7c1fbcb1ceb5))

### Bug Fixes

* **cardano-services:** drep_hash can be null when delegating to abstain or no confidence ([7c6c53b](https://github.com/input-output-hk/cardano-js-sdk/commit/7c6c53ba9ce418cad83e6290cc73672e1ba3232a))
* **cardano-services:** typeorm asset provider release query runner once ([a1f4dbe](https://github.com/input-output-hk/cardano-js-sdk/commit/a1f4dbe3166e26ef1a08982950f8522fd64f8c4d))

## [0.29.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.28.14...@cardano-sdk/cardano-services@0.29.0) (2024-07-31)

### ⚠ BREAKING CHANGES

* **cardano-services:** conway protocol parameters could be undefined in PV8 or lower
* **core:** decentralizationParameter was removed in babbage
* **cardano-services:** removed pool_voting_thresholds and drep_voting_thresholds from
ProtocolParamsModel
* add deposit to stake pool registration certificates
* **cardano-services:** With the introduction of Conway era new certificates we must take care that
many new certificates (reg_cert and all combined certificates) should take the same effects
as previously done by the stake_registration certificate.
The same for stake_deregistration and unreg_cert certificates.
* remove OgmiosTxSubmitProvider
* update core CardanoNode error types
  - Removed `OnChainTx` `witness.scripts` and `auxiliaryData.scripts`

### Features

* add deposit to stake pool registration certificates ([54189a4](https://github.com/input-output-hk/cardano-js-sdk/commit/54189a492d19aafd33037cc9f0fb15c1708712a1))
* **cardano-services:** add conway certificates to db-sync chain history provider ([bb061a7](https://github.com/input-output-hk/cardano-js-sdk/commit/bb061a719ddf4a44bbe9d028faba64b73e55c196))
* **cardano-services:** add distinction between constitutional committee with or without script ([f6b512a](https://github.com/input-output-hk/cardano-js-sdk/commit/f6b512a30f86cc4728e7c20e6a85a5084050962f))
* **cardano-services:** add proposal procedures details ([5f8f7c7](https://github.com/input-output-hk/cardano-js-sdk/commit/5f8f7c7452c2324f5b9263a1e390f58dc0f986af))
* **cardano-services:** add proposal procedures to chain history provider ([e4779b8](https://github.com/input-output-hk/cardano-js-sdk/commit/e4779b8ced065c3fe2c53e57038c55a69e7e5a66))
* **cardano-services:** add voting procedures to db-sync chain history ([4d275ee](https://github.com/input-output-hk/cardano-js-sdk/commit/4d275ee1a7099b91a4717f9fc8945472481e9d0b))
* **cardano-services:** extract rewards which are not correlated to a pool ([b621955](https://github.com/input-output-hk/cardano-js-sdk/commit/b621955b1eb916158cbeef2f827635f01fc956ef))
* **cardano-services:** map conway protocol params update action ([88493d4](https://github.com/input-output-hk/cardano-js-sdk/commit/88493d466e2e8dbfee56d1e58695dbde56ca2885))
* **cardano-services:** map pvt/dvt dbSync fields to pool/drep voting thresholds ([36c3291](https://github.com/input-output-hk/cardano-js-sdk/commit/36c32919ea8cff934e04965a4f8f436788711dd6))
* **cardano-services:** network info provider new protocol params ([82b9ad3](https://github.com/input-output-hk/cardano-js-sdk/commit/82b9ad3d037116fb67127abece17c1199a9cfb83))
* **cardano-services:** sanchonet support ([13109d6](https://github.com/input-output-hk/cardano-js-sdk/commit/13109d60361730c5c36ee0f616f1a478e9b71b98))

### Bug Fixes

* **cardano-services:** committee_term_limit renamed to committee_max_term_length ([90e84fa](https://github.com/input-output-hk/cardano-js-sdk/commit/90e84fa644fdf7c905476d06f61a85c1e9661200))
* **cardano-services:** committee_term_limit renamed to governance_action_validity_period ([79eb6a9](https://github.com/input-output-hk/cardano-js-sdk/commit/79eb6a980031c5320338a229261d1b302c10ae4f))
* **cardano-services:** conway era deposits in db sync network info provider ([ebe7ea7](https://github.com/input-output-hk/cardano-js-sdk/commit/ebe7ea7712546a164cd8640bf7ea6d1c230f4c72))
* **cardano-services:** conway protocol parameters could be undefined in PV8 or lower ([e68c59b](https://github.com/input-output-hk/cardano-js-sdk/commit/e68c59b9c80b9df5992f0e7b04d97719c8d72005))
* **cardano-services:** db-sync redeemer purpose mapping ([c75fef5](https://github.com/input-output-hk/cardano-js-sdk/commit/c75fef5517b777f9e9e8b72d984e11420c9db1f0))
* **cardano-services:** drep representation in certificates in chain history builder ([13de17a](https://github.com/input-output-hk/cardano-js-sdk/commit/13de17a1f76d0e4b25d1163f928d971aee6ebcb6))
* **cardano-services:** drep_inactivity renamed to drep_activity ([9501b18](https://github.com/input-output-hk/cardano-js-sdk/commit/9501b188e33190f9732e6b87e4d51c7d7517a24c))
* **cardano-services:** min_committee_size renamed to committee_min_size ([342bb3c](https://github.com/input-output-hk/cardano-js-sdk/commit/342bb3c88a21af181c3540107cf31399f14ccbfb))
* **cardano-services:** new constitution proposal representation in db sync chain sync provider ([c2bb9cb](https://github.com/input-output-hk/cardano-js-sdk/commit/c2bb9cb78f0d91865174e09b84da4ce611bf552d))
* **cardano-services:** use a single QueryRunner/connection for getAssets ([53f678b](https://github.com/input-output-hk/cardano-js-sdk/commit/53f678b945b10064176f4530455f2ffbe4fb5572))
* **cardano-services:** use correct stake key deregistration certificates deposit value ([a0a2ead](https://github.com/input-output-hk/cardano-js-sdk/commit/a0a2ead3351be80da16afe15f321b019f8a7b6d0))
* **core:** decentralizationParameter was removed in babbage ([808d8c9](https://github.com/input-output-hk/cardano-js-sdk/commit/808d8c9d1a89b0c048e6851fd7221b194f028394))
* **e2e:** local-network cardano-node download url ([c024840](https://github.com/input-output-hk/cardano-js-sdk/commit/c024840a0fa41a90a4e77b61633ecd7bd2ab5639))
* handle bigint in innerError data ([447b75d](https://github.com/input-output-hk/cardano-js-sdk/commit/447b75d030583ae1b0ce1a9f708331cf5ebe67f6))
* produced coins error data is present only for ValueNotConserved ([e01a30c](https://github.com/input-output-hk/cardano-js-sdk/commit/e01a30ce056f1886c0ddbacf245b195f13111244))

### Code Refactoring

* adapt to ogmios 6 changes ([e9c5692](https://github.com/input-output-hk/cardano-js-sdk/commit/e9c5692d3599732869a5bda29fe983df5689bdab)), closes [/github.com/input-output-hk/cardano-js-sdk/pull/927#discussion_r1352081210](https://github.com/input-output-hk//github.com/input-output-hk/cardano-js-sdk/pull/927/issues/discussion_r1352081210)
* remove OgmiosTxSubmitProvider ([8c56c5e](https://github.com/input-output-hk/cardano-js-sdk/commit/8c56c5eddb73a4888013798acf97879f9ce741f7))

## [0.28.14](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.28.13...@cardano-sdk/cardano-services@0.28.14) (2024-07-25)

### Features

* add web socket based network info provider ([7c47ce0](https://github.com/input-output-hk/cardano-js-sdk/commit/7c47ce0aed1e41c4a4034f0e0b65d49b64e59360))

### Bug Fixes

* increase number of db connections in pool for asset provider ([adcb643](https://github.com/input-output-hk/cardano-js-sdk/commit/adcb643b560923f46188673c709874d37e3336f8))

## [0.28.13](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.28.12...@cardano-sdk/cardano-services@0.28.13) (2024-07-22)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.28.12](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.28.11...@cardano-sdk/cardano-services@0.28.12) (2024-07-11)

### Bug Fixes

* **cardano-services:** add workaround for db-sync not projecting epoch 0 to db sync epoch monitor ([b792354](https://github.com/input-output-hk/cardano-js-sdk/commit/b7923545182ed006b68d32b9054ac2f9e91d0592))

## [0.28.11](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.28.10...@cardano-sdk/cardano-services@0.28.11) (2024-07-10)

### Bug Fixes

* **cardano-services:** improve type orm provider health check ([c3c662b](https://github.com/input-output-hk/cardano-js-sdk/commit/c3c662b3ca6638d8a32a2bdef6a246fd71e206c8))

## [0.28.10](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.28.9...@cardano-sdk/cardano-services@0.28.10) (2024-06-26)

### Bug Fixes

* **cardano-services:** negative stake key de-registration certificate deposit ([d52b084](https://github.com/input-output-hk/cardano-js-sdk/commit/d52b0840bee064f9be215183686e0dc1a0203a82))

## [0.28.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.28.8...@cardano-sdk/cardano-services@0.28.9) (2024-06-20)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.28.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.28.7...@cardano-sdk/cardano-services@0.28.8) (2024-06-18)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.28.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.28.6...@cardano-sdk/cardano-services@0.28.7) (2024-06-17)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.28.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.28.5...@cardano-sdk/cardano-services@0.28.6) (2024-06-14)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.28.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.28.4...@cardano-sdk/cardano-services@0.28.5) (2024-06-05)

### Features

* **cardano-services:** chain history provider now also returns reference scripts on outputs ([8b0731d](https://github.com/input-output-hk/cardano-js-sdk/commit/8b0731de9d7c1f0b7eb22528b1e3d22071931b40))

## [0.28.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.28.3...@cardano-sdk/cardano-services@0.28.4) (2024-05-20)

### Features

* **cardano-services:** implement new fuzzy search options ([006ecf8](https://github.com/input-output-hk/cardano-js-sdk/commit/006ecf8d78d1a7e8b6c884fcad8c2910d0d25a5e))
* **cardano-services:** remove check on asset name when fetching nft metadata ([ef562b2](https://github.com/input-output-hk/cardano-js-sdk/commit/ef562b2d0f91f50e45eddc333f98db4f04e8255d))

### Bug Fixes

* **cardano-services:** release query runner after query execution ([37c1887](https://github.com/input-output-hk/cardano-js-sdk/commit/37c188783ac9205a99a26323205218c48c3bbeea))
* **cardano-services:** stake pool fuzzy search empty result ([aff2cdd](https://github.com/input-output-hk/cardano-js-sdk/commit/aff2cdd8ead77cf104da32ea7597650c8a95d0e4))
* **cardano-services:** use correct asset limit pagination for typeorm asset provider ([8c13737](https://github.com/input-output-hk/cardano-js-sdk/commit/8c13737ee07a2d5811a069b86b7acaa1289d5b51))
* increase the size of pledge column of stake pool rewards table ([988f9ae](https://github.com/input-output-hk/cardano-js-sdk/commit/988f9ae02415a1c8dc4327d1d40d2412a97064b0))

## [0.28.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.28.2...@cardano-sdk/cardano-services@0.28.3) (2024-05-02)

### Bug Fixes

* **cardano-services:** correct mapping of chain history redeemer purpose ([b27bcac](https://github.com/input-output-hk/cardano-js-sdk/commit/b27bcac3e807f97f9b1555a8e7df81d58d797006))

## [0.28.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.28.1...@cardano-sdk/cardano-services@0.28.2) (2024-04-26)

### Features

* **cardano-services:** implement location and distance new options in stake pools fuzzy search ([8deeed7](https://github.com/input-output-hk/cardano-js-sdk/commit/8deeed739c2b8d6f9b73a2fccfd6be85f0566f38))

### Bug Fixes

* add needed params in the docker composer file to activate batch pool delisting from smash server ([22eb99d](https://github.com/input-output-hk/cardano-js-sdk/commit/22eb99de65fefcc29bc19885f405ca4f2020a54d))
* **cardano-services:** ensure only leader and member rewards are used to compute stake pool rewards ([b5805fc](https://github.com/input-output-hk/cardano-js-sdk/commit/b5805fcc5490632e5e4be126b07c23ba594bb0e2))

## [0.28.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.28.0...@cardano-sdk/cardano-services@0.28.1) (2024-04-23)

### Features

* use publicly available SMASH docker image ([e29cc9c](https://github.com/input-output-hk/cardano-js-sdk/commit/e29cc9c7ff70495efe8ccf51779bcfb8b05ea335))

## [0.28.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.27.1...@cardano-sdk/cardano-services@0.28.0) (2024-04-15)

### ⚠ BREAKING CHANGES

* upgrade cardano-services, cardano-services-client, e2e and util-dev packages to use version 0.28.0 of Axios

### Features

* optimize projector to not write irrelevant blocks ([132a9f6](https://github.com/input-output-hk/cardano-js-sdk/commit/132a9f63c6927ec82af0ea39516c720d0674ad20))

### Bug Fixes

* **cardano-services:** address projection now applies store operators in correct order ([2178cda](https://github.com/input-output-hk/cardano-js-sdk/commit/2178cdadddb0841c19d8cdea438fec14b4fe0e98))
* **cardano-services:** emergency fix for lw-10209 ([abbf5fe](https://github.com/input-output-hk/cardano-js-sdk/commit/abbf5fed603e1c7e4cc133146035e88248f75f5b))
* the projection now always stores blocks when it reaches tip - k ([ba01291](https://github.com/input-output-hk/cardano-js-sdk/commit/ba01291c66178d372527f3fb07dceafd147c3891))

### Miscellaneous Chores

* upgrade Axios version to 0.28.0 ([59fcd06](https://github.com/input-output-hk/cardano-js-sdk/commit/59fcd06debc2712ca9fdd027400450d52a21caeb))

## [0.27.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.27.0...@cardano-sdk/cardano-services@0.27.1) (2024-04-03)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.27.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.26.6...@cardano-sdk/cardano-services@0.27.0) (2024-03-26)

### ⚠ BREAKING CHANGES

* **cardnao-services:** txSubmitApiProvider can now optionally take an axios adapter in its constructor

### Features

* add fuzzy search on stake pool metadata ([34446ac](https://github.com/input-output-hk/cardano-js-sdk/commit/34446ac87e0d6d8aaf0d732aaaa4cbb946649141))
* add sort by ticker to stake pool search ([2168d9e](https://github.com/input-output-hk/cardano-js-sdk/commit/2168d9e7952d2d926538608ff7977d8e5e9cd178))
* **cardnao-services:** txSubmitApiProvider can now optionally take an axios adapter in its constructor ([afcc82c](https://github.com/input-output-hk/cardano-js-sdk/commit/afcc82cdf4eb7249468be65c77e2e2a66d097b2c))

## [0.26.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.26.5...@cardano-sdk/cardano-services@0.26.6) (2024-03-12)

### Bug Fixes

* **cardano-services:** phase-2 failure tx mapper ([320cd41](https://github.com/input-output-hk/cardano-js-sdk/commit/320cd4147079acd4c06f3ec9598d7ea9ffa47cca))

## [0.26.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.26.4...@cardano-sdk/cardano-services@0.26.5) (2024-02-29)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.26.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.26.3...@cardano-sdk/cardano-services@0.26.4) (2024-02-28)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.26.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.26.2...@cardano-sdk/cardano-services@0.26.3) (2024-02-23)

### Bug Fixes

* **cardano-services:** cardano-submit-api parameters typo ([580ae98](https://github.com/input-output-hk/cardano-js-sdk/commit/580ae9801219d31b8f8466a62a3d92cc0f55c67a))

## [0.26.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.26.1...@cardano-sdk/cardano-services@0.26.2) (2024-02-12)

### Features

* **cardano-services:** add an explicit option for tx-submit provider handle validation ([01938a2](https://github.com/input-output-hk/cardano-js-sdk/commit/01938a2bd69b0710f204d33b0a783e865b6652b9))

### Bug Fixes

* **core:** update isValidHandle RegExp to match ADA Handle rules ([78f7f35](https://github.com/input-output-hk/cardano-js-sdk/commit/78f7f35cb86cec921b13d006c8a314530a09d55e))

## [0.26.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.26.0...@cardano-sdk/cardano-services@0.26.1) (2024-02-08)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.26.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.25.4...@cardano-sdk/cardano-services@0.26.0) (2024-02-07)

### ⚠ BREAKING CHANGES

* add and implement new stake pool sorting options

### Features

* add and implement new stake pool sorting options ([bcc5e80](https://github.com/input-output-hk/cardano-js-sdk/commit/bcc5e807fb58996998c1d0065b448066fb33d946))
* **cardano-services:** resolve collateralReturn property ([98291b5](https://github.com/input-output-hk/cardano-js-sdk/commit/98291b52ffeab7fd7c936716bdba84c8614055cf))

### Bug Fixes

* **cardano-services:** change log pattern match ([d1286b7](https://github.com/input-output-hk/cardano-js-sdk/commit/d1286b7c80c7482d40b72270fcb0525533407c27))

## [0.25.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.25.3...@cardano-sdk/cardano-services@0.25.4) (2024-02-02)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.25.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.25.2...@cardano-sdk/cardano-services@0.25.3) (2024-02-02)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.25.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.25.1...@cardano-sdk/cardano-services@0.25.2) (2024-01-31)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.25.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.25.0...@cardano-sdk/cardano-services@0.25.1) (2024-01-25)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.25.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.24.5...@cardano-sdk/cardano-services@0.25.0) (2024-01-17)

### ⚠ BREAKING CHANGES

* add retry configuration to store stake pool metadata job

### Features

* add retry configuration to store stake pool metadata job ([90c4663](https://github.com/input-output-hk/cardano-js-sdk/commit/90c46632211c2fe3d5546650444d98e577a0278e))

### Bug Fixes

* **cardano-services:** use pgboss.archive table to check computed epoch rewards ([b25d151](https://github.com/input-output-hk/cardano-js-sdk/commit/b25d151cb38c90b2c7e7366577a2523ff217e8dd))

## [0.24.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.24.4...@cardano-sdk/cardano-services@0.24.5) (2024-01-05)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.24.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.24.3...@cardano-sdk/cardano-services@0.24.4) (2023-12-21)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.24.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.24.2...@cardano-sdk/cardano-services@0.24.3) (2023-12-20)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.24.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.24.1...@cardano-sdk/cardano-services@0.24.2) (2023-12-14)

### Features

* **cardano-sevices:** allow api compatible version requests ([14184e2](https://github.com/input-output-hk/cardano-js-sdk/commit/14184e2b003a6d58f1088b26de0e932a6646535a))
* include minted assets in cip67 mapper to ensure minted assets can be collected in withHandles mapper ([8e1b834](https://github.com/input-output-hk/cardano-js-sdk/commit/8e1b834181e909d4cb4c8608a29392716ae5a4b8))
* update Handle entity and HandleStore to save parent handles ([3fa3920](https://github.com/input-output-hk/cardano-js-sdk/commit/3fa3920088857d5019d732a036fc3a89b90d5ab3))

## [0.24.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.24.0...@cardano-sdk/cardano-services@0.24.1) (2023-12-12)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.24.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.23.1...@cardano-sdk/cardano-services@0.24.0) (2023-12-07)

### ⚠ BREAKING CHANGES

* bump stake pool provider api version to 1.1.0

### Bug Fixes

* make type orm stake pool provider back compatible ([b007175](https://github.com/input-output-hk/cardano-js-sdk/commit/b007175502578daaaa738a5380fe0b68ce9d742e))

## [0.23.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.23.0...@cardano-sdk/cardano-services@0.23.1) (2023-12-04)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.23.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.22.0...@cardano-sdk/cardano-services@0.23.0) (2023-11-29)

### ⚠ BREAKING CHANGES

* stake registration and deregistration certificates now take a Credential instead of key hash

### Features

* add support for only updating outdated pool metrics at a given interval ([64f67d6](https://github.com/input-output-hk/cardano-js-sdk/commit/64f67d6bcf6d0973fb0319a51ab9267a3fd16ee3))
* **cardano-services:** implement schedules and added stakepool delist worker schedule ([b30eb6b](https://github.com/input-output-hk/cardano-js-sdk/commit/b30eb6bdd0dbee50972c67f4b9a1b6370e1862b9))
* **cardano-services:** implement tx submit api ([f76ebdd](https://github.com/input-output-hk/cardano-js-sdk/commit/f76ebdd6930a310d68128497a1b93b589ff1b071))
* **cardano-services:** integrate the stake pool rewards store in the projector ([501174c](https://github.com/input-output-hk/cardano-js-sdk/commit/501174c4133904988469db941e6ff4a5de1b9d34))
* **cardano-services:** update NFT metadata and Asset test with Asset db ([27b4323](https://github.com/input-output-hk/cardano-js-sdk/commit/27b4323c4d515f819d463ded5712047112e77759))
* create PoolDelistedEntity and database migration ([650bef2](https://github.com/input-output-hk/cardano-js-sdk/commit/650bef2c4fdd7e35052f316710f51ac6b3a2e0af))
* implement ros in typeorm stake pool provider ([be83024](https://github.com/input-output-hk/cardano-js-sdk/commit/be83024e4e5d0994adaa5548d33a8478d61d4c7d))
* **projection-typeorm:** add stake pool rewards store ([bab242b](https://github.com/input-output-hk/cardano-js-sdk/commit/bab242b71192e904f4805b60c80ec5455bc23ecc))
* stake registration and deregistration certificates now take a Credential instead of key hash ([49612f0](https://github.com/input-output-hk/cardano-js-sdk/commit/49612f0f313f357e7e2a7eed406852cbd2bb3dec))
* update cli.test to work with Asset db ([7b5265e](https://github.com/input-output-hk/cardano-js-sdk/commit/7b5265e7320d68d652511dcb431de9b45ef73edd))

### Bug Fixes

* **cardano-services:** asset provider can be started with POSTGRES_HOST ([1603cfd](https://github.com/input-output-hk/cardano-js-sdk/commit/1603cfd318a2e5a10f5a43665b74f6ac1bb8fb22))
* **cardano-services:** return active stake from previous epoch insted ([12fa427](https://github.com/input-output-hk/cardano-js-sdk/commit/12fa42767e506a7a498aa041c0fa1fe214a86454))

## [0.22.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.21.1...@cardano-sdk/cardano-services@0.22.0) (2023-10-19)

### ⚠ BREAKING CHANGES

* simplify StabilityWindowBuffer interface to just 'getBlock'
- Bootstrap.fromCardanoNode now requires Tip observable parameter

### Features

* do not write to stability window buffer til volatile ([b2244ea](https://github.com/input-output-hk/cardano-js-sdk/commit/b2244eac56352961c36ef9e80038aead47ee9e52))

## [0.21.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.21.0...@cardano-sdk/cardano-services@0.21.1) (2023-10-12)

### Features

* **cardano-services:** add Asset projection to prepareTypeOrmProjection ([129dd35](https://github.com/input-output-hk/cardano-js-sdk/commit/129dd353d3831850b451f2ba75d7cd33d0a0d09b))

## [0.21.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.20.0...@cardano-sdk/cardano-services@0.21.0) (2023-10-09)

### ⚠ BREAKING CHANGES

* core package no longer exports the CML types

### Features

* core package no longer exports the CML types ([51545ed](https://github.com/input-output-hk/cardano-js-sdk/commit/51545ed82b4abeb795b0a50ad7d299ddb5da4a0d))

## [0.20.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.19.0...@cardano-sdk/cardano-services@0.20.0) (2023-09-29)

### ⚠ BREAKING CHANGES

* **cardano-services:** StakePoolHttpService interface changed

### Features

* **cardano-services:** added optional metadata fetch feature from SMASH server ([54a4f5e](https://github.com/input-output-hk/cardano-js-sdk/commit/54a4f5e7eab08f7c06802782e2da62d1406bdf1b))

## [0.19.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.18.0...@cardano-sdk/cardano-services@0.19.0) (2023-09-20)

### ⚠ BREAKING CHANGES

* make withHandles 'logger' argument required
* withHandles now requires WithCIP67 props in
* remove the CML serialization code from core package
* remove AssetInfo.history and AssetInfo.mintOrBurnCount
* convert tokens.quantity column to numeric
* renamed field handle to handleResolutions
* hoist metadatumToCip25 to NftMetadata.fromMetadatum
* incompatible with previous revisions of cardano-services
- rename utxo and transactions PouchDB stores
- update type of Tx.witness.redeemers
- update type of Tx.witness.datums
- update type of TxOut.datum
- remove Cardano.Datum type

fix(cardano-services): correct chain history openApi endpoints path url to match version

### Features

* add address projection ([416e5f5](https://github.com/input-output-hk/cardano-js-sdk/commit/416e5f5edc112727d86e0905733f7f6c1c2fd4c5))
* add NFT metadata projection ([91fe7df](https://github.com/input-output-hk/cardano-js-sdk/commit/91fe7df50a37bce2ac8cba350fafe788a8174112))
* **cardano-services:** add HandleMetadata to handle projection ([233ed70](https://github.com/input-output-hk/cardano-js-sdk/commit/233ed70366bea72d9db223c8ce348ba72e8f64b6))
* **cardano-services:** create typeorm nft-metadata service ([72f6c1b](https://github.com/input-output-hk/cardano-js-sdk/commit/72f6c1b7a091ed4998651e0d5c4bf9c1c0afdfa9))
* **cardano-services:** create TypeormAssetProvider ([aaf133b](https://github.com/input-output-hk/cardano-js-sdk/commit/aaf133bb776d16dafd955345071e05e0faf599e4))
* **cardano-services:** resolve default handle, image, pfp and bg ([9c446ac](https://github.com/input-output-hk/cardano-js-sdk/commit/9c446acea6747562b15c7d60fbe6351f872cc2af))
* **cardano-services:** update handle projector to project 'default' columns ([903faf2](https://github.com/input-output-hk/cardano-js-sdk/commit/903faf2c51ade7fdc3f03b046660d27425a5f660))
* remove the CML serialization code from core package ([62f4252](https://github.com/input-output-hk/cardano-js-sdk/commit/62f4252b094938db05b81c928c03c1eecec2be55))
* update core types with deserialized PlutusData ([d8cc93b](https://github.com/input-output-hk/cardano-js-sdk/commit/d8cc93b520177c98224502aad39109a0cb524f3c))

### Bug Fixes

* **cardano-services:** do not return datum hash for TxOut with inline datum ([8928869](https://github.com/input-output-hk/cardano-js-sdk/commit/8928869d392799f5c5913fc2e60b0ff69964c3dd))
* **cardano-services:** return 0 for stake pool status ([6674b77](https://github.com/input-output-hk/cardano-js-sdk/commit/6674b77e9ae6dfca1b8fff2ef4cf9c6fbd733efc))
* convert tokens.quantity column to numeric ([31b0f0a](https://github.com/input-output-hk/cardano-js-sdk/commit/31b0f0a789ba474156fc8e6615e3b9e1ab8a4077))
* correct cip68 handle name (without label) ([1711969](https://github.com/input-output-hk/cardano-js-sdk/commit/171196916244d0bcde83b18d509669c2c38a0d63))

### Code Refactoring

* hoist metadatumToCip25 to NftMetadata.fromMetadatum ([c36d7ef](https://github.com/input-output-hk/cardano-js-sdk/commit/c36d7ef9480fe195068443a5d8d09728e9429fc5))
* make withHandles 'logger' argument required ([2267689](https://github.com/input-output-hk/cardano-js-sdk/commit/22676895735bde4399e284e60a8e4e7cf2d4a506))
* remove AssetInfo.history and AssetInfo.mintOrBurnCount ([4c0a7ee](https://github.com/input-output-hk/cardano-js-sdk/commit/4c0a7ee77d9ffcf5583fc922597475c4025be17b))
* renamed field handle to handleResolutions ([8b3296e](https://github.com/input-output-hk/cardano-js-sdk/commit/8b3296e19b27815f3a8487479a691483696cc898))

## [0.18.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.17.0...@cardano-sdk/cardano-services@0.18.0) (2023-09-12)

### ⚠ BREAKING CHANGES

* include API version in HTTP service URL scheme

### Features

* **cardano-services:** introduce /live endpoint on HTTP server ([d2d6c6a](https://github.com/input-output-hk/cardano-js-sdk/commit/d2d6c6a6362b68cda9bf0010c64399daf8f82a30))
* **cardano-services:** recognizes a pgboss locked state as a recoverable error ([af53c8e](https://github.com/input-output-hk/cardano-js-sdk/commit/af53c8ed29d88023cbbb121febb81b99319c6e40))
* **cardano-services:** versionPathFromSpec util for embedding OpenApi version in URLs ([2468c57](https://github.com/input-output-hk/cardano-js-sdk/commit/2468c5774509509e279ffcdc5cfa36c77fdfee68))
* include API version in HTTP service URL scheme ([3c10d33](https://github.com/input-output-hk/cardano-js-sdk/commit/3c10d33c28f172f4e9659d7bd26a5b4afbc62efc))
* only validate API responses in test and dev env ([797dfd3](https://github.com/input-output-hk/cardano-js-sdk/commit/797dfd366defc50276f3fb79e2c99ba3d1ff4b48))

### Bug Fixes

* **cardano-services:** improve /ready endpoint ([04b33a9](https://github.com/input-output-hk/cardano-js-sdk/commit/04b33a9434cb07d272df7514a4d95ceebaf88295))
* **cardano-services:** missing OpenAPI models and express configuration ([db9db30](https://github.com/input-output-hk/cardano-js-sdk/commit/db9db30299b3c94227416d5ea79da27d4cd69a99))
* **cardano-services:** stake pool metadaservice correctly return undefined ([471d272](https://github.com/input-output-hk/cardano-js-sdk/commit/471d2728d651ef0ade2cf0cac54da0d19cabfc0f))
* **cardano-services:** stop DbSyncProvider proxying db-sync health ([88a172d](https://github.com/input-output-hk/cardano-js-sdk/commit/88a172d9b59a99060c5f16e62b366d6dbbd537cb))

## [0.17.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.16.1...@cardano-sdk/cardano-services@0.17.0) (2023-08-29)

### ⚠ BREAKING CHANGES

* added protocol parameters and updated cost model core type to match CDDL specification

### Features

* added protocol parameters and updated cost model core type to match CDDL specification ([6576eb9](https://github.com/input-output-hk/cardano-js-sdk/commit/6576eb96566e45299da904fdedbe639e85206352))

## [0.16.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.16.0...@cardano-sdk/cardano-services@0.16.1) (2023-08-21)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.16.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.15.0...@cardano-sdk/cardano-services@0.16.0) (2023-08-15)

### ⚠ BREAKING CHANGES

* add HandleProvider.getPolicyIds and utilize it in PersonalWallet also, handles$ resolvedAt is now only set via hydration (provider)
* updated MIR certificate interface to match the CDDL specification

### Features

* add a buffer after reading blocks from ogmios ([0095c80](https://github.com/input-output-hk/cardano-js-sdk/commit/0095c80346fb0f5ce7bfa7fe805c6b0e79ad1a35))
* add HandleProvider.getPolicyIds and utilize it in PersonalWallet also, handles$ resolvedAt is now only set via hydration (provider) ([af6a8d0](https://github.com/input-output-hk/cardano-js-sdk/commit/af6a8d011bbd2c218aa23e1d75bb25294fc61a27))
* **cardano-service:** add http service method to attach all the provider routes at once ([c8c02d0](https://github.com/input-output-hk/cardano-js-sdk/commit/c8c02d09b7fb118440ccd0997d874e4fe2619d26))
* **cardano-services:** use prepared statement for the get ledger tip query ([6d4d04b](https://github.com/input-output-hk/cardano-js-sdk/commit/6d4d04bd863e76d5f81f27cb8e8cffba5a586163))
* updated MIR certificate interface to match the CDDL specification ([03d5079](https://github.com/input-output-hk/cardano-js-sdk/commit/03d507951ff310a4019f5ec2f1871fdad77939ee))

### Bug Fixes

* **cardano-services:** add get policy ids path/method to handle http service ([04c1347](https://github.com/input-output-hk/cardano-js-sdk/commit/04c1347e9a3f479e5b93b9bbb7644f3555abdd0d))

## [0.15.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.14.8...@cardano-sdk/cardano-services@0.15.0) (2023-08-11)

### ⚠ BREAKING CHANGES

* EpochRewards renamed to Reward
- The pool the stake address was delegated to when the reward is earned is now
included in the EpochRewards (Will be null for payments from the treasury or the reserves)
- Reward no longer coalesce rewards from the same epoch

### Features

* **cardano-services:** add exit at block no argument to projector ([ac5b2bc](https://github.com/input-output-hk/cardano-js-sdk/commit/ac5b2bc4fedb17d695d6fa59f03d2397936b037a))
* epoch rewards now includes the pool id of the pool that generated the reward ([96fd72b](https://github.com/input-output-hk/cardano-js-sdk/commit/96fd72bba7b087a74eb2080f0cc6ed7c1c2a7329))

## [0.14.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.14.7...@cardano-sdk/cardano-services@0.14.8) (2023-07-31)

### Bug Fixes

* **cardano-services:** added pledgeMet filter to TypeormStakePoolProvider ([85a4839](https://github.com/input-output-hk/cardano-js-sdk/commit/85a4839be2d57c9efe450f79fa4dd0731fd11c88))
* **cardano-services:** added wildcard search by 'name' and 'ticker' in TypeormStakePoolProvider ([cef44ba](https://github.com/input-output-hk/cardano-js-sdk/commit/cef44baffa43de957857e3854511362434280650))
* **cardano-services:** excluded 'cost' from nullsInSort in TypeormStakePoolProvider ([839aa5d](https://github.com/input-output-hk/cardano-js-sdk/commit/839aa5dcfcf0749e0c1da67e9d206a884d4756f1))
* **cardano-services:** switched to case-insensitive sort by 'name' in TypeormStakePoolProvider ([738a82d](https://github.com/input-output-hk/cardano-js-sdk/commit/738a82d55d15ee1cfdcd784ba83b051176cb0179))
* **cardano-services:** updated table names for 'cost' and 'name' in queries of TypeormStakePoolProvider ([dd3acbe](https://github.com/input-output-hk/cardano-js-sdk/commit/dd3acbe950d95889dbba54e226987d25472ce93a))

## [0.14.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.14.6...@cardano-sdk/cardano-services@0.14.7) (2023-07-26)

### Bug Fixes

* **cardano-services:** add metadata entity to typeorm stake pool provider data source ([4232194](https://github.com/input-output-hk/cardano-js-sdk/commit/4232194ed0b4a2c74e655b306ecc21ee34900a54))
* **cardano-services:** fix docker compose to forward policy id env var to provider server ([0b8784c](https://github.com/input-output-hk/cardano-js-sdk/commit/0b8784c22bc332bfd49e8dc049e01f518c0d4df0))

## [0.14.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.14.5...@cardano-sdk/cardano-services@0.14.6) (2023-07-17)

### Bug Fixes

* **cardano-services:** add pool metrics entity as dependency for stake-pool projection ([8c86f1b](https://github.com/input-output-hk/cardano-js-sdk/commit/8c86f1b4149d27edd57f0acac6c5b08f80a12b9f))
* update type of pool registration cost and pledge to numeric ([bf86ec1](https://github.com/input-output-hk/cardano-js-sdk/commit/bf86ec1c28cc9f9f5f2c5b85b0d2d91b0d625db0))

## [0.14.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.14.4...@cardano-sdk/cardano-services@0.14.5) (2023-07-13)

### Features

* **cardano-services:** add cli parameter to chose the handle provider ([0d7d423](https://github.com/input-output-hk/cardano-js-sdk/commit/0d7d4236cf054bed10fcebd3daecf63e50ba2434))

## [0.14.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.14.3...@cardano-sdk/cardano-services@0.14.4) (2023-07-04)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.14.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.14.2...@cardano-sdk/cardano-services@0.14.3) (2023-07-03)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.14.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.14.1...@cardano-sdk/cardano-services@0.14.2) (2023-06-29)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.14.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.14.0...@cardano-sdk/cardano-services@0.14.1) (2023-06-29)

### Bug Fixes

* **cardano-services:** don't unsubscribe from projection on health timeout ([5d7e98b](https://github.com/input-output-hk/cardano-js-sdk/commit/5d7e98b500217739a53b82ed448efec31171bc2c))
* **cardano-services:** fix dns resolution twice in a row ([ef42389](https://github.com/input-output-hk/cardano-js-sdk/commit/ef4238990d419df50c19c25899d53044dbf2d20c))
* **util:** add ServerNotReady to list of connection errors ([c7faf01](https://github.com/input-output-hk/cardano-js-sdk/commit/c7faf01194561b2941c42c4a74517de0a5a9f7d9))

## [0.14.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.13.3...@cardano-sdk/cardano-services@0.14.0) (2023-06-28)

### ⚠ BREAKING CHANGES

* revert inclusion of version in the HttpProvider interface

### Features

* adds cardanoAddress type in HandleResolution interface ([2ee31c9](https://github.com/input-output-hk/cardano-js-sdk/commit/2ee31c9f0b61fc5e67385128448225d2d1d85617))
* **cardano-services:** make cli able to read handle policy ids from file ([ac2aa7f](https://github.com/input-output-hk/cardano-js-sdk/commit/ac2aa7f2d6106cb4fa12833c65800b63f59ca0d4))
* implement verification and presubmission checks on handles in OgmiosTxProvider ([0f18042](https://github.com/input-output-hk/cardano-js-sdk/commit/0f1804287672968614e8aa6bf2f095b0e9a88b22))

### Bug Fixes

* revert inclusion of version in the HttpProvider interface ([3f50013](https://github.com/input-output-hk/cardano-js-sdk/commit/3f5001367686668806bfe967d3d7b6dd5e96dccc))

## [0.13.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.13.2...@cardano-sdk/cardano-services@0.13.3) (2023-06-23)

### Features

* add API and software version HTTP headers ([2e9664f](https://github.com/input-output-hk/cardano-js-sdk/commit/2e9664fcaff56adcfa4f21eb2b71b2fb6a3b411d))

## [0.13.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.13.1...@cardano-sdk/cardano-services@0.13.2) (2023-06-20)

### Features

* **cardano-services:** add typeorm handle provider and http handle service ([78d69ec](https://github.com/input-output-hk/cardano-js-sdk/commit/78d69ec1ae48df08cbf5bbf10406b3063bab75bb))
* **cardano-services:** cache asset info and nft metadata ([43fd02f](https://github.com/input-output-hk/cardano-js-sdk/commit/43fd02ffaa5fdfe1812916e9885b383931141532))
* **cardano-services:** improves get entities util to handle entities dependencies ([efc11e8](https://github.com/input-output-hk/cardano-js-sdk/commit/efc11e8a081bacb28a03fa6429f878b8b1eaa394))
* **cardano-services:** improves the error middleware to log unknown errors ([63e58ca](https://github.com/input-output-hk/cardano-js-sdk/commit/63e58ca7c11b47c415876dac98107135243dcdfa))
* **cardano-services:** increase details in asset not found error ([3967cb3](https://github.com/input-output-hk/cardano-js-sdk/commit/3967cb36c7bd8b54ccd59d614e63e651f6f9e5a1))

### Bug Fixes

* **cardano-service:** fix query text in query time log line ([8a6a5e6](https://github.com/input-output-hk/cardano-js-sdk/commit/8a6a5e639abc10164c0cb40466af500fbd3f7d4d))
* **cardano-services:** add postgres connection timeout ([ad8388e](https://github.com/input-output-hk/cardano-js-sdk/commit/ad8388eb0b04e5a044cf6c2af28a2195497a7c09))

## [0.13.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.13.0...@cardano-sdk/cardano-services@0.13.1) (2023-06-13)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.13.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.12.1...@cardano-sdk/cardano-services@0.13.0) (2023-06-12)

### ⚠ BREAKING CHANGES

* **cardano-services:** rm projector postgres cli/env suffix

### Features

* add handle projector service ([448b2a0](https://github.com/input-output-hk/cardano-js-sdk/commit/448b2a0c0a68f6a0d634a58f717b228b43794bae))

### Bug Fixes

* **cardano-services:** postgres ssl option resolution ([de6168c](https://github.com/input-output-hk/cardano-js-sdk/commit/de6168ca8b0b629bf3ded6c22b3d69e0c425f952))

### Code Refactoring

* **cardano-services:** rm projector postgres cli/env suffix ([fe52d91](https://github.com/input-output-hk/cardano-js-sdk/commit/fe52d913c346b3ec4bc8969ae32f666bced2e588))

## [0.12.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.12.0...@cardano-sdk/cardano-services@0.12.1) (2023-06-06)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.12.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.11.4...@cardano-sdk/cardano-services@0.12.0) (2023-06-05)

### ⚠ BREAKING CHANGES

* hoist Cardano.Percent to util package
* make stake pool metrics an optional property to handle activating pools
* - rename `rewardsHistoryLimit` stake pool search arg to `apyEpochsBackLimit`
* - remove `epochRewards` and type `StakePoolEpochRewards`
- remove `transactions` and type `StakePoolTransactions`

### Features

* add handle projection ([1d3f4ca](https://github.com/input-output-hk/cardano-js-sdk/commit/1d3f4ca3cfa3f1dfb668847de58eba4d0402d48e))
* add missing pool stats status ([6a59a78](https://github.com/input-output-hk/cardano-js-sdk/commit/6a59a78cff0eae3d965e62d65d8612a642dce8f8))
* add stake pool metadata entity relation ([99a40b7](https://github.com/input-output-hk/cardano-js-sdk/commit/99a40b79a8809c472c7780bcb626451345b65958))
* **cardano-services:** log CardanoTokenRegistry config on construction ([63c8377](https://github.com/input-output-hk/cardano-js-sdk/commit/63c83774c0487e3883b6b447e1cc7aad75222e45))
* implement TypeormStakePoolProvider ([8afbffd](https://github.com/input-output-hk/cardano-js-sdk/commit/8afbffdadaf9566ee25e553aee7fbb0c8e0eab62))

### Code Refactoring

* hoist Cardano.Percent to util package ([e4da0e3](https://github.com/input-output-hk/cardano-js-sdk/commit/e4da0e3851a4bdfd503c1f195c5ba1455ea6675b))
* make stake pool metrics an optional property to handle activating pools ([d33bd07](https://github.com/input-output-hk/cardano-js-sdk/commit/d33bd07ddb873ba40498a95caa860820f38ee687))
* remove unusable fields from StakePool core type ([a7aa17f](https://github.com/input-output-hk/cardano-js-sdk/commit/a7aa17fdd5224437555840d21f56c4660142c351))
* rename rewardsHistoryLimit ([05ccdc6](https://github.com/input-output-hk/cardano-js-sdk/commit/05ccdc6b448f98ddd09894b633521e79fbb6d9c1))

## [0.11.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.11.3...@cardano-sdk/cardano-services@0.11.4) (2023-06-01)

### Features

* **cardano-services:** add stake pools metrics computation job ([3462595](https://github.com/input-output-hk/cardano-js-sdk/commit/346259540847eb5ac0b41640b37c7c9ecf114535))

## [0.11.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.11.2...@cardano-sdk/cardano-services@0.11.3) (2023-05-24)

### Features

* **cardano-services:** executes get seestes queries in parallel ([a966dd4](https://github.com/input-output-hk/cardano-js-sdk/commit/a966dd4f27d6e62f078802b07f72129f084151cb))

## [0.11.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.11.1...@cardano-sdk/cardano-services@0.11.2) (2023-05-22)

### Features

* add the the pg-boss worker ([561fd50](https://github.com/input-output-hk/cardano-js-sdk/commit/561fd508a4a96307b023b16ce6fed3ce1d7bd536))
* added two new utility functions to extract policy id and asset name from asset id ([b4af015](https://github.com/input-output-hk/cardano-js-sdk/commit/b4af015d26b7c08c8b295ffcba6142caca49f6a8))
* **cardano-services:** improve cli.ts arguments parsing through environment varaibles ([3177edb](https://github.com/input-output-hk/cardano-js-sdk/commit/3177edb86faeac35601d7840a386190e61b885f3))
* **cardano-services:** reduce code complexity - add a catch-all logic for stake pool metadata fetch ([0fda043](https://github.com/input-output-hk/cardano-js-sdk/commit/0fda0431b3e051223a7f4798b9dac6f51c8488c0))

## [0.11.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.11.0...@cardano-sdk/cardano-services@0.11.1) (2023-05-03)

### Bug Fixes

- **cardano-services:** token metadata core mapping ([20d7950](https://github.com/input-output-hk/cardano-js-sdk/commit/20d7950b663468bbb3ed4f265e91ce592091459a))

## [0.11.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.10.0...@cardano-sdk/cardano-services@0.11.0) (2023-05-02)

### ⚠ BREAKING CHANGES

- - auxiliaryDataHash is now included in the TxBody core type.

* networkId is now included in the TxBody core type.
* auxiliaryData no longer contains the optional hash field.
* auxiliaryData no longer contains the optional body field.

- **cardano-services:** do not omit additional data from unhealthy health responses
- rename AssetInfo 'quantity' to 'supply'
- **cardano-services:** remove obsolete NetworkInfo openApi path
  /network-info/current-wallet-protocol-parameters.
- - `TokenMetadata` has new mandatory property `assetId`

* `DbSyncAssetProvider` constructor requires new
  `DbSyncAssetProviderProp` object as first positional argument
* `createAssetsService` accepts an array of assetIds instead of a
  single assetId

- **cardano-services:** give health checks a dedicated db pool

### Features

- add CORS headers config in provider server ([25010cf](https://github.com/input-output-hk/cardano-js-sdk/commit/25010cf752bf31c46268e8ea31f78b00583f9032))
- added new Transaction class that can convert between CBOR and the Core Tx type ([cc9a80c](https://github.com/input-output-hk/cardano-js-sdk/commit/cc9a80c17f1c0f46124b0c04c597a7ff96e517d3))
- adds the sql queries profiling system ([7f972fd](https://github.com/input-output-hk/cardano-js-sdk/commit/7f972fd54073082cc75d2e7b49a92277e47148c1))
- **cardano-services:** add path metrics on server ([4b8f157](https://github.com/input-output-hk/cardano-js-sdk/commit/4b8f1572fa5615ca6fa0ff540febecaf779ea12c))
- **cardano-services:** add projector service ([5a5b281](https://github.com/input-output-hk/cardano-js-sdk/commit/5a5b281690283995b9a20c61c337c621b919fb3c))
- **cardano-services:** cache the DB and node healthCheck results ([1583ede](https://github.com/input-output-hk/cardano-js-sdk/commit/1583edee2b78f1138430c2d3426a37153413944c))
- **cardano-services:** changes stake pool search provider to not repeat on going queries ([8162246](https://github.com/input-output-hk/cardano-js-sdk/commit/8162246c80713443cf0047035c2bfbb123f6d855))
- **cardano-services:** configurable pgpool size ([3eb3250](https://github.com/input-output-hk/cardano-js-sdk/commit/3eb325017696441a068590abff2d627b038e8b31))
- **cardano-services:** do not omit additional data from unhealthy health responses ([5d83da2](https://github.com/input-output-hk/cardano-js-sdk/commit/5d83da288519bd5944e234267f02e8f9d3cd5114))
- **cardano-services:** give health checks a dedicated db pool ([4729889](https://github.com/input-output-hk/cardano-js-sdk/commit/4729889f4218bd5a3cebf7f0fd342800b2f033f6))
- **cardano-services:** ledgerTip query result is now cached ([3749f59](https://github.com/input-output-hk/cardano-js-sdk/commit/3749f5925cc687451d76c0e238377fa39443784d))
- **cardano-services:** log all queries with execution time ([3876b7f](https://github.com/input-output-hk/cardano-js-sdk/commit/3876b7fb17e583410cf2038bb752fee48b7b148d))
- **cardano-services:** metadata fetching logic ([3647598](https://github.com/input-output-hk/cardano-js-sdk/commit/36475984368426f50323322da622f0af4c5d046b))
- **cardano-services:** optimizes get assets queries ([7aebf26](https://github.com/input-output-hk/cardano-js-sdk/commit/7aebf269ecbec142be0b076fb0a7b37d8e733432))
- **cardano-services:** optimizes the query to get the ledger tip ([a81b013](https://github.com/input-output-hk/cardano-js-sdk/commit/a81b01366a4a914e4a58986c61f02d7c2fb2c7c1))
- **cardano-services:** parametrize pagination queries ([61a0d9d](https://github.com/input-output-hk/cardano-js-sdk/commit/61a0d9d7954725c2626b870f21bc04e417b4f079))
- **cardano-services:** use prepared statements for txs by addresses queries ([5502fa9](https://github.com/input-output-hk/cardano-js-sdk/commit/5502fa95dbff61af138eb7d98772e6b26c45face))
- expose configurable request timeout ([cea5379](https://github.com/input-output-hk/cardano-js-sdk/commit/cea5379e77afda47c2b10f5f9ad66695637f5a01))
- metrics for sync status ([1f081f8](https://github.com/input-output-hk/cardano-js-sdk/commit/1f081f8303d705b383c5d98fdad909ffcc7e23d5))
- **ogmios:** ogmios TxSubmit client now uses a long-running ws connection ([36ee96c](https://github.com/input-output-hk/cardano-js-sdk/commit/36ee96c580f79a4f2759fa9bc87a69bf088e5ed9))
- support assets fetching by ids ([8ed208a](https://github.com/input-output-hk/cardano-js-sdk/commit/8ed208a7a060c6999294c1f53266d6452adb278d))
- transaction body core type now includes the auxiliaryDataHash and networkId fields ([8b92b01](https://github.com/input-output-hk/cardano-js-sdk/commit/8b92b0190083a2b956ae1e188121414428f6663b))

### Bug Fixes

- **cardano-service:** fixes a log called method ([4d57718](https://github.com/input-output-hk/cardano-js-sdk/commit/4d5771884a2c67217b8e79d9081b06e7180bc608))
- **cardano-services:** explicitly process.exit(1) on unhandledRejections ([aeb0520](https://github.com/input-output-hk/cardano-js-sdk/commit/aeb0520b77d23d5d877fff667321f8d3deac21e2))
- **cardano-services:** remove duplicate protocolParams operation id ([de22def](https://github.com/input-output-hk/cardano-js-sdk/commit/de22defa8934ece76818745b9230b76acfc65a38))
- **cardano-services:** stake-pool APY sorted search no longer returns error if APY is disabled ([f81d6c0](https://github.com/input-output-hk/cardano-js-sdk/commit/f81d6c00cdd715db037bb05ce58b03d571742910))
- circular deps check in CI ([070f5e9](https://github.com/input-output-hk/cardano-js-sdk/commit/070f5e9f199c8a3b823f80aa98b35a4df7dbe532))
- tx metadata memory leak ([a5dc8ec](https://github.com/input-output-hk/cardano-js-sdk/commit/a5dc8ec4b18dc7170a58a217dd69a65b6189e1f1))

### Code Refactoring

- rename AssetInfo 'quantity' to 'supply' ([6e28df4](https://github.com/input-output-hk/cardano-js-sdk/commit/6e28df412797974b8ce6f6deb0c3346ff5938a05))

## [0.10.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.9.0...@cardano-sdk/cardano-services@0.10.0) (2023-03-13)

### ⚠ BREAKING CHANGES

- **cardano-services:** rename http-server to provider-server
- core type for address string reprensetation 'Address' renamed to PaymentAddress

### Features

- add inputSource in transactions ([7ed99d5](https://github.com/input-output-hk/cardano-js-sdk/commit/7ed99d5a12cf8667114c76ecde0cbdc3cfbc3887))
- adds caching stake pools metric from blockfrost ([d2de0a4](https://github.com/input-output-hk/cardano-js-sdk/commit/d2de0a4efa8f443fb4b63da9a6322eeaa099d09e))
- **cardano-services:** HTTP server /ready endpoint ([e613306](https://github.com/input-output-hk/cardano-js-sdk/commit/e613306d1eba64eaab638d68319db1154e414756))
- **cardano-services:** support disabling stake pool APY metric, for performance benefits ([18e1dfb](https://github.com/input-output-hk/cardano-js-sdk/commit/18e1dfba661705f0e36f5255f7a3a182952c40ed))
- rewards history limit default ([8c32be8](https://github.com/input-output-hk/cardano-js-sdk/commit/8c32be88a9edd3ed82a34c75d33a7a428ecc3b7c))
- **util-dev:** add DockerUtil (hoisted from cardano-services tests) ([ccb86ab](https://github.com/input-output-hk/cardano-js-sdk/commit/ccb86ab3ad8f0ae3c73a3c36173b1f76c0704f6d))

### Bug Fixes

- **cardano-services:** fixes how collaterals are handled in stake pools related queries ([d4a4158](https://github.com/input-output-hk/cardano-js-sdk/commit/d4a4158e94cedd090a5df569a0aa3c2ec2425c2f))
- **cardano-services:** fixes the total ada computation formula ([c63df83](https://github.com/input-output-hk/cardano-js-sdk/commit/c63df8377b867a5e477f81e54a21c5f4a74c3c93))
- **cardano-services:** fixes the type of blocks created and delegats in stake pools search api ([b76ed1e](https://github.com/input-output-hk/cardano-js-sdk/commit/b76ed1e6fb678843d8bfc08b22c46b439f311ec2))

### Code Refactoring

- **cardano-services:** rename http-server to provider-server ([7b58748](https://github.com/input-output-hk/cardano-js-sdk/commit/7b587480edda5a9f36796ac577fd56baa6d4ee11))
- core type for address string reprensetation 'Address' renamed to PaymentAddress ([4287463](https://github.com/input-output-hk/cardano-js-sdk/commit/42874633de6069510efdc57323f61140d22ed203))

## [0.9.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.8.0...@cardano-sdk/cardano-services@0.9.0) (2023-03-01)

### ⚠ BREAKING CHANGES

- **cardano-services:** simplify program args interface
- **cardano-services:** move API URL, build info, enable metrics into common

### Features

- **cardano-services:** add schema for StakePoolMetrics to OpenAPI spec ([959a2f0](https://github.com/input-output-hk/cardano-js-sdk/commit/959a2f02a069fe6f7de7dade658fd054cf37f41a))
- **cardano-services:** remove CLI terminal clear ([97c5a0c](https://github.com/input-output-hk/cardano-js-sdk/commit/97c5a0ca555c993b6349250851239484c1cf834f))

### Code Refactoring

- **cardano-services:** move API URL, build info, enable metrics into common ([c67e550](https://github.com/input-output-hk/cardano-js-sdk/commit/c67e550981df62532f2b8c2f2f28b4a9e88e9de5))
- **cardano-services:** simplify program args interface ([eb6ceb3](https://github.com/input-output-hk/cardano-js-sdk/commit/eb6ceb394a2e9525b65933bda1a5800eaa1cc652))

## [0.8.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.7.0...@cardano-sdk/cardano-services@0.8.0) (2023-02-17)

### ⚠ BREAKING CHANGES

- **cardano-services:** makes genesis data a dependency for providers which need it
- reworks stake pool epoch rewards fields to be ledger compliant
- - Bip32PublicKey removed from core and replaced by the Bip32PublicKeyHex type from the crypto package.

* Bip32PrivateKey removed from core and replaced by the Bip32PrivateKeyHex type from the crypto package.
* Ed25519PublicKey removed from core and replaced by the Ed25519PublicKeyHex type from the crypto package.
* Ed25519PrivateKey removed from core and replaced by the Ed25519PrivateKeyHex type from the crypto package.
* Ed25519KeyHash removed from core and replaced by the Ed25519KeyHashHex type from the the crypto package.
* Ed25519Signature removed from core and replaced by the Ed25519SignatureHex type from the crypto package.
* Hash32ByteBase16 removed from core and replaced by the Hash32ByteBase16 type from the crypto package.
* Hash28ByteBase16 removed from core and replaced by the Hash28ByteBase16 type from the crypto package.
* The KeyAgent interface now has a new field bip32Ed25519.
* The KeyAgentBase class and all its derived classes (InMemoryKeyAgent, LedgerKeyAgent and TrezorKeyAgent) must now be provided with a Bip32Ed25519 implementation on their constructors.
* Bip32Path type was removed from the key-management package and replaced by the Bip32Path from the crypto package.

- hoist Opaque types, hexBlob, Base64Blob and related utils
- CompactGenesis.slotLength type changed
  from `number` to `Seconds`
- **cardano-services:** Nested `narHash`, `path` and `sourceInfo` under top level `extra` property of BUILD_INFO
- - all provider constructors are updated to use standardized form of deps

### Features

- **cardano-services:** adds dev version of mainnet preprod and preview docker compose ([107ea57](https://github.com/input-output-hk/cardano-js-sdk/commit/107ea574a4932d0e7d402bbbc15be5a0999cd779))
- **cardano-services:** changes the way tx metadatum are read from db, from json to raw bytes ([ca9a110](https://github.com/input-output-hk/cardano-js-sdk/commit/ca9a1107ed89d1f18d68c79bf598b2dd3db8989e))
- **cardano-services:** include healthCheck response as detail in Provider.Unhealthy errors ([16d008d](https://github.com/input-output-hk/cardano-js-sdk/commit/16d008dfa31661c76543f8704292a283c41dd38b))
- **cardano-services:** upgrade /meta endpoint ([e9c3a5b](https://github.com/input-output-hk/cardano-js-sdk/commit/e9c3a5b74a2cc1f69c53f562af8a5b4e693bd20a))
- update CompactGenesis slotLength type to be Seconds ([82e63d6](https://github.com/input-output-hk/cardano-js-sdk/commit/82e63d6cacedbab5ecf8491dfd37749bfeddbc22))

### Bug Fixes

- **cardano-service:** fixes a division by zero in stake pools query ([caa4aac](https://github.com/input-output-hk/cardano-js-sdk/commit/caa4aac213be9c40d572d280ccaac62f67ab80a9))
- **cardano-services:** cache TTL validator ([012b6c5](https://github.com/input-output-hk/cardano-js-sdk/commit/012b6c55456b5c7501940186c3783bd8643b4cd5))
- **cardano-services:** fixes a bug excluding some pools from queries filtering by pledge meet ([9f71a99](https://github.com/input-output-hk/cardano-js-sdk/commit/9f71a9989b47e317e2019a38b6ef27e51dd47935))
- **cardano-services:** fixes a bug on stake pool saturation compute also causing a wrong sort ([4e66060](https://github.com/input-output-hk/cardano-js-sdk/commit/4e660601d6b6b0d22dc6ce635e130f4b19cd73df))
- **cardano-services:** fixes epoch rewards of stake pool query to have the right number of elements ([c7bf65e](https://github.com/input-output-hk/cardano-js-sdk/commit/c7bf65e869bf38c1ff258e626c483cc690f67049))
- **cardano-services:** fixes tx_id format in logged messages ([a4116d7](https://github.com/input-output-hk/cardano-js-sdk/commit/a4116d73b4c594d71a69e5a615293bbe2c2c4b86))
- **cardano-services:** makes rewards epoch length the one from genesis for all epochs but current ([90880cf](https://github.com/input-output-hk/cardano-js-sdk/commit/90880cf1be445808b2ca39b3bcd4757bef0f9981))
- **cardano-services:** stake pool query by metrics results no longer exceedes total count ([adceaa2](https://github.com/input-output-hk/cardano-js-sdk/commit/adceaa25bc459fb68ff48cc326ccee2e3d3b33fc))
- **cardano-services:** stake pool search cached results now correctly handle rewards history limit ([62eefd9](https://github.com/input-output-hk/cardano-js-sdk/commit/62eefd9788e3770e80ed779ea280d4448b9efc18))
- fixes a minor bug in stake pool query sort by name ([5eb3aa5](https://github.com/input-output-hk/cardano-js-sdk/commit/5eb3aa52faed5add00fa63f74094033a8fb28fa0))
- fixes the computation of apy ([6ea2474](https://github.com/input-output-hk/cardano-js-sdk/commit/6ea2474026cdf85436811fab07a847ae9bf0a27b))
- unmemoize slot epoch calc in core package ([2dc6af4](https://github.com/input-output-hk/cardano-js-sdk/commit/2dc6af44906f1b61323a69c3e840834f2c86930f))

### Performance Improvements

- **cardano-services:** remove type validations ([551ddad](https://github.com/input-output-hk/cardano-js-sdk/commit/551ddad4fa6e2161e6ed5f9aece3191d5777522e))

### Code Refactoring

- **cardano-services:** makes genesis data a dependency for providers which need it ([d4c7e24](https://github.com/input-output-hk/cardano-js-sdk/commit/d4c7e249ebbce4ec5d52304565b032905e0286cc))
- hoist Opaque types, hexBlob, Base64Blob and related utils ([391a8f2](https://github.com/input-output-hk/cardano-js-sdk/commit/391a8f20d60607c4fb6ce8586b97ae96841f759b))
- refactor the SDK to use the new crypto package ([3b41320](https://github.com/input-output-hk/cardano-js-sdk/commit/3b41320e7971a231d50785733ff4cd0793418d3d))
- reworks stake pool epoch rewards fields to be ledger compliant ([a9ff583](https://github.com/input-output-hk/cardano-js-sdk/commit/a9ff583d26fe427c2816ab286bb3ae4aeacc9301))
- standardize provider dependencies ([05b37e6](https://github.com/input-output-hk/cardano-js-sdk/commit/05b37e6383a906152df457143c5a27341a11c341))

## [0.7.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.6.0...@cardano-sdk/cardano-services@0.7.0) (2022-12-22)

### ⚠ BREAKING CHANGES

- Alonzo transaction outputs will now contain a datumHash field, carrying the datum hash digest. However, they will also contain a datum field with the exact same value for backward compatibility reason. In Babbage however, transaction outputs will carry either datum or datumHash depending on the case; and datum will only contain inline datums.
- - replace KeyAgent.networkId with KeyAgent.chainId

* remove CardanoNetworkId type
* rename CardanoNetworkMagic->NetworkMagics
* add 'logger' to KeyAgentDependencies
* setupWallet now requires a Logger

- use titlecase for mainnet/testnet in NetworkId
- - rename `redeemer.scriptHash` to `redeemer.data` in core

* change the type from `Hash28ByteBase16` to `HexBlob`

- - BlockSize is now an OpaqueNumber rather than a type alias for number

* BlockNo is now an OpaqueNumber rather than a type alias for number
* EpochNo is now an OpaqueNumber rather than a type alias for number
* Slot is now an OpaqueNumber rather than a type alias for number
* Percentage is now an OpaqueNumber rather than a type alias for number

- rename era-specific types in core
- Even if the value of DB_CACHE_TTL was already interpreted in seconds
  rather than in minutes (despite the error in the description), it's default value is
  changed
- rename block types

* CompactBlock -> BlockInfo
* Block -> ExtendedBlockInfo

- hoist ogmiosToCore to ogmios package
- classify TxSubmission errors as variant of CardanoNode error

### Features

- add opaque numeric types to core package ([9ead8bd](https://github.com/input-output-hk/cardano-js-sdk/commit/9ead8bdb34b7ffc57c32f9ab18a6c6ca14af3fda))
- added new babbage era types in Transactions and Outputs ([0b1f2ff](https://github.com/input-output-hk/cardano-js-sdk/commit/0b1f2ffaad2edec281d206a6865cd1e6053d9826))
- adds projected tip to the db sync based providers's health check response ([eb76414](https://github.com/input-output-hk/cardano-js-sdk/commit/eb76414d5796d6009611ba848e8d5c5fdffa46e4))
- **cardano-services:** synchronizes epoch rollover detected by ledger tip ([0de53ae](https://github.com/input-output-hk/cardano-js-sdk/commit/0de53aeaa320a2d7eff9c2c0a7d9786e39e41e14))
- dbSyncUtxoProvider now returns the new Babbage fields in the UTXO when present ([82b271b](https://github.com/input-output-hk/cardano-js-sdk/commit/82b271b602b6075a561ed12529ca29ab558e303b))
- implement ogmiosToCore certificates mapping ([aef2e8d](https://github.com/input-output-hk/cardano-js-sdk/commit/aef2e8d64da9352c6aab206034950d64f44e9559))
- rename era-specific types in core ([c4955b1](https://github.com/input-output-hk/cardano-js-sdk/commit/c4955b1f3ae0992bb55b1c1461a1e449be0b6ef2))
- replace KeyAgent.networkId with KeyAgent.chainId ([e44dee0](https://github.com/input-output-hk/cardano-js-sdk/commit/e44dee054611636f34b0a66e27d7971af01e0296))

### Bug Fixes

- add sideEffects=false to package.json ([a1cb8f8](https://github.com/input-output-hk/cardano-js-sdk/commit/a1cb8f807e8d5947d0c512e0918713ff97d5d48e))
- **cardano-services:** asset with no name ([34f895f](https://github.com/input-output-hk/cardano-js-sdk/commit/34f895fa5e48e637eebafa7d4815044a63a8e020))
- **cardano-services:** fix possible APY calculation overflow on networks with fast epochs ([a226852](https://github.com/input-output-hk/cardano-js-sdk/commit/a226852eba79a29458feb30c1ff1ff0f43dc3cfc))
- **cardano-services:** tx submit provider init ([d75b61d](https://github.com/input-output-hk/cardano-js-sdk/commit/d75b61d7c9204c299cb4757048946486b80e3b95))
- ttl validation now uses seconds and no longer minutes as the cache itself ([f0eb80f](https://github.com/input-output-hk/cardano-js-sdk/commit/f0eb80f73e61ea48f10809fb3c329fb5c4022e6b))

### Code Refactoring

- change redeemer script hash to data ([a24bbb8](https://github.com/input-output-hk/cardano-js-sdk/commit/a24bbb80d57007352d64b5b99dbc7a19d4948208))
- classify TxSubmission errors as variant of CardanoNode error ([234305e](https://github.com/input-output-hk/cardano-js-sdk/commit/234305e28aefd3d9bd1736315bdf89ca31f7556f))
- use titlecase for mainnet/testnet in NetworkId ([252c589](https://github.com/input-output-hk/cardano-js-sdk/commit/252c589480d3e422b9021ea66a67af978fb80264))

## [0.6.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.5.0...@cardano-sdk/cardano-services@0.6.0) (2022-11-04)

### ⚠ BREAKING CHANGES

- **cardano-services:** support pools ext metadata
- support the complete set of protocol parameters
- make stake pools pagination a required arg
- add pagination in 'transactionsByAddresses'
- **cardano-services:** nftMetadataService returns null instead of
- **input-selection:** renamed cip2 package to input-selection
- hoist Cardano.util.{deserializeTx,metadatum}
- rework TxSubmitProvider to submit transactions as hex string instead of Buffer
- rework all provider signatures args from positional to a single object
- convert boolean args to support ENV counterparts, parse as booleans
- hoist hexString utils to util package

### Features

- add pagination in 'transactionsByAddresses' ([fc88afa](https://github.com/input-output-hk/cardano-js-sdk/commit/fc88afa9f006e9fc7b50b5a98665058a0d563e31))
- **cardano-services:** Add '/meta' endpoint for deployment information ([872bf9c](https://github.com/input-output-hk/cardano-js-sdk/commit/872bf9ca629e0d5a6289bd18b0deadad7c0d8cc9))
- **cardano-services:** add support for using a stub token metadata service ([6975156](https://github.com/input-output-hk/cardano-js-sdk/commit/6975156724ee0c3d35bccf28e5820bc4a81a5b87))
- **cardano-services:** adds log of incoming requests ([f302f9c](https://github.com/input-output-hk/cardano-js-sdk/commit/f302f9c656b9026b3b19a63a4ce818acea841a77))
- **cardano-services:** enhance metrics endpoint ([0fdbb85](https://github.com/input-output-hk/cardano-js-sdk/commit/0fdbb85777d1d8c79189843ad8c7936a42e22380))
- **cardano-services:** make search stake pool case insensitive ([7fb42a7](https://github.com/input-output-hk/cardano-js-sdk/commit/7fb42a7941ae7cf721e18719b81858b454cfb6b8))
- **cardano-services:** nftMetadataService returns null instead of ([7b87d1d](https://github.com/input-output-hk/cardano-js-sdk/commit/7b87d1ded0df482d29dd2b581a3baa9035f32d06))
- **cardano-services:** rewardAccounts limitation ([8ca6917](https://github.com/input-output-hk/cardano-js-sdk/commit/8ca6917f3de646bb9cf6f17c7ac5b4bd1940412d))
- **cardano-services:** support pools ext metadata ([0ac5451](https://github.com/input-output-hk/cardano-js-sdk/commit/0ac545179dac74101f978d62c968cc05898da08b))
- create common mock server util ([53bd4f7](https://github.com/input-output-hk/cardano-js-sdk/commit/53bd4f7de87406a8d3623c903847268e57d0ddeb))
- improve db health check query ([1595350](https://github.com/input-output-hk/cardano-js-sdk/commit/159535092033a745664c399ee1273da436fd3374))
- make stake pools pagination a required arg ([6cf8206](https://github.com/input-output-hk/cardano-js-sdk/commit/6cf8206be2162db7196794f7252e5cbb84b65c77))
- support the complete set of protocol parameters ([46d7aa9](https://github.com/input-output-hk/cardano-js-sdk/commit/46d7aa97230a666ca119c7de5ed0cf70b742d2a2))

### Bug Fixes

- **cardano-services:** cache total pools count ([fbd9ac5](https://github.com/input-output-hk/cardano-js-sdk/commit/fbd9ac5ad77f471259089391b8f27077bc924c0a))
- **cardano-services:** correct interval type and only clear if defined ([a23f384](https://github.com/input-output-hk/cardano-js-sdk/commit/a23f3846d85740675b57c14988ac08e35ee133b9))
- **cardano-services:** correct spelling mistakes ([a7b098f](https://github.com/input-output-hk/cardano-js-sdk/commit/a7b098ffa1fa2d47ba01e5dc15bc2c702013c835))
- **cardano-services:** filter available rewards balance by spendable_epoch>=tip ([4da325a](https://github.com/input-output-hk/cardano-js-sdk/commit/4da325ad39a2d7520f8f8c902e41eed916ac7a38))
- **cardano-services:** fix netinf prov possibly causing unhandled rejection on early called shutdown ([1107d4b](https://github.com/input-output-hk/cardano-js-sdk/commit/1107d4b52fc170a86520a4e8b823cfe7ddfc7b5a))
- **cardano-services:** fix some typos ([303497d](https://github.com/input-output-hk/cardano-js-sdk/commit/303497d4bbc70a2a6ea7566002ad260814284196))
- **cardano-services:** fixed an issue that was causing live stake and saturation values to be calculated incorrectly ([5e714e2](https://github.com/input-output-hk/cardano-js-sdk/commit/5e714e2c5af5a2761389cff8ca24b068252216b8))
- **cardano-services:** fixed an issue that was causing pool saturation to be always 0 ([82cab4d](https://github.com/input-output-hk/cardano-js-sdk/commit/82cab4dbe8ab3c8df13309770a953b30f957ebe3))
- **cardano-services:** fixed some not correctly exported symbols ([8c8950a](https://github.com/input-output-hk/cardano-js-sdk/commit/8c8950add7551b6ad4fec4fe50baec40e28b655d))
- **cardano-services:** handle CardanoTokenRegistry errors ([32a9b1f](https://github.com/input-output-hk/cardano-js-sdk/commit/32a9b1f4714cd556ef3bf2597b52a4d481efcc58))
- **cardano-services:** hash/update id model types ([142098c](https://github.com/input-output-hk/cardano-js-sdk/commit/142098ce8cbf74b50230bab85d438bf39b7b045b))
- **cardano-services:** total rewards is now being calculated correctly for current epoch ([6d4cf6c](https://github.com/input-output-hk/cardano-js-sdk/commit/6d4cf6c64ffb038b9e9ef56597ed0ce366ac1826))
- **cardano-services:** wrong source tx input id ([f6efe3b](https://github.com/input-output-hk/cardano-js-sdk/commit/f6efe3b2507761c4ef5ec7c5b9e8ec87ff2c5039))
- convert boolean args to support ENV counterparts, parse as booleans ([d14bd9d](https://github.com/input-output-hk/cardano-js-sdk/commit/d14bd9d8aeec64f04aab094e0aceb8dc5b803926))
- **core:** custom errors no longer hide inner error details ([9d0f51f](https://github.com/input-output-hk/cardano-js-sdk/commit/9d0f51fe4a3b8ae20c8e83b9209397cd99cc044b))
- remove nullability of Protocol Parameters ([f75859d](https://github.com/input-output-hk/cardano-js-sdk/commit/f75859d644c2a6c4d4844b179357ccab7db537bf))
- rollback ProtocolParametersRequiredByWallet type ([0cd8877](https://github.com/input-output-hk/cardano-js-sdk/commit/0cd887737cc5d4f8d920405c803f05f2c47e42f2))

### Performance Improvements

- **cardano-services:** order by block.id in ledger tip queries ([b985d3f](https://github.com/input-output-hk/cardano-js-sdk/commit/b985d3f09a870359e7a463088fd22a8054f2fff0))

### Code Refactoring

- hoist Cardano.util.{deserializeTx,metadatum} ([a1d0754](https://github.com/input-output-hk/cardano-js-sdk/commit/a1d07549e7a5fccd36b9f75b9f713c0def8cb97f))
- hoist hexString utils to util package ([0c99d9d](https://github.com/input-output-hk/cardano-js-sdk/commit/0c99d9d37f23bb504d1ac2a530fbe78aa045db66))
- **input-selection:** renamed cip2 package to input-selection ([f4d6632](https://github.com/input-output-hk/cardano-js-sdk/commit/f4d6632d61c5b63bc15a64ec3962425f9ad2d6eb))
- rework all provider signatures args from positional to a single object ([dee30b5](https://github.com/input-output-hk/cardano-js-sdk/commit/dee30b52af5edc1241142a2c06708266a1ae7fa4))
- rework TxSubmitProvider to submit transactions as hex string instead of Buffer ([032a1b7](https://github.com/input-output-hk/cardano-js-sdk/commit/032a1b7a11941d52b5baf0d447b615c58a294068))

## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.4.0...@cardano-sdk/cardano-services@0.5.0) (2022-08-30)

### ⚠ BREAKING CHANGES

- consolidate cli & run entrypoints
- rm TxAlonzo.implicitCoin
- removed Ogmios schema package dependency
- replace `NetworkInfoProvider.timeSettings` with `eraSummaries`
- logger is now required
- contextLogger support
- **cardano-services:** make interface properties name more specific

### Features

- **cardano-services:** add db-sync asset http service ([fb254e5](https://github.com/input-output-hk/cardano-js-sdk/commit/fb254e5e8d6058f891cefb479456558fb3835dd0))
- **cardano-services:** add db-sync asset provider ([9763c59](https://github.com/input-output-hk/cardano-js-sdk/commit/9763c598ef5f1b3c95672424fb57647784024298))
- **cardano-services:** add support for secure db connection ([380a633](https://github.com/input-output-hk/cardano-js-sdk/commit/380a6338db024a8dd7ca960fb93ec4da7d3769b5))
- **cardano-services:** cache stake pool queries ([3b65972](https://github.com/input-output-hk/cardano-js-sdk/commit/3b65972b74d410312005c9c60d1b48c269b81aaa))
- **cardano-services:** root health check endpoint ([aff7c6a](https://github.com/input-output-hk/cardano-js-sdk/commit/aff7c6a2b277d24c067e9cec1a14ffd35e8afb17))
- **cardano-services:** uniform ttl parameter of in memory cache methods to be expressed in seconds ([670d0c1](https://github.com/input-output-hk/cardano-js-sdk/commit/670d0c12589a4385b72c445e5f332e195f3b8000))
- implement tx submit worker error handling ([55bc023](https://github.com/input-output-hk/cardano-js-sdk/commit/55bc023a255a27ecdcf19ee6a2e92cc37b0f3801))
- ogmios cardano node DNS resolution ([d132c9f](https://github.com/input-output-hk/cardano-js-sdk/commit/d132c9f52485086a5cf797217d48c816ae51d2b3))
- replace `NetworkInfoProvider.timeSettings` with `eraSummaries` ([58f6fc7](https://github.com/input-output-hk/cardano-js-sdk/commit/58f6fc7c5ace703583c36f95d3d6962483ad924d))

### Bug Fixes

- **cardano-services:** empty array and default condition for identifier filters - search stakePool ([43b8481](https://github.com/input-output-hk/cardano-js-sdk/commit/43b848141d66680001f7cf8efc56d14784077de7))
- **cardano-services:** fixed a division by 0 on APY calculation if epoch lenght is less than 1 day ([bb041cf](https://github.com/input-output-hk/cardano-js-sdk/commit/bb041cf9f36b3eefc38859a1260c9baf585593aa))
- **cardano-services:** initialize CardanoNode ([3c3a5ee](https://github.com/input-output-hk/cardano-js-sdk/commit/3c3a5ee9e6d7068981ed35fcf892992f215473b9))
- **cardano-services:** make HTTP services depend on provider interfaces, rather than classes ([1fef381](https://github.com/input-output-hk/cardano-js-sdk/commit/1fef3819d159e92af6d691d89b0e90a73d9f66ca))
- malformed string and add missing service to Docker defaults ([b40edf6](https://github.com/input-output-hk/cardano-js-sdk/commit/b40edf6f2aec7d654206725e38c88ab1f60d8222))

### Performance Improvements

- improve lovelace supply queries ([7964a2f](https://github.com/input-output-hk/cardano-js-sdk/commit/7964a2f4119c5ee9e8c81589781a8494967b81ee))

### Code Refactoring

- **cardano-services:** make interface properties name more specific ([854408d](https://github.com/input-output-hk/cardano-js-sdk/commit/854408dbf6cf5e7c80280ab104826d8309c801fa))
- consolidate cli & run entrypoints ([1452bfb](https://github.com/input-output-hk/cardano-js-sdk/commit/1452bfb4935129a37dbd83680d623dca081f3948))
- contextLogger support ([6d5da8e](https://github.com/input-output-hk/cardano-js-sdk/commit/6d5da8ec8bba2033ce378d2f0d9321fd758e7c90))
- logger is now required ([cc82bc2](https://github.com/input-output-hk/cardano-js-sdk/commit/cc82bc27539e3ff07f7c2d5816fa7e70c32d06ac))
- removed Ogmios schema package dependency ([4ed2408](https://github.com/input-output-hk/cardano-js-sdk/commit/4ed24087aa5646c6f68ba31c42fc3f8a317df3b9))
- rm TxAlonzo.implicitCoin ([167d205](https://github.com/input-output-hk/cardano-js-sdk/commit/167d205dd15c857b229f968ab53a6e52e5504d3f))

## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/cardano-services@0.4.0) (2022-07-25)

### ⚠ BREAKING CHANGES

- **cardano-services:** make interface properties name more specific
- **cardano-services:** remove static create
- **cardano-services:** service improvements

### Features

- add new `apy` sort field to stake pools ([161ccd8](https://github.com/input-output-hk/cardano-js-sdk/commit/161ccd83c318bb874e59c39cbb9fc1f9b94e3e32))
- **cardano-services:** add db-sync asset http service ([fb254e5](https://github.com/input-output-hk/cardano-js-sdk/commit/fb254e5e8d6058f891cefb479456558fb3835dd0))
- **cardano-services:** add db-sync asset provider ([9763c59](https://github.com/input-output-hk/cardano-js-sdk/commit/9763c598ef5f1b3c95672424fb57647784024298))
- **cardano-services:** add DbSyncNftMetadataService ([f667c0a](https://github.com/input-output-hk/cardano-js-sdk/commit/f667c0a41365eb658b6ec7e8fe9f74bb80aa5243))
- **cardano-services:** add token metadata provider ([040e0eb](https://github.com/input-output-hk/cardano-js-sdk/commit/040e0eb4e7e116724a759eb13d38b803863338c7))
- **cardano-services:** implements rabbitmq new interface ([a880367](https://github.com/input-output-hk/cardano-js-sdk/commit/a880367bb8044a45645dbd30772040ad9422dc59))
- **cardano-services:** service discovery via DNS ([4d4dd36](https://github.com/input-output-hk/cardano-js-sdk/commit/4d4dd36cd4cdf302efc4797821917bdb22974519))
- **cardano-services:** support loading secrets in run.ts for compatibility with existing pattern ([b9ece18](https://github.com/input-output-hk/cardano-js-sdk/commit/b9ece181b36022d2c7d732ef8342be47d9f9aad8))
- sort stake pools by fixed cost ([6e1d6e4](https://github.com/input-output-hk/cardano-js-sdk/commit/6e1d6e4179794aa92b7d3279e3534beb2ac29978))
- support any network by fetching time settings from the node ([08d9ed2](https://github.com/input-output-hk/cardano-js-sdk/commit/08d9ed2b6aa20cf4df2a063f046f4e5ca28c6bd5))

### Bug Fixes

- allow pool relay nullable fields in open api validation ([e7fe121](https://github.com/input-output-hk/cardano-js-sdk/commit/e7fe1215ee02e8672c269796e49f639268b02483))
- **cardano-services:** add missing ENV to run.ts ([13f8698](https://github.com/input-output-hk/cardano-js-sdk/commit/13f869899ba50390e8abe29424d742590be17ae1))
- **cardano-services:** make HTTP services depend on provider interfaces, rather than classes ([1fef381](https://github.com/input-output-hk/cardano-js-sdk/commit/1fef3819d159e92af6d691d89b0e90a73d9f66ca))
- **cardano-services:** stake pool healthcheck ([90e84ee](https://github.com/input-output-hk/cardano-js-sdk/commit/90e84eee1d3d50e043098f73b01d2d084f46f40f))

### Performance Improvements

- improve lovelace supply queries ([7964a2f](https://github.com/input-output-hk/cardano-js-sdk/commit/7964a2f4119c5ee9e8c81589781a8494967b81ee))

### Code Refactoring

- **cardano-services:** make interface properties name more specific ([854408d](https://github.com/input-output-hk/cardano-js-sdk/commit/854408dbf6cf5e7c80280ab104826d8309c801fa))
- **cardano-services:** remove static create ([7eddc2b](https://github.com/input-output-hk/cardano-js-sdk/commit/7eddc2b5aa44ba96b9fe50d599bc10fa80c0bff8))
- **cardano-services:** service improvements ([6eda4aa](https://github.com/input-output-hk/cardano-js-sdk/commit/6eda4aa5776db6658c3526e0a17a2554bf01c6b0))

## 0.3.0 (2022-06-24)

### ⚠ BREAKING CHANGES

- move stakePoolStats from wallet provider to stake pool provider
- rename `StakePoolSearchProvider` to `StakePoolProvider`
- **cardano-services:** compress the multiple entrypoints into a single top-level set
- **cardano-services:** make TxSubmitHttpServer compatible with createHttpProvider<T>
- **cardano-graphql-services:** remove graphql concerns from services package, rename

### Features

- add ChainHistory http provider ([64aa7ae](https://github.com/input-output-hk/cardano-js-sdk/commit/64aa7aeff061aa2cf9bc6196347f6cf5b9c7f6be))
- add sort stake pools by saturation ([#270](https://github.com/input-output-hk/cardano-js-sdk/issues/270)) ([2a9abff](https://github.com/input-output-hk/cardano-js-sdk/commit/2a9abffae06fc462e1811430c0dc8dfa4520091c))
- add totalResultCount to StakePoolSearch response ([4265f6a](https://github.com/input-output-hk/cardano-js-sdk/commit/4265f6af60a92c93604b93167fd297530b6e01f8))
- add utxo http provider ([a55fcdb](https://github.com/input-output-hk/cardano-js-sdk/commit/a55fcdb08276c37a1852f0c39e5b0a78501ddf0b))
- **cardano-services:** add HttpServer.sendJSON ([c60bcf9](https://github.com/input-output-hk/cardano-js-sdk/commit/c60bcf9d7cf0cd1d0ad993939996d02f7be2af2f))
- **cardano-services:** add pool rewards to stake pool search ([f2ed680](https://github.com/input-output-hk/cardano-js-sdk/commit/f2ed680b3dd37c3aa7ced4c99b3e36cf1bd89f83))
- **cardano-services:** add query for stake pool epoch rewards ([7417896](https://github.com/input-output-hk/cardano-js-sdk/commit/74178962608abaf8b96a3b6f7fe09eea701cbfbf))
- **cardano-services:** add sort by order & field ([dd80375](https://github.com/input-output-hk/cardano-js-sdk/commit/dd8037523275ecd9ea13b695a5fff6515918d8a2))
- **cardano-services:** add stake pools metrics and open api validation ([2c010ee](https://github.com/input-output-hk/cardano-js-sdk/commit/2c010ee32f05f7f22968a70d19e965e21d49bdcb))
- **cardano-services:** added call chain of close method from HttpServer to HttpService to Provider ([aa44bdf](https://github.com/input-output-hk/cardano-js-sdk/commit/aa44bdf2304ae55ac0084efa85d72fea7b1f7445))
- **cardano-services:** adds tx submission via rabbitmq load test ([5f6a160](https://github.com/input-output-hk/cardano-js-sdk/commit/5f6a160b2b6724ab7d387229f6c4d3e73e43bdc8))
- **cardano-services:** create NetworkInfo service ([b003d49](https://github.com/input-output-hk/cardano-js-sdk/commit/b003d499b6fad289b8d9656c6293a4f23856b5ed))
- **cardano-services:** integrated in CLIs TxSubmitWorker from @cardano-sdk/rabbitmq ([56adf12](https://github.com/input-output-hk/cardano-js-sdk/commit/56adf12cd4dcd1e5144a67f2d4c2fca4ec9e1c93))
- **cardano-services:** log services HTTP server is using ([7da7802](https://github.com/input-output-hk/cardano-js-sdk/commit/7da7802aef5a93128dbe8eefc5e744631c0a8b8a))
- **cardano-services:** run multiple services from a single HTTP server ([35770e0](https://github.com/input-output-hk/cardano-js-sdk/commit/35770e0ee2767e4a9352c4ebbc09563c80be1f65))
- **cardano-services:** stake pool search http server ([c3dd013](https://github.com/input-output-hk/cardano-js-sdk/commit/c3dd0133843327906535ce2ac623482cf95dd397))
- create InMemoryCache ([a2bfcc6](https://github.com/input-output-hk/cardano-js-sdk/commit/a2bfcc62c25e71d78d07b961267d7ce9679b6cf4))
- rewards data ([5ce2ff0](https://github.com/input-output-hk/cardano-js-sdk/commit/5ce2ff00856d362cf0e423ddadadb15cef764932))

### Bug Fixes

- **cardano-services:** added @cardano-sdk/rabbitmq dependency ([f561a1e](https://github.com/input-output-hk/cardano-js-sdk/commit/f561a1e49be3ecba7a0c16dac516c4ad0db7b30c))
- **cardano-services:** align exit codes on error ([ce8464f](https://github.com/input-output-hk/cardano-js-sdk/commit/ce8464fe4f2f3bb3853667bb95e366d2a7fa700b))
- **cardano-services:** change stake pool search response body data to match provider method ([d83d4af](https://github.com/input-output-hk/cardano-js-sdk/commit/d83d4afd1476edf1b36d50f607e0fb2b75854661))
- **cardano-services:** fix findPoolEpoch rewards, add rounding ([e386211](https://github.com/input-output-hk/cardano-js-sdk/commit/e386211f3b4f5307f2001bce792c24e1deba3182))
- **cardano-services:** fix findPoolsOwners query ([619b2b8](https://github.com/input-output-hk/cardano-js-sdk/commit/619b2b8dacdc1f7efa4bdae69c46f253f14df7c8))
- **cardano-services:** fix pools_delegated on pledgeMet query ([a68771a](https://github.com/input-output-hk/cardano-js-sdk/commit/a68771a36884dc03b3badd61162f5f86e0765ef4))
- **cardano-services:** fixed bin entry in package.json ([de9b89e](https://github.com/input-output-hk/cardano-js-sdk/commit/de9b89e0d6a0d624d9dbc91f4aea2a623597de74))
- **cardano-services:** health check api can now be called in get as well ([b68e90c](https://github.com/input-output-hk/cardano-js-sdk/commit/b68e90c9d194e707d6bd7397cb391735b248849a))
- **cardano-services:** resolve package.json path when cli is run with ts-node ([9c77218](https://github.com/input-output-hk/cardano-js-sdk/commit/9c77218c459834911286dfe95a44a140312fd76f))
- **cardano-services:** updates NetworkInfo OpenAPI spec to align with refactor ([626e8be](https://github.com/input-output-hk/cardano-js-sdk/commit/626e8be65e367d139b7444621355ac1918305673))
- division by zero error at pool rewards query ([#280](https://github.com/input-output-hk/cardano-js-sdk/issues/280)) ([116ed12](https://github.com/input-output-hk/cardano-js-sdk/commit/116ed128d488f211639f5648030e30cfa4855fcb))
- use ordering within UTxO query for reproducible results ([889b437](https://github.com/input-output-hk/cardano-js-sdk/commit/889b43773bdab51eb204ad3a7406b4ddb48000a4))

### Performance Improvements

- **cardano-services:** enhance cache get method ([99b2b9d](https://github.com/input-output-hk/cardano-js-sdk/commit/99b2b9db0e0f0a5e1171690ab519f1424e46c283))

### Miscellaneous Chores

- **cardano-graphql-services:** remove graphql concerns from services package, rename ([71a939b](https://github.com/input-output-hk/cardano-js-sdk/commit/71a939b874296d86183d89fce7877c565630e921))

### Code Refactoring

- **cardano-services:** compress the multiple entrypoints into a single top-level set ([4c3c975](https://github.com/input-output-hk/cardano-js-sdk/commit/4c3c9750006eb987edd7eb5b1a0f9038fcb154d9))
- **cardano-services:** make TxSubmitHttpServer compatible with createHttpProvider<T> ([131f234](https://github.com/input-output-hk/cardano-js-sdk/commit/131f2349b2e54be4765a1db1505d2e7ac4504089))
- move stakePoolStats from wallet provider to stake pool provider ([52d71a7](https://github.com/input-output-hk/cardano-js-sdk/commit/52d71a70700b05902cca6205fe01a63f811ba5af))
- rename `StakePoolSearchProvider` to `StakePoolProvider` ([b432103](https://github.com/input-output-hk/cardano-js-sdk/commit/b43210348da7914664733f85f8be8999271a8667))
