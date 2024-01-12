/* eslint-disable sonarjs/no-duplicate-string */
import { Ogmios } from '../../src';

export const mockGenesisShelley = {
  activeSlotsCoefficient: '1/20',
  epochLength: 86_400,
  era: 'shelley',
  maxKesEvolutions: 120,
  maxLovelaceSupply: 45_000_000_000_000_000,
  network: 'testnet',
  networkMagic: 2,
  securityParameter: 432,
  slotLength: {
    milliseconds: 1000
  },
  slotsPerKesPeriod: 86_400,
  startTime: '2022-08-09T00:00:00Z',
  updateQuorum: 5
} as unknown as Ogmios.Schema.GenesisShelley;

// From mainnet
export const mockByronBlock: Ogmios.Schema.Block = {
  ancestor: '43d58aa00099c44787fdb174db22823494814eb2cdf209b044ca20cc5cf62b25',
  delegate: {
    verificationKey:
      '9180d818e69cd997e34663c418a648c076f2e19cd4194e486e159d8580bc6cda81344440c6ad0e5306fd035bef9281da5d8fbd38f59f588f7081016ee61113d2'
  },
  era: 'byron',
  height: 3314,
  id: 'cf80534e520fa8f4bde1ed2f623553b8a6a9fd616d73bf9d4f7d6d1687685248',
  issuer: {
    verificationKey:
      'd2965c869901231798c5d02d39fca2a79aa47c3e854921b5855c82fd1470891517e1fa771655ec8cad13ecf6e5719adc5392fc057e1703d5f583311e837462f1'
  },
  operationalCertificates: [],
  protocol: {
    id: 764_824_073,
    software: {
      appName: 'cardano-sl',
      number: 0
    },
    version: {
      major: 0,
      minor: 0,
      patch: 0
    }
  },
  size: {
    bytes: 908
  },
  slot: 3313,
  transactions: [
    {
      cbor: '82839f8200d8185824825820a12a839c25a01fa5d118167db5acdbd9e38172ae8f00e5ac0a4997ef792a200700ff9f8282d818584283581c6c9982e7f2b6dcc5eaa880e8014568913c8868d9f0f86eb687b2633ca101581e581c010d876783fb2b4d0d17c86df29af8d35356ed3d1827bf4744f06700001a8dc672c11a000f4240ffa0818202d81858658258208c0bdedfbbab26a1308300512ffb1b220f068ee13f7612afb076c22de3fb764158406cc41635a9794234966629ccfa2a5b089a20ae392f0e92154ff97eda30ff7a082a65fc4b362c24cf58c27f30103b1f1345e15479cf4b80cd4134c0f9dca83109',
      id: '6497b33b10fa2619c6efbd9f874ecd1c91badb10bf70850732aab45b90524d9e',
      inputSource: 'inputs',
      inputs: [
        {
          index: 0,
          transaction: {
            id: 'a12a839c25a01fa5d118167db5acdbd9e38172ae8f00e5ac0a4997ef792a2007'
          }
        }
      ],
      outputs: [
        {
          address:
            'DdzFFzCqrhsszHTvbjTmYje5hehGbadkT6WgWbaqCy5XNxNttsPNF13eAjjBHYT7JaLJz2XVxiucam1EvwBRPSTiCrT4TNCBas4hfzic',
          value: {
            ada: {
              lovelace: 1_000_000n
            }
          }
        }
      ],
      signatories: [
        {
          key: '8c0bdedfbbab26a1308300512ffb1b220f068ee13f7612afb076c22de3fb7641',
          signature:
            '6cc41635a9794234966629ccfa2a5b089a20ae392f0e92154ff97eda30ff7a082a65fc4b362c24cf58c27f30103b1f1345e15479cf4b80cd4134c0f9dca83109'
        }
      ]
      // There's currently an Ogmios bug where it sets 'inputSource' instead of 'spends' for Byron blocks
    } as unknown as Ogmios.Schema.Transaction
  ],
  type: 'bft'
};

export const mockEpochBoundaryBlock: Ogmios.Schema.Block = {
  ancestor: '5f20df933584822601f9e3f8c024eb5eb252fe8cefb24d1317dc3d432e940ebb',
  era: 'byron',
  height: 0,
  id: '89d9b5a5b8ddc8d7e5a6795e9774d97faf1efea59b2caf7eaf9f8c5b32059df4',
  type: 'ebb'
};

// From preprod
export const mockShelleyBlock: Ogmios.Schema.Block = {
  ancestor: '664b6ec8a708b9cf90b87c904e688477887b55cbf4ee6c36877166a2ef216665',
  era: 'shelley',
  height: 48,
  id: '49ef96c51afd2fbef46a73e6b535d7aea10a079a84df19d730e1a127be7e76f2',
  issuer: {
    leaderValue: {
      output:
        '40df8ca52c642e4973e5f03b664cf77e64b9ca9fc1e714aec5185ee5d5e81ad4291df3aa3f162e3e305c6c850f09d478465b67f14b65f01d8c5c285fce85612f',
      proof:
        '7d4c292c29ce94c3b59cf82557473dc868a763a6d829f02daceeba23eff4c81b6cbaa0e3fa7321fda12ed7ae1571a540ad3a8926e16d8aee4b786019c64a300fb3ec35e0f636ceaf52fe8d518506380a'
    },
    operationalCertificate: {
      count: 0,
      kes: {
        period: 0,
        verificationKey: '8c5c56fa647f8fc1b2bb165f7ac54b16d6cae30625f74f4cab86e048ba442a84'
      }
    },
    verificationKey: '9aae625d4d15bcb3733d420e064f1cd338f386e0af049fcd42b455a69d28ad36',
    vrfVerificationKey: '990ed20a21e979e67ae7fd32c86cc6901fe6db52a71bdd3fe6cc45027699ea9f'
  },
  nonce: {
    output:
      '5e6799e47bb1605c8c12c1ac7703261929588485f17fcc2dc9c0fc5c7c7f4ffedadd054bc0f9919a831b1c737b758f401cf2d61cdc13bbdb4d3bb6735defa137',
    proof:
      '4a0ec0b6e094c3b30ad355a72ae9d527dba89e1e3a5f52d620dbc5c59b6f85c7338d8753f721ee5dbcff889687cc81f4a1027e30a001c514d032f48284a8fc7d0b7fd508f97e3b6aaad756aeae07ef03'
  },
  protocol: {
    version: {
      major: 3,
      minor: 0
    }
  },
  size: {
    bytes: 1880
  },
  slot: 86_440,
  transactions: [
    {
      cbor: '83a50081825820b75ec46c406113372efeb1e57d9880856c240c9b531e3c680c1c4d8bf225362500018482581d609e5614893238cf85e284c61ec56d5efd9f9cdc4863ba7e1bf00c2c7d1b006983fdc409d457825839009e5614893238cf85e284c61ec56d5efd9f9cdc4863ba7e1bf00c2c7d968d1021ebd7178e1fb0e79676982825cabc779b653e1234d58ce3c61b00005af3107a4000825839009e5614893238cf85e284c61ec56d5efd9f9cdc4863ba7e1bf00c2c7df130204b518f70c19995449e3737eded3d9ffc31cb50ec0e45010ba31b00005af3107a4000825839009e5614893238cf85e284c61ec56d5efd9f9cdc4863ba7e1bf',
      certificates: [
        {
          credential: '968d1021ebd7178e1fb0e79676982825cabc779b653e1234d58ce3c6',
          type: 'stakeCredentialRegistration'
        },
        {
          stakePool: {
            cost: {
              ada: { lovelace: 500_000_000n }
            },
            id: 'pool1547tew8vmuj0g6vj3k5jfddudextcw6hsk2hwgg6pkhk7lwphe6',
            margin: '1/1',
            owners: ['968d1021ebd7178e1fb0e79676982825cabc779b653e1234d58ce3c6'],
            pledge: {
              ada: { lovelace: 100_000_000_000_000n }
            },
            relays: [
              {
                hostname: 'preprod-node.world.dev.cardano.org',
                port: 30_000,
                type: 'hostname'
              }
            ],
            rewardAccount: 'stake_test1uzkdwx64sjkt6xxtzye00y3k2m9wn5zultsguadaf4ggmssadyunp',
            vrfVerificationKeyHash: '868173d343611103acbdb3452b922bbca5e580d08da4e8f7abf3fb0f2284338a'
          },
          type: 'stakePoolRegistration'
        },
        {
          credential: '968d1021ebd7178e1fb0e79676982825cabc779b653e1234d58ce3c6',
          stakePool: {
            id: 'pool1547tew8vmuj0g6vj3k5jfddudextcw6hsk2hwgg6pkhk7lwphe6'
          },
          type: 'stakeDelegation'
        },
        {
          credential: 'f130204b518f70c19995449e3737eded3d9ffc31cb50ec0e45010ba3',
          type: 'stakeCredentialRegistration'
        },
        {
          stakePool: {
            cost: {
              ada: { lovelace: 500_000_000n }
            },
            id: 'pool174mw7e20768e8vj4fn8y6p536n8rkzswsapwtwn354dckpjqzr8',
            margin: '1/1',
            owners: ['f130204b518f70c19995449e3737eded3d9ffc31cb50ec0e45010ba3'],
            pledge: {
              ada: { lovelace: 100_000_000_000_000n }
            },
            relays: [
              {
                hostname: 'preprod-node.world.dev.cardano.org',
                port: 30_000,
                type: 'hostname'
              }
            ],
            rewardAccount: 'stake_test1uzkdwx64sjkt6xxtzye00y3k2m9wn5zultsguadaf4ggmssadyunp',
            vrfVerificationKeyHash: '352196224497a0fd7bad52d113767660bf70f8b11a8c40c265f7bfb359ebe9ee'
          },
          type: 'stakePoolRegistration'
        },
        {
          credential: 'f130204b518f70c19995449e3737eded3d9ffc31cb50ec0e45010ba3',
          stakePool: {
            id: 'pool174mw7e20768e8vj4fn8y6p536n8rkzswsapwtwn354dckpjqzr8'
          },
          type: 'stakeDelegation'
        },
        {
          credential: '392ae9e068e55e8b5c27acc58b0bab8ea568c0aae2f6fc49be23a7ad',
          type: 'stakeCredentialRegistration'
        },
        {
          stakePool: {
            cost: {
              ada: { lovelace: 500_000_000n }
            },
            id: 'pool1z22x50lqsrwent6en0llzzs9e577rx7n3mv9kfw7udwa2rf42fa',
            margin: '1/1',
            owners: ['392ae9e068e55e8b5c27acc58b0bab8ea568c0aae2f6fc49be23a7ad'],
            pledge: {
              ada: { lovelace: 100_000_000_000_000n }
            },
            relays: [
              {
                hostname: 'preprod-node.world.dev.cardano.org',
                port: 30_000,
                type: 'hostname'
              }
            ],
            rewardAccount: 'stake_test1uzkdwx64sjkt6xxtzye00y3k2m9wn5zultsguadaf4ggmssadyunp',
            vrfVerificationKeyHash: '4b21cf2449bbbaa834e403a29788daec0faab9f3c6b8b25d82aa8366a1a94464'
          },
          type: 'stakePoolRegistration'
        },
        {
          credential: '392ae9e068e55e8b5c27acc58b0bab8ea568c0aae2f6fc49be23a7ad',
          stakePool: {
            id: 'pool1z22x50lqsrwent6en0llzzs9e577rx7n3mv9kfw7udwa2rf42fa'
          },
          type: 'stakeDelegation'
        }
      ],
      fee: {
        ada: { lovelace: 238_057n }
      },
      id: 'a3d6f2627a56fe7921eeda546abfe164321881d41549b7f2fbf09ea0b718d758',
      inputs: [
        {
          index: 0,
          transaction: {
            id: 'b75ec46c406113372efeb1e57d9880856c240c9b531e3c680c1c4d8bf2253625'
          }
        }
      ],
      outputs: [
        {
          address: 'addr_test1vz09v9yfxguvlp0zsnrpa3tdtm7el8xufp3m5lsm7qxzclgmzkket',
          value: {
            ada: {
              lovelace: 29_699_998_493_561_943n
            }
          }
        },
        {
          address:
            'addr_test1qz09v9yfxguvlp0zsnrpa3tdtm7el8xufp3m5lsm7qxzclvk35gzr67hz78plv88jemfs2p9e2780xm98cfrf4vvu0rq83pdz2',
          value: {
            ada: {
              lovelace: 100_000_000_000_000n
            }
          }
        },
        {
          address:
            'addr_test1qz09v9yfxguvlp0zsnrpa3tdtm7el8xufp3m5lsm7qxzcl03xqsyk5v0wrqen92yncmn0m0d8k0lcvwt2rkqu3gppw3sdexkvh',
          value: {
            ada: {
              lovelace: 100_000_000_000_000n
            }
          }
        },
        {
          address:
            'addr_test1qz09v9yfxguvlp0zsnrpa3tdtm7el8xufp3m5lsm7qxzclfe9t57q689t694cfavck9sh2uw545vp2hz7m7yn03r57kslz5rjf',
          value: {
            ada: {
              lovelace: 100_000_000_000_000n
            }
          }
        }
      ],
      signatories: [
        {
          key: '9691ed9d98a5b79d5bc46c4496a6dba7e103f668f525c8349b6b92676cb3eae4',
          signature:
            '5ce8776d3b749e7b096f5dbd388029db57a0c9fc87662b93cf31da4ad1748b3d5d92a7d65454043ae10dbfa4ac34929311526323a7ab3a7436f02e16abdbdb08'
        },
        {
          key: '28450e496f2217e62bf9fd2ece94114562ade49368f456d2e63df2bc4af3244c',
          signature:
            '7c56a4a38044f6b5ee32590bf73cb1101c7c650ff76c07c15d31c87181607a750e90dc09abcb1a431e0ba7c31065f5e3743bf3e1bafe120ca45e4c910f2dc000'
        },
        {
          key: '7b5e9791e10baedf8b1393a32e8851b2ab56c4e9ee1ec489a7ea24f2b6043573',
          signature:
            '512f085e1ffcf13d1328cc458929b79d70cef21bc1028ed1f94e716623869eae9aa9b364e129e289cb18e7d0f58b0d6e7502d4427899535d2d29fcdc30c9cc05'
        },
        {
          key: '69a14b724409e0ceef671c76ec4f8bce7509b5919bb971b3855bf92ca5653222',
          signature:
            'aceda22823823a98fd7363a841c0f75f220bc31a5dd057878f4c59836077260b2db7c1df8547d733bc0972c96c7602cfc847218d4c8dc4f4b770e0dc33124a0f'
        },
        {
          key: 'f270c16659735ec4b65d15d1cbef937e50e608585ac3b71a4cd117fdb761624e',
          signature:
            'd4bd1741ee8064438c564d008b2b7278127f2c4d6b711f4ddb3354c66eb520f3bf3eb1b05046b54d7239df8aaa6623df91f5a59e844977c13fb952f40523a705'
        },
        {
          key: '29036ea60a8b5335b4c026aeb30b87bbcb546fb15a207f4a7035519128bf8a64',
          signature:
            '4d521485917683dff50929915e484255d6360a84a1fe06d908558a242725e3d932ab4d72665af1d483e4b5b20656b524445b5267f50207aabf6a29098bbc1302'
        },
        {
          key: 'a9d974fd26bfaf385749113f260271430276bed6ef4dad6968535de6778471ce',
          signature:
            '22e89209cd66803d613dd586b4970ad77256aaf12a345abc28e07ac4b6975b7c5cfa729b18f00ea9cd252fe4ab1e89e37c6748ddca9e111ab2e2dba98743260d'
        }
      ],
      spends: 'inputs',
      validityInterval: {
        invalidAfter: 90_000
      }
    }
  ],
  type: 'praos'
};

