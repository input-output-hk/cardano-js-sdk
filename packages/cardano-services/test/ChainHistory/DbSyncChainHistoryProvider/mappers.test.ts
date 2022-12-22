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
  RedeemerModel,
  StakeCertModel,
  TipModel,
  TxInput,
  TxInputModel,
  TxModel,
  TxOutMultiAssetModel,
  TxOutTokenMap,
  TxOutput,
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
const sourceTransactionHash = 'cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3812';
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

const txInput: TxInput = {
  address: Cardano.Address(address),
  id: '1',
  index: 1,
  txInputId: Cardano.TransactionId(transactionHash),
  txSourceId: Cardano.TransactionId(sourceTransactionHash)
};

const txInputModel: TxInputModel = {
  address,
  id: '1',
  index: 1,
  tx_input_id: Buffer.from(transactionHash, 'hex'),
  tx_source_id: Buffer.from(sourceTransactionHash, 'hex')
};

const txOutput: TxOutput = {
  address: Cardano.Address(address),
  datumHash: Cardano.util.Hash32ByteBase16(hash32ByteBase16),
  index: 1,
  txId: Cardano.TransactionId(transactionHash),
  value: { coins: 20_000_000n }
};

const txOutModel: TxOutputModel = {
  address,
  coin_value: '20000000',
  datum: Buffer.from(hash32ByteBase16, 'hex'),
  id: '1',
  index: 1,
  tx_id: Buffer.from(transactionHash, 'hex')
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
      slot_no: '100',
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
      expect(result).toEqual<Cardano.ExtendedBlockInfo>({
        confirmations: 100,
        date: new Date(datetime),
        epoch: Cardano.EpochNo(12),
        epochSlot: 202,
        fees: 170_000n,
        header: {
          blockNo: Cardano.BlockNo(200),
          hash: Cardano.BlockId(blockHash),
          slot: Cardano.Slot(100)
        },
        nextBlock: Cardano.BlockId(blockHash),
        previousBlock: Cardano.BlockId(blockHash),
        size: Cardano.BlockSize(50),
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
      expect(result).toEqual<Cardano.ExtendedBlockInfo>({
        confirmations: 100,
        date: new Date(datetime),
        epoch: Cardano.EpochNo(12),
        epochSlot: 202,
        fees: 170_000n,
        header: {
          blockNo: Cardano.BlockNo(200),
          hash: Cardano.BlockId(blockHash),
          slot: Cardano.Slot(100)
        },
        size: Cardano.BlockSize(50),
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
        epoch: Cardano.EpochNo(1),
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
        data: Cardano.util.HexBlob(hash28ByteBase16),
        executionUnits: {
          memory: 2000,
          steps: 5000
        },
        index: 1,
        purpose: Cardano.RedeemerPurpose.mint
      });
    });
  });
  describe('mapTxAlonzo', () => {
    const inputs: Cardano.HydratedTxIn[] = [
      { address: Cardano.Address(address), index: 1, txId: Cardano.TransactionId(transactionHash) }
    ];
    const outputs: Cardano.TxOut[] = [{ address: Cardano.Address(address), value: { assets, coins: 20_000_000n } }];
    const redeemers: Cardano.Redeemer[] = [
      {
        data: Cardano.util.HexBlob(hash28ByteBase16),
        executionUnits: { memory: 1, steps: 2 },
        index: 1,
        purpose: Cardano.RedeemerPurpose.spend
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

    const expected: Cardano.HydratedTx = {
      blockHeader: { blockNo: Cardano.BlockNo(200), hash: Cardano.BlockId(blockHash), slot: Cardano.Slot(250) },
      body: {
        fee: 170_000n,
        inputs,
        outputs,
        validityInterval: { invalidBefore: Cardano.Slot(300), invalidHereafter: Cardano.Slot(500) }
      },
      id: Cardano.TransactionId(transactionHash),
      index: 1,
      txSize: 20,
      witness: { signatures: new Map() }
    };
    test('map TxModel to Cardano.HydratedTx with minimal data', () => {
      const result = mappers.mapTxAlonzo(txModel, { inputs, outputs });
      expect(result).toEqual<Cardano.HydratedTx>(expected);
    });
    test('map TxModel with null fields to Cardano.HydratedTx', () => {
      const result = mappers.mapTxAlonzo(
        { ...txModel, invalid_before: null, invalid_hereafter: null },
        { inputs, outputs }
      );
      expect(result).toEqual<Cardano.HydratedTx>({ ...expected, body: { ...expected.body, validityInterval: {} } });
    });
    test('map TxModel to Cardano.HydratedTx with extra data', () => {
      const result = mappers.mapTxAlonzo(txModel, {
        certificates,
        collaterals: inputs,
        inputs,
        metadata,
        mint: assets,
        outputs,
        redeemers,
        withdrawals
      });
      expect(result).toEqual<Cardano.HydratedTx>({
        ...expected,
        auxiliaryData: { body: { blob: metadata } },
        body: { ...expected.body, certificates, collaterals: inputs, mint: assets, withdrawals },
        witness: { ...expected.witness, redeemers }
      });
    });
  });
  describe('mapTxInModel', () => {
    test('map txInputModel to TxInput', () => {
      const result = mappers.mapTxInModel(txInputModel);
      expect(result).toEqual<TxInput>({
        address: Cardano.Address(txInputModel.address),
        id: txInputModel.id,
        index: txInputModel.index,
        txInputId: Cardano.TransactionId(transactionHash),
        txSourceId: Cardano.TransactionId(sourceTransactionHash)
      });
    });
  });
  describe('mapTxIn', () => {
    test('map TxInput to Cardano.HydratedTxIn', () => {
      const result = mappers.mapTxIn(txInput);
      expect(result).toEqual<Cardano.HydratedTxIn>({
        address: Cardano.Address(address),
        index: 1,
        txId: Cardano.TransactionId(sourceTransactionHash)
      });
    });
  });
  describe('mapTxOutModel', () => {
    test('map TxOutputModel with assets to TxOutput', () => {
      const result = mappers.mapTxOutModel(txOutModel, assets);
      expect(result).toEqual<TxOutput>({
        address: Cardano.Address(address),
        datumHash: Cardano.util.Hash32ByteBase16(hash32ByteBase16),
        index: 1,
        txId: Cardano.TransactionId(transactionHash),
        value: { assets, coins: 20_000_000n }
      });
    });
    test('map TxOutputModel with no assets to TxOutput', () => {
      const result = mappers.mapTxOutModel(txOutModel);
      expect(result).toEqual<TxOutput>({
        address: Cardano.Address(address),
        datumHash: Cardano.util.Hash32ByteBase16(hash32ByteBase16),
        index: 1,
        txId: Cardano.TransactionId(transactionHash),
        value: { coins: 20_000_000n }
      });
    });
    test('map TxOutputModel with nulls to TxOutput', () => {
      const result = mappers.mapTxOutModel({ ...txOutModel, datum: null });
      expect(result).toEqual<TxOutput>({
        address: Cardano.Address(address),
        index: 1,
        txId: Cardano.TransactionId(transactionHash),
        value: { coins: 20_000_000n }
      });
    });
  });
  describe('mapTxOut', () => {
    test('map TxOutput to Cardano.TxOut', () => {
      const result = mappers.mapTxOut(txOutput);
      expect(result).toEqual<Cardano.TxOut>({
        address: txOutput.address,
        datumHash: txOutput.datumHash,
        value: txOutput.value
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
