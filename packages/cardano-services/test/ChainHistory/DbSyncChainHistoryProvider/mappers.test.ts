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
  ProtocolParametersUpdateModel,
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
  VoteDelegationCertModel,
  WithCertIndex,
  WithCertType,
  WithdrawalModel
} from '../../../src/ChainHistory/DbSyncChainHistory/types';
import { Cardano } from '@cardano-sdk/core';
import { Hash28ByteBase16, Hash32ByteBase16 } from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';

const blockHash = '7a48b034645f51743550bbaf81f8a14771e58856e031eb63844738ca8ad72298';
const poolId = 'pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh';
const datetime = '2022-05-10T19:22:43.620Z';
const vrfKey = 'vrf_vk19j362pkr4t9y0m3qxgmrv0365vd7c4ze03ny4jh84q8agjy4ep4s99zvg8';
const vrfKeyHash = '220ba9398e3e5fae23a83d0d5927649d577a5f69d6ef1d5253c259d9393ba294';
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
  address: Cardano.PaymentAddress(address),
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
  address: Cardano.PaymentAddress(address),
  datumHash: Hash32ByteBase16(hash32ByteBase16),
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
  reference_script_id: 0,
  tx_id: Buffer.from(transactionHash, 'hex')
};
const assets: Cardano.TokenMap = new Map([
  [AssetId.TSLA, 500n],
  [AssetId.PXL, 500n]
]);

const script: Cardano.PlutusScript = {
  __type: Cardano.ScriptType.Plutus,
  bytes: HexBlob(
    '59079201000033232323232323232323232323232332232323232323232222232325335333006300800530070043333573466E1CD55CEA80124000466442466002006004646464646464646464646464646666AE68CDC39AAB9D500C480008CCCCCCCCCCCC88888888888848CCCCCCCCCCCC00403403002C02802402001C01801401000C008CD4060064D5D0A80619A80C00C9ABA1500B33501801A35742A014666AA038EB9406CD5D0A804999AA80E3AE501B35742A01066A0300466AE85401CCCD54070091D69ABA150063232323333573466E1CD55CEA801240004664424660020060046464646666AE68CDC39AAB9D5002480008CC8848CC00400C008CD40B9D69ABA15002302F357426AE8940088C98C80C8CD5CE01981901809AAB9E5001137540026AE854008C8C8C8CCCD5CD19B8735573AA004900011991091980080180119A8173AD35742A004605E6AE84D5D1280111931901919AB9C033032030135573CA00226EA8004D5D09ABA2500223263202E33573805E05C05826AAE7940044DD50009ABA1500533501875C6AE854010CCD540700808004D5D0A801999AA80E3AE200135742A00460446AE84D5D1280111931901519AB9C02B02A028135744A00226AE8940044D5D1280089ABA25001135744A00226AE8940044D5D1280089ABA25001135744A00226AE8940044D55CF280089BAA00135742A00460246AE84D5D1280111931900E19AB9C01D01C01A101B13263201B3357389201035054350001B135573CA00226EA80054049404448C88C008DD6000990009AA80A911999AAB9F0012500A233500930043574200460066AE880080548C8C8CCCD5CD19B8735573AA004900011991091980080180118061ABA150023005357426AE8940088C98C8054CD5CE00B00A80989AAB9E5001137540024646464646666AE68CDC39AAB9D5004480008CCCC888848CCCC00401401000C008C8C8C8CCCD5CD19B8735573AA0049000119910919800801801180A9ABA1500233500F014357426AE8940088C98C8068CD5CE00D80D00C09AAB9E5001137540026AE854010CCD54021D728039ABA150033232323333573466E1D4005200423212223002004357426AAE79400C8CCCD5CD19B875002480088C84888C004010DD71ABA135573CA00846666AE68CDC3A801A400042444006464C6403866AE700740700680640604D55CEA80089BAA00135742A00466A016EB8D5D09ABA2500223263201633573802E02C02826AE8940044D5D1280089AAB9E500113754002266AA002EB9D6889119118011BAB00132001355012223233335573E0044A010466A00E66442466002006004600C6AAE754008C014D55CF280118021ABA200301313574200222440042442446600200800624464646666AE68CDC3A800A40004642446004006600A6AE84D55CF280191999AB9A3370EA0049001109100091931900899AB9C01201100F00E135573AA00226EA80048C8C8CCCD5CD19B875001480188C848888C010014C01CD5D09AAB9E500323333573466E1D400920042321222230020053009357426AAE7940108CCCD5CD19B875003480088C848888C004014C01CD5D09AAB9E500523333573466E1D40112000232122223003005375C6AE84D55CF280311931900899AB9C01201100F00E00D00C135573AA00226EA80048C8C8CCCD5CD19B8735573AA004900011991091980080180118029ABA15002375A6AE84D5D1280111931900699AB9C00E00D00B135573CA00226EA80048C8CCCD5CD19B8735573AA002900011BAE357426AAE7940088C98C802CCD5CE00600580489BAA001232323232323333573466E1D4005200C21222222200323333573466E1D4009200A21222222200423333573466E1D400D2008233221222222233001009008375C6AE854014DD69ABA135744A00A46666AE68CDC3A8022400C4664424444444660040120106EB8D5D0A8039BAE357426AE89401C8CCCD5CD19B875005480108CC8848888888CC018024020C030D5D0A8049BAE357426AE8940248CCCD5CD19B875006480088C848888888C01C020C034D5D09AAB9E500B23333573466E1D401D2000232122222223005008300E357426AAE7940308C98C8050CD5CE00A80A00900880800780700680609AAB9D5004135573CA00626AAE7940084D55CF280089BAA0012323232323333573466E1D400520022333222122333001005004003375A6AE854010DD69ABA15003375A6AE84D5D1280191999AB9A3370EA0049000119091180100198041ABA135573CA00C464C6401A66AE7003803402C0284D55CEA80189ABA25001135573CA00226EA80048C8C8CCCD5CD19B875001480088C8488C00400CDD71ABA135573CA00646666AE68CDC3A8012400046424460040066EB8D5D09AAB9E500423263200A33573801601401000E26AAE7540044DD500089119191999AB9A3370EA00290021091100091999AB9A3370EA00490011190911180180218031ABA135573CA00846666AE68CDC3A801A400042444004464C6401666AE7003002C02402001C4D55CEA80089BAA0012323333573466E1D40052002212200223333573466E1D40092000212200123263200733573801000E00A00826AAE74DD5000891999AB9A3370E6AAE74DD5000A40004008464C6400866AE700140100092612001490103505431001123230010012233003300200200122212200201'
  ),
  version: Cardano.PlutusLanguageVersion.V2
};

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
  size: 20,
  valid_contract: true
};