// From preprod
export const mockAlonzoBlock: Ogmios.Schema.Block = {
  ancestor: '89b666de5df4603c050a7a758e4e07f6b29acbaeb020603920e7ae82981bb7a5',
  era: 'alonzo',
  height: 86_474,
  id: '1515d47fe2edba2275eca300e160032f99f684bbf4e852d6f2d86b2e13d0b897',
  issuer: {
    leaderValue: {
      output:
        '01ae1fea04bab713e644813881eaced238b123ce7222ed47cafff40e75125fa92fa4a31d0d878d3c7c5f1212cb1cf86cb25192998c9098867e29f898a7302d3d',
      proof:
        '6d0b0b72effefbd50a62e766869fd8dba277f366453ded2eb85af4b1be006bf49af1e0e5facd1351e63c703fe05cdc2ac281e571684439337b3c431c8a75910826623264e04a0197869369a6f7ba070a'
    },
    operationalCertificate: {
      count: 0,
      kes: {
        period: 0,
        verificationKey: 'fed2662ecbb60ac0a72bca0faeae963649a0c219f4bdd4fc9570ca470727050b'
      }
    },
    verificationKey: 'f270c16659735ec4b65d15d1cbef937e50e608585ac3b71a4cd117fdb761624e',
    vrfVerificationKey: 'ebb507d7e0b0399ffced1a35297203134f8a2a85b616c3591c452cbefa61b88a'
  },
  nonce: {
    output:
      '95ae16b3523a809153697a75428dd758e318a02b8cf80360dea2125a71bbc9c489b20c132ce48100c328e3fb33eaff2f4fc17c2d036d3a126fd9a72ef1376b51',
    proof:
      '50ae06ec16e44e34996c1b270b6237eac5d71dac586a5035e8784c0a6f9efce146d2c57edab46d8f28ece72e2ea20e9f7f634bae9065e6d48bdc9c0f711a4c117c0dad233b2d29fcd4fce20bf08e3d09'
  },
  protocol: {
    version: {
      major: 7,
      minor: 2
    }
  },
  size: {
    bytes: 1152
  },
  slot: 1_814_649,
  transactions: [
    {
      cbor: '84a400818258200dd9b1dd89ff50c6907b3fd0385fde86f7c6877c2c9a95a9a9aa83b1cfead12800018182581d609e5614893238cf85e284c61ec56d5efd9f9cdc4863ba7e1bf00c2c7d1b006983fdc3fd39a3021a0003249d0682a7581c637f2e950b0fd8f8e3e811c5fbeb19e411e7a2bf37272b84b29c1a0ba10e820600581c8a4b77c4f534f8b8cc6f269e5ebb7ba77fa63a476e50e05e66d7051ca10e820600581cb00470cd193d67aac47c373602fccd4195aad3002c169b5570de1126a10e820600581cb260ffdb6eba541fcf18601923457307647dce807851b9d19da133aba10e820600581cced1599fd821a39593e00592e5292bd',
      fee: {
        ada: { lovelace: 205_981n }
      },
      id: 'cb9a4cdc0e6555b713d99dd2088180be7a36a6c64d89e32b710e7c3a5d366cf2',
      inputs: [
        {
          index: 0,
          transaction: {
            id: '0dd9b1dd89ff50c6907b3fd0385fde86f7c6877c2c9a95a9a9aa83b1cfead128'
          }
        }
      ],
      outputs: [
        {
          address: 'addr_test1vz09v9yfxguvlp0zsnrpa3tdtm7el8xufp3m5lsm7qxzclgmzkket',
          datum: 'c5dfa8c3cbd5a959829618a7b46e163078cb3f1b39f152514d0c3686d553529a',
          datumHash: 'c5dfa8c3cbd5a959829618a7b46e163078cb3f1b39f152514d0c3686d553529a',
          value: {
            ada: {
              lovelace: 29_699_998_492_735_907n
            }
          }
        }
      ],
      proposals: [
        {
          action: {
            type: 'hardForkInitiation',
            version: {
              major: 6,
              minor: 0
            }
          }
        },
        {
          action: {
            type: 'hardForkInitiation',
            version: {
              major: 6,
              minor: 0
            }
          }
        },
        {
          action: {
            type: 'hardForkInitiation',
            version: {
              major: 6,
              minor: 0
            }
          }
        },
        {
          action: {
            type: 'hardForkInitiation',
            version: {
              major: 6,
              minor: 0
            }
          }
        },
        {
          action: {
            type: 'hardForkInitiation',
            version: {
              major: 6,
              minor: 0
            }
          }
        },
        {
          action: {
            type: 'hardForkInitiation',
            version: {
              major: 6,
              minor: 0
            }
          }
        },
        {
          action: {
            type: 'hardForkInitiation',
            version: {
              major: 6,
              minor: 0
            }
          }
        }
      ],
      signatories: [
        {
          key: '8b0960d234bda67d52432c5d1a26aca2bfb5b9a09f966d9592a7bf0c728a1ecd',
          signature:
            '845756107198dcd60b639313ca9ca17ea4553ee24fcaa23620260f9da8304eee99b7bfce574071ec216a148b75162b01294dea76a6a8abae1de5387a68b44c03'
        },
        {
          key: '618b625df30de53895ff29e7a3770dca56c2ff066d4aa05a6971905deecef6db',
          signature:
            '2c65c8f60495bdcf7fc077ff3545bf31d2379b5bc0efb88e393d54a2a43fbb7616d18c3e6537bb83d1c56f75241b9b13c72d9f28d96d692eb1e58cf52977a30d'
        },
        {
          key: '69a14b724409e0ceef671c76ec4f8bce7509b5919bb971b3855bf92ca5653222',
          signature:
            '86f498524e0c7cfdd8999929ae915318d9bc67e1a935f24787bb9e7f5f4e68686650f5191f0783bfa343a56215d1ba67b721e9635d44af0d8fa28f003dcbe007'
        },
        {
          key: 'd1a8de6caa8fd9b175c59862ecdd5abcd0477b84b82a0e52faecc6b3c85100a4',
          signature:
            '898bbf40ffd2e7890665947986051ab90fa6b8988bf53ae89d263e3ba84acc288757aef8d0327692c94a487e919ef720bfa485bcff33b342787ff719fb83cc04'
        },
        {
          key: '9aae625d4d15bcb3733d420e064f1cd338f386e0af049fcd42b455a69d28ad36',
          signature:
            '0b8eb0ec9dd0b16037a5f457176d6635c1934eeea7f3d8c419b7bb35316479adae9cf037a609ed0cc77fac76774bd8d50d1e2b205bd707127007312acfe8ac0e'
        },
        {
          key: '942bb3aaab0f6442b906b65ba6ddbf7969caa662d90968926211a3d56532f11d',
          signature:
            'eac02a754184454b5a83983560b830e522f828fd17f5e014d49044891013cd87d3dab5730971459cad48a62ea33271f9164d9196e46a708538efce06d16c3e09'
        },
        {
          key: 'd4dd69a41071bc2dc8e64a97f4bd6379524ce0c2b665728043a067e34d3e218a',
          signature:
            '176b13ca898b1e8b9e87cefdd4a168f0d2ae65999e83fc82f4780ba0aaf3c81e9da85b46a294f780eb1318d40bea6678dc08eab441ce8f70b4fa9bfbceabdc07'
        },
        {
          key: '8ef320c2df6654a6188c45e9c639c0a686bf5a865295587d399dfeb05fe74ab6',
          signature:
            'f36dcb0ae7d5a7d833ebe9adf272047794b6b0be28971302bfe0fa8ab09fd682080b42046c3f11362556aa76727cbaaa3c09c60618c47e35c0ed32fe89adf603'
        }
      ],
      spends: 'inputs',
      validityInterval: {},
      votes: [
        {
          issuer: {
            id: '637f2e950b0fd8f8e3e811c5fbeb19e411e7a2bf37272b84b29c1a0b',
            role: 'genesisDelegate'
          },
          vote: 'yes'
        },
        {
          issuer: {
            id: '8a4b77c4f534f8b8cc6f269e5ebb7ba77fa63a476e50e05e66d7051c',
            role: 'genesisDelegate'
          },
          vote: 'yes'
        },
        {
          issuer: {
            id: 'b00470cd193d67aac47c373602fccd4195aad3002c169b5570de1126',
            role: 'genesisDelegate'
          },
          vote: 'yes'
        },
        {
          issuer: {
            id: 'b260ffdb6eba541fcf18601923457307647dce807851b9d19da133ab',
            role: 'genesisDelegate'
          },
          vote: 'yes'
        },
        {
          issuer: {
            id: 'ced1599fd821a39593e00592e5292bdc1437ae0f7af388ef5257344a',
            role: 'genesisDelegate'
          },
          vote: 'yes'
        },
        {
          issuer: {
            id: 'dd2a7d71a05bed11db61555ba4c658cb1ce06c8024193d064f2a66ae',
            role: 'genesisDelegate'
          },
          vote: 'yes'
        },
        {
          issuer: {
            id: 'f3b9e74f7d0f24d2314ea5dfbca94b65b2059d1ff94d97436b82d5b4',
            role: 'genesisDelegate'
          },
          vote: 'yes'
        }
      ]
    }
  ],
  type: 'praos'
};

// From preprod
export const mockAllegraBlock: Ogmios.Schema.Block = {
  ancestor: 'cacf5da6b8d81bbdf77b5ce4f5ea7f7b6714a29b1e81dbf541b01e92d8e1a321',
  era: 'allegra',
  height: 21_655,
  id: 'affaf81ee993f657212d094c345ba86eed383a1ba19b5510e419390b85aa77a2',
  issuer: {
    leaderValue: {
      output:
        'ed8ac2d394a4a8022224b6f4b4b859bb748e6af00b8daa998c2aad2a9f42f8f4dc4f3eba29e323b426099805d02a7daf79ba262b51191b26bf07fce07f3effb7',
      proof:
        'e58bd3d0326bf69fb3ed652a556f16fb61e4835f6766d92965ddeea69a7000fcff6d98fa5f5cae9f5c3cf99b5606a76319180eaaff4af81aea358077e4363237579c9078dfce08a72a0b5ca90c5d140e'
    },
    operationalCertificate: {
      count: 0,
      kes: {
        period: 0,
        verificationKey: '05424ee48b0616cdbd5bc631ed25a628518575912c22c6dfea7e2778aac12bba'
      }
    },
    verificationKey: '618b625df30de53895ff29e7a3770dca56c2ff066d4aa05a6971905deecef6db',
    vrfVerificationKey: '707a5e99ceec213eb56768da310566da8f4ff56cbdd90431ebd0ae17f6c8cc8b'
  },
  nonce: {
    output:
      '91b1c2d55cc491732a4cfa591a4e9bfd1aada7610d25e0fb9bb62176a0daf709485271c911c275b007005a0cf17e41e6639dff95d59319bf96270ec1515c1619',
    proof:
      '6195ed4ddd4efd642b1810aa5ff92f91cb25082f07a61be35c7b82f06c9b8dc3a2fb7f9f1d40ff5779e63d02b09253716971018f8dfc0e4aa07bbeaa0e26f3fb235e0de00f60ba879c8a52744e8d470f'
  },
  protocol: {
    version: {
      major: 4,
      minor: 0
    }
  },
  size: {
    bytes: 1193
  },
  slot: 518_600,
  transactions: [
    {
      cbor: '83a40081825820a00696a0c2d70c381a265a845e43c55e1d00f96b27c06defc015dc92eb20624000018182581d609e5614893238cf85e284c61ec56d5efd9f9cdc4863ba7e1bf00c2c7d1b006983fdc40382dd021a00032bd50682a7581c637f2e950b0fd8f8e3e811c5fbeb19e411e7a2bf37272b84b29c1a0ba20cd81e8200010e820400581c8a4b77c4f534f8b8cc6f269e5ebb7ba77fa63a476e50e05e66d7051ca20cd81e8200010e820400581cb00470cd193d67aac47c373602fccd4195aad3002c169b5570de1126a20cd81e8200010e820400581cb260ffdb6eba541fcf18601923457307647dce807851b9d19da133aba20cd81e8',
      fee: {
        ada: { lovelace: 207_829n }
      },
      id: '59f68ea73b95940d443dc516702d5e5deccac2429e4d974f464cc9b26292fd9c',
      inputs: [
        {
          index: 0,
          transaction: {
            id: 'a00696a0c2d70c381a265a845e43c55e1d00f96b27c06defc015dc92eb206240'
          }
        }
      ],
      outputs: [
        {
          address: 'addr_test1vz09v9yfxguvlp0zsnrpa3tdtm7el8xufp3m5lsm7qxzclgmzkket',
          value: {
            ada: {
              lovelace: 29_699_998_493_147_869n
            }
          }
        }
      ],
      proposals: [
        {
          action: {
            type: 'hardForkInitiation',
            version: {
              major: 4,
              minor: 0
            }
          }
        },
        {
          action: {
            parameters: {
              federatedBlockProductionRatio: '0/1'
            },
            type: 'protocolParametersUpdate'
          }
        },
        {
          action: {
            type: 'hardForkInitiation',
            version: {
              major: 4,
              minor: 0
            }
          }
        },
        {
          action: {
            parameters: {
              federatedBlockProductionRatio: '0/1'
            },
            type: 'protocolParametersUpdate'
          }
        },
        {
          action: {
            type: 'hardForkInitiation',
            version: {
              major: 4,
              minor: 0
            }
          }
        },
        {
          action: {
            parameters: {
              federatedBlockProductionRatio: '0/1'
            },
            type: 'protocolParametersUpdate'
          }
        },
        {
          action: {
            type: 'hardForkInitiation',
            version: {
              major: 4,
              minor: 0
            }
          }
        },
        {
          action: {
            parameters: {
              federatedBlockProductionRatio: '0/1'
            },
            type: 'protocolParametersUpdate'
          }
        },
        {
          action: {
            type: 'hardForkInitiation',
            version: {
              major: 4,
              minor: 0
            }
          }
        },
        {
          action: {
            parameters: {
              federatedBlockProductionRatio: '0/1'
            },
            type: 'protocolParametersUpdate'
          }
        },
        {
          action: {
            type: 'hardForkInitiation',
            version: {
              major: 4,
              minor: 0
            }
          }
        },
        {
          action: {
            parameters: {
              federatedBlockProductionRatio: '0/1'
            },
            type: 'protocolParametersUpdate'
          }
        },
        {
          action: {
            type: 'hardForkInitiation',
            version: {
              major: 4,
              minor: 0
            }
          }
        },
        {
          action: {
            parameters: {
              federatedBlockProductionRatio: '0/1'
            },
            type: 'protocolParametersUpdate'
          }
        }
      ],
      signatories: [
        {
          key: '8b0960d234bda67d52432c5d1a26aca2bfb5b9a09f966d9592a7bf0c728a1ecd',
          signature:
            '11a439a7391e34bd1bd4829f669a630276deb8cbe59f2a5ccca5190d19963bef9477e6f61e8d47438323ce9424befec3357c88908473fd332a7633ab2882c006'
        },
        {
          key: '618b625df30de53895ff29e7a3770dca56c2ff066d4aa05a6971905deecef6db',
          signature:
            '5cde79e14b9c033276fb503aaf6ae84fd0142d63e01c0a81ec1fb0794874184c2e3ac0fca64274f01be1ff3b7a93d2e7df60b485deb71fa8549a8ad879b0cb07'
        },
        {
          key: '69a14b724409e0ceef671c76ec4f8bce7509b5919bb971b3855bf92ca5653222',
          signature:
            'ecd0ea504800f96b34cc42742b1bd45990fa0068161c9cce3fb0703568c7dfe2a9283c02e63d0593bab15fa34fe9b732ad1915019d0f2d05a0fd0a570aa14205'
        },
        {
          key: 'd1a8de6caa8fd9b175c59862ecdd5abcd0477b84b82a0e52faecc6b3c85100a4',
          signature:
            '60a4389a2a3ef54f7060c638a4268b5c7e2042bde1d1c7dc9ae9d29ffbe8bb9170fc929f27e3b0b298d42f34035fd3c149c1ede0fce7ec2981c3c882123f180e'
        },
        {
          key: '9aae625d4d15bcb3733d420e064f1cd338f386e0af049fcd42b455a69d28ad36',
          signature:
            '7e986eef76c9dcfb2483ca3fbe299f224c51a58da94b85ba1fcba41b384691b4cde236ca0d72237a2a21fe373a0d68c69ec490f0628cb6523b0263ca3338fc0a'
        },
        {
          key: '942bb3aaab0f6442b906b65ba6ddbf7969caa662d90968926211a3d56532f11d',
          signature:
            '90b5745d1007bfc524ffc53dfa17e58483ff74e9d37275f0b9e9ca084e180e2c2799b7947dcdb34774836719ea897ee4bd3e38b7e52513084ef61dfd1ead3809'
        },
        {
          key: 'd4dd69a41071bc2dc8e64a97f4bd6379524ce0c2b665728043a067e34d3e218a',
          signature:
            'd9b5a70f1f14b084385930fa47ed66ed0c8237812825f6c3923bdc702ab1f219cc4583b8c0e5d291cfd3e0ae586f4e98d5e87d251304ed3afd1c088c129a190f'
        },
        {
          key: '8ef320c2df6654a6188c45e9c639c0a686bf5a865295587d399dfeb05fe74ab6',
          signature:
            'a59197afd5188eba40323d57246103eda1bb231a4df0879e6b1c3ce512978af0c6e33355f53bb9db0e6f85cc8d835355b6b30af9dde11a94c8c7ed2c635a7603'
        }
      ],
      spends: 'inputs',
      validityInterval: {},
      votes: [
        {
          issuer: {
            id: '637f2e950b0fd8f8e3e811c5fbeb19e411e7a2bf37272b84b29c1a0b',
            role: 'genesisDelegate'
          },
          vote: 'yes'
        },
        {
          issuer: {
            id: '8a4b77c4f534f8b8cc6f269e5ebb7ba77fa63a476e50e05e66d7051c',
            role: 'genesisDelegate'
          },
          vote: 'yes'
        },
        {
          issuer: {
            id: 'b00470cd193d67aac47c373602fccd4195aad3002c169b5570de1126',
            role: 'genesisDelegate'
          },
          vote: 'yes'
        },
        {
          issuer: {
            id: 'b260ffdb6eba541fcf18601923457307647dce807851b9d19da133ab',
            role: 'genesisDelegate'
          },
          vote: 'yes'
        },
        {
          issuer: {
            id: 'ced1599fd821a39593e00592e5292bdc1437ae0f7af388ef5257344a',
            role: 'genesisDelegate'
          },
          vote: 'yes'
        },
        {
          issuer: {
            id: 'dd2a7d71a05bed11db61555ba4c658cb1ce06c8024193d064f2a66ae',
            role: 'genesisDelegate'
          },
          vote: 'yes'
        },
        {
          issuer: {
            id: 'f3b9e74f7d0f24d2314ea5dfbca94b65b2059d1ff94d97436b82d5b4',
            role: 'genesisDelegate'
          },
          vote: 'yes'
        }
      ]
    }
  ],
  type: 'praos'
};

