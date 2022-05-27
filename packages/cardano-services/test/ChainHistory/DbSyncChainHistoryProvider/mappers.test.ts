import * as mappers from '../../../src/ChainHistory/DbSyncChainHistory/mappers';
import { AssetId } from '@cardano-sdk/util-dev';
import {
  BlockModel,
  BlockOutputModel,
  CertificateModel,
  DelegationCertModel,
  MirCertModel,
  MultiAssetModel,
  PoolRegisterCertModel,
  PoolRetireCertModel,
  ProtocolParamsModel,
  RedeemerModel,
  StakeCertModel,
  TipModel,
  TxInOutModel,
  TxMetadataModel,
  TxModel,
  TxOutMultiAssetModel,
  TxOutTokenMap,
  TxOutputModel,
  TxTokenMap,
  WithCertIndex,
  WithCertType,
  WithdrawalModel
} from '../../../src/ChainHistory/DbSyncChainHistory/types';
import { Cardano } from '@cardano-sdk/core';

const blockHash = '7a48b034645f51743550bbaf81f8a14771e58856e031eb63844738ca8ad72298';
const poolId = 'pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh';
const datetime = '2022-05-10T19:22:43.620Z';
const vrfKey = 'vrf_vk19j362pkr4t9y0m3qxgmrv0365vd7c4ze03ny4jh84q8agjy4ep4s99zvg8';
const genesisLeaderHash = 'eff1b5b26e65b791d6f236c7c0264012bd1696759d22bdb4dd0f6f56';
const transactionHash = 'cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819';
const hash28ByteBase16 = '8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d';
const hash32ByteBase16 = '3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d';
const address = 'addr_test1wphyve8r76kvfr5yn6k0fcmq0mn2uf6c6mvtsrafmr7awcg0vnzpg';
const stakeAddress = 'stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d';
const assetName = '6e7574636f696e';
const policyId = 'b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a7';
const fingerprint = 'asset1pkpwyknlvul7az0xx8czhl60pyel45rpje4z8w';

const baseCertModel: CertificateModel = {
  cert_index: 0,
  tx_id: Buffer.from(transactionHash, 'hex')
};
const txInModel: TxInOutModel = {
  address,
  coin_value: '20000000',
  id: '1',
  index: 1,
  tx_id: Buffer.from(transactionHash, 'hex')
};
const txOutModel: TxInOutModel = {
  ...txInModel,
  datum: Buffer.from(hash32ByteBase16, 'hex')
};
const assets: Cardano.TokenMap = new Map([
  [AssetId.TSLA, 500n],
  [AssetId.PXL, 500n]
]);
const multiAssetModel: MultiAssetModel = {
  asset_name: Buffer.from(assetName, 'hex'),
  fingerprint,
  policy_id: Buffer.from(policyId, 'hex'),
  quantity: '12000',
  tx_id: Buffer.from(transactionHash, 'hex')
};
const txOutMaModel: TxOutMultiAssetModel = {
  ...multiAssetModel,
  tx_out_id: '1'
};
const withdrawalModel: WithdrawalModel = {
  quantity: '20000000',
  stake_address: stakeAddress,
  tx_id: Buffer.from(transactionHash, 'hex')
};
const txMetadataModel: TxMetadataModel[] = [
  {
    json_value: { v: 1 },
    key: '127',
    tx_id: Buffer.from(transactionHash, 'hex')
  },
  {
    json_value: { a: 2 },
    key: '500',
    tx_id: Buffer.from(transactionHash, 'hex')
  }
];

const txModel: TxModel = {
  block_hash: Buffer.from(blockHash, 'hex'),
  block_no: 200,
  block_slot_no: 250,
  fee: '170000',
  id: Buffer.from(transactionHash, 'hex'),
  index: 1,
  invalid_before: '300',
  invalid_hereafter: '500',
  size: 20
};

