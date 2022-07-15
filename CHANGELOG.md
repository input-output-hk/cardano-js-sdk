# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...0.4.0) (2022-07-15)


### ⚠ BREAKING CHANGES

* hoist KeyAgent's InputResolver dependency to constructor
* **wallet:** tipTracker replaces more generic SyncableIntervalPersistentDocumentTrackerSubject
* **wallet:** - coldObservableProvider expects an object of type
ColdObservableProviderProps instead of positional args
* **cardano-services:** remove static create
* **cardano-services:** service improvements

### Features

* add cip36 metadataBuilder ([0632dc5](https://github.com/input-output-hk/cardano-js-sdk/commit/0632dc508e6be7bc37024e5f8128337ba64a9f47))
* add new `apy` sort field to stake pools ([161ccd8](https://github.com/input-output-hk/cardano-js-sdk/commit/161ccd83c318bb874e59c39cbb9fc1f9b94e3e32))
* **cardano-services:** add DbSyncNftMetadataService ([f667c0a](https://github.com/input-output-hk/cardano-js-sdk/commit/f667c0a41365eb658b6ec7e8fe9f74bb80aa5243))
* **cardano-services:** add token metadata provider ([040e0eb](https://github.com/input-output-hk/cardano-js-sdk/commit/040e0eb4e7e116724a759eb13d38b803863338c7))
* **cardano-services:** implements rabbitmq new interface ([a880367](https://github.com/input-output-hk/cardano-js-sdk/commit/a880367bb8044a45645dbd30772040ad9422dc59))
* **cardano-services:** service discovery via DNS ([4d4dd36](https://github.com/input-output-hk/cardano-js-sdk/commit/4d4dd36cd4cdf302efc4797821917bdb22974519))
* **cardano-services:** support loading secrets in run.ts for compatibility with existing pattern ([b9ece18](https://github.com/input-output-hk/cardano-js-sdk/commit/b9ece181b36022d2c7d732ef8342be47d9f9aad8))
* **core:** accept common ipfs hash without protocol for nft metadata uri ([f1878e3](https://github.com/input-output-hk/cardano-js-sdk/commit/f1878e39b63800d451db1f97624f041f4f424567))
* **core:** added Ed25519PrivateKey to keys ([db1f42c](https://github.com/input-output-hk/cardano-js-sdk/commit/db1f42c9d21115e43a1581de077b5f4f9c84ca43))
* **core:** adds util to get a tx from its body ([f680720](https://github.com/input-output-hk/cardano-js-sdk/commit/f680720f8bd6610871aad587e4a198de9190e229))
* **ogmios:** enriched the test mock to respond with beforeValidityInterval ([b56f9a8](https://github.com/input-output-hk/cardano-js-sdk/commit/b56f9a83b38d9c46dfa1d7008ab632f9a737b9ea))
* sort stake pools by fixed cost ([6e1d6e4](https://github.com/input-output-hk/cardano-js-sdk/commit/6e1d6e4179794aa92b7d3279e3534beb2ac29978))
* support any network by fetching time settings from the node ([08d9ed2](https://github.com/input-output-hk/cardano-js-sdk/commit/08d9ed2b6aa20cf4df2a063f046f4e5ca28c6bd5))
* **wallet:** add createLazyWalletUtil ([8a5ec35](https://github.com/input-output-hk/cardano-js-sdk/commit/8a5ec35cd1af283b15a494d8b25911543252d1b8))
* **wallet:** add missing Alonzo-era tx body fields ([69d3db4](https://github.com/input-output-hk/cardano-js-sdk/commit/69d3db4750d40bb816441b6490e604030c3d7540))
* **wallet:** polling strategy uses new connection status tracker ([03603d8](https://github.com/input-output-hk/cardano-js-sdk/commit/03603d82bddf03bee0fe181c11adb02660fc195d))


### Bug Fixes

* allow pool relay nullable fields in open api validation ([e7fe121](https://github.com/input-output-hk/cardano-js-sdk/commit/e7fe1215ee02e8672c269796e49f639268b02483))
* **cardano-services:** add missing ENV to run.ts ([13f8698](https://github.com/input-output-hk/cardano-js-sdk/commit/13f869899ba50390e8abe29424d742590be17ae1))
* **cardano-services:** stake pool healthcheck ([90e84ee](https://github.com/input-output-hk/cardano-js-sdk/commit/90e84eee1d3d50e043098f73b01d2d084f46f40f))
* **golden-test-generator:** add missing blockBody assignment if Alonzo block ([888e25b](https://github.com/input-output-hk/cardano-js-sdk/commit/888e25b681b370fe072d40728f8d71223a9b42fe))
* **util:** add Set serialization support ([237913f](https://github.com/input-output-hk/cardano-js-sdk/commit/237913f685ee5ae2d5cd7353a92ada8d9f9ff82b))
* **util:** correctly deserialize Set items ([adf458d](https://github.com/input-output-hk/cardano-js-sdk/commit/adf458d150c398ce9589821ef40703c2da5685f7))
* **wallet:** in memory store name typo ([d63d3fb](https://github.com/input-output-hk/cardano-js-sdk/commit/d63d3fbccb414cc75dad8d4a5a43cc611798c281))
* **wallet:** remove assets no longer available in total balance ([fef65d0](https://github.com/input-output-hk/cardano-js-sdk/commit/fef65d0da9413a2f4631736240ddb88d1de7a86b))


* **cardano-services:** remove static create ([7eddc2b](https://github.com/input-output-hk/cardano-js-sdk/commit/7eddc2b5aa44ba96b9fe50d599bc10fa80c0bff8))
* **cardano-services:** service improvements ([6eda4aa](https://github.com/input-output-hk/cardano-js-sdk/commit/6eda4aa5776db6658c3526e0a17a2554bf01c6b0))
* hoist KeyAgent's InputResolver dependency to constructor ([759dc09](https://github.com/input-output-hk/cardano-js-sdk/commit/759dc09b427831cb193f1c0a545901abd4d50254))
* **wallet:** replace positional with named params in coldObservableProvider ([4361cb0](https://github.com/input-output-hk/cardano-js-sdk/commit/4361cb0ff5c2c587668c20e3824bf9c2a8a2ff76))
* **wallet:** tipTracker replaces more generic SyncableIntervalPersistentDocumentTrackerSubject ([311a437](https://github.com/input-output-hk/cardano-js-sdk/commit/311a43708f0468d9810a454bf10f265cd104e857))

## [0.3.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.2.0...0.3.0) (2022-06-24)


### ⚠ BREAKING CHANGES

* **wallet:** - `store` property in TransactionsTrackerProps interface was renamed to `transactionsHistoryStore`
- new property `inFlightTransactionsStore` is required for TransactionsTrackerProps interface
* improve ObservableWallet.balance interface
* **web-extension:** rename RemoteApiProperty.Observable->HotObservable
* **wallet:** observable wallet supports only async properties
* remove transactions and blocks methods from blockfrost wallet provider
* move stakePoolStats from wallet provider to stake pool provider
* rename `StakePoolSearchProvider` to `StakePoolProvider`
* add serializable object key transformation support
* **web-extension:** do not timeout remote observable subscriptions
* **wallet:** replace SingleAddressWallet KeyAgent dep with AsyncKeyAgent
* rm ObservableWallet.networkId (to be resolved via networkInfo$)
* **cip30:** synchronize creation of PersistentAuthenticator
* move jsonToMetadatum from blockfrost package to core.ProviderUtil
* revert 7076fc2ae987948e2c52b696666842ddb67af5d7
* rm cip30 dependency on web-extension
* **wallet:** clean up ObservableWallet interface so it can be easily exposed remotely
* require to explicitly specify exposed api property names (security reasons)
* hoist cip30 mapping of ObservableWallet to cip30 pkg
* **wallet:** rename Wallet interface to ObservableWallet
* **wallet:** rm obsolete cip30.initialize
* rework cip30 to use web extension messaging ports
* delete nftMetadataProvider and remove it from AssetTracker
* **cardano-services:** compress the multiple entrypoints into a single top-level set
* **wallet:** removes history all$, outgoing$ and incoming$ from transactions tracker
* **core:** changes value sent and received inspectors
* **wallet:** changes transactions.history.all$ type from DirectionalTransaction to TxAlonzo
* remove TimeSettingsProvider and NetworkInfo.currentEpoch
* **wallet:** move output validation under Wallet.util
* **cardano-services:** make TxSubmitHttpServer compatible with createHttpProvider<T>
* **cardano-services-client:** reimplement txSubmitHttpProvider using createHttpProvider
* split up WalletProvider.utxoDelegationAndRewards
* rename some WalletProvider functions
* makeTxIn.address required, add NewTxIn that has no address
* **core:** rm epoch? from core certificate types
* rename uiWallet->webExtensionWalletClient
* **core:** set tx body scriptIntegrityHash to correct length (32 byte)
* validate the correct Ed25519KeyHash length (28 bytes)
* **core:** remove PoolRegistrationCertificate.poolId
* **core:** make StakeDelegationCertificate.epoch optional
* **cardano-graphql-services:** remove graphql concerns from services package, rename
* **cardano-graphql:** remove graphql concerns from services client package, rename
* **cardano-graphql-db-sync:** remove package
* **cardano-graphql-services:** hoist health endpoint to HttpServer
* **cardano-graphql-services:** rework the HTTP server construction params
* **wallet:** convert Wallet.syncStatus$ into an object
* change TimeSettings interface from fn to obj
* **core:** nest errors under TxSubmissionErrors object
* **wallet:** getExtendedAccountPublicKey -> extendedAccountPublicKey
* **wallet:** change Wallet.assets$ behavior to not emit empty obj while loading
* **core:** change WalletProvider.rewardsHistory return type to Map
* **wallet:** update stores interface to complete instead of emitting null/empty result
* make blockfrost API instance a parameter of the providers
* Given transaction submission is really an independent behaviour,
as evidenced by microservices such as the HTTP submission API,
it's more flexible modelled as an independent provider.
* **wallet:** remove SingleAddressWallet.address
* **util-dev:** rename mock minimumCost to minimumCostCoefficient
* **wallet:** use HexBlob type from core
* change MetadatumMap type to allow any metadatum as key
* rename AssetInfo metadata->tokenMetadata
* **core:** support T | T[] where appropriate in metadatumToCip25
* move asset info type from Cardano to Asset
* rename AssetMetadata->TokenMetadata, update fields
* **wallet:** move cachedGetPassword under KeyManagement.util
* **wallet:** track known/derived addresses in KeyAgent
* **cardano-graphql:** update schema to store a history of stakepool metrics
* update ogmios to 5.1.0
* **core:** add support to genesis delegate as slot leader
* **core:** add support for base58-encoded addresses
* **core:** move StakePool.metadata under PoolParameters
* **blockfrost:** update blockHeader fields to new core type
* **core:** align Tip and PartialBlockHeader types
* **blockfrost:** use hex-encoded asset name
* **core:** change type of Asset.name to AssetName
* **core:** remove AssetMintOrBurn.action in favor of using negative qty for burn

### Features

* add ChainHistory http provider ([64aa7ae](https://github.com/input-output-hk/cardano-js-sdk/commit/64aa7aeff061aa2cf9bc6196347f6cf5b9c7f6be))
* add cip30 getCollateral method (not implemented) ([2f20255](https://github.com/input-output-hk/cardano-js-sdk/commit/2f202550d8187a5e053afac6490d76df7bffa3f5))
* add optional 'sinceBlock' argument to queryTransactionsByAddresses ([94fdd65](https://github.com/input-output-hk/cardano-js-sdk/commit/94fdd65e0f5b7901081d847eb619a88a1211402c))
* add Provider interface, use as base for TxSubmitProvider ([e155ed4](https://github.com/input-output-hk/cardano-js-sdk/commit/e155ed4efcd1338a54099d1a9034ccbeddeef1cc))
* add sort stake pools by saturation ([#270](https://github.com/input-output-hk/cardano-js-sdk/issues/270)) ([2a9abff](https://github.com/input-output-hk/cardano-js-sdk/commit/2a9abffae06fc462e1811430c0dc8dfa4520091c))
* add totalResultCount to StakePoolSearch response ([4265f6a](https://github.com/input-output-hk/cardano-js-sdk/commit/4265f6af60a92c93604b93167fd297530b6e01f8))
* add utxo http provider ([a55fcdb](https://github.com/input-output-hk/cardano-js-sdk/commit/a55fcdb08276c37a1852f0c39e5b0a78501ddf0b))
* **blockfrost:** implement TxBodyAlonzo.implicitCoin ([99d9b41](https://github.com/input-output-hk/cardano-js-sdk/commit/99d9b416dd173fe595c868c67e8e838e4cad9127))
* **cardano-graphql-services:** add HttpServer abstract class ([2cd3f94](https://github.com/input-output-hk/cardano-js-sdk/commit/2cd3f94b2087fb74f049443208d685bfc7f37ffe))
* **cardano-graphql-services:** add Prometheus metrics middleware to HttpServer ([1a13d34](https://github.com/input-output-hk/cardano-js-sdk/commit/1a13d346d95df049c5a9a08c42bcb9cc5e5f7e54))
* **cardano-graphql-services:** add RunnableModule ([99c2f9d](https://github.com/input-output-hk/cardano-js-sdk/commit/99c2f9d6b0c97498159b4f36ef63665040eefe05))
* **cardano-graphql-services:** add TxSubmitHttpServer ([cb03f69](https://github.com/input-output-hk/cardano-js-sdk/commit/cb03f69248269cfb466690faae9049cfd8c43b55))
* **cardano-graphql-services:** module logger ([d93a121](https://github.com/input-output-hk/cardano-js-sdk/commit/d93a121c626e7c9ce060d575802bc2775cf875e3))
* **cardano-graphql:** add Address and RewardAccount objects ([fddec8f](https://github.com/input-output-hk/cardano-js-sdk/commit/fddec8fad1f5bd361f3889a4837bea1edeb191e3))
* **cardano-graphql:** add Int64 support ([d6f052c](https://github.com/input-output-hk/cardano-js-sdk/commit/d6f052ce90fce43949752348c92e165e099fe7c4))
* **cardano-graphql:** add jsonSerializer that supports bigints, update deps ([36d1375](https://github.com/input-output-hk/cardano-js-sdk/commit/36d1375f28c6d7fa5941407d0153039d0746d64b))
* **cardano-graphql:** add object types for Asset and its metadatas ([834f93d](https://github.com/input-output-hk/cardano-js-sdk/commit/834f93d4699890d89c9cc27656f0bf60c2033163))
* **cardano-graphql:** add preliminary WalletProvider provider implementation ([3ecb80a](https://github.com/input-output-hk/cardano-js-sdk/commit/3ecb80af014c6f620411e64459e563b40b001b89))
* **cardano-graphql:** add Reward object and RewardAccount.withdrawals edge ([fef270d](https://github.com/input-output-hk/cardano-js-sdk/commit/fef270d36251681a2cb164a4a0781bf3c92be662))
* **cardano-graphql:** add rewardsHistory fn to CardanoGraphQLWalletProvider ([f979ee2](https://github.com/input-output-hk/cardano-js-sdk/commit/f979ee2a20c5e56a346b578e1fba62f68ad32453))
* **cardano-graphql:** add StakePool.rewardsHistory and make use of StakePoolSearch options ([40e0bd5](https://github.com/input-output-hk/cardano-js-sdk/commit/40e0bd58907abb87c2f61b5f40010bb9f418bd26))
* **cardano-graphql:** add txSubmitHttpProvider ([81dad15](https://github.com/input-output-hk/cardano-js-sdk/commit/81dad15c85411fd7a3f89ce4fe5722a85d94fcde))
* **cardano-graphql:** complete mapping tx fields ([af95690](https://github.com/input-output-hk/cardano-js-sdk/commit/af95690c692eedd855b44d8b0691064f4a9dbc9b))
* **cardano-graphql:** implement AssetProvider ([ecdf5b4](https://github.com/input-output-hk/cardano-js-sdk/commit/ecdf5b4f1f49f485f1dcb163f88551bc12abb6a2))
* **cardano-graphql:** implement currentWalletProtocolParameters() ([39a7e97](https://github.com/input-output-hk/cardano-js-sdk/commit/39a7e971f412bade47a571fdfa8554734a6672e8))
* **cardano-graphql:** implement genesisParameters(), add util.getExactlyOneObject ([d8d1772](https://github.com/input-output-hk/cardano-js-sdk/commit/d8d17724088d3647327b86017fe92c3f12673bd7))
* **cardano-graphql:** implement genesisParameters(), refactor genesis/protocol parameter schema ([fb72ed1](https://github.com/input-output-hk/cardano-js-sdk/commit/fb72ed1dff6c249fa525a5cd7f2503540afeac87))
* **cardano-graphql:** implement networkInfo() ([62daecc](https://github.com/input-output-hk/cardano-js-sdk/commit/62daecc4dd02f13b3005a9a1eb351f03849495fe))
* **cardano-graphql:** implement queryBlocksByHashes ([d0f28a2](https://github.com/input-output-hk/cardano-js-sdk/commit/d0f28a268d1dd1fd0f2cf19d625aa9976ccfc8c2))
* **cardano-graphql:** implement queryTransactionsByAddresses ([9319f80](https://github.com/input-output-hk/cardano-js-sdk/commit/9319f80971b3ba54f8969814c05f1274c56de880))
* **cardano-graphql:** implement queryTransactionsByHashes (wip) ([f4e4ce7](https://github.com/input-output-hk/cardano-js-sdk/commit/f4e4ce77ddec637bd6ddb22006989ea62dcfae30))
* **cardano-graphql:** map graphql transactions to core types ([1ddf74a](https://github.com/input-output-hk/cardano-js-sdk/commit/1ddf74a195b3610b2e9d97cc2cd095e36ae47502))
* **cardano-graphql:** query transactions (wip), add missing witness props ([9ff5735](https://github.com/input-output-hk/cardano-js-sdk/commit/9ff57350ef8134c8b5336146cc90b82f248b20a8))
* **cardano-graphql:** update schema to store a history of stakepool metrics ([5b22148](https://github.com/input-output-hk/cardano-js-sdk/commit/5b22148a9567c2aee2f960ec4d88458a9f588bdd))
* **cardano-graphql:** utilize Int64 scalar ([4d91589](https://github.com/input-output-hk/cardano-js-sdk/commit/4d91589e90b14cca6265f4b3ddcfce977152a663))
* **cardano-services-client:** add generic http provider client ([72e2060](https://github.com/input-output-hk/cardano-js-sdk/commit/72e20602137a55ca4c6f95221b3d7aa09c10da9a))
* **cardano-services-client:** add stakePoolSearchHttpProvider ([286f41f](https://github.com/input-output-hk/cardano-js-sdk/commit/286f41f700cc6d41fa5192d33e73c87ea6a418ac))
* **cardano-services-client:** networkInfoProvider ([a304468](https://github.com/input-output-hk/cardano-js-sdk/commit/a30446870528acbabda121c691443ee4ba1b2784))
* **cardano-services:** add HttpServer.sendJSON ([c60bcf9](https://github.com/input-output-hk/cardano-js-sdk/commit/c60bcf9d7cf0cd1d0ad993939996d02f7be2af2f))
* **cardano-services:** add pool rewards to stake pool search ([f2ed680](https://github.com/input-output-hk/cardano-js-sdk/commit/f2ed680b3dd37c3aa7ced4c99b3e36cf1bd89f83))
* **cardano-services:** add query for stake pool epoch rewards ([7417896](https://github.com/input-output-hk/cardano-js-sdk/commit/74178962608abaf8b96a3b6f7fe09eea701cbfbf))
* **cardano-services:** add sort by order & field ([dd80375](https://github.com/input-output-hk/cardano-js-sdk/commit/dd8037523275ecd9ea13b695a5fff6515918d8a2))
* **cardano-services:** add stake pools metrics and open api validation ([2c010ee](https://github.com/input-output-hk/cardano-js-sdk/commit/2c010ee32f05f7f22968a70d19e965e21d49bdcb))
* **cardano-services:** added call chain of close method from HttpServer to HttpService to Provider ([aa44bdf](https://github.com/input-output-hk/cardano-js-sdk/commit/aa44bdf2304ae55ac0084efa85d72fea7b1f7445))
* **cardano-services:** adds tx submission via rabbitmq load test ([5f6a160](https://github.com/input-output-hk/cardano-js-sdk/commit/5f6a160b2b6724ab7d387229f6c4d3e73e43bdc8))
* **cardano-services:** create NetworkInfo service ([b003d49](https://github.com/input-output-hk/cardano-js-sdk/commit/b003d499b6fad289b8d9656c6293a4f23856b5ed))
* **cardano-services:** integrated in CLIs TxSubmitWorker from @cardano-sdk/rabbitmq ([56adf12](https://github.com/input-output-hk/cardano-js-sdk/commit/56adf12cd4dcd1e5144a67f2d4c2fca4ec9e1c93))
* **cardano-services:** log services HTTP server is using ([7da7802](https://github.com/input-output-hk/cardano-js-sdk/commit/7da7802aef5a93128dbe8eefc5e744631c0a8b8a))
* **cardano-services:** run multiple services from a single HTTP server ([35770e0](https://github.com/input-output-hk/cardano-js-sdk/commit/35770e0ee2767e4a9352c4ebbc09563c80be1f65))
* **cardano-services:** stake pool search http server ([c3dd013](https://github.com/input-output-hk/cardano-js-sdk/commit/c3dd0133843327906535ce2ac623482cf95dd397))
* **cip2:** add support for custom random fn ([934c855](https://github.com/input-output-hk/cardano-js-sdk/commit/934c85520ca666bc62cc51afa6fbf17dda7bbfb5))
* **cip30:** add extension ID prop ([f4bbd2d](https://github.com/input-output-hk/cardano-js-sdk/commit/f4bbd2d224c90dec8a535236dd013d9fc2b7df22))
* **cip30:** add missing networkId method to api ([bff6958](https://github.com/input-output-hk/cardano-js-sdk/commit/bff6958e45201743b8421dc5f9656e6514522f04))
* **cip30:** add tests for multi-dapp connections, update mapping tests ([8119511](https://github.com/input-output-hk/cardano-js-sdk/commit/81195110f31dff1c9cb62dab03f139cc6e04fe8c))
* **cip30:** implement ApiError{InternalError} ([8d9ed3f](https://github.com/input-output-hk/cardano-js-sdk/commit/8d9ed3fa252bc1e8a66b4e5d2cbd21dc5942f23c))
* **cip30:** initial wallet mapping to cip30api ([66aa6d5](https://github.com/input-output-hk/cardano-js-sdk/commit/66aa6d5b7cc5836dfa6f947af3df86e62318960c))
* **cip30:** removed dependency on window ([20b6af9](https://github.com/input-output-hk/cardano-js-sdk/commit/20b6af9bd9b717632c18971c658966298629e553))
* **cip30:** replace window.localStorage with webextension-polyfill storage ([86e0123](https://github.com/input-output-hk/cardano-js-sdk/commit/86e0123f7c3b357d560ab5aff350b8404b19662c))
* **cip30:** update public api definition ([2a5e2a5](https://github.com/input-output-hk/cardano-js-sdk/commit/2a5e2a52a13ae4793de3db857bff399eb990a3af))
* **cip30:** updated imports + jsdoc tags ([6b734f4](https://github.com/input-output-hk/cardano-js-sdk/commit/6b734f49a058858b693a2cf4193bb3d70faa6006))
* **core:** add 'activating' stakepool status, change certificate enum values to match type names ([59129b5](https://github.com/input-output-hk/cardano-js-sdk/commit/59129b5101a5c8fdc7face33357939db968b2924))
* **core:** add 'bytesToHex', 'HexBlob' and 'castHexBlob' utils ([dc33f15](https://github.com/input-output-hk/cardano-js-sdk/commit/dc33f153288255b256453209433f08dae1a22291))
* **core:** add coreToCsl.txAuxiliaryData ([8686610](https://github.com/input-output-hk/cardano-js-sdk/commit/8686610d776471c96fdc1969b946edd8d26eff23))
* **core:** add coreToCsl.txMint ([16261c6](https://github.com/input-output-hk/cardano-js-sdk/commit/16261c6958dffd59f1cc0c330ffb657ff86e9be3))
* **core:** add cslToCore.utxo ([d497928](https://github.com/input-output-hk/cardano-js-sdk/commit/d497928628a1aaa980898bccb2da98d2c6a19747))
* **core:** add Date support for serializableObject ([d6dc693](https://github.com/input-output-hk/cardano-js-sdk/commit/d6dc693781202d808becbceacd45dd5e1dba6619))
* **core:** add metadatum parsing utils ([51a57ab](https://github.com/input-output-hk/cardano-js-sdk/commit/51a57ab3aebfb67aec1ed5080912cfc0ed68fe40))
* **core:** add optional 'options' argument to StakePoolSearchProvider.queryStakePools ([6ae18a6](https://github.com/input-output-hk/cardano-js-sdk/commit/6ae18a6915d771baef6d7104dfaf0f1054f93be8))
* **core:** add ProviderFailure.Unhealthy ([98fb4a7](https://github.com/input-output-hk/cardano-js-sdk/commit/98fb4a7ac85b0b1bde8977e1c8b6035e7d484cbf))
* **core:** add ProviderUtil.withProviderErrors ([d5bad75](https://github.com/input-output-hk/cardano-js-sdk/commit/d5bad75a78ea1b5dc1741b30f37d8422298449c8))
* **core:** add serializable obj support for custom transformed field discriminator key ([63cf354](https://github.com/input-output-hk/cardano-js-sdk/commit/63cf3549ad84c59c2561e15d633f9757f4a53016))
* **core:** add SerializationFailures: InvalidType, Overflow ([cd262a7](https://github.com/input-output-hk/cardano-js-sdk/commit/cd262a7ec8b58b3e73771b3677db0788636f66dd))
* **core:** add slot time computation util ([17fc677](https://github.com/input-output-hk/cardano-js-sdk/commit/17fc677e1b75579c8ee08d5c6c4d710b41aa7907))
* **core:** add slotEpochCalc util ([d190853](https://github.com/input-output-hk/cardano-js-sdk/commit/d190853a026bc9dd7d98451e5e8afcd4077e997b))
* **core:** add SlotEpochInfoCalc ([c0d3145](https://github.com/input-output-hk/cardano-js-sdk/commit/c0d3145355561472c616fedcaea34adde6300617))
* **core:** add StakePool.epochRewards and estimateStakePoolAPY util ([ff69031](https://github.com/input-output-hk/cardano-js-sdk/commit/ff69031b19b5d902b8bb54e7440ccd334aa68b71))
* **core:** add TimeSettingsProvider type ([602fa88](https://github.com/input-output-hk/cardano-js-sdk/commit/602fa88d04567fb8b7ea00917ccaea56b438f032))
* **core:** add util to create AssetId from PolicyId and AssetName ([aef3345](https://github.com/input-output-hk/cardano-js-sdk/commit/aef334546d53be746608129a96fc5032d67cd1c0))
* **core:** added optional close method to Provider ([69b49cc](https://github.com/input-output-hk/cardano-js-sdk/commit/69b49cc6e7730ea4e1387085dbca3c6db8aee309))
* **core:** cslToCore stake delegation certificate ([1703828](https://github.com/input-output-hk/cardano-js-sdk/commit/1703828583ea9c14fcb9aabf7d92590fc0c06b0b))
* **core:** export NativeScriptType ([92707b6](https://github.com/input-output-hk/cardano-js-sdk/commit/92707b680069b96af4c8cebd7aaf5aa32327b300))
* **core:** extend StakePoolQueryOptions with sort ([9a5d3ba](https://github.com/input-output-hk/cardano-js-sdk/commit/9a5d3ba7bd299dbb5a2fed6aa45cbd6497feda2a))
* **core:** hoist computeImplicitCoin from wallet package ([d991f73](https://github.com/input-output-hk/cardano-js-sdk/commit/d991f73982af48f18386077614693a78d2c420bf))
* **core:** initial cslToCore.newTx implementation ([52835f2](https://github.com/input-output-hk/cardano-js-sdk/commit/52835f279381e79422b1a6761cabc3a6b6144961))
* **core:** introduces transaction inspection utility ([a887733](https://github.com/input-output-hk/cardano-js-sdk/commit/a887733267339cfcade9efae9aec240b2f70d388))
* **core:** isAddressWithin + isOutgoing address utils ([65003b5](https://github.com/input-output-hk/cardano-js-sdk/commit/65003b5314900e15f5842bb9518b35a69b6931b8))
* **core:** partial support for legacy base58 addresses ([0f4cb28](https://github.com/input-output-hk/cardano-js-sdk/commit/0f4cb2835efc9baf8a0e2d7921da59fe70fae1d7))
* **core:** partial support for ShelleyGenesis PoolId ([51bcfb6](https://github.com/input-output-hk/cardano-js-sdk/commit/51bcfb6ae4357477735dbaccd6c40d2c18a28d8e))
* **core:** txSubmissionError util ([1f8dc0f](https://github.com/input-output-hk/cardano-js-sdk/commit/1f8dc0f7ebd3219dbcaaef595262b96813ea67bc))
* create InMemoryCache ([a2bfcc6](https://github.com/input-output-hk/cardano-js-sdk/commit/a2bfcc62c25e71d78d07b961267d7ce9679b6cf4))
* extend NetworkInfo interface ([7b40bca](https://github.com/input-output-hk/cardano-js-sdk/commit/7b40bca2a34c80e9f746339939ed5ce9412e52e9))
* **ogmios:** added submitTxHook to test mock server ([ccbddae](https://github.com/input-output-hk/cardano-js-sdk/commit/ccbddaefeae228b7b02160a6b2ef4e7e0995e689))
* **ogmios:** added urlToConnectionConfig function ([bd22262](https://github.com/input-output-hk/cardano-js-sdk/commit/bd22262cdac4d90561069fefe89028eaf01643a0))
* **ogmios:** export Ogmios client function for SDK access ([92af547](https://github.com/input-output-hk/cardano-js-sdk/commit/92af5472ceff52b747428c37c953ffd3c940d950))
* **ogmios:** exported listenPromise & serverClosePromise test functions ([354de85](https://github.com/input-output-hk/cardano-js-sdk/commit/354de855990b3cad66d61314d481f8063a346b6c))
* **ogmios:** package init and ogmiosTxSubmitProvider ([3b8461b](https://github.com/input-output-hk/cardano-js-sdk/commit/3b8461b2ca9081736c1495318be68deb0e12bd6b))
* **rabbitmq:** added @cardano-sdk/rabbitmq to perform tx submission though a queue ([ff894a5](https://github.com/input-output-hk/cardano-js-sdk/commit/ff894a5e55e62594d5b8565e96585597f7850e8e))
* **rabbitmq:** added TxSubmitWorker, the consumer for RabbitMqTxSubmitProvider ([3c0f604](https://github.com/input-output-hk/cardano-js-sdk/commit/3c0f6048c5cfa04654f0a5463dfccefd24c9054e))
* require to explicitly specify exposed api property names (security reasons) ([f1a0aa4](https://github.com/input-output-hk/cardano-js-sdk/commit/f1a0aa4129705920ea5a734448fea6b99efbdcb4))
* rewards data ([5ce2ff0](https://github.com/input-output-hk/cardano-js-sdk/commit/5ce2ff00856d362cf0e423ddadadb15cef764932))
* **util-dev:** add createStubTimeSettingsProvider ([d19321b](https://github.com/input-output-hk/cardano-js-sdk/commit/d19321b515387f8943f7e0df88b0173c71c46ffb))
* **util-dev:** add createStubUtxoProvider ([ac4156d](https://github.com/input-output-hk/cardano-js-sdk/commit/ac4156d6b74ce05daf11e5feeceef9c941973020))
* **wallet:** add AsyncKeyAgent ([b4856d3](https://github.com/input-output-hk/cardano-js-sdk/commit/b4856d3adfd55d13147215d8e9ec7af0eb1b370b))
* **wallet:** add destroy() to clear resources of the stores ([8a1fc09](https://github.com/input-output-hk/cardano-js-sdk/commit/8a1fc09dcdfc42258fd128eabea76a4ac5c5946f))
* **wallet:** add KeyManagement.util.ownSignaturePaths ([26ca7ce](https://github.com/input-output-hk/cardano-js-sdk/commit/26ca7ce42dac87f4f184cd8a3b564c511632389f))
* **wallet:** Add NodeHID support and HW tests using it ([522669f](https://github.com/input-output-hk/cardano-js-sdk/commit/522669f40833db63031e4c16284e75123ac43c78))
* **wallet:** add optional NFT metadata to Wallet.assets$ ([6671f7e](https://github.com/input-output-hk/cardano-js-sdk/commit/6671f7eb308e460d74e9ce79ac2b63f24f3dd760))
* **wallet:** add restoreLedgerKeyAgent ([2049b48](https://github.com/input-output-hk/cardano-js-sdk/commit/2049b488b2323d088a29c655fa43fa1c8e9e0d43))
* **wallet:** add signed certificate inspector ([e58ce48](https://github.com/input-output-hk/cardano-js-sdk/commit/e58ce488ac34bde325d2cebacef13b1ac0bdd2d9))
* **wallet:** add static method to create agent with device and change accessing xpub method ([726b29f](https://github.com/input-output-hk/cardano-js-sdk/commit/726b29fb72fdaf4d0f460ad54a194a316c29fb96))
* **wallet:** add support for building tx with metadata ([28d0e67](https://github.com/input-output-hk/cardano-js-sdk/commit/28d0e670f9023d5f98fbe7a7840273fc5e0dd20d))
* **wallet:** add types for NFT metadata ([913c217](https://github.com/input-output-hk/cardano-js-sdk/commit/913c217a6da706f8acd3d60d556092bef7447415))
* **wallet:** add unspendable utxo observable and store ([e7d743e](https://github.com/input-output-hk/cardano-js-sdk/commit/e7d743e0fa68e56efe86ce24cc5d83cdb82d0395))
* **wallet:** add util to convert metadatum into cip25-typed object ([2609d0d](https://github.com/input-output-hk/cardano-js-sdk/commit/2609d0d6c32f217110ccf85d6f09a92a9ee4e184))
* **wallet:** add Wallet.syncStatus$ ([06d8805](https://github.com/input-output-hk/cardano-js-sdk/commit/06d8805b6bb2da836c3455374a28d772b31774f0))
* **wallet:** add Wallet.timeSettings$ ([001d447](https://github.com/input-output-hk/cardano-js-sdk/commit/001d4477862bafa7435e96ef01c30edd1f72425e))
* **wallet:** do not re-fetch transactions already in store ([39cd288](https://github.com/input-output-hk/cardano-js-sdk/commit/39cd288de3201d24d9bfeb509c24d45e7a26d3a4))
* **wallet:** implement data signing ([ef0632f](https://github.com/input-output-hk/cardano-js-sdk/commit/ef0632f4f811158ef648883c92231f3919731512))
* **wallet:** implement generic PouchDB stores ([9e46fee](https://github.com/input-output-hk/cardano-js-sdk/commit/9e46fee1ca51df5e20985a44643adf99eb254d86))
* **wallet:** implement pouchdbWalletStores ([6f03cd3](https://github.com/input-output-hk/cardano-js-sdk/commit/6f03cd3428a5655319f032f3ba929d87ec183217))
* **wallet:** implement SingleAddressWallet storage and restoration ([6ff3dc7](https://github.com/input-output-hk/cardano-js-sdk/commit/6ff3dc799f28e773f1e1d75c3260200e6abe92d0))
* **wallet:** implement tx chaining (pending change outputs available as utxo) ([95c2671](https://github.com/input-output-hk/cardano-js-sdk/commit/95c2671055627a7c6cb334adc1a05b6b43bcb738))
* **wallet:** implemented cip30 callbacks ([da7aea2](https://github.com/input-output-hk/cardano-js-sdk/commit/da7aea24b40aea07205a2206f4f562c73a15b0e6))
* **wallet:** introduce LedgerKeyAgent ([cb5cf81](https://github.com/input-output-hk/cardano-js-sdk/commit/cb5cf810a31e35c6db825022b89c576613955d8a))
* **wallet:** introduce TrezorKeyAgent ([beef3de](https://github.com/input-output-hk/cardano-js-sdk/commit/beef3dec60c55cfc3a657ea81221f8cadfdd9167))
* **wallet:** introduce TrezorKeyAgent transaction signing ([08402bd](https://github.com/input-output-hk/cardano-js-sdk/commit/08402bd9f1a9c4d984979040e73f19e287e37de3))
* **wallet:** persistence types and in-memory implementation ([bd50044](https://github.com/input-output-hk/cardano-js-sdk/commit/bd50044b0dc669a1e4c7b15d322d90f2fc213d58))
* **wallet:** re-export rxjs utils to primisify observables ([34e877d](https://github.com/input-output-hk/cardano-js-sdk/commit/34e877dd96833d7374b00e3b0651a06d7836d8ed))
* **wallet:** support loading without KeyAgent being available ([5fb0b46](https://github.com/input-output-hk/cardano-js-sdk/commit/5fb0b46b1ad3d5fbfabe3ab54688dfd2aeb9f1a3))
* **wallet:** track known/derived addresses in KeyAgent ([9ac12c5](https://github.com/input-output-hk/cardano-js-sdk/commit/9ac12c5e391ad8e028f9e0b299b300ccdfcadd71))
* **web-extension:** add remote api nested objects support ([d9f738c](https://github.com/input-output-hk/cardano-js-sdk/commit/d9f738c70c658790aceb2cc855e3b5c87a300107))
* **web-extension:** add remote api observable support ([8ed968c](https://github.com/input-output-hk/cardano-js-sdk/commit/8ed968cf2ca18e902fa9d61281882d1ca20a458a))
* **web-extension:** add rewards provider support ([3630fba](https://github.com/input-output-hk/cardano-js-sdk/commit/3630fbae9fd8bdb5539a32e39b65f2ce8577a481))
* **web-extension:** add utils to expose/consume an AsyncKeyAgent ([80e173d](https://github.com/input-output-hk/cardano-js-sdk/commit/80e173dfb8c7910a660cb62dba67a8765eed247c))
* **web-extension:** export utils to expose/consume an observable wallet ([b215e51](https://github.com/input-output-hk/cardano-js-sdk/commit/b215e5188a011497050921bbaf53c34417189163))


### Bug Fixes

* add missing UTXO_PROVIDER and WALLET_PROVIDER envs to blockfrost instatiation condition ([3773a69](https://github.com/input-output-hk/cardano-js-sdk/commit/3773a69a609a81f5c2541b2c2c21125ae6464cdf))
* **blockfrost:** add e2e test for getAsset, fix it to call blockfrost method on api obj ([10a79bc](https://github.com/input-output-hk/cardano-js-sdk/commit/10a79bc951ea7442f0526e0a84010adb4491deb5))
* **blockfrost:** add support to genesis delegate as slot leader ([ab8766f](https://github.com/input-output-hk/cardano-js-sdk/commit/ab8766f40a270f9db74526185dc3b929900a080a))
* **blockfrost:** added e2e test and fix for collaterals ([c53263e](https://github.com/input-output-hk/cardano-js-sdk/commit/c53263eb44088fc5e254564df49354efd790d8a8))
* **blockfrost:** do not re-fetch protocol parameters for every tx ([3748065](https://github.com/input-output-hk/cardano-js-sdk/commit/37480659aabda979892c5bfa2c7c54af111249fb))
* **blockfrost:** refactored BlockfrostToCore ([112a1c2](https://github.com/input-output-hk/cardano-js-sdk/commit/112a1c21387c2bd819d7cbfccbd40073b40091a4))
* **blockfrost:** set correct testnet network magic ([b0db9dd](https://github.com/input-output-hk/cardano-js-sdk/commit/b0db9dd687bb4f1692d37d4cc43cb1e73372ed69))
* **blockfrost:** sort certificates by cert_index ([8a04a27](https://github.com/input-output-hk/cardano-js-sdk/commit/8a04a27514ec2f7dbf74b1962f992d47074f9e88))
* **cardano-graphql:** correctly convert native metadatum to core types ([8fd2146](https://github.com/input-output-hk/cardano-js-sdk/commit/8fd2146ad11bb5098faafdf9b2d059f545bc7dec))
* **cardano-graphql:** replace bad WalletProvider.rewardsHistory implementation ([de45f5f](https://github.com/input-output-hk/cardano-js-sdk/commit/de45f5f7006dbdf7925813308f07f134d37a7ce7))
* **cardano-graphql:** update StakePool.poolRetirementCertificates to correct type ([411f3b0](https://github.com/input-output-hk/cardano-js-sdk/commit/411f3b0c6a79109bd8e7163daed59313f5a56fe7))
* **cardano-services-client:** http provider can now be the return value of an async function ([e732f5d](https://github.com/input-output-hk/cardano-js-sdk/commit/e732f5d7fcacd75cfecda3e1c21f387d21f46bed))
* **cardano-services-client:** update test URL and reword docblock ([4bfe001](https://github.com/input-output-hk/cardano-js-sdk/commit/4bfe0017a48146c81f571967299d360b8efc6732))
* **cardano-services:** added @cardano-sdk/rabbitmq dependency ([f561a1e](https://github.com/input-output-hk/cardano-js-sdk/commit/f561a1e49be3ecba7a0c16dac516c4ad0db7b30c))
* **cardano-services:** align exit codes on error ([ce8464f](https://github.com/input-output-hk/cardano-js-sdk/commit/ce8464fe4f2f3bb3853667bb95e366d2a7fa700b))
* **cardano-services:** change stake pool search response body data to match provider method ([d83d4af](https://github.com/input-output-hk/cardano-js-sdk/commit/d83d4afd1476edf1b36d50f607e0fb2b75854661))
* **cardano-services:** fix findPoolEpoch rewards, add rounding ([e386211](https://github.com/input-output-hk/cardano-js-sdk/commit/e386211f3b4f5307f2001bce792c24e1deba3182))
* **cardano-services:** fix findPoolsOwners query ([619b2b8](https://github.com/input-output-hk/cardano-js-sdk/commit/619b2b8dacdc1f7efa4bdae69c46f253f14df7c8))
* **cardano-services:** fix pools_delegated on pledgeMet query ([a68771a](https://github.com/input-output-hk/cardano-js-sdk/commit/a68771a36884dc03b3badd61162f5f86e0765ef4))
* **cardano-services:** fixed bin entry in package.json ([de9b89e](https://github.com/input-output-hk/cardano-js-sdk/commit/de9b89e0d6a0d624d9dbc91f4aea2a623597de74))
* **cardano-services:** health check api can now be called in get as well ([b68e90c](https://github.com/input-output-hk/cardano-js-sdk/commit/b68e90c9d194e707d6bd7397cb391735b248849a))
* **cardano-services:** resolve package.json path when cli is run with ts-node ([9c77218](https://github.com/input-output-hk/cardano-js-sdk/commit/9c77218c459834911286dfe95a44a140312fd76f))
* **cardano-services:** updates NetworkInfo OpenAPI spec to align with refactor ([626e8be](https://github.com/input-output-hk/cardano-js-sdk/commit/626e8be65e367d139b7444621355ac1918305673))
* check walletName in cip30 messages ([966b362](https://github.com/input-output-hk/cardano-js-sdk/commit/966b36233c7946ee13418100c7d96bf156e3c526))
* checkout with submodules in post_integration.yml ([111e49e](https://github.com/input-output-hk/cardano-js-sdk/commit/111e49eb1df0d4f9dbc025eb90a00853c8959629))
* **cip2:** adjust fee by hardcoded value (+10k) ([7410ae0](https://github.com/input-output-hk/cardano-js-sdk/commit/7410ae053ea2b4c78d82659a89bdcfd895a4e808))
* **cip2:** computeSelectionLimit constraint logic error ([b329971](https://github.com/input-output-hk/cardano-js-sdk/commit/b3299713ae40a6e5e06a312b4b28f6c20a6a3ef8))
* **cip2:** omit 0 qty assets from change bundles ([d3a12cf](https://github.com/input-output-hk/cardano-js-sdk/commit/d3a12cfb577bcae04f793e96f23ce84ee87a7bcb))
* **cip2:** property tests generate quantities > 0 ([3988ca0](https://github.com/input-output-hk/cardano-js-sdk/commit/3988ca002d45ca8a060d54fb67b244702157ca7e))
* **cip2:** recompute min fee after selecting extra utxo due to min value ([bfb7db5](https://github.com/input-output-hk/cardano-js-sdk/commit/bfb7db55b76d154e036e788edae376b1589510ee))
* **cip2:** remove hardcoded value in minimum cost selection constraint ([ad6d133](https://github.com/input-output-hk/cardano-js-sdk/commit/ad6d133a0ba1f865bf2ae1ca3f46b8e6f918502b))
* **cip30:** make handleMessages more resilient ([67e316e](https://github.com/input-output-hk/cardano-js-sdk/commit/67e316ed583b335a5400842a250ca04965d8e66b))
* **cip30:** remove dangling dependency ([8c5274f](https://github.com/input-output-hk/cardano-js-sdk/commit/8c5274fa7e2b82448359b40ccef1495f040c2648)), closes [#194](https://github.com/input-output-hk/cardano-js-sdk/issues/194)
* **core:** add support for base58-encoded addresses ([b3dc768](https://github.com/input-output-hk/cardano-js-sdk/commit/b3dc7680cbc44c2864d4ea6476e28ae9bbbcc9ab))
* **core:** add support to genesis delegate as slot leader ([d1c098c](https://github.com/input-output-hk/cardano-js-sdk/commit/d1c098cc4dcd34421336cc0516d0a2a59ff355e1))
* **core:** consider empty string a hex value ([3d55224](https://github.com/input-output-hk/cardano-js-sdk/commit/3d552242fb7c9fe5fdf35a9d728b53ae16070432))
* **core:** correct metadata length check ([5394bed](https://github.com/input-output-hk/cardano-js-sdk/commit/5394bedc6cf5db819e74a8de98094fc55bc836fd))
* **core:** finalize cslToCore tx metadata conversion ([eb5740f](https://github.com/input-output-hk/cardano-js-sdk/commit/eb5740ff00b288cfcc6769997e911dc150c16d90))
* **core:** finalize cslToCore.newTx ([2cc40aa](https://github.com/input-output-hk/cardano-js-sdk/commit/2cc40aa0cb065513ba195c0bfb256a3fc8eb7162))
* **core:** remove duplicated insert when assets from the same policy are present in the token map ([7466bac](https://github.com/input-output-hk/cardano-js-sdk/commit/7466bacd7b6feadc56fb77fb71ea44db4f9702a8))
* **core:** set tx body scriptIntegrityHash to correct length (32 byte) ([37822ce](https://github.com/input-output-hk/cardano-js-sdk/commit/37822ce14093ee6e7849fe9c72bd70f86d576a79))
* **core:** support T | T[] where appropriate in metadatumToCip25 ([1a873ec](https://github.com/input-output-hk/cardano-js-sdk/commit/1a873ec182c901813feae8244c86c0346bb70022))
* **core:** throw serialization error for invalid metadata fields ([d67debb](https://github.com/input-output-hk/cardano-js-sdk/commit/d67debb96781474eed775e524fabb3ee48827ea3))
* **core:** tx error mapping fix ([#210](https://github.com/input-output-hk/cardano-js-sdk/issues/210)) ([a03edcd](https://github.com/input-output-hk/cardano-js-sdk/commit/a03edcd806b9038d060ac772b35fccc5819a53ac))
* correct cip30 getUtxos return type ([9ddc5af](https://github.com/input-output-hk/cardano-js-sdk/commit/9ddc5afb57dc0d74b7c11a350c948c4fdd4b06e7))
* division by zero error at pool rewards query ([#280](https://github.com/input-output-hk/cardano-js-sdk/issues/280)) ([116ed12](https://github.com/input-output-hk/cardano-js-sdk/commit/116ed128d488f211639f5648030e30cfa4855fcb))
* **ogmios:** fix failing tests ([3c8c5f7](https://github.com/input-output-hk/cardano-js-sdk/commit/3c8c5f746a41508006e9f059e138b70d9ea1baff))
* **ogmios:** tx submit provider ts error fix ([a24a78c](https://github.com/input-output-hk/cardano-js-sdk/commit/a24a78c5b2d8e75f0c99c12c47cf0b5eb3424b49))
* **rabbitmq:** added @cardano-sdk/core dependency ([6192b72](https://github.com/input-output-hk/cardano-js-sdk/commit/6192b72e6be733270ea953d6ade872ea0f4d2b34))
* **test:** updated nft.test.ts ([8a71c1c](https://github.com/input-output-hk/cardano-js-sdk/commit/8a71c1c5b51a640d48394900bb7c7cd3e50259b5))
* use ordering within UTxO query for reproducible results ([889b437](https://github.com/input-output-hk/cardano-js-sdk/commit/889b43773bdab51eb204ad3a7406b4ddb48000a4))
* validate the correct Ed25519KeyHash length (28 bytes) ([0e0b592](https://github.com/input-output-hk/cardano-js-sdk/commit/0e0b592e2b4b0689f592076cd79dfaac88b43c57))
* **wallet:** add communicationType arg to ledger getHidDeviceList ([7ea7f8c](https://github.com/input-output-hk/cardano-js-sdk/commit/7ea7f8c2f755f2bf7ce4e24c7aebea5ca8cfe955))
* **wallet:** add missing argument in ObservableWallet interface ([e4fefec](https://github.com/input-output-hk/cardano-js-sdk/commit/e4fefec9584a6ed1042c69b80a4d4fe74425f401))
* **wallet:** add missing cleanup for SingleAddressWallet ([083fec9](https://github.com/input-output-hk/cardano-js-sdk/commit/083fec965814f02fefb73bf96d668a7cd024cea2))
* **wallet:** added utxoProvider to e2e tests ([1277aae](https://github.com/input-output-hk/cardano-js-sdk/commit/1277aae60c6674044c4e0befb6a5542a1c85dbdd))
* **wallet:** always initialize chacha with Buffer (for polyfilled browser usage) ([cdb5a3a](https://github.com/input-output-hk/cardano-js-sdk/commit/cdb5a3a057798c3edb0226a5be01fbc0996726c9))
* **wallet:** cache cachedGetPassword calls to getPassword instead of result ([fa67b9e](https://github.com/input-output-hk/cardano-js-sdk/commit/fa67b9e6ddcba788c3e13f850f7d31f6b1bba7d9))
* **wallet:** change Wallet.assets$ behavior to not emit empty obj while loading ([e9cad4a](https://github.com/input-output-hk/cardano-js-sdk/commit/e9cad4a7dc2d2822a697c26834b32484a7a41158))
* **wallet:** consume chained tx outputs ([f051351](https://github.com/input-output-hk/cardano-js-sdk/commit/f05135197f11de9bedf45944d5eeff7c7ed58531))
* **wallet:** correct pouchdb stores implementation ([154cba7](https://github.com/input-output-hk/cardano-js-sdk/commit/154cba7bc0cd62d18bc21d054b62a352f4519e5a))
* **wallet:** correctly load upcoming epoch delegatee ([24001f6](https://github.com/input-output-hk/cardano-js-sdk/commit/24001f65443eff346d61853b5c391924b8da9b5f))
* **wallet:** do not decrypt private key on InMemoryKeyAgent restoration ([1316d4b](https://github.com/input-output-hk/cardano-js-sdk/commit/1316d4b03ee857cc1db9487a6214c339c3d3687d))
* **wallet:** do not mutate previously emitted inFlight transactions ([dcc5dce](https://github.com/input-output-hk/cardano-js-sdk/commit/dcc5dcecef1b06db85641a9dc57f1e03bed612af))
* **wallet:** do not re-derive addresses with same type and index ([11947af](https://github.com/input-output-hk/cardano-js-sdk/commit/11947af71a2d02814f8f156e6d17359e8b8365a3))
* **wallet:** emit ObservableWallet.addresses$ only when it changes ([c6ae4ae](https://github.com/input-output-hk/cardano-js-sdk/commit/c6ae4aefe6c09312f23050bdae02ec95309ebb61))
* **wallet:** ensure transactions are loaded once at any time ([d367eb7](https://github.com/input-output-hk/cardano-js-sdk/commit/d367eb7c0db42ceef1f581e31b95f6577eafbca6))
* **wallet:** filter own delegation certificates when detecting new delegations ([52d22e2](https://github.com/input-output-hk/cardano-js-sdk/commit/52d22e2767b3bbce0c7ec5293ecc621251c59df4))
* **wallet:** fix cachedGetPassword timeout type ([1e9df2f](https://github.com/input-output-hk/cardano-js-sdk/commit/1e9df2f6a04b813da5e6a54a418623a5d4091622))
* **wallet:** fix emip3decrypt to work in browsers (Uint8Array incompatibility) ([dda9e58](https://github.com/input-output-hk/cardano-js-sdk/commit/dda9e58a9b1342d5e27d242e95a92101f107b69e))
* **wallet:** fix hardware test setup - webextension-mock ([ac234bf](https://github.com/input-output-hk/cardano-js-sdk/commit/ac234bf88e28f9679626e57a0462d53fc83bd38e))
* **wallet:** fix ledger tx signing with acc index greater than [#0](https://github.com/input-output-hk/cardano-js-sdk/issues/0) ([c7286e5](https://github.com/input-output-hk/cardano-js-sdk/commit/c7286e54788a4175f3df6c28d34b781e7af5934c))
* **wallet:** forward extraData in TrackedAssetProvider.getAsset ([f877396](https://github.com/input-output-hk/cardano-js-sdk/commit/f8773965b437f8506a30129d97e9ffb33477fa67))
* **wallet:** handle failures when tracking requests for Wallet.syncStatus$ ([6d5b1fd](https://github.com/input-output-hk/cardano-js-sdk/commit/6d5b1fda27bee505a696b5760567dc7d362ab672))
* **wallet:** map doc to serializable in PouchdbCollectionStore.setAll ([0c52c17](https://github.com/input-output-hk/cardano-js-sdk/commit/0c52c177507e7f6b10b7486ba06bb82db7f6e3aa))
* **wallet:** optimize polling by not making some redundant requests ([213f1aa](https://github.com/input-output-hk/cardano-js-sdk/commit/213f1aaee3355cc3dd7a745f6e3b2873f030553a))
* **wallet:** overwrite existing pouchdb docs ([32b743a](https://github.com/input-output-hk/cardano-js-sdk/commit/32b743a2f8783e250e01fb9438c8a0fb4d81c47c))
* **wallet:** pass through pouchdb stores logger ([68ec0a1](https://github.com/input-output-hk/cardano-js-sdk/commit/68ec0a1cae6026ac8f043b468eae7c8c30f641da))
* **wallet:** pouchdb stores support for objects with keys starting with _ ([0ed546a](https://github.com/input-output-hk/cardano-js-sdk/commit/0ed546a3919bf9ec78644a147002d16a9d5ace0d))
* **wallet:** queue pouchdb writes ([36ed98d](https://github.com/input-output-hk/cardano-js-sdk/commit/36ed98dc40e8a6ce8a6a85e7311ec1e68836d4f0))
* **wallet:** set TrackedAssetProvider as initialized ([473a467](https://github.com/input-output-hk/cardano-js-sdk/commit/473a467d663ccb16ea99b0de578e9c0e5e975a9f))
* **wallet:** store keeps track of in flight transactions ([7b55b8e](https://github.com/input-output-hk/cardano-js-sdk/commit/7b55b8effe5480bdc7212cc072de42bfa3066613))
* **wallet:** stub sign for input selection constraints ([edbc6d4](https://github.com/input-output-hk/cardano-js-sdk/commit/edbc6d499efc2c61f6925e09288ded0d75aaacfc))
* **wallet:** support TrackerSubject source observables that instantly complete ([811e4c3](https://github.com/input-output-hk/cardano-js-sdk/commit/811e4c3e392c05b34b02bd5849ff288adea3973a))
* **wallet:** track missing providers ([d441f92](https://github.com/input-output-hk/cardano-js-sdk/commit/d441f9210d6676b98b735044d71a011043a9569d))
* **wallet:** use custom serializableObj type key option ([e531fc2](https://github.com/input-output-hk/cardano-js-sdk/commit/e531fc2f26d7574a4a6bfcd88b2b4f6d0642bd78))
* **web-extension:** cache remote api properties ([44764aa](https://github.com/input-output-hk/cardano-js-sdk/commit/44764aa6ef578d43b5726ba56a7d5c2f80958359))
* **web-extension:** correctly forward message arguments ([9ceadb4](https://github.com/input-output-hk/cardano-js-sdk/commit/9ceadb4bf4ba8d6de428f3e07ea9e9ff86bde40c))
* **web-extension:** do not timeout remote observable subscriptions ([39422e4](https://github.com/input-output-hk/cardano-js-sdk/commit/39422e4fb1bef7760d4aeacdb4c53a84e326bc8d))
* **web-extension:** ignore non-explicitly-exposed observables and objects ([417dd3b](https://github.com/input-output-hk/cardano-js-sdk/commit/417dd3b1949774ecb26f29af8031ada2751ddd3a))
* **web-extension:** support creating remote objects before source exists ([d4ac17f](https://github.com/input-output-hk/cardano-js-sdk/commit/d4ac17f2ad80bdf3dea1d211187ad4c6457f562d))


* add serializable object key transformation support ([32e422e](https://github.com/input-output-hk/cardano-js-sdk/commit/32e422e83f723a41521193d9cf4206a538fbcb43))
* **blockfrost:** update blockHeader fields to new core type ([2a20818](https://github.com/input-output-hk/cardano-js-sdk/commit/2a20818507ec44e9d4aff2647a8095aa92a7a5b9))
* **blockfrost:** use hex-encoded asset name ([41f3039](https://github.com/input-output-hk/cardano-js-sdk/commit/41f30394c53bd7e16728ae1e3862e659822253f9))
* **cardano-graphql-db-sync:** remove package ([1d46146](https://github.com/input-output-hk/cardano-js-sdk/commit/1d461466de73fa432021bd3e08e3f822539817d4))
* **cardano-graphql-services:** hoist health endpoint to HttpServer ([2be5428](https://github.com/input-output-hk/cardano-js-sdk/commit/2be5428638e82e0a6b6dcf0857e5a062e83d272e))
* **cardano-graphql-services:** remove graphql concerns from services package, rename ([71a939b](https://github.com/input-output-hk/cardano-js-sdk/commit/71a939b874296d86183d89fce7877c565630e921))
* **cardano-graphql-services:** rework the HTTP server construction params ([0c5d4b4](https://github.com/input-output-hk/cardano-js-sdk/commit/0c5d4b4cfa49a7683ab5b90293905425372445d6))
* **cardano-graphql:** remove graphql concerns from services client package, rename ([f197e46](https://github.com/input-output-hk/cardano-js-sdk/commit/f197e46254f7f56b6461239a12f213c0e34ccc5c))
* **cardano-services-client:** reimplement txSubmitHttpProvider using createHttpProvider ([db17e34](https://github.com/input-output-hk/cardano-js-sdk/commit/db17e34193322856b1f5073c39658f223d31087b))
* **cardano-services:** compress the multiple entrypoints into a single top-level set ([4c3c975](https://github.com/input-output-hk/cardano-js-sdk/commit/4c3c9750006eb987edd7eb5b1a0f9038fcb154d9))
* **cardano-services:** make TxSubmitHttpServer compatible with createHttpProvider<T> ([131f234](https://github.com/input-output-hk/cardano-js-sdk/commit/131f2349b2e54be4765a1db1505d2e7ac4504089))
* change MetadatumMap type to allow any metadatum as key ([48c33e5](https://github.com/input-output-hk/cardano-js-sdk/commit/48c33e552406cce35ea19d720451a1ba641ff51b))
* change TimeSettings interface from fn to obj ([bc3b22d](https://github.com/input-output-hk/cardano-js-sdk/commit/bc3b22d55071f85073c54dcf47c535912bedb512))
* **cip30:** synchronize creation of PersistentAuthenticator ([fb5dd1b](https://github.com/input-output-hk/cardano-js-sdk/commit/fb5dd1b9c05eda035dcbd6651ad71c0cc3eae5f2))
* **core:** align Tip and PartialBlockHeader types ([a5d5e49](https://github.com/input-output-hk/cardano-js-sdk/commit/a5d5e494cbc65ce61c84decab228acbeb40ef1d5))
* **core:** change type of Asset.name to AssetName ([ced96ed](https://github.com/input-output-hk/cardano-js-sdk/commit/ced96ed100c06afc855ab0bc526180ba5f5152ce))
* **core:** change WalletProvider.rewardsHistory return type to Map ([07ace58](https://github.com/input-output-hk/cardano-js-sdk/commit/07ace5887e9fed02f5ccb8090594022cd3df28d9))
* **core:** changes value sent and received inspectors ([bdecf31](https://github.com/input-output-hk/cardano-js-sdk/commit/bdecf31b5e316c99e526b2555fa3713842258d79))
* **core:** make StakeDelegationCertificate.epoch optional ([3c6155b](https://github.com/input-output-hk/cardano-js-sdk/commit/3c6155b0bc5da5f9724c5604ee19eb9082b4af8f))
* **core:** move StakePool.metadata under PoolParameters ([9a9ac26](https://github.com/input-output-hk/cardano-js-sdk/commit/9a9ac26e3e0cedc10fc80810af11b9d4e0a36467))
* **core:** nest errors under TxSubmissionErrors object ([6e61857](https://github.com/input-output-hk/cardano-js-sdk/commit/6e618570957a655d856f45e4e52d17bf3b164def))
* **core:** remove AssetMintOrBurn.action in favor of using negative qty for burn ([993f53a](https://github.com/input-output-hk/cardano-js-sdk/commit/993f53aed4c192a57ca26526c3ddd879befbd796))
* **core:** remove PoolRegistrationCertificate.poolId ([c73ac29](https://github.com/input-output-hk/cardano-js-sdk/commit/c73ac29e7120cd7fc57a1f262244e20c26cae78a))
* **core:** rm epoch? from core certificate types ([cc904a1](https://github.com/input-output-hk/cardano-js-sdk/commit/cc904a1b2ee5002b71c8f94bddc50db0effb52ad))
* delete nftMetadataProvider and remove it from AssetTracker ([2904cc3](https://github.com/input-output-hk/cardano-js-sdk/commit/2904cc32a60734e2972425c96c67a2a590c7d2cb))
* extract tx submit into own provider ([1d7ac73](https://github.com/input-output-hk/cardano-js-sdk/commit/1d7ac7393fbd669f08b516c4067883d982f2e711))
* hoist cip30 mapping of ObservableWallet to cip30 pkg ([7076fc2](https://github.com/input-output-hk/cardano-js-sdk/commit/7076fc2ae987948e2c52b696666842ddb67af5d7))
* improve ObservableWallet.balance interface ([b8371f9](https://github.com/input-output-hk/cardano-js-sdk/commit/b8371f97e151c2e9cb18e0ac431e9703fe490d26))
* make blockfrost API instance a parameter of the providers ([52b2bda](https://github.com/input-output-hk/cardano-js-sdk/commit/52b2bda4574cb9c7cacf2e3e02ced5ada2c58dd3))
* makeTxIn.address required, add NewTxIn that has no address ([83cd354](https://github.com/input-output-hk/cardano-js-sdk/commit/83cd3546840f936af5e0cde0e43d54f924602400))
* move asset info type from Cardano to Asset ([212b670](https://github.com/input-output-hk/cardano-js-sdk/commit/212b67041598cbcc2c2cf4f5678928943de7aa29))
* move jsonToMetadatum from blockfrost package to core.ProviderUtil ([adeb02c](https://github.com/input-output-hk/cardano-js-sdk/commit/adeb02cdbb1401ff4e9c43d28263357d6f27b0d6))
* move stakePoolStats from wallet provider to stake pool provider ([52d71a7](https://github.com/input-output-hk/cardano-js-sdk/commit/52d71a70700b05902cca6205fe01a63f811ba5af))
* remove TimeSettingsProvider and NetworkInfo.currentEpoch ([4a8f72f](https://github.com/input-output-hk/cardano-js-sdk/commit/4a8f72f57f699f7c0bf4a9a4b742fc0a3e4aa8ce))
* remove transactions and blocks methods from blockfrost wallet provider ([e4de136](https://github.com/input-output-hk/cardano-js-sdk/commit/e4de13650f0d387b8e7126077e8721f353af8c85))
* rename `StakePoolSearchProvider` to `StakePoolProvider` ([b432103](https://github.com/input-output-hk/cardano-js-sdk/commit/b43210348da7914664733f85f8be8999271a8667))
* rename AssetInfo metadata->tokenMetadata ([f064f37](https://github.com/input-output-hk/cardano-js-sdk/commit/f064f372b3d7273c24d78695ceac7254fa55e51f))
* rename AssetMetadata->TokenMetadata, update fields ([a83b897](https://github.com/input-output-hk/cardano-js-sdk/commit/a83b89748ec7efe7dcdbb849ab4b369dd49e5fcc))
* rename some WalletProvider functions ([72ad875](https://github.com/input-output-hk/cardano-js-sdk/commit/72ad875ca8e9c3b65c23794a95ca4110cf34a034))
* rename uiWallet->webExtensionWalletClient ([c4ebdea](https://github.com/input-output-hk/cardano-js-sdk/commit/c4ebdeab881be7f6cfd0ff3d3428bcb8e04529a7))
* revert 7076fc2ae987948e2c52b696666842ddb67af5d7 ([b30183e](https://github.com/input-output-hk/cardano-js-sdk/commit/b30183e4852606e38c1d5b55dd9dc51ed138fc29))
* rework cip30 to use web extension messaging ports ([837dc9d](https://github.com/input-output-hk/cardano-js-sdk/commit/837dc9da1c19df340953c47381becfe07f02a0c9))
* rm cip30 dependency on web-extension ([77f8642](https://github.com/input-output-hk/cardano-js-sdk/commit/77f8642ebaac3b2615d082184d22a96f4cf86d42))
* rm ObservableWallet.networkId (to be resolved via networkInfo$) ([72be7d7](https://github.com/input-output-hk/cardano-js-sdk/commit/72be7d7fc9dfd1bd12593ab572d9b6734d789822))
* split up WalletProvider.utxoDelegationAndRewards ([18f5a57](https://github.com/input-output-hk/cardano-js-sdk/commit/18f5a571cb9d581007182b39d2c68b38491c70e6))
* update ogmios to 5.1.0 ([973bf9e](https://github.com/input-output-hk/cardano-js-sdk/commit/973bf9e6b74f51167f8a1c45560eaabd37bb8525))
* **util-dev:** rename mock minimumCost to minimumCostCoefficient ([1632c1d](https://github.com/input-output-hk/cardano-js-sdk/commit/1632c1d9775dec97edf815816017b7f6714dcd4d))
* **wallet:** changes transactions.history.all$ type from DirectionalTransaction to TxAlonzo ([256a034](https://github.com/input-output-hk/cardano-js-sdk/commit/256a0344971f5366bd2659b5317267b08a714fb9))
* **wallet:** clean up ObservableWallet interface so it can be easily exposed remotely ([249b5b0](https://github.com/input-output-hk/cardano-js-sdk/commit/249b5b0ac12a0c8d8dbca00e11f9b288ba7aaf0a))
* **wallet:** convert Wallet.syncStatus$ into an object ([7662e2b](https://github.com/input-output-hk/cardano-js-sdk/commit/7662e2b71dc1e47b0b1966113ce5bef0d293b92c))
* **wallet:** getExtendedAccountPublicKey -> extendedAccountPublicKey ([8cbe1cc](https://github.com/input-output-hk/cardano-js-sdk/commit/8cbe1cc1c71bd2c93eae7857cfbd41c35531f56b))
* **wallet:** move cachedGetPassword under KeyManagement.util ([e34c0a4](https://github.com/input-output-hk/cardano-js-sdk/commit/e34c0a49a86ffff15afd135820a129767681b24d))
* **wallet:** move output validation under Wallet.util ([d2b2330](https://github.com/input-output-hk/cardano-js-sdk/commit/d2b2330e2bcea0bc3adc64c12d21da3fe7b644d4))
* **wallet:** observable wallet supports only async properties ([f5f3526](https://github.com/input-output-hk/cardano-js-sdk/commit/f5f3526c1662765f48695b54984305e09c8d28b8))
* **wallet:** remove SingleAddressWallet.address ([4344a76](https://github.com/input-output-hk/cardano-js-sdk/commit/4344a7662a59a4b16edaae0a63b13856dea5a863))
* **wallet:** removes history all$, outgoing$ and incoming$ from transactions tracker ([9d400d2](https://github.com/input-output-hk/cardano-js-sdk/commit/9d400d2b14b2c19bb86402a504f5701446d0a680))
* **wallet:** rename Wallet interface to ObservableWallet ([555e56f](https://github.com/input-output-hk/cardano-js-sdk/commit/555e56f78010e68f98eafa2cadf6972437f6cbbd))
* **wallet:** replace SingleAddressWallet KeyAgent dep with AsyncKeyAgent ([5517d81](https://github.com/input-output-hk/cardano-js-sdk/commit/5517d81eb7294cdbfa4cc8cc6f8d5fcebf4660e6))
* **wallet:** rm obsolete cip30.initialize ([5deb87a](https://github.com/input-output-hk/cardano-js-sdk/commit/5deb87a4de5529b0a913e24f2ca2d5df3f492576))
* **wallet:** update stores interface to complete instead of emitting null/empty result ([444ff1d](https://github.com/input-output-hk/cardano-js-sdk/commit/444ff1d4da4493e633be53d5f0d3b4791893b91a))
* **wallet:** use HexBlob type from core ([662656f](https://github.com/input-output-hk/cardano-js-sdk/commit/662656f96b2bb1161673d4ec0ae060cdfe5a1dec))
* **web-extension:** rename RemoteApiProperty.Observable->HotObservable ([4bc9922](https://github.com/input-output-hk/cardano-js-sdk/commit/4bc99224d3cdcadc90729eecd8cb9ea2d6227438))

## [0.2.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.1.8...0.2.0) (2021-12-09)


### ⚠ BREAKING CHANGES

* **cip2:** update interfaces to use core package types instead of CSL
* **wallet:** rename KeyManagement types, improve test coverage
* **wallet:** use emip3 key encryption, refactor KeyManager to support hw wallets (wip)

### Features

* **blockfrost:** wrap submitTx error in UnknownTxSubmissionError ([8244f6b](https://github.com/input-output-hk/cardano-js-sdk/commit/8244f6b814b4483e3d0c279573f3ee360e358134))
* **core:** add Bip32PublicKey and Bip32PrivateKey types, export Witness.Signatures type ([999c33f](https://github.com/input-output-hk/cardano-js-sdk/commit/999c33f03e82f302c68ce8b1685bfc6e44e1621e))
* **core:** add coreToCsl.tokenMap ([e864228](https://github.com/input-output-hk/cardano-js-sdk/commit/e86422822faa2d1ddf72d5eed1956b34dcdfef7f))
* **core:** add utils for custom string types, safer pool id types ([bd430f6](https://github.com/input-output-hk/cardano-js-sdk/commit/bd430f6d1db5ff3c1f3a78317b68811eb4794b6e))
* **core:** export TxSubmissionError type and its variants ([d562a61](https://github.com/input-output-hk/cardano-js-sdk/commit/d562a619b97ae3f8b3d5e92f2f4cb3b4bd6a73ca))
* **util-dev:** add utils to create TxIn/TxOut/Utxo, refactor SelectionConstraints to use core types ([021087e](https://github.com/input-output-hk/cardano-js-sdk/commit/021087e7d3b0ca3de0fbc1bdc9438a6a00a4a07e))
* **wallet:** 2nd-factor mnemonic encryption ([7ddac7a](https://github.com/input-output-hk/cardano-js-sdk/commit/7ddac7ad731e9f2dfb2fbc9f5a2a9cc18b6ab852))
* **wallet:** add 'inputSelection' to initializeTx result ([15a28b3](https://github.com/input-output-hk/cardano-js-sdk/commit/15a28b3ad3f37f433c2acf43266ee0957b4a645a))
* **wallet:** add emip3 encryption util ([7ceee7a](https://github.com/input-output-hk/cardano-js-sdk/commit/7ceee7a469905e6faf070c6dde4aa748b10b5649))
* **wallet:** add KeyManagement.cachedGetPassword util ([0594492](https://github.com/input-output-hk/cardano-js-sdk/commit/0594492a4489ac12115a6437e5256e6c7c82dcab))
* **wallet:** add Wallet.validateTx ([a752da3](https://github.com/input-output-hk/cardano-js-sdk/commit/a752da3af5e82c9a1fe83701925bc4db44fe10cf))
* **wallet:** include TxSubmissionError in Wallet.transactions.outgoing.failed$ ([1c0a86d](https://github.com/input-output-hk/cardano-js-sdk/commit/1c0a86db0f425561467cd0f05d9b5ed80b90f431))
* **wallet:** use emip3 key encryption, refactor KeyManager to support hw wallets (wip) ([961ac26](https://github.com/input-output-hk/cardano-js-sdk/commit/961ac2682c436cf894b401f7d1939e26574f9a6f))


### Bug Fixes

* **blockfrost:** ensure tx metadata number type aligns with core ([ad0eafd](https://github.com/input-output-hk/cardano-js-sdk/commit/ad0eafdeb0953f96ea201b1d0f9a10080ca2b71e))
* change stakepool metadata extVkey field type to bech32 string ([ec523a7](https://github.com/input-output-hk/cardano-js-sdk/commit/ec523a78e62ba30c4297ccd71eb6070dbd58acc3))
* **wallet:** subscribing after initial fetch of tip will no longer wait for new block to emit ([c00d9a7](https://github.com/input-output-hk/cardano-js-sdk/commit/c00d9a778dcef073770e9976f030ccd012a1cd8e))


* **cip2:** update interfaces to use core package types instead of CSL ([5c66d32](https://github.com/input-output-hk/cardano-js-sdk/commit/5c66d32fdc58100a2b0807a0470342d54a3989ed))
* **wallet:** rename KeyManagement types, improve test coverage ([2742eca](https://github.com/input-output-hk/cardano-js-sdk/commit/2742ecab0643fa1badf1e7df2dfede2617c60635))

### [0.1.8](https://github.com/input-output-hk/cardano-js-sdk/compare/0.1.7...0.1.8) (2021-11-22)


### Features

* **blockfrost:** add blockfrostAssetProvider ([8b5acbc](https://github.com/input-output-hk/cardano-js-sdk/commit/8b5acbcfa96b9fa04f43a8747727b75e8d139bd1))
* **blockfrost:** fetch tx metadata, update blockfrost sdk to 2.0.2 ([f5c16a6](https://github.com/input-output-hk/cardano-js-sdk/commit/f5c16a629465df6b4c4db4bb4470420d860b1c7b))
* **core:** add BigIntMath.max, export Cardano.RewardAccount type ([bc14ec8](https://github.com/input-output-hk/cardano-js-sdk/commit/bc14ec8d61854f218d861dc01750030d11f8b336))
* **wallet:** add KeyManager.derivePublicKey and KeyManager.extendedAccountPublicKey ([f3a53b0](https://github.com/input-output-hk/cardano-js-sdk/commit/f3a53b07d83e601d45f5113899f0ed68a4227177))
* **wallet:** add Wallet.assets$ ([351b8e7](https://github.com/input-output-hk/cardano-js-sdk/commit/351b8e7a82ab925ec75c90edc293afc9ef9c47d4))


### Bug Fixes

* **wallet:** delegation changes reflect at end of cuurrent epoch + 2 ([ee0ee2b](https://github.com/input-output-hk/cardano-js-sdk/commit/ee0ee2bc38ce0bac0970848d07364f981bbc5dfd))
* **wallet:** subscribing to confirmed$ and failed$ after tx submission ([1e651bc](https://github.com/input-output-hk/cardano-js-sdk/commit/1e651bcc256f2ee43866ccc42b968055fe920f30))

### [0.1.7](https://github.com/input-output-hk/cardano-js-sdk/compare/0.1.6...0.1.7) (2021-11-16)


### Features

* **wallet:** add Balance.deposit and Wallet.delegation.rewardAccounts$ ([7a47d26](https://github.com/input-output-hk/cardano-js-sdk/commit/7a47d26a724d7670e5b4d3c54552491274c0d829))


### Bug Fixes

* resolve issues preventing to make a delegation tx ([7429f46](https://github.com/input-output-hk/cardano-js-sdk/commit/7429f466763342b08b6bed44f23d3bf24dbf92f2))
* rm imports from @cardano-sdk/*/src/* ([3fdead3](https://github.com/input-output-hk/cardano-js-sdk/commit/3fdead3ae381a3efb98299b9881c6a964461b7db))

### [0.1.6](https://github.com/input-output-hk/cardano-js-sdk/compare/0.1.5...0.1.6) (2021-11-12)


### Features

* add StakePool.status and a few other minor improvements to StakePool types ([1405d05](https://github.com/input-output-hk/cardano-js-sdk/commit/1405d05ca29bac3863178512a73d3a67ee4b7af5))
* add WalletProvider.genesisParameters ([1d824fc](https://github.com/input-output-hk/cardano-js-sdk/commit/1d824fc4c7ded176eb045a253b406d6aa31b016a))
* add WalletProvider.queryBlocksByHashes ([f0431b7](https://github.com/input-output-hk/cardano-js-sdk/commit/f0431b7398c9525f50c0b803748cf2fb6195a36f))
* add WalletProvider.rewardsHistory ([d84c980](https://github.com/input-output-hk/cardano-js-sdk/commit/d84c98086a8cb49de47a2ffd78448899cb47036b))
* **core:** add cslToCore.txInputs, make ProtocolParamsRequiredByWallet fields required ([d67097e](https://github.com/input-output-hk/cardano-js-sdk/commit/d67097ee1fe4c38bd5b37c40795c4737e9a19f68))
* **wallet:** add KeyManager.rewardAccount ([5107afd](https://github.com/input-output-hk/cardano-js-sdk/commit/5107afdc4f5fdbe08abf1c0ccc73376e65121dee))
* **wallet:** add Wallet.delegation.delegatee$ ([83f4782](https://github.com/input-output-hk/cardano-js-sdk/commit/83f478237af0397a42b05d5e2ec6bb4e79b97f76))
* **wallet:** add Wallet.delegation.rewardsHistory$ ([8b8a355](https://github.com/input-output-hk/cardano-js-sdk/commit/8b8a355825ae00b7bd1c95a7e925b32066d22ded))
* **wallet:** add Wallet.genesisParameters$ ([381ef6a](https://github.com/input-output-hk/cardano-js-sdk/commit/381ef6ae03bbec0115e4c836f6d9a9da90fa5bb6))
* **wallet:** add Wallet.networkInfo$ ([7c46ce5](https://github.com/input-output-hk/cardano-js-sdk/commit/7c46ce5807c04f1dd4daa6d217d9699514b713d9))
* **wallet:** change Address type to include additional info ([7a5807e](https://github.com/input-output-hk/cardano-js-sdk/commit/7a5807ef944a8a8abc233ede68ed65002fa4cfb7))
* **wallet:** observable interface & tx tracker ([dd1312b](https://github.com/input-output-hk/cardano-js-sdk/commit/dd1312b45b123f9f3fc7d52cae7f45e9205c406e))
* **wallet:** use block$ and epoch$ to reduce # of provider requests ([0568290](https://github.com/input-output-hk/cardano-js-sdk/commit/0568290debcb0f7561b0b955c7c0c7a6ed667ba8))


### Bug Fixes

* **blockfrost:** interpret 404s in Blockfrost provider and optimise batching ([a795e4c](https://github.com/input-output-hk/cardano-js-sdk/commit/a795e4c70464ad0bbed714b69e826ee3f11be92c))
* **core:** export Address module from root ([2a1d775](https://github.com/input-output-hk/cardano-js-sdk/commit/2a1d7758d740b1cbea1339fdd25b3b4ac40ba7a3))
* **wallet:** do not emit provider data until it changes ([5f74cdd](https://github.com/input-output-hk/cardano-js-sdk/commit/5f74cdd30a66027173ba094e471ed59b2c627ffc))
* **wallet:** don't classify transaction as incoming if it has change output, add some tests ([64b363f](https://github.com/input-output-hk/cardano-js-sdk/commit/64b363f540860de9caa303ca880a7c3ad9479ce2))
* **wallet:** omit rewards for UtxoTracker query, add e2e balance test ([a54f9e0](https://github.com/input-output-hk/cardano-js-sdk/commit/a54f9e05a4fd47b9fde0263316050c92e37bd7c6))
* **wallet:** use keyManager.rewardAccount where bech32 stake address is expected ([f769594](https://github.com/input-output-hk/cardano-js-sdk/commit/f7695945c834ceee9859a5069dcd543616c3ce35))

### [0.1.5](https://github.com/input-output-hk/cardano-js-sdk/compare/0.1.4...0.1.5) (2021-10-27)


### Features

* add WalletProvider.transactionDetails, add address to TxIn ([889a39b](https://github.com/input-output-hk/cardano-js-sdk/commit/889a39b1feb988144dd2249c6c47f91e8096fd48))
* **cardano-graphql:** dgraph integration ([e1195e9](https://github.com/input-output-hk/cardano-js-sdk/commit/e1195e9cd9da84d49fb4160d5e2c69f134afdcac))
* **cardano-graphql:** generate graphql client from shema+operations ([9632eb4](https://github.com/input-output-hk/cardano-js-sdk/commit/9632eb40263cabc0eea8ff813180be90af63eacb))
* **cardano-graphql:** generate graphql schema from ts code ([a3e90ad](https://github.com/input-output-hk/cardano-js-sdk/commit/a3e90ad8e5c790ea250bc779b7e10f4657cdccbd))
* **cardano-graphql:** implement CardanoGraphQLStakePoolSearchProvider (wip) ([80deda6](https://github.com/input-output-hk/cardano-js-sdk/commit/80deda6963a0c07b2f0b24a0a5465c488305d83c))
* **cardano-graphql:** implement search stake pools via dgraph schema ([5487db8](https://github.com/input-output-hk/cardano-js-sdk/commit/5487db818c8a91c8648836d13febfd150392d390))
* **cardano-graphql:** initial implementation of StakePoolSearchClient ([8f4f72a](https://github.com/input-output-hk/cardano-js-sdk/commit/8f4f72af7f6ca61b025f2d98e2edf24108b6e38c))
* **core:** isAddress util ([3f53e79](https://github.com/input-output-hk/cardano-js-sdk/commit/3f53e79f08fd0fd10764c3c648e356d368398df5))
* **util-dev:** add createStubStakePoolSearchProvider ([2e0906b](https://github.com/input-output-hk/cardano-js-sdk/commit/2e0906bc19acdf91b805e1eb647e88aa33ed1b7b))


### Bug Fixes

* **blockfrost:** early return from tallyPools function ([2ab1afc](https://github.com/input-output-hk/cardano-js-sdk/commit/2ab1afcce3f7b02b17352a8abe82b5adb17d8d52))
* **blockfrost:** invalid handling of timestamp ([eed927c](https://github.com/input-output-hk/cardano-js-sdk/commit/eed927ce579426eef38a15797d2223e8df21a40f))
* **wallet:** make txTracker not optional to ensure it's the same as UtxoRepository uses ([653b8d9](https://github.com/input-output-hk/cardano-js-sdk/commit/653b8d90409e79e6624f01368ebb73f61aac1aeb))

### [0.1.4](https://github.com/input-output-hk/cardano-js-sdk/compare/0.1.3...0.1.4) (2021-10-14)


### Features

* **cip2:** add support for implicit coin ([47f6bd2](https://github.com/input-output-hk/cardano-js-sdk/commit/47f6bd2ee714ff9b6b9d8d311f2b3526f88a1a2b))
* **core:** add cslToOgmios.txIn ([5bb937e](https://github.com/input-output-hk/cardano-js-sdk/commit/5bb937e277e3fd23991db2cff1c1ec574904e048))
* **core:** add cslUtil.bytewiseEquals ([1851eb4](https://github.com/input-output-hk/cardano-js-sdk/commit/1851eb4749f8cc43c11acec30377ea5c2f42671a))
* **core:** add NotImplementedError ([5344969](https://github.com/input-output-hk/cardano-js-sdk/commit/534496926a6034f4cea401efa0bb23622b1cb3e6))
* **util-dev:** add flushPromises util ([19eb508](https://github.com/input-output-hk/cardano-js-sdk/commit/19eb508af9c5364f9db604cfe4705857cd62f720))
* **wallet:** add balance interface ([48a820f](https://github.com/input-output-hk/cardano-js-sdk/commit/48a820f57d50ec320d2f80ce236371e95ae5aeff))
* **wallet:** add SingleAddressWallet.balance ([01cda8f](https://github.com/input-output-hk/cardano-js-sdk/commit/01cda8fa6c6ba611a571cc5184a2cb8684f3941c))
* **wallet:** add support for transaction certs and withdrawals ([d8842b0](https://github.com/input-output-hk/cardano-js-sdk/commit/d8842b0ff2f64b0f6899113d4d61d2aefda569ad))
* **wallet:** add utility to create withdrawal ([c49f782](https://github.com/input-output-hk/cardano-js-sdk/commit/c49f7822b58c25a6d7d928f19790d4e45730ef60))
* **wallet:** add UtxoRepository.availableRewards and fix availableUtxo sync ([4f9b13f](https://github.com/input-output-hk/cardano-js-sdk/commit/4f9b13fe043d2c700db4f454bb6454dd4e5e62f4))
* **wallet:** add UtxoRepositoryEvent.Changed ([42e0753](https://github.com/input-output-hk/cardano-js-sdk/commit/42e07535fd6c3f4d1adbe38ee41edfc04a13865c))
* **wallet:** implement BalanceTracker, refactor tests: move all test mocks under ./mocks ([28746ca](https://github.com/input-output-hk/cardano-js-sdk/commit/28746ca214a485bbceb0aae932e6ce3e156eb849))
* **wallet:** implement UTxO lock/unlock functionality, fix utxo sync ([3b6a935](https://github.com/input-output-hk/cardano-js-sdk/commit/3b6a935a440beb961ea6b555bce753ed05a92cdd))
* **wallet:** utilities to create pool certificates, pass implicit coin to input selection ([b5bfbc8](https://github.com/input-output-hk/cardano-js-sdk/commit/b5bfbc8dd850bae20f104df1f5d440dd3940ebb6))


### Bug Fixes

* **wallet:** lock utxo right after submitting, run input selection with availableUtxo set ([0008368](https://github.com/input-output-hk/cardano-js-sdk/commit/0008368293f9dac705fdcbd7e240e0e88046f7e8))

### [0.1.3](https://github.com/input-output-hk/cardano-js-sdk/compare/0.1.2...0.1.3) (2021-10-05)


### Features

* **wallet:** add SingleAddressWallet.name ([7eb4e78](https://github.com/input-output-hk/cardano-js-sdk/commit/7eb4e78cb557c92da038d91b3e4507d873d46818))

### [0.1.2](https://github.com/input-output-hk/cardano-js-sdk/compare/0.1.1...0.1.2) (2021-09-30)


### Bug Fixes

* add missing dependencies ([2d3bfbc](https://github.com/input-output-hk/cardano-js-sdk/commit/2d3bfbc3f8d5fdce3be64835c57304b540e05811))

### 0.1.1 (2021-09-30)


### Features

* add `deriveAddress` and `stakeKey` to the `KeyManager` ([b5ae13b](https://github.com/input-output-hk/cardano-js-sdk/commit/b5ae13b8472519b5a1dde5d9cfa0c64ad7638d07))
* add CardanoProvider.networkInfo ([1596ac2](https://github.com/input-output-hk/cardano-js-sdk/commit/1596ac27b3fa3494f784db37831f85e06a8e0e03))
* add CardanoProvider.stakePoolStats ([c25e570](https://github.com/input-output-hk/cardano-js-sdk/commit/c25e5704be13a9c259fa399e35a3771caad58d38))
* **blockfrost:** create new provider called blockfrost ([b8bd72f](https://github.com/input-output-hk/cardano-js-sdk/commit/b8bd72ffc91769e525400a898cf8e7a749b7d610))
* **cardano-graphql-provider:** create cardano-graphql-provider package ([096225f](https://github.com/input-output-hk/cardano-js-sdk/commit/096225f571aa1b5def660a2bdccfd5bad3d1ef12))
* **cip-30:** create cip-30 package ([266e719](https://github.com/input-output-hk/cardano-js-sdk/commit/266e719d8c0b8550e05ff4d8da199a4575c0664e))
* **cip2:** implement defaultSelectionConstraints ([f93e3f1](https://github.com/input-output-hk/cardano-js-sdk/commit/f93e3f1fd860a477f81975ad415d38c3c93c65d9))
* **cip2:** initial implementation of RoundRobinRandomImprove ([17080e2](https://github.com/input-output-hk/cardano-js-sdk/commit/17080e2ee37ed5b3f51affef8dc834ae3943219f))
* **cip30:** create Messaging bridge for WalletAPi ([c3d0515](https://github.com/input-output-hk/cardano-js-sdk/commit/c3d0515d8bd649b5395d38dd311e04d6381b2b63))
* **core|blockfrost:** modify utxo method on provider to return delegations & rewards ([e0a1bf0](https://github.com/input-output-hk/cardano-js-sdk/commit/e0a1bf020c54d66d2c7920e21dc1369cfc912cbf))
* **core:** add `currentWalletProtocolParameters` method to `CardanoProvider` ([af741c0](https://github.com/input-output-hk/cardano-js-sdk/commit/af741c073c48f7f5ad2f065fd50a48af741c133c))
* **core:** add utils originally used in cip2 package ([2314c4f](https://github.com/input-output-hk/cardano-js-sdk/commit/2314c4f4c19bb7ffeadf98ec2a74399cf7722335))
* create in-memory-key-manager package ([a819e5e](https://github.com/input-output-hk/cardano-js-sdk/commit/a819e5e2161a0cd6bd45c61825957efa810530d3))
* **wallet:** add SingleAddressWallet ([5021dde](https://github.com/input-output-hk/cardano-js-sdk/commit/5021dde20e3dbf08c2fa5dff6f244400a9e7dfa3))
* **wallet:** add UTxO repository and in-memory implementation ([1dc98c3](https://github.com/input-output-hk/cardano-js-sdk/commit/1dc98c3da4660b7f1fa58475948f8cf0f98566e3))
* **wallet:** createTransactionInternals ([1aa7032](https://github.com/input-output-hk/cardano-js-sdk/commit/1aa7032421940ef85aa9eb3d0251a79caaaa19d8))


### Bug Fixes

* add missing yarn script, and rename ([840135f](https://github.com/input-output-hk/cardano-js-sdk/commit/840135f7d100c9a00ff410147758ee7d02112897))
* blockfrost types ([4f77001](https://github.com/input-output-hk/cardano-js-sdk/commit/4f77001f5f6264bd6dd254c4e0ef0a8a14cfb820))
* **cardano-graphql-db-sync:** typescript types of graphql responses ([32ab96f](https://github.com/input-output-hk/cardano-js-sdk/commit/32ab96fb609eeb2788cfd75fa15798c441397ca5))
* **cardano-serialization-lib:** load browser variant of cardano-serialization-lib ([dc367e5](https://github.com/input-output-hk/cardano-js-sdk/commit/dc367e5dd64444d5e1c7209227e3d78797c14fe3))
* **cip2:** add fee to selection skeleton ([36e93bc](https://github.com/input-output-hk/cardano-js-sdk/commit/36e93bccb8f5426022631f409b85aa2fe4ea7470))
* **cip2:** change token bundle size constraint arg to CSL.MultiAsset ([4bde8e8](https://github.com/input-output-hk/cardano-js-sdk/commit/4bde8e8fde11908d4295f3f53918faed255f1ba0))
* **cip2:** compute selection limit constraint with actual fee instead of max u64 ([eee4f5e](https://github.com/input-output-hk/cardano-js-sdk/commit/eee4f5e035a20fb61b151d294213978fd8f39302))
* **cip2:** ensure there are no empty change bundles, add some test info to README ([8f3f20b](https://github.com/input-output-hk/cardano-js-sdk/commit/8f3f20ba8de812895844fad0d09eb63104114a83))
* **cip2:** exclude fee from change bundles ([16d7c26](https://github.com/input-output-hk/cardano-js-sdk/commit/16d7c267df0b9f70d1e2ba1afd03e531282686fd))
* **core:** handle values without assets ([e2862b7](https://github.com/input-output-hk/cardano-js-sdk/commit/e2862b7e54ae1ce8eb6b2b2d2e8eb694136ab5ce))
* getBlocks invalid return ([98f495d](https://github.com/input-output-hk/cardano-js-sdk/commit/98f495de0f5e6701b842eaa4567dc8b47d739b27))
* pack and publish scripts ([992993e](https://github.com/input-output-hk/cardano-js-sdk/commit/992993eee5c05b1f64c811795a46d9c34b7d01f6))
* use cardano-node-ogmios in Docker compose file ([300742b](https://github.com/input-output-hk/cardano-js-sdk/commit/300742bf25d51a2f3c964ef8c783b4d983d55d80))
* use isomorphic CSL in InMemoryKeyManager ([7db40cb](https://github.com/input-output-hk/cardano-js-sdk/commit/7db40cb9664659f0c123dfe4da40d06942860483))
* **wallet:** add tx outputs for change, refactor to use update cip2 interface ([3f07d5c](https://github.com/input-output-hk/cardano-js-sdk/commit/3f07d5c7c716ce3e928596c4736be59ca55d4b11))