// From preprod
export const mockMaryBlock: Ogmios.Schema.Block = {
  ancestor: '3618c2ea1f45f1735d990c15327446e60b36f60ca8c5266dcaae9a898d80e029',
  era: 'mary',
  height: 43_245,
  id: 'e5e19970aa093a9cf6df9f62aa263ceccc9b06a7a8456a9a3cc3270cd980d7ab',
  issuer: {
    leaderValue: {
      output:
        '03f5646ddd8dde870186383dd6bdf9c84074b12bc6feeea7b4a79338ca11985f39f078326132dc468ac80d67eefc61283fe66b4ccfbc4046e86fa139ec8b7b9c',
      proof:
        '4f7f7aad57d783336b180e3140ab2f8ab06768bcf0917067259dd4c205404eb7ae711e723f9201e796a3167401560b7449fd8463f5d0b1c4914f2d3eacbb09aa1921cc8757dd7cb8ec644b8092f34a01'
    },
    operationalCertificate: {
      count: 0,
      kes: {
        period: 0,
        verificationKey: 'fed2662ecbb60ac0a72bca0faeae963649a0c219f4bdd4fc9570ca470727050b'
      }
    },
    verificationKey: 'f270c16659735ec4b65d15d1cbef937e50e608585ac3b71a4cd117fdb761624e',
    vrfVerificationKey: 'ebb507d7e0b0399ffced1a35297203134f8a2a85b616c3591c452cbefa61b88a'
  },
  nonce: {
    output:
      'f046e97b29cb76ff5d0a6a3654b081fcb7147852f3432b137ebc18099494cbe8a1d3c28ea18f8c17798659446d3edc335aac6e2b58e69bc888e733849ab98127',
    proof:
      'd145860d7a339898b51c65a172d204746709d84eb702f2f6c1991f1344a55be79538750940cac623005fb7a0e95bdda6e908733cad1681fa787cc5cbe631e43951cb417613c69207afdfdc5f08aeb805'
  },
  protocol: {
    version: {
      major: 5,
      minor: 0
    }
  },
  size: {
    bytes: 1151
  },
  slot: 950_500,
  transactions: [
    {
      cbor: '83a4008182582059f68ea73b95940d443dc516702d5e5deccac2429e4d974f464cc9b26292fd9c00018182581d609e5614893238cf85e284c61ec56d5efd9f9cdc4863ba7e1bf00c2c7d1b006983fdc4005e40021a0003249d0682a7581c637f2e950b0fd8f8e3e811c5fbeb19e411e7a2bf37272b84b29c1a0ba10e820500581c8a4b77c4f534f8b8cc6f269e5ebb7ba77fa63a476e50e05e66d7051ca10e820500581cb00470cd193d67aac47c373602fccd4195aad3002c169b5570de1126a10e820500581cb260ffdb6eba541fcf18601923457307647dce807851b9d19da133aba10e820500581cced1599fd821a39593e00592e5292bd',
      fee: {
        ada: { lovelace: 205_981n }
      },
      id: '0dd9b1dd89ff50c6907b3fd0385fde86f7c6877c2c9a95a9a9aa83b1cfead128',
      inputs: [
        {
          index: 0,
          transaction: {
            id: '59f68ea73b95940d443dc516702d5e5deccac2429e4d974f464cc9b26292fd9c'
          }
        }
      ],
      outputs: [
        {
          address: 'addr_test1vz09v9yfxguvlp0zsnrpa3tdtm7el8xufp3m5lsm7qxzclgmzkket',
          value: {
            ada: {
              lovelace: 29_699_998_492_941_888n
            }
          }
        }
      ],
      proposals: [
        {
          action: {
            type: 'hardForkInitiation',
            version: {
              major: 5,
              minor: 0
            }
          }
        },
        {
          action: {
            type: 'hardForkInitiation',
            version: {
              major: 5,
              minor: 0
            }
          }
        },
        {
          action: {
            type: 'hardForkInitiation',
            version: {
              major: 5,
              minor: 0
            }
          }
        },
        {
          action: {
            type: 'hardForkInitiation',
            version: {
              major: 5,
              minor: 0
            }
          }
        },
        {
          action: {
            type: 'hardForkInitiation',
            version: {
              major: 5,
              minor: 0
            }
          }
        },
        {
          action: {
            type: 'hardForkInitiation',
            version: {
              major: 5,
              minor: 0
            }
          }
        },
        {
          action: {
            type: 'hardForkInitiation',
            version: {
              major: 5,
              minor: 0
            }
          }
        }
      ],
      signatories: [
        {
          key: '8b0960d234bda67d52432c5d1a26aca2bfb5b9a09f966d9592a7bf0c728a1ecd',
          signature:
            '222b333c56031a63e8e975f59fa6e646a733cc8c4b6d9d2aecea0d23366edadb83077a9ac79541e3044798549bc9088e9409194f4451324a65bb1d8237b74a03'
        },
        {
          key: '618b625df30de53895ff29e7a3770dca56c2ff066d4aa05a6971905deecef6db',
          signature:
            '05d8f7aff6fc03cbb3b8c63e0ebcef7cfd55c86be48d1d39642d46d62f879114e3285ec16814746e836d1f6ac6e8be4caf203651e5cbb41297c01b4dde17a606'
        },
        {
          key: '69a14b724409e0ceef671c76ec4f8bce7509b5919bb971b3855bf92ca5653222',
          signature:
            '8575f55be5b478d224842bb841bc46e3b347613e54f5245e16b644bc022910ac847e55af0081ed17750a790bf703cde299c30c8f170026983a956206c5ef0108'
        },
        {
          key: 'd1a8de6caa8fd9b175c59862ecdd5abcd0477b84b82a0e52faecc6b3c85100a4',
          signature:
            '709e0431c27585279b573554c19f0cc4726334f594e03e483c22022116a2521920e148348e85cf447440883b12fb31367448b335be2eeed7f67cfff46bdf0b09'
        },
        {
          key: '9aae625d4d15bcb3733d420e064f1cd338f386e0af049fcd42b455a69d28ad36',
          signature:
            '5757bb1a900d76381c3b2d3effcbb9be4ded84ccbed18a4e6fec1f2a9473b8fd39243c1a15c33b0094debb069bb0022827c691c23fef4558f70b4dea82a97f05'
        },
        {
          key: '942bb3aaab0f6442b906b65ba6ddbf7969caa662d90968926211a3d56532f11d',
          signature:
            'e8aebefe3cf0415f7c3d5f45fd890962eeadf29e9c6e07456967cccbd17827add3a35e0b15d500a1c28522603e987fbb1733b2e4a2921d052ff8b2a2df975609'
        },
        {
          key: 'd4dd69a41071bc2dc8e64a97f4bd6379524ce0c2b665728043a067e34d3e218a',
          signature:
            '3db756d3166532edce43afb52affca938d2d6d50f4ce12354e20279ac30b2dc503329d482ac71c7412e9f39cf98a2d7d79014673d3e92d2d1e4cf7921794610d'
        },
        {
          key: '8ef320c2df6654a6188c45e9c639c0a686bf5a865295587d399dfeb05fe74ab6',
          signature:
            'a9c6378add6790ec88661ed90b86d11f1e5db8750b5f758c6b4f7c43331b5414f86e519ffed0fe34ecf3ee030122bd1b58676e209ac7383039e42790477c1b02'
        }
      ],
      spends: 'inputs',
      validityInterval: {},
      votes: [
        {
          issuer: {
            id: '637f2e950b0fd8f8e3e811c5fbeb19e411e7a2bf37272b84b29c1a0b',
            role: 'genesisDelegate'
          },
          vote: 'yes'
        },
        {
          issuer: {
            id: '8a4b77c4f534f8b8cc6f269e5ebb7ba77fa63a476e50e05e66d7051c',
            role: 'genesisDelegate'
          },
          vote: 'yes'
        },
        {
          issuer: {
            id: 'b00470cd193d67aac47c373602fccd4195aad3002c169b5570de1126',
            role: 'genesisDelegate'
          },
          vote: 'yes'
        },
        {
          issuer: {
            id: 'b260ffdb6eba541fcf18601923457307647dce807851b9d19da133ab',
            role: 'genesisDelegate'
          },
          vote: 'yes'
        },
        {
          issuer: {
            id: 'ced1599fd821a39593e00592e5292bdc1437ae0f7af388ef5257344a',
            role: 'genesisDelegate'
          },
          vote: 'yes'
        },
        {
          issuer: {
            id: 'dd2a7d71a05bed11db61555ba4c658cb1ce06c8024193d064f2a66ae',
            role: 'genesisDelegate'
          },
          vote: 'yes'
        },
        {
          issuer: {
            id: 'f3b9e74f7d0f24d2314ea5dfbca94b65b2059d1ff94d97436b82d5b4',
            role: 'genesisDelegate'
          },
          vote: 'yes'
        }
      ]
    }
  ],
  type: 'praos'
};