describe('chain history mappers', () => {
  describe('mapBlock', () => {
    const blockModel: BlockModel = {
      block_no: 200,
      epoch_no: 12,
      epoch_slot_no: 202,
      hash: Buffer.from(blockHash, 'hex'),
      next_block: Buffer.from(blockHash, 'hex'),
      previous_block: Buffer.from(blockHash, 'hex'),
      size: 50,
      slot_leader_hash: Buffer.from(genesisLeaderHash, 'hex'),
      slot_leader_pool: poolId,
      slot_no: 100,
      time: datetime,
      tx_count: '3000',
      vrf: vrfKey
    };
    const blockOutputModel: BlockOutputModel = {
      fees: '170000',
      hash: Buffer.from(blockHash, 'hex'),
      output: '100000000'
    };
    const tipModel: TipModel = {
      block_no: 300,
      hash: Buffer.from(blockHash, 'hex'),
      slot_no: 400
    };
    test('map BlockModel to Cardano.Block', () => {
      const result = mappers.mapBlock(blockModel, blockOutputModel, tipModel);
      expect(result).toEqual<Cardano.Block>({
        confirmations: 100,
        date: new Date(datetime),
        epoch: 12,
        epochSlot: 202,
        fees: 170_000n,
        header: {
          blockNo: 200,
          hash: Cardano.BlockId(blockHash),
          slot: 100
        },
        nextBlock: Cardano.BlockId(blockHash),
        previousBlock: Cardano.BlockId(blockHash),
        size: 50,
        slotLeader: Cardano.SlotLeader(poolId),
        totalOutput: 100_000_000n,
        txCount: 3000,
        vrf: Cardano.VrfVkBech32(vrfKey)
      });
    });
    test('map BlockModel with nulls to Cardano.Block', () => {
      const result = mappers.mapBlock(
        { ...blockModel, next_block: null, previous_block: null, slot_leader_pool: null },
        blockOutputModel,
        tipModel
      );
      expect(result).toEqual<Cardano.Block>({
        confirmations: 100,
        date: new Date(datetime),
        epoch: 12,
        epochSlot: 202,
        fees: 170_000n,
        header: {
          blockNo: 200,
          hash: Cardano.BlockId(blockHash),
          slot: 100
        },
        size: 50,
        slotLeader: Cardano.SlotLeader(genesisLeaderHash),
        totalOutput: 100_000_000n,
        txCount: 3000,
        vrf: Cardano.VrfVkBech32(vrfKey)
      });
    });
  });
  describe('mapCertificate', () => {
    test('map PoolRetireCertModel to Cardano.PoolRetirementCertificate', () => {
      const result = mappers.mapCertificate({
        ...baseCertModel,
        pool_id: poolId,
        retiring_epoch: 1,
        type: 'retire'
      } as WithCertType<PoolRetireCertModel>);
      expect(result).toEqual<WithCertIndex<Cardano.PoolRetirementCertificate>>({
        __typename: Cardano.CertificateType.PoolRetirement,
        cert_index: 0,
        epoch: 1,
        poolId: Cardano.PoolId(poolId)
      });
    });
    test('map PoolUpdateCertModel to Cardano.PoolRegistrationCertificate', () => {
      const result = mappers.mapCertificate({
        ...baseCertModel,
        pool_id: poolId,
        type: 'register'
      } as WithCertType<PoolRegisterCertModel>);
      expect(result).toEqual<WithCertIndex<Cardano.PoolRegistrationCertificate>>({
        __typename: Cardano.CertificateType.PoolRegistration,
        cert_index: 0,
        poolParameters: null as unknown as Cardano.PoolParameters
      });
    });
    test('map MirCertModel to Cardano.MirCertificate', () => {
      const mirCert: WithCertType<MirCertModel> = {
        ...baseCertModel,
        address: stakeAddress,
        amount: '500000',
        pot: 'reserve',
        type: 'mir'
      };
      const reservePotResult = mappers.mapCertificate(mirCert);
      const treasuryPotResult = mappers.mapCertificate({ ...mirCert, pot: 'treasury' } as WithCertType<MirCertModel>);
      expect(reservePotResult).toEqual<WithCertIndex<Cardano.MirCertificate>>({
        __typename: Cardano.CertificateType.MIR,
        cert_index: 0,
        pot: Cardano.MirCertificatePot.Reserves,
        quantity: 500_000n,
        rewardAccount: Cardano.RewardAccount(stakeAddress)
      });
      expect(treasuryPotResult).toEqual<WithCertIndex<Cardano.MirCertificate>>({
        __typename: Cardano.CertificateType.MIR,
        cert_index: 0,
        pot: Cardano.MirCertificatePot.Treasury,
        quantity: 500_000n,
        rewardAccount: Cardano.RewardAccount(stakeAddress)
      });
    });
    test('map StakeCertModel to Cardano.StakeAddressCertificate', () => {
      const stakeCert: WithCertType<StakeCertModel> = {
        ...baseCertModel,
        address: stakeAddress,
        registration: true,
        type: 'stake'
      };
      const registrationResult = mappers.mapCertificate(stakeCert);
      const deregistrationResult = mappers.mapCertificate({
        ...stakeCert,
        registration: false
      } as WithCertType<StakeCertModel>);
      expect(registrationResult).toEqual<WithCertIndex<Cardano.StakeAddressCertificate>>({
        __typename: Cardano.CertificateType.StakeKeyRegistration,
        cert_index: 0,
        stakeKeyHash: Cardano.Ed25519KeyHash.fromRewardAccount(Cardano.RewardAccount(stakeAddress))
      });
      expect(deregistrationResult).toEqual<WithCertIndex<Cardano.StakeAddressCertificate>>({
        __typename: Cardano.CertificateType.StakeKeyDeregistration,
        cert_index: 0,
        stakeKeyHash: Cardano.Ed25519KeyHash.fromRewardAccount(Cardano.RewardAccount(stakeAddress))
      });
    });
    test('map DelegationCertModel to Cardano.StakeDelegationCertificate', () => {
      const result = mappers.mapCertificate({
        ...baseCertModel,
        address: stakeAddress,
        pool_id: poolId,
        type: 'delegation'
      } as WithCertType<DelegationCertModel>);
      expect(result).toEqual<WithCertIndex<Cardano.StakeDelegationCertificate>>({
        __typename: Cardano.CertificateType.StakeDelegation,
        cert_index: 0,
        poolId: Cardano.PoolId(poolId),
        stakeKeyHash: Cardano.Ed25519KeyHash.fromRewardAccount(Cardano.RewardAccount(stakeAddress))
      });
    });
  });
  describe('mapProtocolParams', () => {
    const protocolParams: ProtocolParamsModel = {
      coin_per_utxo_word: '91218',
      key_deposit: '20000000',
      max_collateral_inputs: 2,
      max_tx_size: 20,
      max_val_size: '40000000000',
      min_fee_coefficient: 23,
      min_fee_constant: 44,
      min_pool_cost: '500000',
      pool_deposit: '20000000',
      protocol_major: 2,
      protocol_minor: 1
    };
    test('map ProtocolParamsModel to Cardano.ProtocolParametersAlonzo', () => {
      const result = mappers.mapProtocolParams(protocolParams);
      expect(result).toEqual<Cardano.ProtocolParametersAlonzo>({
        coinsPerUtxoWord: 91_218,
        maxCollateralInputs: 2,
        maxTxSize: 20,
        maxValueSize: 40_000_000_000,
        minFeeCoefficient: 23,
        minFeeConstant: 44,
        minPoolCost: 500_000,
        poolDeposit: 20_000_000,
        protocolVersion: {
          major: 2,
          minor: 1
        },
        stakeKeyDeposit: 20_000_000
      });
    });
  });
  describe('mapRedeemer', () => {
    const redeemerModel: RedeemerModel = {
      index: 1,
      purpose: 'mint',
      script_hash: Buffer.from(hash28ByteBase16, 'hex'),
      tx_id: Buffer.from(transactionHash, 'hex'),
      unit_mem: '2000',
      unit_steps: '5000'
    };
    test('map RedeemerModel to Cardano.Redeemer', () => {
      const result = mappers.mapRedeemer(redeemerModel);
      expect(result).toEqual<Cardano.Redeemer>({
        executionUnits: {
          memory: 2000,
          steps: 5000
        },
        index: 1,
        purpose: Cardano.RedeemerPurpose.mint,
        scriptHash: Cardano.util.Hash28ByteBase16(hash28ByteBase16)
      });
    });
  });
  describe('mapTxAlonzo', () => {
    const inputs: Cardano.TxIn[] = [
      { address: Cardano.Address(address), index: 1, txId: Cardano.TransactionId(transactionHash) }
    ];
    const outputs: Cardano.TxOut[] = [{ address: Cardano.Address(address), value: { assets, coins: 20_000_000n } }];
    const protocolParams = {
      coinsPerUtxoWord: 91_218,
      maxCollateralInputs: 2,
      maxTxSize: 20,
      maxValueSize: 40_000_000_000,
      minFeeCoefficient: 23,
      minFeeConstant: 44,
      minPoolCost: 500_000,
      poolDeposit: 2_000_000,
      protocolVersion: { major: 2, minor: 1 },
      stakeKeyDeposit: 2_000_000
    };
    const redeemers: Cardano.Redeemer[] = [
      {
        executionUnits: { memory: 1, steps: 2 },
        index: 1,
        purpose: Cardano.RedeemerPurpose.spend,
        scriptHash: Cardano.util.Hash28ByteBase16(hash28ByteBase16)
      }
    ];
    const withdrawals: Cardano.Withdrawal[] = [{ quantity: 200n, stakeAddress: Cardano.RewardAccount(stakeAddress) }];
    const metadata: Cardano.TxMetadata = new Map([[1n, 'data']]);
    const certificates: Cardano.Certificate[] = [
      {
        __typename: Cardano.CertificateType.StakeKeyRegistration,
        stakeKeyHash: Cardano.Ed25519KeyHash.fromRewardAccount(Cardano.RewardAccount(stakeAddress))
      }
    ];

    const expected: Cardano.TxAlonzo = {
      blockHeader: { blockNo: 200, hash: Cardano.BlockId(blockHash), slot: 250 },
      body: { fee: 170_000n, inputs, outputs, validityInterval: { invalidBefore: 300, invalidHereafter: 500 } },
      id: Cardano.TransactionId(transactionHash),
      implicitCoin: { deposit: 0n, input: 0n },
      index: 1,
      txSize: 20,
      witness: { signatures: new Map() }
    };
    test('map TxModel to Cardano.TxAlonzo with minimal data', () => {
      const result = mappers.mapTxAlonzo(txModel, { inputs, outputs, protocolParams });
      expect(result).toEqual<Cardano.TxAlonzo>(expected);
    });
    test('map TxModel with null fields to Cardano.TxAlonzo', () => {
      const result = mappers.mapTxAlonzo(
        { ...txModel, invalid_before: null, invalid_hereafter: null },
        { inputs, outputs, protocolParams }
      );
      expect(result).toEqual<Cardano.TxAlonzo>({ ...expected, body: { ...expected.body, validityInterval: {} } });
    });
    test('map TxModel to Cardano.TxAlonzo with extra data', () => {
      const result = mappers.mapTxAlonzo(txModel, {
        certificates,
        collaterals: inputs,
        inputs,
        metadata,
        mint: assets,
        outputs,
        protocolParams,
        redeemers,
        withdrawals
      });
      expect(result).toEqual<Cardano.TxAlonzo>({
        ...expected,
        auxiliaryData: { body: { blob: metadata } },
        body: { ...expected.body, certificates, collaterals: inputs, mint: assets, withdrawals },
        implicitCoin: { deposit: 2_000_000n, input: 200n },
        witness: { ...expected.witness, redeemers }
      });
    });
  });
  describe('mapTxIn', () => {
    test('map TxInOutModel to Cardano.TxIn', () => {
      const result = mappers.mapTxIn(txInModel);
      expect(result).toEqual<Cardano.TxIn>({
        address: Cardano.Address(address),
        index: 1,
        txId: Cardano.TransactionId(transactionHash)
      });
    });
  });
  describe('mapTxOut', () => {
    test('map TxInOutModel with assets to TxOutput', () => {
      const result = mappers.mapTxOut(txOutModel, assets);
      expect(result).toEqual<TxOutputModel>({
        address: Cardano.Address(address),
        datum: Cardano.util.Hash32ByteBase16(hash32ByteBase16),
        index: 1,
        txId: Cardano.TransactionId(transactionHash),
        value: { assets, coins: 20_000_000n }
      });
    });
    test('map TxInOutModel with no assets to TxOutput', () => {
      const result = mappers.mapTxOut(txOutModel);
      expect(result).toEqual<TxOutputModel>({
        address: Cardano.Address(address),
        datum: Cardano.util.Hash32ByteBase16(hash32ByteBase16),
        index: 1,
        txId: Cardano.TransactionId(transactionHash),
        value: { coins: 20_000_000n }
      });
    });
    test('map TxInOutModel with nulls to TxOutput', () => {
      const result = mappers.mapTxOut({ ...txOutModel, datum: null });
      expect(result).toEqual<TxOutputModel>({
        address: Cardano.Address(address),
        index: 1,
        txId: Cardano.TransactionId(transactionHash),
        value: { coins: 20_000_000n }
      });
    });
  });
  describe('mapTxOutTokenMap', () => {
    test('map TxOutMultiAssetModel to TxOutTokenMap', () => {
      const result = mappers.mapTxOutTokenMap([txOutMaModel, txOutMaModel]);
      expect(result).toEqual<TxOutTokenMap>(
        new Map([['1', new Map([[Cardano.AssetId(policyId + assetName), 24_000n]])]])
      );
    });
  });
  describe('mapTxTokenMap', () => {
    test('map MultiAssetModel to TxTokenMap', () => {
      const result = mappers.mapTxTokenMap([multiAssetModel, multiAssetModel]);
      expect(result).toEqual<TxTokenMap>(
        new Map([[Cardano.TransactionId(transactionHash), new Map([[Cardano.AssetId(policyId + assetName), 24_000n]])]])
      );
    });
  });
  describe('mapTxMetadata', () => {
    test('map TxMetadataModel to Cardano.TxMetadata', () => {
      const result = mappers.mapTxMetadata(txMetadataModel);
      expect(result).toEqual<Cardano.TxMetadata>(
        new Map([
          [127n, new Map([['v', 1n]])],
          [500n, new Map([['a', 2n]])]
        ])
      );
    });
  });
  describe('mapWithdrawal', () => {
    test('map WithdrawalModel to Cardano.Withdrawal', () => {
      const result = mappers.mapWithdrawal(withdrawalModel);
      expect(result).toEqual<Cardano.Withdrawal>({
        quantity: 20_000_000n,
        stakeAddress: Cardano.RewardAccount(stakeAddress)
      });
    });
  });
});
