import { Cardano } from '..';

export interface ValidityInterval {
  invalidBefore?: Cardano.Slot;
  invalidHereafter?: Cardano.Slot;
}

export interface Tx {
  inputs: Cardano.TxIn[];
  outputs: Cardano.TxOut[];
  hash: Cardano.Hash16;
}

export type Block = Cardano.Tip;

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

export interface Redeemer {
  index: number;
  purpose: 'spend' | 'mint' | 'cert' | 'reward';
  scriptHash: Cardano.Hash16;
  datumHash: Cardano.Hash16;
  executionUnits: Cardano.ExUnits;
  fee: Cardano.Lovelace;
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

export interface TxDetails {
  block: Block;
  index: number;
  fee: Cardano.Lovelace;
  deposit: Cardano.Lovelace;
  size: number;
  invalidBefore?: Cardano.Slot;
  invalidHereafter?: Cardano.Slot;
  withdrawals?: Withdrawal[];
  certificates?: Certificate[];
  mint?: Cardano.TokenMap;
  redeemers?: Redeemer[];
  validContract?: boolean;
}

// TODO: consider consolidating all core types from Cardano/ Core/ Ogmios/types, maybe under Cardano?

export enum TransactionStatus {
  Pending = 'pending',
  Confirmed = 'confirmed'
}

export interface DetailedTransaction extends Tx {
  details: TxDetails;
  status: TransactionStatus;
}