// From preprod
export const mockBabbageBlock: Ogmios.Schema.Block = {
  ancestor: '93c19803741b88256b485b51f4f4f21753e3828033634c65ace84b637dac3259',
  era: 'babbage',
  height: 203_082,
  id: 'cfe3bf5be724076a3afbdf590873a4c616baa9a7daf5da26843a8bf1592b5757',
  issuer: {
    leaderValue: {
      output:
        '5b68d142b12bccfbacf1f17db75f000a1b7ffd83747d0f70ed5fc67669758ea8fb8319c300f550f49fe28dc528f848f263b788af0c50c454e366573ef38b4e3d',
      proof:
        '9fdef05f650248d702f09393221559e5b1e9bb25517a6d90aa1841aae2fbdc10698e4756c0baf7955946e05feb816cc4d2b346f1afc407e665968820dfbf22912e617b6f7ae8899b8474a7558aafdd0a'
    },
    operationalCertificate: {
      count: 1,
      kes: {
        period: 60,
        verificationKey: 'c8682c718e8670f9edd295d8b0db50e2e32bf25397726eef56227dbaf89a254a'
      }
    },
    verificationKey: '9691ed9d98a5b79d5bc46c4496a6dba7e103f668f525c8349b6b92676cb3eae4',
    vrfVerificationKey: 'ea49e4652c460b9ee6daafefc999ca667fbe5eb5d7a7aeabbdff6fe19c1a3c9f'
  },
  protocol: {
    version: {
      major: 7,
      minor: 0
    }
  },
  size: {
    bytes: 8511
  },
  slot: 11_191_217,
  transactions: [
    {
      cbor: '84a50081825820b5d98d634ff9992fc448e665cf0a3f56c07fe5d96b511f8b17111dbb3f7eb7c90001818258390015c8e5fd49a2d058b4ba42b679db38fef4dd6ace3373088a20e28a0bc568341dc347876c1c79e07de3e76265560bca4bb9e6af9f36e409231b0000000253feb017021a00029e8d031a00aaed7e048182018200581cc568341dc347876c1c79e07de3e76265560bca4bb9e6af9f36e40923a1008282582087e756b9b15d5d1265bb1297d63b20ef9461fd9d863e52656ec8cb6aca99a25c5840d6f7bfebd57ede5023d0a766ad976cdf1b7c033b7ba95cf115ab8be70661c67134059c7a8c9a5fe3942096a6737e91e264d0add70b50a5215100dc12bdb751058258200b4bfb2f2fc4fbeaf9399455cad837f428706a76bc37deb4d9b0cc0ed8093e6b5840639b988a45be61e0fd2cc0ddc46958dcf7ed9cb902ddcd55ecfb6c1a199b4b5e85e109e3d05d36301f6468c70c0e7dfde28068a0a31eb9a61bf9682348d0a102f5f6',
      certificates: [
        {
          credential: 'c568341dc347876c1c79e07de3e76265560bca4bb9e6af9f36e40923',
          type: 'stakeCredentialDeregistration'
        }
      ],
      fee: {
        ada: { lovelace: 171_661n }
      },
      id: '543dd5eb80eb34d4caabeb00f7137e9330d1c8afa890d367ef8bdfad24b7f321',
      inputs: [
        {
          index: 0,
          transaction: {
            id: 'b5d98d634ff9992fc448e665cf0a3f56c07fe5d96b511f8b17111dbb3f7eb7c9'
          }
        }
      ],
      outputs: [
        {
          address:
            'addr_test1qq2u3e0afx3dqk95hfptv7wm8rl0fht2ecehxzy2yr3g5z79dq6pms68sakpc70q0h37wcn92c9u5jaeu6he7dhypy3sxd05k6',
          value: {
            ada: {
              lovelace: 9_999_134_743n
            }
          }
        }
      ],
      signatories: [
        {
          key: '87e756b9b15d5d1265bb1297d63b20ef9461fd9d863e52656ec8cb6aca99a25c',
          signature:
            'd6f7bfebd57ede5023d0a766ad976cdf1b7c033b7ba95cf115ab8be70661c67134059c7a8c9a5fe3942096a6737e91e264d0add70b50a5215100dc12bdb75105'
        },
        {
          key: '0b4bfb2f2fc4fbeaf9399455cad837f428706a76bc37deb4d9b0cc0ed8093e6b',
          signature:
            '639b988a45be61e0fd2cc0ddc46958dcf7ed9cb902ddcd55ecfb6c1a199b4b5e85e109e3d05d36301f6468c70c0e7dfde28068a0a31eb9a61bf9682348d0a102'
        }
      ],
      spends: 'inputs',
      validityInterval: {
        invalidAfter: 11_201_918
      }
    },
    {
      cbor: '84a60082825820458965adb212f57bbe3bf97ba0cc9caa142ce59f79be803332408e567b55b4af00825820458965adb212f57bbe3bf97ba0cc9caa142ce59f79be803332408e567b55b4af010182825839000abe35e91065a0b720ce503df5549a1231e4a3e39d8e495bd36701e78a02c5cb406e02d9582e168dc0ae4310b95e34d06d42227b516f4be7821a00118f32a1581ceb48b495393986032e8cef0b0a9b2ce64b3881e8a29347e169c7122ca14246541846825839000abe35e91065a0b720ce503df5549a1231e4a3e39d8e495bd36701e78a02c5cb406e02d9582e168dc0ae4310b95e34d06d42227b516f4be71b0000000241b50aa1021a0002c329031a00aac8010758203f5d7adf353de22cf1fc514aa911901c5fbd1b5ee3ed57950a6dc5a0fe1dbb2009a1581ceb48b495393986032e8cef0b0a9b2ce64b3881e8a29347e169c7122ca1424654381da2008282582047c7878b4737c1676d83422fb8f72eb66f1ecb7c94a3c9a7b93ccc0dec7e8f255840080a8bf5a6ffbdc521776fca3272290f243e441ffdbbd873e4dfa3f2466fa45e082176b3dbcd09f376eed9cc465fcf538520b2c58a487565e711ad158d2f1c07825820c92a58c6a3bd0d181122e6294bdaf00ba43cf65c65d7275ceb2388570be883d75840594bb85fed2bef13f2f573607831a69b7a5cce97ca6fed2a0026303e85f65a9d552fd6bbd77d10720110321e0aa8e5d1571fb2d38c848a7f4789e80f1751660101818200581c583dda8c51947fb1653150f3daa7c724637f099d77bc7759edc22a8ef5a1183a60',
      fee: {
        ada: { lovelace: 181_033n }
      },
      id: 'be69e4186eaf01fa31a1ad1b16780269f34dbab5d73dd34b8e785ed88e330e12',
      inputs: [
        {
          index: 0,
          transaction: {
            id: '458965adb212f57bbe3bf97ba0cc9caa142ce59f79be803332408e567b55b4af'
          }
        },
        {
          index: 1,
          transaction: {
            id: '458965adb212f57bbe3bf97ba0cc9caa142ce59f79be803332408e567b55b4af'
          }
        }
      ],
      metadata: {
        hash: '3f5d7adf353de22cf1fc514aa911901c5fbd1b5ee3ed57950a6dc5a0fe1dbb20',
        labels: {
          '58': {
            cbor: '60',
            json: ''
          }
        }
      },
      mint: {
        eb48b495393986032e8cef0b0a9b2ce64b3881e8a29347e169c7122c: {
          '4654': -30n
        }
      },
      outputs: [
        {
          address:
            'addr_test1qq9tud0fzpj6pdeqeegrma25ngfrre9ruwwcuj2m6dnsreu2qtzuksrwqtv4stsk3hq2uscsh90rf5rdgg38k5t0f0nsp30w94',
          value: {
            ada: {
              lovelace: 1_150_770n
            },
            eb48b495393986032e8cef0b0a9b2ce64b3881e8a29347e169c7122c: {
              '4654': 70n
            }
          }
        },
        {
          address:
            'addr_test1qq9tud0fzpj6pdeqeegrma25ngfrre9ruwwcuj2m6dnsreu2qtzuksrwqtv4stsk3hq2uscsh90rf5rdgg38k5t0f0nsp30w94',
          value: {
            ada: {
              lovelace: 9_692_318_369n
            }
          }
        }
      ],
      scripts: {
        eb48b495393986032e8cef0b0a9b2ce64b3881e8a29347e169c7122c: {
          json: {
            clause: 'signature',
            from: '583dda8c51947fb1653150f3daa7c724637f099d77bc7759edc22a8e'
          },
          language: 'native'
        }
      },
      signatories: [
        {
          key: 'c92a58c6a3bd0d181122e6294bdaf00ba43cf65c65d7275ceb2388570be883d7',
          signature:
            '594bb85fed2bef13f2f573607831a69b7a5cce97ca6fed2a0026303e85f65a9d552fd6bbd77d10720110321e0aa8e5d1571fb2d38c848a7f4789e80f17516601'
        },
        {
          key: '47c7878b4737c1676d83422fb8f72eb66f1ecb7c94a3c9a7b93ccc0dec7e8f25',
          signature:
            '080a8bf5a6ffbdc521776fca3272290f243e441ffdbbd873e4dfa3f2466fa45e082176b3dbcd09f376eed9cc465fcf538520b2c58a487565e711ad158d2f1c07'
        }
      ],
      spends: 'inputs',
      validityInterval: {
        invalidAfter: 11_192_321
      }
    },
    {
      cbor: '84a50082825820803f8599f482d6f4c84da3b095efb4667aa4506d442cf080125a1baa1d66085e0182582090f5bcb35b44d7f3f49ddb2907e0f916a86328eefe69bab9214bed9f5fad7487000182a200583900c8fd82eefa4f5090b3b8a80e5b9244a4656b0e4444066d5d0678004f241511e532f73ba0a4e25c6a659813e7492a0842a3698ac8d72a0983011a000f4240a200583900fb57816ce653a68eb8b3048de7d0451775b65790f0ad1f8c9a943c83241511e532f73ba0a4e25c6a659813e7492a0842a3698ac8d72a0983011a0019053a021a0002b385031a00aadf8f075820b93d8e428871a0b0e12c5c554653f515f50fe48dc5b55af7e3667e7d9661ea2ca1008282582021ccfef5d816ed98dbf00de037322303fda53e1a01a844f38444ba3eb6f6e9e45840634c8e2a38429b95e588732655c0513909b5415e7f736ba95c98c394b0fbdb9f1cf102d4230939db883226b7d850fc04b10101aec235686c1ad4da7b0765e6008258202cf1d6c8d41391e658e25dbc88638831d7af3254988bde4650e1c595c21214615840b81ebb6d1c2ec74a5c210e9656cb27732f084f653abfe01f56e3d5d39a87a47d933724684d753564274b32def9d923dd3885240265ae7ce87904efd80a563708f5d90103a100a10080',
      fee: {
        ada: { lovelace: 177_029n }
      },
      id: 'd95c45762d620b81a6eeeebacb86d2b6af4e00df2324f0b1bf14cf9d86b18c16',
      inputs: [
        {
          index: 1,
          transaction: {
            id: '803f8599f482d6f4c84da3b095efb4667aa4506d442cf080125a1baa1d66085e'
          }
        },
        {
          index: 0,
          transaction: {
            id: '90f5bcb35b44d7f3f49ddb2907e0f916a86328eefe69bab9214bed9f5fad7487'
          }
        }
      ],
      metadata: {
        hash: 'b93d8e428871a0b0e12c5c554653f515f50fe48dc5b55af7e3667e7d9661ea2c',
        labels: {
          '0': {
            cbor: '80',
            json: []
          }
        }
      },
      outputs: [
        {
          address:
            'addr_test1qry0mqhwlf84py9nhz5qukujgjjx26cwg3zqvm2aqeuqqneyz5g72vhh8ws2fcjudfjesyl8fy4qss4rdx9v34e2pxps5s28ar',
          value: {
            ada: {
              lovelace: 1_000_000n
            }
          }
        },
        {
          address:
            'addr_test1qra40qtvuef6dr4ckvzgme7sg5thtdjhjrc268uvn22reqeyz5g72vhh8ws2fcjudfjesyl8fy4qss4rdx9v34e2pxpsglu3mg',
          value: {
            ada: {
              lovelace: 1_639_738n
            }
          }
        }
      ],
      signatories: [
        {
          key: '21ccfef5d816ed98dbf00de037322303fda53e1a01a844f38444ba3eb6f6e9e4',
          signature:
            '634c8e2a38429b95e588732655c0513909b5415e7f736ba95c98c394b0fbdb9f1cf102d4230939db883226b7d850fc04b10101aec235686c1ad4da7b0765e600'
        },
        {
          key: '2cf1d6c8d41391e658e25dbc88638831d7af3254988bde4650e1c595c2121461',
          signature:
            'b81ebb6d1c2ec74a5c210e9656cb27732f084f653abfe01f56e3d5d39a87a47d933724684d753564274b32def9d923dd3885240265ae7ce87904efd80a563708'
        }
      ],
      spends: 'inputs',
      validityInterval: {
        invalidAfter: 11_198_351
      }
    },
    {
      cbor: '84a70081825820c962f25ff9293e84862f336cfa290adce4804fc7e9488c9a10939c17918935f0000d81825820958adee7adb5cfe0510e9f9b63af2d9409bf25637af1ac899fe34b751956811200018382583900f1eda47a5724f121fe27d208fb96c675db997cdb7ef6c7a3a75d1a1bd43c31e11fda8ed21cc1f2f3803b586d44fa53e1e35fc30a1e840b671a00242e6683581d70e65d5b0f31bdea82641630440de069a15cc31b21c2b4f2270c6e9cde821a001a4e60a1581c4d2047d7af3d8de799de5daa6e1b0ebfc039f4274084d5bb9ba3975da14c42594e45544c6963656e7365015820118cd93427a8e035d484e55ddd4c70200ac5a4d8e63d9d1b89e8a8d49d22941583581d70e65d5b0f31bdea82641630440de069a15cc31b21c2b4f2270c6e9cde821a001a4e60a1581c4d2047d7af3d8de799de5daa6e1b0ebfc039f4274084d5bb9ba3975da14c42594e45544c6963656e7365015820118cd93427a8e035d484e55ddd4c70200ac5a4d8e63d9d1b89e8a8d49d229415021a00059ab20e81581cf1eda47a5724f121fe27d208fb96c675db997cdb7ef6c7a3a75d1a1b09a1581c4d2047d7af3d8de799de5daa6e1b0ebfc039f4274084d5bb9ba3975da14c42594e45544c6963656e7365020b582086b2db419eb3ac0d6180255726b53900d26ea7c7eab5cd209607eb6d9ae5a136a400818258203213e3fa6e42a75ba69df35d80666a021b0a650be3c5dadee03532414e90ab9c584076183df968ab1309d7a411d5513c24640c766c87d875415769cf373c59454a181c93963b1b1c33be70cc62db0bc8e3e2e0a1b53c1ba338ab58e1baf79642ca0c0381590a08590a05010000333323322323322323233223232323232323232323232323232323232323232322222322323253353232533500213500122333350012302949894cd4cc03800c03040ac4cd5ce24921496e76616c6964206c6963656e7365206d696e74696e6720617574686f726974790002a230294988c0a52613500122333350012302949894cd54cd4cc03800c03040ac4cd5ce248121496e76616c6964206c6963656e7365206d696e74696e6720617574686f726974790002a153355335333355300f120013350102223003300200120012202c35026122333550272233355029225335002213300702600210010013502a1223300235004222533500121533533355302b1200122333573466e3c0080040dc0d8004d403488888888880088c8c84ccccccd5d200191999ab9a3370e6aae75400d2000233335573ea0064a06646666aae7cd5d128021299a991999999aba400125036250362503625036235037375c0040626ae85401484d40d848c004008540d0940d00bc0b8940c80b0940c4940c4940c4940c40b04d55cf280089baa0011502d1502c00100135005222222222200902b102a102b102b13357389211a2020496e636f7272656374206c6963656e7365206d696e7465640002a102a230294988c0a5263333573466e1cd55cea801a400046644246600200600464646464646464646464646666ae68cdc39aab9d500a480008cccccccccc888888888848cccccccccc00402c02802402001c01801401000c008cd40688c8c8cccd5cd19b8735573aa004900011991091980080180118119aba15002301f357426ae8940088c98c80b0cd5ce01681601509aab9e5001137540026ae854028cd406806cd5d0a804999aa80ebae501c35742a010666aa03aeb94070d5d0a80399a80d0119aba1500633501a335502602475a6ae854014c8c8c8cccd5cd19b8735573aa00490001199109198008018011919191999ab9a3370e6aae754009200023322123300100300233502975a6ae854008c0a8d5d09aba2500223263203033573806206005c26aae7940044dd50009aba150023232323333573466e1cd55cea8012400046644246600200600466a052eb4d5d0a80118151aba135744a004464c6406066ae700c40c00b84d55cf280089baa001357426ae8940088c98c80b0cd5ce01681601509aab9e5001137540026ae854010cd4069d71aba1500333501a335502675c40026ae854008c080d5d09aba2500223263202833573805205004c26ae8940044d5d1280089aba25001135744a00226ae8940044d5d1280089aba25001135744a00226aae7940044dd50009aba150033232323333573466e1d40052006232122223004005301b357426aae79400c8cccd5cd19b875002480108c848888c008014c074d5d09aab9e500423333573466e1d400d20022321222230010053019357426aae7940148cccd5cd19b875004480008c848888c00c014dd71aba135573ca00c464c6404666ae7009008c08408007c0784d55cea80089baa001357426ae89400c8c98c8070cd5ce00e80e00d1999ab9a3370ea0089001109100111999ab9a3370ea00a9000109100091931900e19ab9c01d01c01a019101a13263201a335738921035054350001a135573ca00226ea80044d55ce9baa00122350022222222222533533355300d1200133500e225335002210031001502125335333573466e3c0300040a80a44d408c0045408800c840a840a0c8004d5407488448894cd40044d400c88004884ccd401488008c010008ccd54c01c4800401401000448848cc00400c00848c88c008dd6000990009aa80e111999aab9f0012501b233501a30043574200460066ae880080448c8c8c8cccd5cd19b8735573aa00690001199911091998008020018011919191999ab9a3370e6aae7540092000233221233001003002301335742a00466a0180246ae84d5d1280111931900b19ab9c017016014135573ca00226ea8004d5d0a801999aa803bae500635742a00466a010eb8d5d09aba2500223263201233573802602402026ae8940044d55cf280089baa0011335500175ceb44488c88c008dd5800990009aa80d11191999aab9f0022501a23350193355014300635573aa004600a6aae794008c010d5d100180809aba100112232323333573466e1d400520002350143005357426aae79400c8cccd5cd19b87500248008940508c98c8040cd5ce00880800700689aab9d500113754002464646666ae68cdc39aab9d5002480008cc8848cc00400c008c014d5d0a8011bad357426ae8940088c98c8034cd5ce00700680589aab9e5001137540024646666ae68cdc39aab9d5001480008dd71aba135573ca004464c6401666ae7003002c0244dd500089119191999ab9a3370ea00290021091100091999ab9a3370ea00490011190911180180218031aba135573ca00846666ae68cdc3a801a400042444004464c6401c66ae7003c03803002c0284d55cea80089baa0012323333573466e1d40052002201523333573466e1d40092000201523263200a33573801601401000e26aae74dd5000919191919191999ab9a3370ea002900610911111100191999ab9a3370ea004900510911111100211999ab9a3370ea00690041199109111111198008048041bae35742a00a6eb4d5d09aba2500523333573466e1d40112006233221222222233002009008375c6ae85401cdd71aba135744a00e46666ae68cdc3a802a400846644244444446600c01201060186ae854024dd71aba135744a01246666ae68cdc3a8032400446424444444600e010601a6ae84d55cf280591999ab9a3370ea00e900011909111111180280418071aba135573ca018464c6402466ae7004c04804003c03803403002c0284d55cea80209aab9e5003135573ca00426aae7940044dd50009191919191999ab9a3370ea002900111999110911998008028020019bad35742a0086eb4d5d0a8019bad357426ae89400c8cccd5cd19b875002480008c8488c00800cc020d5d09aab9e500623263200b33573801801601201026aae75400c4d5d1280089aab9e500113754002464646666ae68cdc3a800a400446424460020066eb8d5d09aab9e500323333573466e1d400920002321223002003375c6ae84d55cf280211931900419ab9c009008006005135573aa00226ea800444888c8c8cccd5cd19b8735573aa0049000119aa80598031aba150023005357426ae8940088c98c8020cd5ce00480400309aab9e5001137540029309000a48103505431003200135500b2211222533500115007221350022253353300700600213500c0011333553009120010070060031122123300100300212122300200311220011122320013200135500922533500110032213300600230040011233500150025003112200212212233001004003233573892011443617463682d616c6c2063617365206572726f720000212200212200111232300100122330033002002001480092211cf1eda47a5724f121fe27d208fb96c675db997cdb7ef6c7a3a75d1a1b0048810c42594e45544c6963656e736500010481d8799f581c0bfe875a7ae9db3c1b3827483ac6a1d02a7a93d3d26df00c7973aa47ff0581840100d87980821a000bbc461a0d822321f5f6',
      collaterals: [
        {
          index: 0,
          transaction: {
            id: '958adee7adb5cfe0510e9f9b63af2d9409bf25637af1ac899fe34b7519568112'
          }
        }
      ],
      datums: {
        '118cd93427a8e035d484e55ddd4c70200ac5a4d8e63d9d1b89e8a8d49d229415':
          'd8799f581c0bfe875a7ae9db3c1b3827483ac6a1d02a7a93d3d26df00c7973aa47ff'
      },
      fee: {
        ada: { lovelace: 367_282n }
      },
      id: 'e8b1c72c0c3002f8d157dc94bb28d3f2ebb3839c859ef8a325c6feefb120e11b',
      inputs: [
        {
          index: 0,
          transaction: {
            id: 'c962f25ff9293e84862f336cfa290adce4804fc7e9488c9a10939c17918935f0'
          }
        }
      ],
      mint: {
        '4d2047d7af3d8de799de5daa6e1b0ebfc039f4274084d5bb9ba3975d': {
          '42594e45544c6963656e7365': 2n
        }
      },
      outputs: [
        {
          address:
            'addr_test1qrc7mfr62uj0zg07ylfq37ukce6ahxtumdl0d3ar5aw35x758sc7z8763mfpes0j7wqrkkrdgna98c0rtlps585ypdnst69syh',
          value: {
            ada: {
              lovelace: 2_371_174n
            }
          }
        },
        {
          address: 'addr_test1wrn96kc0xx774qnyzccygr0qdxs4escmy8ptfu38p3hfehsu5427k',
          datumHash: '118cd93427a8e035d484e55ddd4c70200ac5a4d8e63d9d1b89e8a8d49d229415',
          value: {
            '4d2047d7af3d8de799de5daa6e1b0ebfc039f4274084d5bb9ba3975d': {
              '42594e45544c6963656e7365': 1n
            },
            ada: {
              lovelace: 1_724_000n
            }
          }
        },
        {
          address: 'addr_test1wrn96kc0xx774qnyzccygr0qdxs4escmy8ptfu38p3hfehsu5427k',
          datumHash: '118cd93427a8e035d484e55ddd4c70200ac5a4d8e63d9d1b89e8a8d49d229415',
          value: {
            '4d2047d7af3d8de799de5daa6e1b0ebfc039f4274084d5bb9ba3975d': {
              '42594e45544c6963656e7365': 1n
            },
            ada: {
              lovelace: 1_724_000n
            }
          }
        }
      ],
      redeemers: [
        {
          executionUnits: {
            cpu: 226_632_481,
            memory: 769_094
          },
          redeemer: 'd87980',
          validator: {
            index: 0,
            purpose: 'mint'
          }
        }
      ],
      requiredExtraSignatories: ['f1eda47a5724f121fe27d208fb96c675db997cdb7ef6c7a3a75d1a1b'],
      scriptIntegrityHash: '86b2db419eb3ac0d6180255726b53900d26ea7c7eab5cd209607eb6d9ae5a136',
      scripts: {
        '4d2047d7af3d8de799de5daa6e1b0ebfc039f4274084d5bb9ba3975d': {
          cbor: '590a05010000333323322323322323233223232323232323232323232323232323232323232322222322323253353232533500213500122333350012302949894cd4cc03800c03040ac4cd5ce24921496e76616c6964206c6963656e7365206d696e74696e6720617574686f726974790002a230294988c0a52613500122333350012302949894cd54cd4cc03800c03040ac4cd5ce248121496e76616c6964206c6963656e7365206d696e74696e6720617574686f726974790002a153355335333355300f120013350102223003300200120012202c35026122333550272233355029225335002213300702600210010013502a1223300235004222533500121533533355302b1200122333573466e3c0080040dc0d8004d403488888888880088c8c84ccccccd5d200191999ab9a3370e6aae75400d2000233335573ea0064a06646666aae7cd5d128021299a991999999aba400125036250362503625036235037375c0040626ae85401484d40d848c004008540d0940d00bc0b8940c80b0940c4940c4940c4940c40b04d55cf280089baa0011502d1502c00100135005222222222200902b102a102b102b13357389211a2020496e636f7272656374206c6963656e7365206d696e7465640002a102a230294988c0a5263333573466e1cd55cea801a400046644246600200600464646464646464646464646666ae68cdc39aab9d500a480008cccccccccc888888888848cccccccccc00402c02802402001c01801401000c008cd40688c8c8cccd5cd19b8735573aa004900011991091980080180118119aba15002301f357426ae8940088c98c80b0cd5ce01681601509aab9e5001137540026ae854028cd406806cd5d0a804999aa80ebae501c35742a010666aa03aeb94070d5d0a80399a80d0119aba1500633501a335502602475a6ae854014c8c8c8cccd5cd19b8735573aa00490001199109198008018011919191999ab9a3370e6aae754009200023322123300100300233502975a6ae854008c0a8d5d09aba2500223263203033573806206005c26aae7940044dd50009aba150023232323333573466e1cd55cea8012400046644246600200600466a052eb4d5d0a80118151aba135744a004464c6406066ae700c40c00b84d55cf280089baa001357426ae8940088c98c80b0cd5ce01681601509aab9e5001137540026ae854010cd4069d71aba1500333501a335502675c40026ae854008c080d5d09aba2500223263202833573805205004c26ae8940044d5d1280089aba25001135744a00226ae8940044d5d1280089aba25001135744a00226aae7940044dd50009aba150033232323333573466e1d40052006232122223004005301b357426aae79400c8cccd5cd19b875002480108c848888c008014c074d5d09aab9e500423333573466e1d400d20022321222230010053019357426aae7940148cccd5cd19b875004480008c848888c00c014dd71aba135573ca00c464c6404666ae7009008c08408007c0784d55cea80089baa001357426ae89400c8c98c8070cd5ce00e80e00d1999ab9a3370ea0089001109100111999ab9a3370ea00a9000109100091931900e19ab9c01d01c01a019101a13263201a335738921035054350001a135573ca00226ea80044d55ce9baa00122350022222222222533533355300d1200133500e225335002210031001502125335333573466e3c0300040a80a44d408c0045408800c840a840a0c8004d5407488448894cd40044d400c88004884ccd401488008c010008ccd54c01c4800401401000448848cc00400c00848c88c008dd6000990009aa80e111999aab9f0012501b233501a30043574200460066ae880080448c8c8c8cccd5cd19b8735573aa00690001199911091998008020018011919191999ab9a3370e6aae7540092000233221233001003002301335742a00466a0180246ae84d5d1280111931900b19ab9c017016014135573ca00226ea8004d5d0a801999aa803bae500635742a00466a010eb8d5d09aba2500223263201233573802602402026ae8940044d55cf280089baa0011335500175ceb44488c88c008dd5800990009aa80d11191999aab9f0022501a23350193355014300635573aa004600a6aae794008c010d5d100180809aba100112232323333573466e1d400520002350143005357426aae79400c8cccd5cd19b87500248008940508c98c8040cd5ce00880800700689aab9d500113754002464646666ae68cdc39aab9d5002480008cc8848cc00400c008c014d5d0a8011bad357426ae8940088c98c8034cd5ce00700680589aab9e5001137540024646666ae68cdc39aab9d5001480008dd71aba135573ca004464c6401666ae7003002c0244dd500089119191999ab9a3370ea00290021091100091999ab9a3370ea00490011190911180180218031aba135573ca00846666ae68cdc3a801a400042444004464c6401c66ae7003c03803002c0284d55cea80089baa0012323333573466e1d40052002201523333573466e1d40092000201523263200a33573801601401000e26aae74dd5000919191919191999ab9a3370ea002900610911111100191999ab9a3370ea004900510911111100211999ab9a3370ea00690041199109111111198008048041bae35742a00a6eb4d5d09aba2500523333573466e1d40112006233221222222233002009008375c6ae85401cdd71aba135744a00e46666ae68cdc3a802a400846644244444446600c01201060186ae854024dd71aba135744a01246666ae68cdc3a8032400446424444444600e010601a6ae84d55cf280591999ab9a3370ea00e900011909111111180280418071aba135573ca018464c6402466ae7004c04804003c03803403002c0284d55cea80209aab9e5003135573ca00426aae7940044dd50009191919191999ab9a3370ea002900111999110911998008028020019bad35742a0086eb4d5d0a8019bad357426ae89400c8cccd5cd19b875002480008c8488c00800cc020d5d09aab9e500623263200b33573801801601201026aae75400c4d5d1280089aab9e500113754002464646666ae68cdc3a800a400446424460020066eb8d5d09aab9e500323333573466e1d400920002321223002003375c6ae84d55cf280211931900419ab9c009008006005135573aa00226ea800444888c8c8cccd5cd19b8735573aa0049000119aa80598031aba150023005357426ae8940088c98c8020cd5ce00480400309aab9e5001137540029309000a48103505431003200135500b2211222533500115007221350022253353300700600213500c0011333553009120010070060031122123300100300212122300200311220011122320013200135500922533500110032213300600230040011233500150025003112200212212233001004003233573892011443617463682d616c6c2063617365206572726f720000212200212200111232300100122330033002002001480092211cf1eda47a5724f121fe27d208fb96c675db997cdb7ef6c7a3a75d1a1b0048810c42594e45544c6963656e73650001',
          language: 'plutus:v1'
        }
      },
      signatories: [
        {
          key: '3213e3fa6e42a75ba69df35d80666a021b0a650be3c5dadee03532414e90ab9c',
          signature:
            '76183df968ab1309d7a411d5513c24640c766c87d875415769cf373c59454a181c93963b1b1c33be70cc62db0bc8e3e2e0a1b53c1ba338ab58e1baf79642ca0c'
        }
      ],
      spends: 'inputs',
      validityInterval: {}
    },
    {
      cbor: '84a7008182582020365bc2f9e9b368cf61f4670d0e0fb295a178f66fe8986d4aee713d105b27f6070d81825820958adee7adb5cfe0510e9f9b63af2d9409bf25637af1ac899fe34b751956811200018482583900f1eda47a5724f121fe27d208fb96c675db997cdb7ef6c7a3a75d1a1bd43c31e11fda8ed21cc1f2f3803b586d44fa53e1e35fc30a1e840b671a0043d2c183581d70e65d5b0f31bdea82641630440de069a15cc31b21c2b4f2270c6e9cde821a001a4e60a1581c4d2047d7af3d8de799de5daa6e1b0ebfc039f4274084d5bb9ba3975da14c42594e45544c6963656e7365015820118cd93427a8e035d484e55ddd4c70200ac5a4d8e63d9d1b89e8a8d49d22941583581d70e65d5b0f31bdea82641630440de069a15cc31b21c2b4f2270c6e9cde821a001a4e60a1581c4d2047d7af3d8de799de5daa6e1b0ebfc039f4274084d5bb9ba3975da14c42594e45544c6963656e7365015820118cd93427a8e035d484e55ddd4c70200ac5a4d8e63d9d1b89e8a8d49d22941583581d70e65d5b0f31bdea82641630440de069a15cc31b21c2b4f2270c6e9cde821a001a4e60a1581c4d2047d7af3d8de799de5daa6e1b0ebfc039f4274084d5bb9ba3975da14c42594e45544c6963656e7365015820118cd93427a8e035d484e55ddd4c70200ac5a4d8e63d9d1b89e8a8d49d229415021a0005d89f0e81581cf1eda47a5724f121fe27d208fb96c675db997cdb7ef6c7a3a75d1a1b09a1581c4d2047d7af3d8de799de5daa6e1b0ebfc039f4274084d5bb9ba3975da14c42594e45544c6963656e7365030b5820efa020e8985191676d8922ea1bb7f0134dda7008a9a02fa5d87d00363a9ae096a400818258203213e3fa6e42a75ba69df35d80666a021b0a650be3c5dadee03532414e90ab9c58402c130293b9ec327d2ae59c4bfbc7779951b1deb1a9545ac9c3462ecb7e18b407e4d48d153500ee848dac1dd07c5db97e1fa1d094ee7903fa689e45fb08f96e0e0381590a08590a05010000333323322323322323233223232323232323232323232323232323232323232322222322323253353232533500213500122333350012302949894cd4cc03800c03040ac4cd5ce24921496e76616c6964206c6963656e7365206d696e74696e6720617574686f726974790002a230294988c0a52613500122333350012302949894cd54cd4cc03800c03040ac4cd5ce248121496e76616c6964206c6963656e7365206d696e74696e6720617574686f726974790002a153355335333355300f120013350102223003300200120012202c35026122333550272233355029225335002213300702600210010013502a1223300235004222533500121533533355302b1200122333573466e3c0080040dc0d8004d403488888888880088c8c84ccccccd5d200191999ab9a3370e6aae75400d2000233335573ea0064a06646666aae7cd5d128021299a991999999aba400125036250362503625036235037375c0040626ae85401484d40d848c004008540d0940d00bc0b8940c80b0940c4940c4940c4940c40b04d55cf280089baa0011502d1502c00100135005222222222200902b102a102b102b13357389211a2020496e636f7272656374206c6963656e7365206d696e7465640002a102a230294988c0a5263333573466e1cd55cea801a400046644246600200600464646464646464646464646666ae68cdc39aab9d500a480008cccccccccc888888888848cccccccccc00402c02802402001c01801401000c008cd40688c8c8cccd5cd19b8735573aa004900011991091980080180118119aba15002301f357426ae8940088c98c80b0cd5ce01681601509aab9e5001137540026ae854028cd406806cd5d0a804999aa80ebae501c35742a010666aa03aeb94070d5d0a80399a80d0119aba1500633501a335502602475a6ae854014c8c8c8cccd5cd19b8735573aa00490001199109198008018011919191999ab9a3370e6aae754009200023322123300100300233502975a6ae854008c0a8d5d09aba2500223263203033573806206005c26aae7940044dd50009aba150023232323333573466e1cd55cea8012400046644246600200600466a052eb4d5d0a80118151aba135744a004464c6406066ae700c40c00b84d55cf280089baa001357426ae8940088c98c80b0cd5ce01681601509aab9e5001137540026ae854010cd4069d71aba1500333501a335502675c40026ae854008c080d5d09aba2500223263202833573805205004c26ae8940044d5d1280089aba25001135744a00226ae8940044d5d1280089aba25001135744a00226aae7940044dd50009aba150033232323333573466e1d40052006232122223004005301b357426aae79400c8cccd5cd19b875002480108c848888c008014c074d5d09aab9e500423333573466e1d400d20022321222230010053019357426aae7940148cccd5cd19b875004480008c848888c00c014dd71aba135573ca00c464c6404666ae7009008c08408007c0784d55cea80089baa001357426ae89400c8c98c8070cd5ce00e80e00d1999ab9a3370ea0089001109100111999ab9a3370ea00a9000109100091931900e19ab9c01d01c01a019101a13263201a335738921035054350001a135573ca00226ea80044d55ce9baa00122350022222222222533533355300d1200133500e225335002210031001502125335333573466e3c0300040a80a44d408c0045408800c840a840a0c8004d5407488448894cd40044d400c88004884ccd401488008c010008ccd54c01c4800401401000448848cc00400c00848c88c008dd6000990009aa80e111999aab9f0012501b233501a30043574200460066ae880080448c8c8c8cccd5cd19b8735573aa00690001199911091998008020018011919191999ab9a3370e6aae7540092000233221233001003002301335742a00466a0180246ae84d5d1280111931900b19ab9c017016014135573ca00226ea8004d5d0a801999aa803bae500635742a00466a010eb8d5d09aba2500223263201233573802602402026ae8940044d55cf280089baa0011335500175ceb44488c88c008dd5800990009aa80d11191999aab9f0022501a23350193355014300635573aa004600a6aae794008c010d5d100180809aba100112232323333573466e1d400520002350143005357426aae79400c8cccd5cd19b87500248008940508c98c8040cd5ce00880800700689aab9d500113754002464646666ae68cdc39aab9d5002480008cc8848cc00400c008c014d5d0a8011bad357426ae8940088c98c8034cd5ce00700680589aab9e5001137540024646666ae68cdc39aab9d5001480008dd71aba135573ca004464c6401666ae7003002c0244dd500089119191999ab9a3370ea00290021091100091999ab9a3370ea00490011190911180180218031aba135573ca00846666ae68cdc3a801a400042444004464c6401c66ae7003c03803002c0284d55cea80089baa0012323333573466e1d40052002201523333573466e1d40092000201523263200a33573801601401000e26aae74dd5000919191919191999ab9a3370ea002900610911111100191999ab9a3370ea004900510911111100211999ab9a3370ea00690041199109111111198008048041bae35742a00a6eb4d5d09aba2500523333573466e1d40112006233221222222233002009008375c6ae85401cdd71aba135744a00e46666ae68cdc3a802a400846644244444446600c01201060186ae854024dd71aba135744a01246666ae68cdc3a8032400446424444444600e010601a6ae84d55cf280591999ab9a3370ea00e900011909111111180280418071aba135573ca018464c6402466ae7004c04804003c03803403002c0284d55cea80209aab9e5003135573ca00426aae7940044dd50009191919191999ab9a3370ea002900111999110911998008028020019bad35742a0086eb4d5d0a8019bad357426ae89400c8cccd5cd19b875002480008c8488c00800cc020d5d09aab9e500623263200b33573801801601201026aae75400c4d5d1280089aab9e500113754002464646666ae68cdc3a800a400446424460020066eb8d5d09aab9e500323333573466e1d400920002321223002003375c6ae84d55cf280211931900419ab9c009008006005135573aa00226ea800444888c8c8cccd5cd19b8735573aa0049000119aa80598031aba150023005357426ae8940088c98c8020cd5ce00480400309aab9e5001137540029309000a48103505431003200135500b2211222533500115007221350022253353300700600213500c0011333553009120010070060031122123300100300212122300200311220011122320013200135500922533500110032213300600230040011233500150025003112200212212233001004003233573892011443617463682d616c6c2063617365206572726f720000212200212200111232300100122330033002002001480092211cf1eda47a5724f121fe27d208fb96c675db997cdb7ef6c7a3a75d1a1b0048810c42594e45544c6963656e736500010481d8799f581c0bfe875a7ae9db3c1b3827483ac6a1d02a7a93d3d26df00c7973aa47ff0581840100d87980821a000dcfe21a0fd4528ef5f6',
      collaterals: [
        {
          index: 0,
          transaction: {
            id: '958adee7adb5cfe0510e9f9b63af2d9409bf25637af1ac899fe34b7519568112'
          }
        }
      ],
      datums: {
        '118cd93427a8e035d484e55ddd4c70200ac5a4d8e63d9d1b89e8a8d49d229415':
          'd8799f581c0bfe875a7ae9db3c1b3827483ac6a1d02a7a93d3d26df00c7973aa47ff'
      },
      fee: {
        ada: { lovelace: 383_135n }
      },
      id: '2c8ddb336af166f19bf609f259fa9217fc3c7fed76c576e13bde393c145e181f',
      inputs: [
        {
          index: 7,
          transaction: {
            id: '20365bc2f9e9b368cf61f4670d0e0fb295a178f66fe8986d4aee713d105b27f6'
          }
        }
      ],
      mint: {
        '4d2047d7af3d8de799de5daa6e1b0ebfc039f4274084d5bb9ba3975d': {
          '42594e45544c6963656e7365': 3n
        }
      },
      outputs: [
        {
          address:
            'addr_test1qrc7mfr62uj0zg07ylfq37ukce6ahxtumdl0d3ar5aw35x758sc7z8763mfpes0j7wqrkkrdgna98c0rtlps585ypdnst69syh',
          value: {
            ada: {
              lovelace: 4_444_865n
            }
          }
        },
        {
          address: 'addr_test1wrn96kc0xx774qnyzccygr0qdxs4escmy8ptfu38p3hfehsu5427k',
          datumHash: '118cd93427a8e035d484e55ddd4c70200ac5a4d8e63d9d1b89e8a8d49d229415',
          value: {
            '4d2047d7af3d8de799de5daa6e1b0ebfc039f4274084d5bb9ba3975d': {
              '42594e45544c6963656e7365': 1n
            },
            ada: {
              lovelace: 1_724_000n
            }
          }
        },
        {
          address: 'addr_test1wrn96kc0xx774qnyzccygr0qdxs4escmy8ptfu38p3hfehsu5427k',
          datumHash: '118cd93427a8e035d484e55ddd4c70200ac5a4d8e63d9d1b89e8a8d49d229415',
          value: {
            '4d2047d7af3d8de799de5daa6e1b0ebfc039f4274084d5bb9ba3975d': {
              '42594e45544c6963656e7365': 1n
            },
            ada: {
              lovelace: 1_724_000n
            }
          }
        },
        {
          address: 'addr_test1wrn96kc0xx774qnyzccygr0qdxs4escmy8ptfu38p3hfehsu5427k',
          datumHash: '118cd93427a8e035d484e55ddd4c70200ac5a4d8e63d9d1b89e8a8d49d229415',
          value: {
            '4d2047d7af3d8de799de5daa6e1b0ebfc039f4274084d5bb9ba3975d': {
              '42594e45544c6963656e7365': 1n
            },
            ada: {
              lovelace: 1_724_000n
            }
          }
        }
      ],
      redeemers: [
        {
          executionUnits: {
            cpu: 265_573_006,
            memory: 905_186
          },
          redeemer: 'd87980',
          validator: {
            index: 0,
            purpose: 'mint'
          }
        }
      ],
      requiredExtraSignatories: ['f1eda47a5724f121fe27d208fb96c675db997cdb7ef6c7a3a75d1a1b'],
      scriptIntegrityHash: 'efa020e8985191676d8922ea1bb7f0134dda7008a9a02fa5d87d00363a9ae096',
      scripts: {
        '4d2047d7af3d8de799de5daa6e1b0ebfc039f4274084d5bb9ba3975d': {
          cbor: '590a05010000333323322323322323233223232323232323232323232323232323232323232322222322323253353232533500213500122333350012302949894cd4cc03800c03040ac4cd5ce24921496e76616c6964206c6963656e7365206d696e74696e6720617574686f726974790002a230294988c0a52613500122333350012302949894cd54cd4cc03800c03040ac4cd5ce248121496e76616c6964206c6963656e7365206d696e74696e6720617574686f726974790002a153355335333355300f120013350102223003300200120012202c35026122333550272233355029225335002213300702600210010013502a1223300235004222533500121533533355302b1200122333573466e3c0080040dc0d8004d403488888888880088c8c84ccccccd5d200191999ab9a3370e6aae75400d2000233335573ea0064a06646666aae7cd5d128021299a991999999aba400125036250362503625036235037375c0040626ae85401484d40d848c004008540d0940d00bc0b8940c80b0940c4940c4940c4940c40b04d55cf280089baa0011502d1502c00100135005222222222200902b102a102b102b13357389211a2020496e636f7272656374206c6963656e7365206d696e7465640002a102a230294988c0a5263333573466e1cd55cea801a400046644246600200600464646464646464646464646666ae68cdc39aab9d500a480008cccccccccc888888888848cccccccccc00402c02802402001c01801401000c008cd40688c8c8cccd5cd19b8735573aa004900011991091980080180118119aba15002301f357426ae8940088c98c80b0cd5ce01681601509aab9e5001137540026ae854028cd406806cd5d0a804999aa80ebae501c35742a010666aa03aeb94070d5d0a80399a80d0119aba1500633501a335502602475a6ae854014c8c8c8cccd5cd19b8735573aa00490001199109198008018011919191999ab9a3370e6aae754009200023322123300100300233502975a6ae854008c0a8d5d09aba2500223263203033573806206005c26aae7940044dd50009aba150023232323333573466e1cd55cea8012400046644246600200600466a052eb4d5d0a80118151aba135744a004464c6406066ae700c40c00b84d55cf280089baa001357426ae8940088c98c80b0cd5ce01681601509aab9e5001137540026ae854010cd4069d71aba1500333501a335502675c40026ae854008c080d5d09aba2500223263202833573805205004c26ae8940044d5d1280089aba25001135744a00226ae8940044d5d1280089aba25001135744a00226aae7940044dd50009aba150033232323333573466e1d40052006232122223004005301b357426aae79400c8cccd5cd19b875002480108c848888c008014c074d5d09aab9e500423333573466e1d400d20022321222230010053019357426aae7940148cccd5cd19b875004480008c848888c00c014dd71aba135573ca00c464c6404666ae7009008c08408007c0784d55cea80089baa001357426ae89400c8c98c8070cd5ce00e80e00d1999ab9a3370ea0089001109100111999ab9a3370ea00a9000109100091931900e19ab9c01d01c01a019101a13263201a335738921035054350001a135573ca00226ea80044d55ce9baa00122350022222222222533533355300d1200133500e225335002210031001502125335333573466e3c0300040a80a44d408c0045408800c840a840a0c8004d5407488448894cd40044d400c88004884ccd401488008c010008ccd54c01c4800401401000448848cc00400c00848c88c008dd6000990009aa80e111999aab9f0012501b233501a30043574200460066ae880080448c8c8c8cccd5cd19b8735573aa00690001199911091998008020018011919191999ab9a3370e6aae7540092000233221233001003002301335742a00466a0180246ae84d5d1280111931900b19ab9c017016014135573ca00226ea8004d5d0a801999aa803bae500635742a00466a010eb8d5d09aba2500223263201233573802602402026ae8940044d55cf280089baa0011335500175ceb44488c88c008dd5800990009aa80d11191999aab9f0022501a23350193355014300635573aa004600a6aae794008c010d5d100180809aba100112232323333573466e1d400520002350143005357426aae79400c8cccd5cd19b87500248008940508c98c8040cd5ce00880800700689aab9d500113754002464646666ae68cdc39aab9d5002480008cc8848cc00400c008c014d5d0a8011bad357426ae8940088c98c8034cd5ce00700680589aab9e5001137540024646666ae68cdc39aab9d5001480008dd71aba135573ca004464c6401666ae7003002c0244dd500089119191999ab9a3370ea00290021091100091999ab9a3370ea00490011190911180180218031aba135573ca00846666ae68cdc3a801a400042444004464c6401c66ae7003c03803002c0284d55cea80089baa0012323333573466e1d40052002201523333573466e1d40092000201523263200a33573801601401000e26aae74dd5000919191919191999ab9a3370ea002900610911111100191999ab9a3370ea004900510911111100211999ab9a3370ea00690041199109111111198008048041bae35742a00a6eb4d5d09aba2500523333573466e1d40112006233221222222233002009008375c6ae85401cdd71aba135744a00e46666ae68cdc3a802a400846644244444446600c01201060186ae854024dd71aba135744a01246666ae68cdc3a8032400446424444444600e010601a6ae84d55cf280591999ab9a3370ea00e900011909111111180280418071aba135573ca018464c6402466ae7004c04804003c03803403002c0284d55cea80209aab9e5003135573ca00426aae7940044dd50009191919191999ab9a3370ea002900111999110911998008028020019bad35742a0086eb4d5d0a8019bad357426ae89400c8cccd5cd19b875002480008c8488c00800cc020d5d09aab9e500623263200b33573801801601201026aae75400c4d5d1280089aab9e500113754002464646666ae68cdc3a800a400446424460020066eb8d5d09aab9e500323333573466e1d400920002321223002003375c6ae84d55cf280211931900419ab9c009008006005135573aa00226ea800444888c8c8cccd5cd19b8735573aa0049000119aa80598031aba150023005357426ae8940088c98c8020cd5ce00480400309aab9e5001137540029309000a48103505431003200135500b2211222533500115007221350022253353300700600213500c0011333553009120010070060031122123300100300212122300200311220011122320013200135500922533500110032213300600230040011233500150025003112200212212233001004003233573892011443617463682d616c6c2063617365206572726f720000212200212200111232300100122330033002002001480092211cf1eda47a5724f121fe27d208fb96c675db997cdb7ef6c7a3a75d1a1b0048810c42594e45544c6963656e73650001',
          language: 'plutus:v1'
        }
      },
      signatories: [
        {
          key: '3213e3fa6e42a75ba69df35d80666a021b0a650be3c5dadee03532414e90ab9c',
          signature:
            '2c130293b9ec327d2ae59c4bfbc7779951b1deb1a9545ac9c3462ecb7e18b407e4d48d153500ee848dac1dd07c5db97e1fa1d094ee7903fa689e45fb08f96e0e'
        }
      ],
      spends: 'inputs',
      validityInterval: {}
    },
    {
      cbor: '84a50083825820803f8599f482d6f4c84da3b095efb4667aa4506d442cf080125a1baa1d66085e0082582098d92512364c908d1866e5a23e73c3f2b5219d7f4963343565943823dfc9b3a60082582098d92512364c908d1866e5a23e73c3f2b5219d7f4963343565943823dfc9b3a6010182a200583900c8fd82eefa4f5090b3b8a80e5b9244a4656b0e4444066d5d0678004f241511e532f73ba0a4e25c6a659813e7492a0842a3698ac8d72a0983011a000f4240a2005839007ac8763b8be2c94c30ed70190a08c8376ef7ce2762c2d605082ae58c241511e532f73ba0a4e25c6a659813e7492a0842a3698ac8d72a0983011b0000000253451827021a0002cbc1031a00aadfcb075820b93d8e428871a0b0e12c5c554653f515f50fe48dc5b55af7e3667e7d9661ea2ca1008282582053b8509684715055c86ded21c00e6f7c9c2efa73a94959842a3fe91d6001e9325840cc35732a94c3f4521479942a07bdbf54f71062dd134fe66ff015a66ec74016b348782e4d2eafd99ae66cc7894249587622c4092090c841b439dfea558ff2190d8258202cf1d6c8d41391e658e25dbc88638831d7af3254988bde4650e1c595c21214615840f76fd79984cb7bbdeb5445c040aa873f60f1f3f56c71d3db77468261c864b8e745916bf519ae2e54453692dc2d1b0a0b1daf68ece63f084ac3b67d665637920df5d90103a100a10080',
      fee: {
        ada: { lovelace: 183_233n }
      },
      id: '5448314ba8c137b110f279c2b8869f88b77cce325cddf8aec64480708bd18915',
      inputs: [
        {
          index: 0,
          transaction: {
            id: '803f8599f482d6f4c84da3b095efb4667aa4506d442cf080125a1baa1d66085e'
          }
        },
        {
          index: 0,
          transaction: {
            id: '98d92512364c908d1866e5a23e73c3f2b5219d7f4963343565943823dfc9b3a6'
          }
        },
        {
          index: 1,
          transaction: {
            id: '98d92512364c908d1866e5a23e73c3f2b5219d7f4963343565943823dfc9b3a6'
          }
        }
      ],
      metadata: {
        hash: 'b93d8e428871a0b0e12c5c554653f515f50fe48dc5b55af7e3667e7d9661ea2c',
        labels: {
          '0': {
            cbor: '80',
            json: []
          }
        }
      },
      outputs: [
        {
          address:
            'addr_test1qry0mqhwlf84py9nhz5qukujgjjx26cwg3zqvm2aqeuqqneyz5g72vhh8ws2fcjudfjesyl8fy4qss4rdx9v34e2pxps5s28ar',
          value: {
            ada: {
              lovelace: 1_000_000n
            }
          }
        },
        {
          address:
            'addr_test1qpavsa3m303vjnpsa4cpjzsgeqmkaa7wya3v94s9pq4wtrpyz5g72vhh8ws2fcjudfjesyl8fy4qss4rdx9v34e2pxpsnutk58',
          value: {
            ada: {
              lovelace: 9_986_971_687n
            }
          }
        }
      ],
      signatories: [
        {
          key: '53b8509684715055c86ded21c00e6f7c9c2efa73a94959842a3fe91d6001e932',
          signature:
            'cc35732a94c3f4521479942a07bdbf54f71062dd134fe66ff015a66ec74016b348782e4d2eafd99ae66cc7894249587622c4092090c841b439dfea558ff2190d'
        },
        {
          key: '2cf1d6c8d41391e658e25dbc88638831d7af3254988bde4650e1c595c2121461',
          signature:
            'f76fd79984cb7bbdeb5445c040aa873f60f1f3f56c71d3db77468261c864b8e745916bf519ae2e54453692dc2d1b0a0b1daf68ece63f084ac3b67d665637920d'
        }
      ],
      spends: 'inputs',
      validityInterval: {
        invalidAfter: 11_198_411
      }
    }
  ],
  type: 'praos'
};