const protocolParametersUpdate: ProtocolParametersUpdateModel = {
  collateralPercentage: 852,
  committeeMaxTermLength: 200,
  committeeMinSize: 100,
  costModels: {
    PlutusV1: [
      197_209, 0, 1, 1, 396_231, 621, 0, 1, 150_000, 1000, 0, 1, 150_000, 32, 2_477_736, 29_175, 4, 29_773, 100, 29_773,
      100, 29_773, 100, 29_773, 100, 29_773, 100, 29_773, 100, 100, 100, 29_773, 100, 150_000, 32, 150_000, 32, 150_000,
      32, 150_000, 1000, 0, 1, 150_000, 32, 150_000, 1000, 0, 8, 148_000, 425_507, 118, 0, 1, 1, 150_000, 1000, 0, 8,
      150_000, 112_536, 247, 1, 150_000, 10_000, 1, 136_542, 1326, 1, 1000, 150_000, 1000, 1, 150_000, 32, 150_000, 32,
      150_000, 32, 1, 1, 150_000, 1, 150_000, 4, 103_599, 248, 1, 103_599, 248, 1, 145_276, 1366, 1, 179_690, 497, 1,
      150_000, 32, 150_000, 32, 150_000, 32, 150_000, 32, 150_000, 32, 150_000, 32, 148_000, 425_507, 118, 0, 1, 1,
      61_516, 11_218, 0, 1, 150_000, 32, 148_000, 425_507, 118, 0, 1, 1, 148_000, 425_507, 118, 0, 1, 1, 2_477_736,
      29_175, 4, 0, 82_363, 4, 150_000, 5000, 0, 1, 150_000, 32, 197_209, 0, 1, 1, 150_000, 32, 150_000, 32, 150_000,
      32, 150_000, 32, 150_000, 32, 150_000, 32, 150_000, 32, 3_345_831, 1, 1
    ],
    PlutusV2: [
      205_665, 812, 1, 1, 1000, 571, 0, 1, 1000, 24_177, 4, 1, 1000, 32, 117_366, 10_475, 4, 23_000, 100, 23_000, 100,
      23_000, 100, 23_000, 100, 23_000, 100, 23_000, 100, 100, 100, 23_000, 100, 19_537, 32, 175_354, 32, 46_417, 4,
      221_973, 511, 0, 1, 89_141, 32, 497_525, 14_068, 4, 2, 196_500, 453_240, 220, 0, 1, 1, 1000, 28_662, 4, 2,
      245_000, 216_773, 62, 1, 1_060_367, 12_586, 1, 208_512, 421, 1, 187_000, 1000, 52_998, 1, 80_436, 32, 43_249, 32,
      1000, 32, 80_556, 1, 57_667, 4, 1000, 10, 197_145, 156, 1, 197_145, 156, 1, 204_924, 473, 1, 208_896, 511, 1,
      52_467, 32, 64_832, 32, 65_493, 32, 22_558, 32, 16_563, 32, 76_511, 32, 196_500, 453_240, 220, 0, 1, 1, 69_522,
      11_687, 0, 1, 60_091, 32, 196_500, 453_240, 220, 0, 1, 1, 196_500, 453_240, 220, 0, 1, 1, 1_159_724, 392_670, 0,
      2, 806_990, 30_482, 4, 1_927_926, 82_523, 4, 265_318, 0, 4, 0, 85_931, 32, 205_665, 812, 1, 1, 41_182, 32,
      212_342, 32, 31_220, 32, 32_696, 32, 43_357, 32, 32_247, 32, 38_314, 32, 35_892_428, 10, 9_462_713, 1021, 10,
      38_887_044, 32_947, 10
    ]
  },
  dRepActivity: 5000,
  dRepDeposit: 2000,
  dRepVotingThresholds: {
    committeeNoConfidence: { denominator: 3, numerator: 1 },
    committeeNormal: { denominator: 3, numerator: 1 },
    hardForkInitiation: { denominator: 7, numerator: 4 },
    motionNoConfidence: { denominator: 3, numerator: 1 },
    ppEconomicGroup: { denominator: 7, numerator: 6 },
    ppGovGroup: { denominator: 7, numerator: 6 },
    ppNetworkGroup: { denominator: 7, numerator: 6 },
    ppTechnicalGroup: { denominator: 7, numerator: 6 },
    treasuryWithdrawal: { denominator: 7, numerator: 6 },
    updateToConstitution: { denominator: 7, numerator: 6 }
  },
  executionUnitPrices: { priceMemory: 0.5, priceSteps: 0.5 },
  govActionDeposit: 1000,
  govActionLifetime: 1_000_000,
  maxBlockBodySize: 300,
  maxBlockExecutionUnits: { memory: 4_294_967_296, steps: 4_294_967_296 },
  maxBlockHeaderSize: 500,
  maxCollateralInputs: 100,
  maxTxExecutionUnits: { memory: 4_294_967_296, steps: 4_294_967_296 },
  maxTxSize: 400,
  maxValueSize: 954,
  minFeeRefScriptCostPerByte: 44.5,
  minPoolCost: 1000,
  monetaryExpansion: { denominator: 3, numerator: 1 },
  poolPledgeInfluence: 0.5,
  poolRetireMaxEpoch: 800,
  poolVotingThresholds: {
    committeeNoConfidence: { denominator: 3, numerator: 1 },
    committeeNormal: { denominator: 3, numerator: 1 },
    hardForkInitiation: { denominator: 7, numerator: 6 },
    motionNoConfidence: { denominator: 3, numerator: 1 },
    ppSecurityGroup: { denominator: 3, numerator: 1 }
  },
  stakeAddressDeposit: 2_000_000,
  stakePoolDeposit: 200_000_000,
  stakePoolTargetNum: 900,
  treasuryCut: 0.25,
  txFeeFixed: 200,
  txFeePerByte: 100,
  utxoCostPerByte: 35_000
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
    test('map PoolUpdateCertModel to Cardano.HydratedPoolRegistrationCertificate', () => {
      const result = mappers.mapCertificate({
        ...baseCertModel,
        deposit: '500000000',
        fixed_cost: '390000000',
        margin: 0.15,
        pledge: '420000000',
        pool_id: poolId,
        reward_account: stakeAddress,
        type: 'register',
        vrf_key_hash: Buffer.from(vrfKeyHash, 'hex')
      } as WithCertType<PoolRegisterCertModel>);
      expect(result).toEqual<WithCertIndex<Cardano.HydratedPoolRegistrationCertificate>>({
        __typename: Cardano.CertificateType.PoolRegistration,
        cert_index: 0,
        deposit: 500_000_000n,
        poolParameters: {
          cost: 390_000_000n,
          id: poolId as Cardano.PoolId,
          margin: { denominator: 20, numerator: 3 },
          owners: [],
          pledge: 420_000_000n,
          relays: [],
          rewardAccount: stakeAddress as Cardano.RewardAccount,
          vrf: vrfKeyHash as Cardano.VrfVkHex
        }
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
        kind: Cardano.MirCertificateKind.ToStakeCreds,
        pot: Cardano.MirCertificatePot.Reserves,
        quantity: 500_000n,
        stakeCredential: Cardano.Address.fromString(stakeAddress)!.asReward()!.getPaymentCredential()
      });
      expect(treasuryPotResult).toEqual<WithCertIndex<Cardano.MirCertificate>>({
        __typename: Cardano.CertificateType.MIR,
        cert_index: 0,
        kind: Cardano.MirCertificateKind.ToStakeCreds,
        pot: Cardano.MirCertificatePot.Treasury,
        quantity: 500_000n,
        stakeCredential: Cardano.Address.fromString(stakeAddress)!.asReward()!.getPaymentCredential()
      });
    });
    test('map StakeCertModel to Cardano.StakeAddressCertificate', () => {
      const stakeCert: WithCertType<StakeCertModel> = {
        ...baseCertModel,
        address: stakeAddress,
        deposit: '0',
        registration: true,
        type: 'stake'
      };
      const registrationResult = mappers.mapCertificate(stakeCert);
      const deregistrationResult = mappers.mapCertificate({
        ...stakeCert,
        registration: false
      } as WithCertType<StakeCertModel>);
      expect(registrationResult).toEqual<WithCertIndex<Cardano.NewStakeAddressCertificate>>({
        __typename: Cardano.CertificateType.Registration,
        cert_index: 0,
        deposit: 0n,
        stakeCredential: {
          hash: Hash28ByteBase16.fromEd25519KeyHashHex(
            Cardano.RewardAccount.toHash(Cardano.RewardAccount(stakeAddress))
          ),
          type: Cardano.CredentialType.KeyHash
        }
      });
      expect(deregistrationResult).toEqual<WithCertIndex<Cardano.NewStakeAddressCertificate>>({
        __typename: Cardano.CertificateType.Unregistration,
        cert_index: 0,
        deposit: 0n,
        stakeCredential: {
          hash: Hash28ByteBase16.fromEd25519KeyHashHex(
            Cardano.RewardAccount.toHash(Cardano.RewardAccount(stakeAddress))
          ),
          type: Cardano.CredentialType.KeyHash
        }
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
        stakeCredential: {
          hash: Hash28ByteBase16.fromEd25519KeyHashHex(
            Cardano.RewardAccount.toHash(Cardano.RewardAccount(stakeAddress))
          ),
          type: Cardano.CredentialType.KeyHash
        }
      });
    });

    test.each([
      {
        dRep: { __typename: 'AlwaysAbstain' },
        drep_hash: null,
        drep_view: 'drep_always_abstain',
        has_script: false
      },
      {
        dRep: { __typename: 'AlwaysNoConfidence' },
        drep_hash: null,
        drep_view: 'drep_always_no_confidence',
        has_script: false
      },
      {
        dRep: {
          hash: Hash28ByteBase16('8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d'),
          type: Cardano.CredentialType.KeyHash
        },
        drep_hash: Buffer.from(hash28ByteBase16, 'hex'),
        has_script: false
      },
      {
        dRep: {
          hash: Hash28ByteBase16('8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d'),
          type: Cardano.CredentialType.ScriptHash
        },
        drep_hash: Buffer.from(hash28ByteBase16, 'hex'),
        has_script: true
      }
    ] as (Pick<VoteDelegationCertModel, 'drep_hash' | 'drep_view' | 'has_script'> & { dRep: Cardano.DelegateRepresentative })[])(
      'map AlwaysAbstain VoteDelegationCertModel to Cardano.VoteDelegationCertificate',
      ({ drep_hash, drep_view, dRep, has_script }) => {
        const result = mappers.mapCertificate({
          ...baseCertModel,
          address: stakeAddress,
          drep_hash,
          drep_view,
          has_script,
          type: 'voteDelegation'
        } as WithCertType<VoteDelegationCertModel>);
        expect(result).toEqual<WithCertIndex<Cardano.VoteDelegationCertificate>>({
          __typename: Cardano.CertificateType.VoteDelegation,
          cert_index: 0,
          dRep,
          stakeCredential: {
            hash: Hash28ByteBase16.fromEd25519KeyHashHex(
              Cardano.RewardAccount.toHash(Cardano.RewardAccount(stakeAddress))
            ),
            type: Cardano.CredentialType.KeyHash
          }
        });
      }
    );
  });
  describe('mapRedeemer', () => {
    const redeemerModel: Omit<RedeemerModel, 'purpose'> = {
      index: 1,
      script_hash: Buffer.from(hash28ByteBase16, 'hex'),
      tx_id: Buffer.from(transactionHash, 'hex'),
      unit_mem: '2000',
      unit_steps: '5000'
    };
    test.each([
      ['spend' as const, Cardano.RedeemerPurpose.spend],
      ['mint' as const, Cardano.RedeemerPurpose.mint],
      ['cert' as const, Cardano.RedeemerPurpose.certificate],
      ['reward' as const, Cardano.RedeemerPurpose.withdrawal],
      ['vote' as const, Cardano.RedeemerPurpose.vote],
      ['propose' as const, Cardano.RedeemerPurpose.propose]
    ])("maps '%p' redeemer", (dbSyncRedeemerPurpose, sdkRedeemerPurpose) => {
      const result = mappers.mapRedeemer({ ...redeemerModel, purpose: dbSyncRedeemerPurpose });
      expect(result).toEqual<Cardano.Redeemer>({
        data: Buffer.from('not implemented'),
        executionUnits: {
          memory: 2000,
          steps: 5000
        },
        index: 1,
        purpose: sdkRedeemerPurpose
      });
    });
  });
  describe('mapTxAlonzo', () => {
    const inputs: Cardano.HydratedTxIn[] = [
      { address: Cardano.PaymentAddress(address), index: 1, txId: Cardano.TransactionId(transactionHash) }
    ];
    const outputs: Cardano.TxOut[] = [
      { address: Cardano.PaymentAddress(address), value: { assets, coins: 20_000_000n } }
    ];
    const redeemers: Cardano.Redeemer[] = [
      {
        data: Buffer.from('not implemented'),
        executionUnits: { memory: 1, steps: 2 },
        index: 1,
        purpose: Cardano.RedeemerPurpose.spend
      }
    ];
    const withdrawals: Cardano.Withdrawal[] = [{ quantity: 200n, stakeAddress: Cardano.RewardAccount(stakeAddress) }];
    const metadata: Cardano.TxMetadata = new Map([[1n, 'data']]);
    const inputSource = Cardano.InputSource.inputs;

    const certificates: Cardano.Certificate[] = [
      {
        __typename: Cardano.CertificateType.StakeRegistration,
        stakeCredential: {
          hash: Hash28ByteBase16.fromEd25519KeyHashHex(
            Cardano.RewardAccount.toHash(Cardano.RewardAccount(stakeAddress))
          ),
          type: Cardano.CredentialType.KeyHash
        }
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
      inputSource: Cardano.InputSource.inputs,
      txSize: 20,
      witness: { signatures: new Map() }
    };
    test('map TxModel to Cardano.HydratedTx with minimal data', () => {
      const result = mappers.mapTxAlonzo(txModel, { inputSource, inputs, outputs });
      expect(result).toEqual<Cardano.HydratedTx>(expected);
    });
    test('map TxModel with null fields to Cardano.HydratedTx', () => {
      const result = mappers.mapTxAlonzo(
        { ...txModel, invalid_before: null, invalid_hereafter: null },
        { inputSource, inputs, outputs }
      );
      expect(result).toEqual<Cardano.HydratedTx>({ ...expected, body: { ...expected.body, validityInterval: {} } });
    });
    test('map TxModel to Cardano.HydratedTx with extra data', () => {
      const result = mappers.mapTxAlonzo(txModel, {
        certificates,
        collateralOutputs: [txOutput],
        collaterals: inputs,
        inputSource,
        inputs,
        metadata,
        mint: assets,
        outputs,
        redeemers,
        withdrawals
      });
      expect(result).toEqual<Cardano.HydratedTx>({
        ...expected,
        auxiliaryData: { blob: metadata },
        body: {
          ...expected.body,
          certificates,
          collateralReturn: txOutput,
          collaterals: inputs,
          mint: assets,
          withdrawals
        },
        witness: { ...expected.witness, redeemers }
      });
    });
    test('map collaterals input source TxModel to Cardano.HydratedTx', () => {
      const result = mappers.mapTxAlonzo(txModel, {
        certificates,
        inputSource: Cardano.InputSource.collaterals,
        inputs,
        metadata,
        mint: assets,
        outputs,
        redeemers,
        withdrawals
      });
      expect(result).toEqual<Cardano.HydratedTx>({
        ...expected,
        auxiliaryData: { blob: metadata },
        body: {
          ...expected.body,
          certificates,
          collateralReturn: outputs[0],
          collaterals: inputs,
          fee: 0n,
          inputs: [],
          mint: assets,
          outputs: [],
          proposalProcedures: undefined,
          totalCollateral: 170_000n,
          votingProcedures: undefined,
          withdrawals
        },
        inputSource: Cardano.InputSource.collaterals,
        witness: { ...expected.witness, redeemers }
      });
    });
  });
  describe('mapTxInModel', () => {
    test('map txInputModel to TxInput', () => {
      const result = mappers.mapTxInModel(txInputModel);
      expect(result).toEqual<TxInput>({
        address: Cardano.PaymentAddress(txInputModel.address),
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
        address: Cardano.PaymentAddress(address),
        index: 1,
        txId: Cardano.TransactionId(sourceTransactionHash)
      });
    });
  });
  describe('mapTxOutModel', () => {
    test('map TxOutputModel with assets to TxOutput', () => {
      const result = mappers.mapTxOutModel(txOutModel, { assets });
      expect(result).toEqual<TxOutput>({
        address: Cardano.PaymentAddress(address),
        datumHash: Hash32ByteBase16(hash32ByteBase16),
        index: 1,
        txId: Cardano.TransactionId(transactionHash),
        value: { assets, coins: 20_000_000n }
      });
    });

    test('map TxOutputModel with reference script to TxOutput', () => {
      const result = mappers.mapTxOutModel(txOutModel, { assets, script });
      expect(result).toEqual<TxOutput>({
        address: Cardano.PaymentAddress(address),
        datumHash: Hash32ByteBase16(hash32ByteBase16),
        index: 1,
        scriptReference: script,
        txId: Cardano.TransactionId(transactionHash),
        value: { assets, coins: 20_000_000n }
      });
    });

    test('map TxOutputModel with no assets to TxOutput', () => {
      const result = mappers.mapTxOutModel(txOutModel, {});
      expect(result).toEqual<TxOutput>({
        address: Cardano.PaymentAddress(address),
        datumHash: Hash32ByteBase16(hash32ByteBase16),
        index: 1,
        txId: Cardano.TransactionId(transactionHash),
        value: { coins: 20_000_000n }
      });
    });
    test('map TxOutputModel with nulls to TxOutput', () => {
      const result = mappers.mapTxOutModel({ ...txOutModel, datum: null }, {});
      expect(result).toEqual<TxOutput>({
        address: Cardano.PaymentAddress(address),
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

  describe('mapProtocolParametersUpdateAction', () => {
    test('map ProtocolParametersUpdateAction', () => {
      const result = mappers.mapProtocolParametersUpdateAction(protocolParametersUpdate);
      expect(result).toEqual<Cardano.ProtocolParametersUpdateConway>({
        coinsPerUtxoByte: 35_000,
        collateralPercentage: 852,
        committeeTermLimit: Cardano.EpochNo(200),
        costModels: new Map<Cardano.PlutusLanguageVersion, Cardano.CostModel>([
          [Cardano.PlutusLanguageVersion.V1, protocolParametersUpdate.costModels!.PlutusV1!],
          [Cardano.PlutusLanguageVersion.V2, protocolParametersUpdate.costModels!.PlutusV2!]
        ]),
        dRepDeposit: 2000,
        dRepInactivityPeriod: Cardano.EpochNo(5000),
        dRepVotingThresholds: {
          committeeNoConfidence: { denominator: 3, numerator: 1 },
          committeeNormal: { denominator: 3, numerator: 1 },
          hardForkInitiation: { denominator: 7, numerator: 4 },
          motionNoConfidence: { denominator: 3, numerator: 1 },
          ppEconomicGroup: { denominator: 7, numerator: 6 },
          ppGovernanceGroup: { denominator: 7, numerator: 6 },
          ppNetworkGroup: { denominator: 7, numerator: 6 },
          ppTechnicalGroup: { denominator: 7, numerator: 6 },
          treasuryWithdrawal: { denominator: 7, numerator: 6 },
          updateConstitution: { denominator: 7, numerator: 6 }
        },
        desiredNumberOfPools: 900,
        governanceActionDeposit: 1000,
        governanceActionValidityPeriod: Cardano.EpochNo(1_000_000),
        maxBlockBodySize: 300,
        maxBlockHeaderSize: 500,
        maxCollateralInputs: 100,
        maxExecutionUnitsPerBlock: { memory: 4_294_967_296, steps: 4_294_967_296 },
        maxExecutionUnitsPerTransaction: { memory: 4_294_967_296, steps: 4_294_967_296 },
        maxTxSize: 400,
        maxValueSize: 954,
        minCommitteeSize: 100,
        minFeeCoefficient: 100,
        minFeeConstant: 200,
        minFeeRefScriptCostPerByte: '44.5',
        minPoolCost: 1000,
        monetaryExpansion: '0.3333333333333333',
        poolDeposit: 200_000_000,
        poolInfluence: '0.5',
        poolRetirementEpochBound: 800,
        poolVotingThresholds: {
          committeeNoConfidence: { denominator: 3, numerator: 1 },
          committeeNormal: { denominator: 3, numerator: 1 },
          hardForkInitiation: { denominator: 7, numerator: 6 },
          motionNoConfidence: { denominator: 3, numerator: 1 },
          securityRelevantParamVotingThreshold: { denominator: 3, numerator: 1 }
        },
        prices: { memory: 0.5, steps: 0.5 },
        stakeKeyDeposit: 2_000_000,
        treasuryExpansion: '0.25'
      });
    });

    test('map subset of ProtocolParametersUpdateAction', () => {
      const result = mappers.mapProtocolParametersUpdateAction({
        collateralPercentage: 500,
        utxoCostPerByte: 30_000
      });
      expect(result).toEqual<Cardano.ProtocolParametersUpdateConway>({
        coinsPerUtxoByte: 30_000,
        collateralPercentage: 500
      });
    });
  });
});
