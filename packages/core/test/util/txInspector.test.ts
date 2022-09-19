import * as AssetIds from '../AssetId';
import {
  Address,
  AssetFingerprint,
  AssetId,
  AssetName,
  BlockId,
  Certificate,
  CertificateType,
  Ed25519KeyHash,
  Ed25519PublicKey,
  Ed25519Signature,
  NativeScriptKind,
  PolicyId,
  PoolId,
  RewardAccount,
  ScriptType,
  StakeAddressCertificate,
  StakeDelegationCertificate,
  TokenMap,
  TransactionId,
  TxAlonzo,
  TxIn,
  TxOut,
  Withdrawal,
  Witness,
  util
} from '../../src/Cardano';
import {
  assetsBurnedInspector,
  assetsMintedInspector,
  createTxInspector,
  delegationInspector,
  metadataInspector,
  sentInspector,
  signedCertificatesInspector,
  stakeKeyDeregistrationInspector,
  stakeKeyRegistrationInspector,
  totalAddressInputsValueInspector,
  totalAddressOutputsValueInspector,
  valueReceivedInspector,
  valueSentInspector,
  withdrawalInspector
} from '../../src';

// eslint-disable-next-line max-statements
describe('txInspector', () => {
  const sendingAddress = Address(
    'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
  );
  const receivingAddress = Address(
    'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
  );
  const rewardAccount = RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d');
  const stakeKeyHash = Ed25519KeyHash.fromRewardAccount(rewardAccount);
  const poolId = PoolId('pool1euf2nh92ehqfw7rpd4s9qgq34z8dg4pvfqhjmhggmzk95gcd402');
  const delegationCert: StakeDelegationCertificate = {
    __typename: CertificateType.StakeDelegation,
    poolId,
    stakeKeyHash
  };
  const keyRegistrationCert: StakeAddressCertificate = {
    __typename: CertificateType.StakeKeyRegistration,
    stakeKeyHash
  };
  const keyDeregistrationCert: StakeAddressCertificate = {
    __typename: CertificateType.StakeKeyDeregistration,
    stakeKeyHash
  };
  const withdrawals: Withdrawal[] = [
    {
      quantity: 2_000_000n,
      stakeAddress: RewardAccount('stake_test1upqykkjq3zhf4085s6n70w8cyp57dl87r0ezduv9rnnj2uqk5zmdv')
    },
    {
      quantity: 7_000_000n,
      stakeAddress: RewardAccount('stake_test1upqykkjq3zhf4085s6n70w8cyp57dl87r0ezduv9rnnj2uqk5zmdv')
    }
  ];

  const historicalTxs: TxAlonzo[] = [
    {
      body: {
        outputs: [
          {
            value: {
              assets: new Map([[AssetIds.TSLA, 5n]]),
              coins: 4_500_000n
            }
          },
          {
            value: {
              assets: new Map([[AssetIds.PXL, 15n]]),
              coins: 5_000_000n
            }
          },
          {
            value: {
              assets: new Map([[AssetIds.TSLA, 25n]]),
              coins: 2_000_000n
            }
          }
        ]
      },
      id: TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
    } as unknown as TxAlonzo
  ];

  const mockPolicy1 = 'b8fdbcbe003cef7e47eb5307d328e10191952bd02901a850699e7e35';
  const mockPolicy2 = '5ba141e401cfebf1929d539e48d14f4b20679c5409526814e0f17121';
  const mockPolicy3 = '00000000000000000000000000000000000000000000000000000000';

  const mockTokenName1 = '00000000000000';
  const mockTokenName2 = 'ffffffffffffff';
  const mockTokenName3 = 'aaaaaaaaaaaaaa';

  const txMetadatum = new Map([
    [
      721n,
      util.metadatum.jsonToMetadatum({
        b8fdbcbe003cef7e47eb5307d328e10191952bd02901a850699e7e35: {
          'NFT-001': {
            image: ['ipfs://some_hash1'],
            name: 'One',
            version: '1.0'
          }
        }
      })
    ]
  ]);

  const mockScript1 = {
    __type: ScriptType.Native,
    kind: NativeScriptKind.RequireAllOf,
    scripts: [
      {
        __type: ScriptType.Native,
        keyHash: Ed25519KeyHash('24accb6ca2690388f067175d773871f5640de57bf11aec0be258d6c7'),
        kind: NativeScriptKind.RequireSignature
      }
    ]
  };

  const mockScript2 = {
    __type: ScriptType.Native,
    kind: NativeScriptKind.RequireAllOf,
    scripts: [
      {
        __type: ScriptType.Native,
        keyHash: Ed25519KeyHash('00accb6ca2690388f067175d773871f5640de57bf11aec0be258d6c7'),
        kind: NativeScriptKind.RequireSignature
      }
    ]
  };

  const auxiliaryData = {
    body: {
      blob: txMetadatum,
      scripts: [mockScript2]
    }
  };

  const buildMockTx = (
    args: {
      inputs?: TxIn[];
      outputs?: TxOut[];
      certificates?: Certificate[];
      withdrawals?: Withdrawal[];
      mint?: TokenMap;
      witness?: Witness;
      includeAuxData?: boolean;
    } = {}
  ): TxAlonzo =>
    ({
      auxiliaryData: args.includeAuxData ? auxiliaryData : undefined,
      blockHeader: {
        blockNo: 200,
        hash: BlockId('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed'),
        slot: 1000
      },
      body: {
        certificates: args.certificates,
        fee: 170_000n,
        inputs: args.inputs ?? [
          {
            address: sendingAddress,
            index: 0,
            txId: TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          }
        ],
        mint:
          args.mint ??
          new Map([
            [AssetId('b8fdbcbe003cef7e47eb5307d328e10191952bd02901a850699e7e3500000000000000'), 1n],
            [AssetId('5ba141e401cfebf1929d539e48d14f4b20679c5409526814e0f17121ffffffffffffff'), 100_000n],
            [AssetId('00000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaa'), -1n]
          ]),

        outputs: args.outputs ?? [
          {
            address: receivingAddress,
            value: { coins: 5_000_000n }
          },
          {
            address: receivingAddress,
            value: {
              assets: new Map([
                [AssetIds.PXL, 3n],
                [AssetIds.TSLA, 4n]
              ]),
              coins: 2_000_000n
            }
          },
          {
            address: receivingAddress,
            value: {
              assets: new Map([[AssetIds.PXL, 6n]]),
              coins: 2_000_000n
            }
          },
          {
            address: sendingAddress,
            value: {
              assets: new Map([[AssetIds.PXL, 1n]]),
              coins: 2_000_000n
            }
          }
        ],
        validityInterval: {},
        withdrawals: args.withdrawals
      },
      id: TransactionId('e3a443363eb6ee3d67c5e75ec10b931603787581a948d68fa3b2cd3ff2e0d2ad'),
      index: 0,
      witness: args.witness ?? { scripts: [mockScript1], signatures: new Map<Ed25519PublicKey, Ed25519Signature>() }
    } as TxAlonzo);

  describe('transaction sent inspector', () => {
    test('a transaction with inputs with provided addresses produces an inspection containing those inputs', () => {
      const tx = buildMockTx();
      const inspectTx = createTxInspector({
        sent: sentInspector({ addresses: [sendingAddress] })
      });
      const txProperties = inspectTx(tx);

      expect(txProperties.sent.inputs).toEqual(tx.body.inputs);
      expect(txProperties.sent.certificates).toEqual([]);
    });

    test(
      'a transaction with certificates including the reward account' +
        ' produces an inspection containing those certificates',
      () => {
        const tx = buildMockTx({ certificates: [delegationCert, keyRegistrationCert] });
        const inspectTx = createTxInspector({
          sent: sentInspector({ rewardAccounts: [rewardAccount] })
        });
        const txProperties = inspectTx(tx);

        expect(txProperties.sent.inputs).toEqual([]);
        expect(txProperties.sent.certificates).toEqual([delegationCert, keyRegistrationCert]);
      }
    );

    test(
      'a transaction with certificates including the reward account' +
        ' and inputs containing provided addresses' +
        ' produces an inspection containing those certificates and inputs',
      () => {
        const tx = buildMockTx({ certificates: [delegationCert, keyRegistrationCert] });
        const inspectTx = createTxInspector({
          sent: sentInspector({ addresses: [sendingAddress], rewardAccounts: [rewardAccount] })
        });
        const txProperties = inspectTx(tx);

        expect(txProperties.sent.inputs).toEqual(tx.body.inputs);
        expect(txProperties.sent.certificates).toEqual([delegationCert, keyRegistrationCert]);
      }
    );
  });

  describe('total address inputs and outputs value inspector', () => {
    test('adds total input and outputs values for an address', () => {
      const tx = buildMockTx({
        inputs: [
          {
            address: sendingAddress,
            index: 0,
            txId: TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          },
          {
            address: sendingAddress,
            index: 1,
            txId: TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          },
          {
            address: receivingAddress,
            index: 2,
            txId: TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          }
        ]
      });
      const inspectTx = createTxInspector({
        totalInputsValue: totalAddressInputsValueInspector([sendingAddress], () => historicalTxs),
        totalOutputsValue: totalAddressOutputsValueInspector([receivingAddress])
      });
      const txProperties = inspectTx(tx);
      expect(txProperties.totalInputsValue).toEqual({
        assets: new Map([
          [AssetIds.TSLA, 5n],
          [AssetIds.PXL, 15n]
        ]),
        coins: 9_500_000n
      });
      expect(txProperties.totalOutputsValue).toEqual({
        assets: new Map([
          [AssetIds.TSLA, 4n],
          [AssetIds.PXL, 9n]
        ]),
        coins: 9_000_000n
      });
    });
  });

  describe('value sent and received inspectors', () => {
    test('a transaction produces an inspection containing total net value sent and received', () => {
      const tx = buildMockTx({
        inputs: [
          {
            address: sendingAddress,
            index: 0,
            txId: TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          },
          {
            address: sendingAddress,
            index: 1,
            txId: TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          },
          {
            address: receivingAddress,
            index: 2,
            txId: TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          }
        ]
      });

      const inspectTx = createTxInspector({
        valueReceived: valueReceivedInspector([receivingAddress], () => historicalTxs),
        valueSent: valueSentInspector([sendingAddress], () => historicalTxs)
      });
      const txProperties = inspectTx(tx);

      expect(txProperties.valueSent).toEqual({
        assets: new Map([
          [AssetIds.TSLA, 5n],
          [AssetIds.PXL, 14n]
        ]),
        coins: 7_500_000n
      });
      expect(txProperties.valueReceived).toEqual({
        assets: new Map([[AssetIds.PXL, 9n]]),
        coins: 7_000_000n
      });
    });
  });

  describe('delegation inspector', () => {
    test(
      'a transaction containing delegations produces an inspection ' +
        'containing an array with the key hashes and pool ids',
      () => {
        const tx = buildMockTx({ certificates: [delegationCert] });
        const inspectTx = createTxInspector({ delegation: delegationInspector });
        const txProperties = inspectTx(tx);

        expect(txProperties.delegation[0].stakeKeyHash).toEqual(delegationCert.stakeKeyHash);
        expect(txProperties.delegation[0].poolId).toEqual(delegationCert.poolId);
      }
    );

    test('a transaction with no delegations produces an inspection containing an empty array', () => {
      const tx = buildMockTx({ certificates: [] });
      const inspectTx = createTxInspector({ delegation: delegationInspector });
      const txProperties = inspectTx(tx);

      expect(txProperties.delegation).toEqual([]);
    });
  });

  describe('stake key registration inspector', () => {
    test(
      'a transaction containing stake key registrations produces an inspection ' +
        'containing an array with the key hashes',
      () => {
        const tx = buildMockTx({ certificates: [keyRegistrationCert] });
        const inspectTx = createTxInspector({
          stakeKeyRegistration: stakeKeyRegistrationInspector
        });

        const txProperties = inspectTx(tx);

        expect(txProperties.stakeKeyRegistration[0].stakeKeyHash).toEqual(keyRegistrationCert.stakeKeyHash);
      }
    );

    test('a transaction with no stake key registrations produces an inspection containing an empty array', () => {
      const tx = buildMockTx({ certificates: [] });
      const inspectTx = createTxInspector({
        stakeKeyRegistration: stakeKeyRegistrationInspector
      });
      const txProperties = inspectTx(tx);

      expect(txProperties.stakeKeyRegistration).toEqual([]);
    });
  });

  describe('stake key deregistration inspector', () => {
    test(
      'a transaction containing stake key deregistrations produces an inspection ' +
        'containing an array with the key hashes',
      () => {
        const tx = buildMockTx({
          certificates: [keyDeregistrationCert]
        });
        const inspectTx = createTxInspector({
          stakeKeyDeregistration: stakeKeyDeregistrationInspector
        });
        const txProperties = inspectTx(tx);
        expect(txProperties.stakeKeyDeregistration[0].stakeKeyHash).toEqual(keyDeregistrationCert.stakeKeyHash);
      }
    );

    test('a transaction with no stake key deregistrations produces an inspection containing an empty array', () => {
      const tx = buildMockTx({ certificates: [] });
      const inspectTx = createTxInspector({
        stakeKeyDeregistration: stakeKeyDeregistrationInspector
      });
      const txProperties = inspectTx(tx);

      expect(txProperties.stakeKeyDeregistration).toEqual([]);
    });
  });

  describe('withdrawal inspector', () => {
    test('a transaction containing withdrawals produces an inspection containing the accumulated withdrawals', () => {
      const tx = buildMockTx({ withdrawals });
      const inspectTx = createTxInspector({ totalWithdrawals: withdrawalInspector });
      const txProperties = inspectTx(tx);
      expect(txProperties.totalWithdrawals).toEqual(9_000_000n);
    });

    test('a transaction with no withdrawals produces an inspection with total withdrawals equal to 0', () => {
      const tx = buildMockTx({ withdrawals: [] });
      const inspectTx = createTxInspector({ totalWithdrawals: withdrawalInspector });
      const txProperties = inspectTx(tx);
      expect(txProperties.totalWithdrawals).toEqual(0n);
    });
  });

  describe('certificates signed inspector', () => {
    test(
      'a transaction with certificates signed with any of the provided reward accounts' +
        ' produces an inspection containing those certificates',
      () => {
        const tx = buildMockTx({ certificates: [delegationCert, keyRegistrationCert] });
        const inspectTx = createTxInspector({ signedCertificates: signedCertificatesInspector([rewardAccount]) });
        const txProperties = inspectTx(tx);
        expect(txProperties.signedCertificates).toEqual([delegationCert, keyRegistrationCert]);
      }
    );

    test(
      'a transaction with some certificates signed with any of the provided reward accounts' +
        ' and some signed with other produces an inspection containing only the former',
      () => {
        const otherCert = { ...delegationCert, stakeKeyHash: '' as unknown as Ed25519KeyHash };
        const tx = buildMockTx({ certificates: [delegationCert, otherCert] });
        const inspectTx = createTxInspector({ signedCertificates: signedCertificatesInspector([rewardAccount]) });
        const txProperties = inspectTx(tx);
        expect(txProperties.signedCertificates).toEqual([delegationCert]);
      }
    );

    test(
      'a transaction with certificates signed with any of the provided reward accounts' +
        ' produces an inspection containing only the certificates of the provided types',
      () => {
        const tx = buildMockTx({ certificates: [delegationCert, keyRegistrationCert] });
        const inspectTx = createTxInspector({
          signedCertificates: signedCertificatesInspector([rewardAccount], [CertificateType.StakeKeyRegistration])
        });
        const txProperties = inspectTx(tx);
        expect(txProperties.signedCertificates).toEqual([keyRegistrationCert]);
      }
    );
  });

  describe('mint and burn transaction inspector', () => {
    test('inspects a transaction that mints and burns tokens and can retrieve the minting details', () => {
      const tx = buildMockTx({ includeAuxData: true });
      const inspectTx = createTxInspector({ burned: assetsBurnedInspector, minted: assetsMintedInspector });
      const { minted, burned } = inspectTx(tx);

      expect(minted.length).toEqual(2);
      expect(burned.length).toEqual(1);
      expect(minted[0].assetName).toEqual(mockTokenName1);
      expect(minted[0].policyId).toEqual(mockPolicy1);
      expect(minted[0].fingerprint).toEqual(
        AssetFingerprint.fromParts(PolicyId(mockPolicy1), AssetName(mockTokenName1))
      );
      expect(minted[0].quantity).toEqual(1n);
      expect(minted[0].script).toEqual(mockScript1);

      expect(minted[1].assetName).toEqual(mockTokenName2);
      expect(minted[1].policyId).toEqual(mockPolicy2);
      expect(minted[1].fingerprint).toEqual(
        AssetFingerprint.fromParts(PolicyId(mockPolicy2), AssetName(mockTokenName2))
      );
      expect(minted[1].quantity).toEqual(100_000n);
      expect(minted[1].script).toEqual(mockScript2);

      expect(burned[0].assetName).toEqual(mockTokenName3);
      expect(burned[0].policyId).toEqual(mockPolicy3);
      expect(burned[0].fingerprint).toEqual(
        AssetFingerprint.fromParts(PolicyId(mockPolicy3), AssetName(mockTokenName3))
      );
      expect(burned[0].quantity).toEqual(-1n);
      expect(burned[0].script).toBeUndefined();
    });
  });

  describe('metadata inspector', () => {
    it('inspects a transaction with metadata and produces an inspection with the metadatum', () => {
      const tx = buildMockTx();
      const inspectTx = createTxInspector({ metadata: metadataInspector });
      const { metadata } = inspectTx(tx);

      expect(metadata).toEqual(txMetadatum);
    });
  });
});