// From preprod
export const mockBabbageBlockWithNftMetadata: Ogmios.Schema.Block = {
  ancestor: '5258b02d707648af74d2e7fe4d0c4473c1a0a20e37a7d1f2b51156774cf39bda',
  era: 'babbage',
  height: 177_242,
  id: 'd49cfb3383fa8a52db3b4a44f7a4cb30287324b15b800de1ba3f2e06d7e44434',
  issuer: {
    leaderValue: {
      output:
        '7fde158e2a6ca47d8beba4a2cc8a80ea6128a6f3baf8f311a475b439915418862182a6a2af0bd71253c52bdfd3d26c836cc2495a15ee545d7d3cdc8df7b71cff',
      proof:
        'd6d415bebd2a97982b3f147b331aa1e142056337d11b4f06768f469a1a62d69d416aed620536639665c5023c3bb802fe50ed4f900aed1586b9a08534458e53170c5796e920f82f13892c9163004e460d'
    },
    operationalCertificate: {
      count: 1,
      kes: {
        period: 60,
        verificationKey: '01a2a5d502467f061867fd59881bd2ddf11bb1d287c82d56692dd68c5428ec6c'
      }
    },
    verificationKey: 'a9d974fd26bfaf385749113f260271430276bed6ef4dad6968535de6778471ce',
    vrfVerificationKey: '09e142413e6a20c48dcf0bc1e1604d22ec6c1682802212c130bd8b0888fa925a'
  },
  protocol: {
    version: {
      major: 7,
      minor: 0
    }
  },
  size: {
    bytes: 1050
  },
  slot: 10_662_793,
  transactions: [
    {
      cbor: '84a4008182582070d52f0948a449ddad36dc0537850d33dd076bae29f4b22befe22eb2a75753c3000182a200581d609e5614893238cf85e284c61ec56d5efd9f9cdc4863ba7e1bf00c2c7d011b0068ac6cbeec0618a2005839009e5614893238cf85e284c61ec56d5efd9f9cdc4863ba7e1bf00c2c7d92a4e1a62625324b8099bfc57ac707a9ebdcfa7ee953f96b7e0d6757011b000000e8d4a51000021a00029309048182008200581c92a4e1a62625324b8099bfc57ac707a9ebdcfa7ee953f96b7e0d6757a1008182582069a14b724409e0ceef671c76ec4f8bce7509b5919bb971b3855bf92ca565322258409f1c556812a5d94e8a94c3beba0caae68e149025ecb8aa05f3eba76e15eacf1e31f108b32517c5ec127dfc6bcd4c646239a2ff4f7c1ab5a0b051be0f10ca1b07f5f6',
      certificates: [
        {
          credential: '92a4e1a62625324b8099bfc57ac707a9ebdcfa7ee953f96b7e0d6757',
          type: 'stakeCredentialRegistration'
        }
      ],
      fee: {
        ada: { lovelace: 168_713n }
      },
      id: '3e942e2930be32561dbe1764bea4d1a1cebe28c087ba3fcc827f1dcea2c8b92e',
      inputs: [
        {
          index: 0,
          transaction: {
            id: '70d52f0948a449ddad36dc0537850d33dd076bae29f4b22befe22eb2a75753c3'
          }
        }
      ],
      outputs: [
        {
          address: 'addr_test1vz09v9yfxguvlp0zsnrpa3tdtm7el8xufp3m5lsm7qxzclgmzkket',
          value: {
            ada: {
              lovelace: 29_462_980_637_492_760n
            }
          }
        },
        {
          address:
            'addr_test1qz09v9yfxguvlp0zsnrpa3tdtm7el8xufp3m5lsm7qxzclvj5ns6vf39xf9cpxdlc4avwpafa0w05lhf20ukklsdvats3awze0',
          value: {
            ada: {
              lovelace: 1_000_000_000_000n
            }
          }
        }
      ],
      signatories: [
        {
          key: '69a14b724409e0ceef671c76ec4f8bce7509b5919bb971b3855bf92ca5653222',
          signature:
            '9f1c556812a5d94e8a94c3beba0caae68e149025ecb8aa05f3eba76e15eacf1e31f108b32517c5ec127dfc6bcd4c646239a2ff4f7c1ab5a0b051be0f10ca1b07'
        }
      ],
      spends: 'inputs',
      validityInterval: {}
    },
    {
      cbor: '84a60081825820017b0c21d858752eee8120da51e3397f8f5b4481ed35c802006e73393d63378b000181825839006f5a3e4acedf6b6941f2bc705e11392fe52ac8e063395324b16936e2505a4bd1f291535fbf768a6e6de59b39b18c3d158dc43d4cfc08771f821b000000025408ff27a1581ce2bab64ca481afc5a695b7db22fd0a7df4bf930158dfa652fb337999a15053554d4d49544157415244534465666901021a0002e4d9031a00ef646309a1581ce2bab64ca481afc5a695b7db22fd0a7df4bf930158dfa652fb337999a15053554d4d49544157415244534465666901075820b46ae643d61f636ee612f7740d7ff6990963d2b4e13',
      fee: {
        ada: { lovelace: 189_657n }
      },
      id: 'a86d5246c1e5ce7d66446d0a68355abe6622545d8ffe7dd832a062f6cde010bd',
      inputs: [
        {
          index: 0,
          transaction: {
            id: '017b0c21d858752eee8120da51e3397f8f5b4481ed35c802006e73393d63378b'
          }
        }
      ],
      metadata: {
        hash: 'b46ae643d61f636ee612f7740d7ff6990963d2b4e13a5685befc4433d0f36652',
        labels: {
          '721': {
            cbor: 'a278386532626162363463613438316166633561363935623764623232666430613764663462663933303135386466613635326662333337393939a17053554d4d495441574152445344656669a46b4465736372697074696f6e781e5468697320697320616e206578616d706c65206465736372697074696f6e6461726561644465666965696d6167657835697066733a2f2f516d5a7a4832317a575372675931345a3145557a344a33796f59424e47733978545237356142524b3538324e5839646e616d657053554d4d4954415741524453446566696776657273696f6e63312e30',
            json: [
              {
                e2bab64ca481afc5a695b7db22fd0a7df4bf930158dfa652fb337999: [
                  {
                    SUMMITAWARDSDefi: [
                      {
                        Description: 'This is an example description'
                      },
                      {
                        area: 'Defi'
                      },
                      {
                        image: 'ipfs://QmZzH21zWSrgY14Z1EUz4J3yoYBNGs9xTR75aBRK582NX9'
                      },
                      {
                        name: 'SUMMITAWARDSDefi'
                      }
                    ]
                  }
                ]
              },
              {
                version: '1.0'
              }
            ]
          }
        }
      },
      mint: {
        e2bab64ca481afc5a695b7db22fd0a7df4bf930158dfa652fb337999: {
          '53554d4d495441574152445344656669': 1n
        }
      },
      outputs: [
        {
          address:
            'addr_test1qph450j2em0kk62p7278qhs38yh722kgup3nj5eyk95ndcjstf9aru532d0m7a52dek7txeekxxr69vdcs75elqgwu0syrcdqg',
          value: {
            ada: {
              lovelace: 9_999_810_343n
            },
            e2bab64ca481afc5a695b7db22fd0a7df4bf930158dfa652fb337999: {
              '53554d4d495441574152445344656669': 1n
            }
          }
        }
      ],
      scripts: {
        e2bab64ca481afc5a695b7db22fd0a7df4bf930158dfa652fb337999: {
          json: {
            clause: 'all',
            from: [
              {
                clause: 'before',
                slot: 15_688_803
              },
              {
                clause: 'signature',
                from: '1f3af84024d2b2df54ab84c2a1ba55df164611d24602c1d92edfb619'
              }
            ]
          },
          language: 'native'
        }
      },
      signatories: [
        {
          key: 'c13c9bf092263713bce05a96a825c9fcd7e0830ce794264a33ce895ebb89ce25',
          signature:
            '708e36bdff752b3b535b83f7be7e40c860c770c80cf95a3f1f2b956e83185b1c2fe5768d9b5adc4d77153423d620c5db113abeb1afea22ed297bd8b1a15ace0e'
        },
        {
          key: 'd8e1439ecfd0b112ef910478b58ca5f702a24eccb14007a678d06e8e59745da7',
          signature:
            '50c0e9a5144f04d440c55edee87669cacc3820bb7f8ec4015595d9af4ec1ad45e28e766270d195f1817b9256ec83dfbd28dd9dfc8c738c8d5ba4eef38806ae08'
        }
      ],
      spends: 'inputs',
      validityInterval: {
        invalidAfter: 15_688_803
      }
    }
  ],
  type: 'praos'
};

