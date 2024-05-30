import { Cardano } from '@cardano-sdk/core';

export type TransactionDataMap<T> = Map<Cardano.TransactionId, T>;
export type TxOutTokenMap = Map<string, Cardano.TokenMap>;
export type TxTokenMap = TransactionDataMap<Cardano.TokenMap>;
export type TxOutScriptMap = Map<string, Cardano.Script>;

export interface BlockModel {
  block_no: number;
  epoch_no: number;
  epoch_slot_no: number;
  hash: Buffer;
  next_block: Buffer | null;
  previous_block: Buffer | null;
  size: number;
  slot_leader_hash: Buffer;
  slot_leader_pool: string | null;
  slot_no: string;
  time: string;
  tx_count: string;
  vrf: string;
}

export interface BlockOutputModel {
  fees: string;
  output: string;
  hash: Buffer;
}

export interface TipModel {
  block_no: number;
  hash: Buffer;
  slot_no: number;
}

export interface TxModel {
  id: Buffer;
  index: number;
  size: number;
  fee: string;
  valid_contract: boolean;
  invalid_before: string | null;
  invalid_hereafter: string | null;
  block_no: number;
  block_hash: Buffer;
  block_slot_no: number;
}

export interface TxInputModel {
  address: string;
  id: string;
  index: number;
  tx_input_id: Buffer;
  tx_source_id: Buffer;
}

export interface TxInput {
  address: Cardano.PaymentAddress;
  id: string;
  index: number;
  txInputId: Cardano.TransactionId;
  txSourceId: Cardano.TransactionId;
}

export interface TxOutputModel {
  address: string;
  coin_value: string;
  datum?: Buffer | null;
  id: string;
  index: number;
  reference_script_id: number | null;
  tx_id: Buffer;
}

export interface TxOutput extends Cardano.TxOut {
  txId: Cardano.TransactionId;
  index: number;
}

export interface MultiAssetModel {
  asset_name: Buffer;
  fingerprint: string;
  policy_id: Buffer;
  quantity: string;
  tx_id: Buffer;
}

export interface TxOutMultiAssetModel extends MultiAssetModel {
  tx_out_id: string;
}

export interface ScriptModel {
  type: 'timelock' | 'plutusV1' | 'plutusV2' | 'plutusV3';
  bytes: Buffer;
  hash: Buffer;
  serialised_size: number;
}

export interface WithdrawalModel {
  quantity: string;
  tx_id: Buffer;
  stake_address: string;
}

export interface RedeemerModel {
  index: number;
  purpose: 'cert' | 'mint' | 'spend' | 'reward' | 'voting' | 'proposing';
  script_hash: Buffer;
  unit_mem: string;
  unit_steps: string;
  tx_id: Buffer;
}

export interface CertificateModel {
  cert_index: number;
  tx_id: Buffer;
}
export type WithCertIndex<T extends Cardano.Certificate> = T & { cert_index: number };
export type WithCertType<T extends CertificateModel> = T & {
  type: 'retire' | 'register' | 'mir' | 'stake' | 'delegation';
};

export interface PoolRetireCertModel extends CertificateModel {
  retiring_epoch: number;
  pool_id: string;
}
export interface PoolRegisterCertModel extends CertificateModel {
  pool_id: string;
}

export interface MirCertModel extends CertificateModel {
  amount: string;
  pot: 'reserve' | 'treasury';
  address: string;
}
export interface StakeCertModel extends CertificateModel {
  address: string;
  registration: boolean;
}

export interface DelegationCertModel extends CertificateModel {
  address: string;
  pool_id: string;
}

export interface TxIdModel {
  tx_id: string;
}
