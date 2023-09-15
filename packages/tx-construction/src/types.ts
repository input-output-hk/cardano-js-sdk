import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, HandleResolution } from '@cardano-sdk/core';
import { SelectionSkeleton } from '@cardano-sdk/input-selection';
import { SignTransactionOptions, TransactionSigner } from '@cardano-sdk/key-management';

import { MinimumCoinQuantityPerOutput } from './output-validation';

export type InitializeTxResult = Cardano.TxBodyWithHash & { inputSelection: SelectionSkeleton };

export type RewardAccountWithPoolId = Omit<Cardano.RewardAccountInfo, 'delegatee'> & {
  delegatee?: { nextNextEpoch?: { id: Cardano.PoolId } };
};

export interface TxBuilderProviders {
  tip: () => Promise<Cardano.Tip>;
  protocolParameters: () => Promise<Cardano.ProtocolParameters>;
  genesisParameters: () => Promise<Cardano.CompactGenesis>;
  rewardAccounts: () => Promise<RewardAccountWithPoolId[]>;
  utxoAvailable: () => Promise<Cardano.Utxo[]>;
}

export type InitializeTxWitness = Partial<Cardano.Witness> & { extraSigners?: TransactionSigner[] };

export interface InitializeTxProps {
  outputs?: Set<Cardano.TxOut>;
  certificates?: Cardano.Certificate[];
  options?: {
    validityInterval?: Cardano.ValidityInterval;
  };
  collaterals?: Set<Cardano.TxIn>;
  mint?: Cardano.TokenMap;
  scriptIntegrityHash?: Crypto.Hash32ByteBase16;
  requiredExtraSignatures?: Crypto.Ed25519KeyHashHex[];
  auxiliaryData?: Cardano.AuxiliaryData;
  witness?: InitializeTxWitness;
  signingOptions?: SignTransactionOptions;
  handleResolutions?: HandleResolution[];
}

export interface InitializeTxPropsValidationResult {
  minimumCoinQuantities: MinimumCoinQuantityPerOutput;
}