// From preprod
export const mockBabbageBlockWithInlineDatum = {
  ancestor: 'e82c0484f433cceeaf63e2b1ef1e8c2f89f3a23efce8e4623d400db4616a5eee',
  era: 'babbage',
  height: 178_279,
  id: '47ce1d79ffd414412071bf172f78efee48c634fac48668073ef63c58e51131b0',
  issuer: {
    leaderValue: {
      output:
        '898d909c7838a354b9a849cfd5b5e6765b3bf8ddcd0d7a327a7cc7c713cfd8fcf63c5f762b378f74bbf2db3667d209446f7be62a2938cbe507b68ecee7b56707',
      proof:
        '95d089bda66a622fc4536a2a99cdfc7dd96495ad0e03644ee60109688209c2e6329dc999e51cc2a75d2a70eb7ffb46e574191049e3a6744421c5e88009910783961df918778e08acbb071f6fb91b2d0f'
    },
    operationalCertificate: {
      count: 1,
      kes: {
        period: 60,
        verificationKey: 'c8682c718e8670f9edd295d8b0db50e2e32bf25397726eef56227dbaf89a254a'
      }
    },
    verificationKey: '9691ed9d98a5b79d5bc46c4496a6dba7e103f668f525c8349b6b92676cb3eae4',
    vrfVerificationKey: 'ea49e4652c460b9ee6daafefc999ca667fbe5eb5d7a7aeabbdff6fe19c1a3c9f'
  },
  protocol: {
    version: {
      major: 7,
      minor: 0
    }
  },
  size: {
    bytes: 9002
  },
  slot: 10_684_581,
  transactions: [
    {
      collateralReturn: {
        address: 'addr_test1vq85t2h3k22emdh9l72dhv0cywlj2a5qc0rj8tpdf8uh23st77ahh',
        value: {
          ada: {
            lovelace: 9_995_000_000n
          }
        }
      },
      collaterals: [
        {
          index: 0,
          transaction: {
            id: '3af0570cd555abee485f9597fe8aa7440a5e27bcc6f4d39b13ec9a8d55d56c97'
          }
        }
      ],
      fee: {
        lovelace: 779_848n
      },
      id: 'd5fed4dca96c7efda3d1b0897c91c0eee8f8c6a18e5931dfbd56b6ec7a5951a1',
      inputs: [
        {
          index: 0,
          transaction: {
            id: '3af0570cd555abee485f9597fe8aa7440a5e27bcc6f4d39b13ec9a8d55d56c97'
          }
        }
      ],
      mint: {
        '1cf569e1ec3e0fee92f1f5002bfd4213b796c151c708db46e6e2d3a4': {
          '': 1n
        },
        '8b14b900bbf9f43d911da209a28e7bd2cce500d8e4bc928c9ca714fb': {
          '': 1n
        },
        b413bc466dadcb6bcf93e840a9eedabe04e83aa9d55f9deeb94d9743: {
          '': 1n
        }
      },
      network: 'testnet',
      outputs: [
        {
          address: 'addr_test1vq85t2h3k22emdh9l72dhv0cywlj2a5qc0rj8tpdf8uh23st77ahh',
          value: {
            ada: {
              lovelace: 9_995_285_122n
            }
          }
        },
        {
          address: 'addr_test1wqjk8rfyc26nwnrmff2nvglpy702mg8xv2ftf2jq0lwspjc4qd6gu',
          datum: 'd8799f58200baae24a9c812b37f9d76eb577172ff6c7b147279499edfb7b9d2468c22ff75eff',
          value: {
            '8b14b900bbf9f43d911da209a28e7bd2cce500d8e4bc928c9ca714fb': {
              '': 1n
            },
            ada: {
              lovelace: 1_310_240n
            }
          }
        },
        {
          address: 'addr_test1wrjuscfz96m0emnfz6xxjf2j0afd5drhn6whr2muskqnxvszu08he',
          datum:
            'd8799f581cb413bc466dadcb6bcf93e840a9eedabe04e83aa9d55f9deeb94d9743581cebc705b30531d5b34e524f94bf2f276b4593b437eba67338f9108608ff',
          value: {
            '1cf569e1ec3e0fee92f1f5002bfd4213b796c151c708db46e6e2d3a4': {
              '': 1n
            },
            ada: {
              lovelace: 1_314_550n
            }
          }
        },
        {
          address: 'addr_test1wp92jdmehuy48v758t062v86py8e9z7qv4qm30jmqwfzrkg50zlqa',
          datum: 'd8799f5821ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
          value: {
            ada: {
              lovelace: 1_310_240n
            },
            b413bc466dadcb6bcf93e840a9eedabe04e83aa9d55f9deeb94d9743: {
              '': 1n
            }
          }
        }
      ],
      redeemers: {
        'mint:0': {
          executionUnits: {
            cpu: 270_069_846,
            memory: 881_262
          },
          redeemer: 'd87980'
        },
        'mint:1': {
          executionUnits: {
            cpu: 270_492_926,
            memory: 884_102
          },
          redeemer: 'd87980'
        },
        'mint:2': {
          executionUnits: {
            cpu: 330_098_849,
            memory: 1_105_485
          },
          redeemer: 'd87980'
        }
      },
      scriptIntegrityHash: '03a3ee5cc4b1ac8863731642101888bb7622f7f61d61976f985ff5f4bace4748',
      scripts: {
        '1cf569e1ec3e0fee92f1f5002bfd4213b796c151c708db46e6e2d3a4': {
          cbor: '5909b6010000332323233223233223232323232323232323232323322323232323232323355501c22232325335330053333573466e1cd55ce9baa0044800080648c98c8064cd5ce00d00c80b9999ab9a3370e6aae7540092000233221233001003002323232323232323232323232323333573466e1cd55cea8062400046666666666664444444444442466666666666600201a01801601401201000e00c00a00800600466a02c02e6ae854030cd405805cd5d0a80599a80b00c1aba1500a3335501a75ca0326ae854024ccd54069d7280c9aba1500833501602135742a00e666aa034044eb4d5d0a8031919191999ab9a3370e6aae75400920002332212330010030023232323333573466e1cd55cea8012400046644246600200600466a058eb4d5d0a80118169aba135744a004464c6405e66ae700c00bc0b44d55cf280089baa00135742a0046464646666ae68cdc39aab9d5002480008cc8848cc00400c008cd40b1d69aba15002302d357426ae8940088c98c80bccd5ce01801781689aab9e5001137540026ae84d5d1280111931901599ab9c02c02b029135573ca00226ea8004d5d0a80299a80b3ae35742a008666aa03403c40026ae85400cccd54069d710009aba150023020357426ae8940088c98c809ccd5ce01401381289aba25001135744a00226ae8940044d5d1280089aba25001135744a00226ae8940044d5d1280089aba25001135744a00226aae7940044dd50009aba150023010357426ae8940088c98c8064cd5ce00d00c80b880c09931900c19ab9c4910350543500018135573ca00226ea8004cd554070888c8c8c94cd40084004407ccc019241236572726f7220276d6b4473436f6e66506f6c6963792720696c6c6567616c206d696e740053353355020323223002001320013550232253350011501022135002225335330240020071350150011300600335003223333500123263201b3357389201024c680001b200123263201b3357389201024c680001b23263201b3357389201024c680001b3200132350012222222222220085002215335001101f2213500222533500315335330220024890015335333573466e1c0052002024023102410231023221025101e33005491276572726f7220276d6b4473436f6e66506f6c69637927206d697373696e672054784f757452656600335501f2533500121020101e32350012222222222223335530261200132123300122533500221003100100250192350012253355335333573466e3cd400888008d4050880080b80b44ccd5cd19b873500222001350142200102e02d102d13501d0031501c00c5001135001220022323333573466e1cd55cea800a40004601c6ae84d55cf280111931900b19ab9c0170160141375400244a66a0022036266ae7000806848c88c008dd6000990009aa80e111999aab9f00125019233501830043574200460066ae880080508c8c8cccd5cd19b8735573aa004900011991091980080180118061aba150023005357426ae8940088c98c8050cd5ce00a80a00909aab9e5001137540024646464646666ae68cdc39aab9d5004480008cccc888848cccc00401401000c008c8c8c8cccd5cd19b8735573aa0049000119910919800801801180a9aba1500233500d014357426ae8940088c98c8064cd5ce00d00c80b89aab9e5001137540026ae854010ccd54021d728039aba150033232323333573466e1d4005200423212223002004357426aae79400c8cccd5cd19b875002480088c84888c004010dd71aba135573ca00846666ae68cdc3a801a400042444006464c6403666ae7007006c06406005c4d55cea80089baa00135742a00466a012eb8d5d09aba2500223263201533573802c02a02626ae8940044d5d1280089aab9e500113754002266aa002eb9d6889119118011bab00132001355019223233335573e0044a02e466a02c66442466002006004600c6aae754008c014d55cf280118021aba200301213574200224464646666ae68cdc3a800a400046a00e600a6ae84d55cf280191999ab9a3370ea00490011280391931900919ab9c01301201000f135573aa00226ea800448488c00800c44880048c8c8cccd5cd19b875001480188c848888c010014c01cd5d09aab9e500323333573466e1d400920042321222230020053009357426aae7940108cccd5cd19b875003480088c848888c004014c01cd5d09aab9e500523333573466e1d40112000232122223003005375c6ae84d55cf280311931900819ab9c01101000e00d00c00b135573aa00226ea80048c8c8cccd5cd19b8735573aa004900011991091980080180118029aba15002375a6ae84d5d1280111931900619ab9c00d00c00a135573ca00226ea80048c8cccd5cd19b8735573aa002900011bae357426aae7940088c98c8028cd5ce00580500409baa001232323232323333573466e1d4005200c21222222200323333573466e1d4009200a21222222200423333573466e1d400d2008233221222222233001009008375c6ae854014dd69aba135744a00a46666ae68cdc3a8022400c4664424444444660040120106eb8d5d0a8039bae357426ae89401c8cccd5cd19b875005480108cc8848888888cc018024020c030d5d0a8049bae357426ae8940248cccd5cd19b875006480088c848888888c01c020c034d5d09aab9e500b23333573466e1d401d2000232122222223005008300e357426aae7940308c98c804ccd5ce00a00980880800780700680600589aab9d5004135573ca00626aae7940084d55cf280089baa0012323232323333573466e1d400520022333222122333001005004003375a6ae854010dd69aba15003375a6ae84d5d1280191999ab9a3370ea0049000119091180100198041aba135573ca00c464c6401866ae700340300280244d55cea80189aba25001135573ca00226ea80048c8c8cccd5cd19b875001480088c8488c00400cdd71aba135573ca00646666ae68cdc3a8012400046424460040066eb8d5d09aab9e500423263200933573801401200e00c26aae7540044dd500089119191999ab9a3370ea00290021091100091999ab9a3370ea00490011190911180180218031aba135573ca00846666ae68cdc3a801a400042444004464c6401466ae7002c02802001c0184d55cea80089baa0012323333573466e1d40052002200c23333573466e1d40092000200c23263200633573800e00c00800626aae74dd5000a4c24002921035054310032001355008221122253350011350032200122133350052200230040023335530071200100500400111220021221223300100400322333573466e3c00800401000c4880084880044488c008004444888c00cc008004448c8c00400488cc00cc00800800530012fd8799fd8799fd8799f58203af0570cd555abee485f9597fe8aa7440a5e27bcc6f4d39b13ec9a8d55d56c97ff00ffff0001',
          language: 'plutus:v2'
        },
        '8b14b900bbf9f43d911da209a28e7bd2cce500d8e4bc928c9ca714fb': {
          cbor: '59098801000033232332232332232323232323232323232323233223232323232323355501a22232325335330053333573466e1cd55ce9baa0044800080608c98c8060cd5ce00c80c00b1999ab9a3370e6aae7540092000233221233001003002323232323232323232323232323333573466e1cd55cea8062400046666666666664444444444442466666666666600201a01801601401201000e00c00a00800600466a02a02c6ae854030cd4054058d5d0a80599a80a80b9aba1500a3335501975ca0306ae854024ccd54065d7280c1aba1500833501502035742a00e666aa032042eb4d5d0a8031919191999ab9a3370e6aae75400920002332212330010030023232323333573466e1cd55cea8012400046644246600200600466a056eb4d5d0a80118161aba135744a004464c6405c66ae700bc0b80b04d55cf280089baa00135742a0046464646666ae68cdc39aab9d5002480008cc8848cc00400c008cd40add69aba15002302c357426ae8940088c98c80b8cd5ce01781701609aab9e5001137540026ae84d5d1280111931901519ab9c02b02a028135573ca00226ea8004d5d0a80299a80abae35742a008666aa03203a40026ae85400cccd54065d710009aba15002301f357426ae8940088c98c8098cd5ce01381301209aba25001135744a00226ae8940044d5d1280089aba25001135744a00226ae8940044d5d1280089aba25001135744a00226aae7940044dd50009aba15002300f357426ae8940088c98c8060cd5ce00c80c00b080b89931900b99ab9c4910350543500017135573ca00226ea8004cd554068888c8c94cd54cd4ccd54c07048004c8c848cc00488ccd401488008008004008d40048800448cc004894cd40084078400406c8c94cd4ccd5cd19b8f3500722002350012200201d01c1333573466e1cd401c88004d4004880040740704070d400488008d54004888888888888030406c4cd5ce24812f6572726f7220276d6b436f6d6d697474656548617368506f6c69637927205554784f206e6f7420636f6e73756d65640001a15335533553353002355001222222222222008213500e0011500c215335001101b22135002225335003153353301e002489001333573466e1c005200202001f101f221021101a101b1335738921316572726f7220276d6b436f6d6d697474656548617368506f6c696379272077726f6e6720616d6f756e74206d696e7465640001a101a135002220023200135501e2253350011500c221350022253353301d00235007223333500123263201e335738921024c680001e200123263201e3357389201024c680001e23263201e3357389201024c680001e1350110011300600300a1232230023758002640026aa036446666aae7c004940708cd406cc010d5d080118019aba2002014232323333573466e1cd55cea8012400046644246600200600460186ae854008c014d5d09aba2500223263201433573802a02802426aae7940044dd50009191919191999ab9a3370e6aae75401120002333322221233330010050040030023232323333573466e1cd55cea80124000466442466002006004602a6ae854008cd4034050d5d09aba2500223263201933573803403202e26aae7940044dd50009aba150043335500875ca00e6ae85400cc8c8c8cccd5cd19b875001480108c84888c008010d5d09aab9e500323333573466e1d4009200223212223001004375c6ae84d55cf280211999ab9a3370ea00690001091100191931900d99ab9c01c01b019018017135573aa00226ea8004d5d0a80119a804bae357426ae8940088c98c8054cd5ce00b00a80989aba25001135744a00226aae7940044dd5000899aa800bae75a224464460046eac004c8004d5406088c8cccd55cf8011280d119a80c9991091980080180118031aab9d5002300535573ca00460086ae8800c0484d5d080089119191999ab9a3370ea002900011a80398029aba135573ca00646666ae68cdc3a801240044a00e464c6402466ae7004c04804003c4d55cea80089baa0011212230020031122001232323333573466e1d400520062321222230040053007357426aae79400c8cccd5cd19b875002480108c848888c008014c024d5d09aab9e500423333573466e1d400d20022321222230010053007357426aae7940148cccd5cd19b875004480008c848888c00c014dd71aba135573ca00c464c6402066ae7004404003803403002c4d55cea80089baa001232323333573466e1cd55cea80124000466442466002006004600a6ae854008dd69aba135744a004464c6401866ae700340300284d55cf280089baa0012323333573466e1cd55cea800a400046eb8d5d09aab9e500223263200a33573801601401026ea80048c8c8c8c8c8cccd5cd19b8750014803084888888800c8cccd5cd19b875002480288488888880108cccd5cd19b875003480208cc8848888888cc004024020dd71aba15005375a6ae84d5d1280291999ab9a3370ea00890031199109111111198010048041bae35742a00e6eb8d5d09aba2500723333573466e1d40152004233221222222233006009008300c35742a0126eb8d5d09aba2500923333573466e1d40192002232122222223007008300d357426aae79402c8cccd5cd19b875007480008c848888888c014020c038d5d09aab9e500c23263201333573802802602202001e01c01a01801626aae7540104d55cf280189aab9e5002135573ca00226ea80048c8c8c8c8cccd5cd19b875001480088ccc888488ccc00401401000cdd69aba15004375a6ae85400cdd69aba135744a00646666ae68cdc3a80124000464244600400660106ae84d55cf280311931900619ab9c00d00c00a009135573aa00626ae8940044d55cf280089baa001232323333573466e1d400520022321223001003375c6ae84d55cf280191999ab9a3370ea004900011909118010019bae357426aae7940108c98c8024cd5ce00500480380309aab9d50011375400224464646666ae68cdc3a800a40084244400246666ae68cdc3a8012400446424446006008600c6ae84d55cf280211999ab9a3370ea00690001091100111931900519ab9c00b00a008007006135573aa00226ea80048c8cccd5cd19b8750014800880248cccd5cd19b8750024800080248c98c8018cd5ce00380300200189aab9d37540029309000a481035054310022333573466e3c00800401000c488008488004c8004d5401088448894cd40044d400c88004884ccd401488008c010008ccd54c01c480040140100044488008488488cc00401000c444888c00cc008004448c8c00400488cc00cc0080080053012bd8799fd8799f58203af0570cd555abee485f9597fe8aa7440a5e27bcc6f4d39b13ec9a8d55d56c97ff00ff0001',
          language: 'plutus:v2'
        },
        b413bc466dadcb6bcf93e840a9eedabe04e83aa9d55f9deeb94d9743: {
          cbor: '590c7b01000033232323232323232323233223233223232323232323322323232323232323232323232323232323232323232323232323232323355501722232325335330053333573466e1cd55ce9baa0044800080c88c98c80c8cd5ce00c8190181999ab9a3370e6aae7540092000233221233001003002323232323232323232323232323333573466e1cd55cea8062400046666666666664444444444442466666666666600201a01801601401201000e00c00a00800600466a0320346ae854030cd4064068d5d0a80599a80c80d9aba1500a3335501d75ca0386ae854024ccd54075d7280e1aba1500833501902235742a00e666aa03a046eb4d5d0a8031919191999ab9a3370e6aae75400920002332212330010030023232323333573466e1cd55cea8012400046644246600200600466a05aeb4d5d0a80118171aba135744a004464c6409066ae700bc1201184d55cf280089baa00135742a0046464646666ae68cdc39aab9d5002480008cc8848cc00400c008cd40b5d69aba15002302e357426ae8940088c98c8120cd5ce01782402309aab9e5001137540026ae84d5d1280111931902219ab9c02b044042135573ca00226ea8004d5d0a80299a80cbae35742a008666aa03a03e40026ae85400cccd54075d710009aba150023021357426ae8940088c98c8100cd5ce01382001f09aba25001135744a00226ae8940044d5d1280089aba25001135744a00226ae8940044d5d1280089aba25001135744a00226aae7940044dd50009aba150023011357426ae8940088c98c80c8cd5ce00c819018081889a817a4810350543500135573ca00226ea8004cd55405c888c8c8c94cd4c008c8d4004888888888888031400454cd4cd540a0cd5406809cd401888004cd540a08004c025400454cd54cd4cd540a0cd5407009d400cc8004c0254004854cd4ccc88cd54008c8cd409088ccd400c88008008004d40048800448cc004894cd4008400440c40c0004c08048004cd5540788cc0a000520022350012200100113355301c12001235001220020011302e4984c0b5261302a4988854cd400454cd4cc0a4008c8d400488008c848cc0040f0008cdc5a41fc0666e2940d540d44cd540a894cd400440bc4cd5ce249256572726f7220276d6b44734b6579506f6c6963792720696c6c6567616c206f7574707574730002e5335323335530221200133502322533500221003100150262533533320015025300c001300e302200a13502800115027001323500122222222222200a500321335502b335501d02a5006335502b2001300a001102d1302c498884c0b926130294988854cd400440b8884c0b52613500322002320013550372253350011502f2322321533533320015025300c5003300e302200a15335335502c335502002b500732001300b500321533500113002498884d400888cd40dc008c02c01c4c00526130014988c0180084d4004880044d400488cccd40048c98c80c8cd5ce2481024c680003220012326320323357389201024c68000322326320323357389201024c6800032232323333573466e1cd55cea801240004664424660020060046eb8d5d0a8011bae357426ae8940088c98c80c0cd5ce00b81801709aab9e50011375400246a002444400646a002444400846a0024444444444440104660326038002a0342464460046eb0004c8004d540bc88cccd55cf80092814119a81398021aba1002300335744004054464646666ae68cdc39aab9d5002480008cc8848cc00400c008c028d5d0a80118029aba135744a004464c6405466ae700440a80a04d55cf280089baa0012323232323333573466e1cd55cea8022400046666444424666600200a0080060046464646666ae68cdc39aab9d5002480008cc07cc04cd5d0a80119a8068091aba135744a004464c6405e66ae700580bc0b44d55cf280089baa00135742a008666aa010eb9401cd5d0a8019919191999ab9a3370ea0029002119091118010021aba135573ca00646666ae68cdc3a80124004464244460020086eb8d5d09aab9e500423333573466e1d400d20002122200323263203133573803006205e05c05a26aae7540044dd50009aba1500233500975c6ae84d5d1280111931901599ab9c01202b029135744a00226ae8940044d55cf280089baa0011335500175ceb44488c88c008dd5800990009aa81611191999aab9f00225026233502533221233001003002300635573aa004600a6aae794008c010d5d100181409aba100112232323333573466e1d400520002350193005357426aae79400c8cccd5cd19b87500248008940648c98c80a0cd5ce00781401301289aab9d500113754002464646666ae68cdc3a800a400c46424444600800a600e6ae84d55cf280191999ab9a3370ea004900211909111180100298049aba135573ca00846666ae68cdc3a801a400446424444600200a600e6ae84d55cf280291999ab9a3370ea00890001190911118018029bae357426aae7940188c98c80a0cd5ce00781401301281201189aab9d500113754002464646666ae68cdc39aab9d5002480008cc8848cc00400c008c014d5d0a8011bad357426ae8940088c98c8090cd5ce00581201109aab9e5001137540024646666ae68cdc39aab9d5001480008dd71aba135573ca004464c6404466ae700240880804dd5000919191919191999ab9a3370ea002900610911111100191999ab9a3370ea004900510911111100211999ab9a3370ea00690041199109111111198008048041bae35742a00a6eb4d5d09aba2500523333573466e1d40112006233221222222233002009008375c6ae85401cdd71aba135744a00e46666ae68cdc3a802a400846644244444446600c01201060186ae854024dd71aba135744a01246666ae68cdc3a8032400446424444444600e010601a6ae84d55cf280591999ab9a3370ea00e900011909111111180280418071aba135573ca018464c6405666ae700480ac0a40a009c09809409008c4d55cea80209aab9e5003135573ca00426aae7940044dd50009191919191999ab9a3370ea002900111999110911998008028020019bad35742a0086eb4d5d0a8019bad357426ae89400c8cccd5cd19b875002480008c8488c00800cc020d5d09aab9e500623263202433573801604804404226aae75400c4d5d1280089aab9e500113754002464646666ae68cdc3a800a4004460266eb8d5d09aab9e500323333573466e1d400920002321223002003375c6ae84d55cf280211931901099ab9c00802101f01e135573aa00226ea8004488c8c8cccd5cd19b87500148010848880048cccd5cd19b875002480088c84888c00c010c018d5d09aab9e500423333573466e1d400d20002122200223263202233573801204404003e03c26aae7540044dd50009191999ab9a3370ea0029001100b91999ab9a3370ea0049000100b91931900f19ab9c00501e01c01b135573a6ea800524010350543100112232230020013200135502122533500110152213500222533533008002007101a130060033200135501e22112253350011501822133501930040023355300612001004001112232230020013200135501f2253350011500b22135002225335330080020071350100011300600311122230033002001235001220023200135501a221122253350011350032200122133350052200230040023335530071200100500400112212330010030021223500222350032232335005233500425335333573466e3c00800405004c5400c404c804c8cd4010804c94cd4ccd5cd19b8f002001014013150031013153350032153350022133500223350022335002233500223301200200120162335002201623301200200122201622233500420162225335333573466e1c01800c06406054cd4ccd5cd19b870050020190181330130040011018101810111533500121011101122123300100300212122300200311220012122300100322333573466e1c00800402001c88ccd5cd19b8f0020010070061122300200123500849012f6572726f7220276d6b44734b6579506f6c696379272062616420696e7075747320696e207472616e73616374696f6e002350074901266572726f7220276d6b44734b6579506f6c696379272062616420696e697469616c206d696e74001220021220012350044901286572726f7220276d6b44734b6579506f6c696379273a20626164206d696e74656420746f6b656e730011220021221223300100400312326320033357380020069309000899b8a50015001133714a002a002266e29400540044cdc52800a800899b8b483f80c005220100112323001001223300330020020014c140d8799f581c4aa93779bf0953b3d43adfa530fa090f928bc06541b8be5b039221d9581c1cf569e1ec3e0fee92f1f5002bfd4213b796c151c708db46e6e2d3a4ff0001',
          language: 'plutus:v2'
        }
      },
      signatories: [
        {
          key: '096092b8515d75c2a2f75d6aa7c5191996755840e81deaa403dba5b690f091b6',
          signature:
            '6df908dc905c533ee2f8997675a3907a7ad36022e45f32a79d5834e0342ec850161eee69cfe58314f2735d97d5f298acf59692bedf31fef7a2a3cadfe1f70a0d'
        }
      ],
      spends: 'inputs',
      totalCollateral: {
        lovelace: 5_000_000n
      },
      validityInterval: {}
    }
  ],
  type: 'praos'
};
