import * as Cardano from '.';
import { BlockAlonzo, BlockBodyAlonzo } from '@cardano-ogmios/schema';

type OgmiosHeader = NonNullable<BlockAlonzo['header']>;
export type PartialBlockHeader = Pick<OgmiosHeader, 'blockHeight' | 'slot' | 'blockHash'>;

export interface Withdrawal {
  address: Cardano.Address;
  quantity: Cardano.Lovelace;
}

export enum CertificateType {
  StakeRegistration = 'StakeRegistration',
  StakeDeregistration = 'StakeDeregistration',
  PoolRegistration = 'PoolRegistration',
  PoolRetirement = 'PoolRetirement',
  StakeDelegation = 'StakeDelegation',
  MIR = 'MoveInstantaneousRewards',
  GenesisKeyDelegation = 'GenesisKeyDelegation'
}

export interface StakeAddressCertificate {
  type: CertificateType.StakeRegistration | CertificateType.StakeDeregistration;
  certIndex: number;
  address: Cardano.Address;
}

export interface PoolCertificate {
  type: CertificateType.PoolRegistration | CertificateType.PoolRetirement;
  certIndex: number;
  poolId: Cardano.PoolId;
  epoch: Cardano.Epoch;
}

export interface StakeDelegationCertificate {
  type: CertificateType.StakeDelegation;
  certIndex: number;
  delegationIndex: number;
  address: Cardano.Address;
  poolId: Cardano.PoolId;
  epoch: Cardano.Epoch;
}

export interface MirCertificate {
  type: CertificateType.MIR;
  certIndex: number;
  address: Cardano.Address;
  quantity: Cardano.Lovelace;
  pot: 'reserve' | 'treasury';
}

export interface GenesisKeyDelegationCertificate {
  type: CertificateType.GenesisKeyDelegation;
  certIndex: number;
  genesisHash: Cardano.Hash16;
  genesisDelegateHash: Cardano.Hash16;
  vrfKeyHash: Cardano.Hash16;
}

export type Certificate =
  | StakeAddressCertificate
  | PoolCertificate
  | StakeDelegationCertificate
  | MirCertificate
  | GenesisKeyDelegationCertificate;

export interface TxBodyAlonzo {
  index: number;
  inputs: Cardano.TxIn[];
  collaterals?: Cardano.TxIn[];
  outputs: Cardano.TxOut[];
  fee: Cardano.Lovelace;
  validityInterval: Cardano.ValidityInterval;
  withdrawals?: Withdrawal[];
  certificates?: Certificate[];
  mint?: Cardano.TokenMap;
  scriptIntegrityHash?: Cardano.Hash16;
  requiredExtraSignatures?: Cardano.Hash16[];
}

/**
 * Implicit coin quantities used in the transaction
 */
export interface ImplicitCoin {
  /**
   * Reward withdrawals + deposit reclaims
   */
  input?: Cardano.Lovelace;
  /**
   * Delegation registration deposit
   */
  deposit?: Cardano.Lovelace;
}

export interface Redeemer {
  index: number;
  purpose: 'spend' | 'mint' | 'certificate' | 'withdrawal';
  scriptHash: Cardano.Hash64;
  executionUnits: Cardano.ExUnits;
}

export type Witness = Omit<Partial<BlockBodyAlonzo['witness']>, 'redeemers'> & {
  redeemers?: Redeemer[];
};
export interface TxAlonzo {
  id: Cardano.Hash16;
  blockHeader: PartialBlockHeader;
  body: TxBodyAlonzo;
  implicitCoin: ImplicitCoin;
  txSize: number;
  witness: Witness;
  auxiliaryData?: Cardano.AuxiliaryData;
}

export type NewTxAlonzo = Omit<TxAlonzo, 'blockHeader' | 'implicitCoin' | 'txSize'>;
