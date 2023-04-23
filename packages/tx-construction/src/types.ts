import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { SelectionSkeleton } from '@cardano-sdk/input-selection';
import { SignTransactionOptions, TransactionSigner } from '@cardano-sdk/key-management';

import { MinimumCoinQuantityPerOutput } from './output-validation';

export type InitializeTxResult = Cardano.TxBodyWithHash & { inputSelection: SelectionSkeleton };

export interface TxProps {
  auxiliaryData?: Cardano.AuxiliaryData;
  witness?: {
    datums?: Cardano.Datum[];
    redeemers?: Cardano.Redeemer[];
    bootstrap?: Cardano.BootstrapWitness[];
    extraSigners?: TransactionSigner[];
  };
  scripts?: Cardano.Script[];
  signingOptions?: SignTransactionOptions;
}

export interface InitializeTxProps extends TxProps {
  outputs?: Set<Cardano.TxOut>;
  certificates?: Cardano.Certificate[];
  options?: {
    validityInterval?: Cardano.ValidityInterval;
  };
  collaterals?: Set<Cardano.TxIn>;
  mint?: Cardano.TokenMap;
  scriptIntegrityHash?: Crypto.Hash32ByteBase16;
  requiredExtraSignatures?: Crypto.Ed25519KeyHashHex[];
}

export interface FinalizeTxProps extends TxProps {
  tx: Cardano.TxBodyWithHash;
  isValid?: boolean;
}

export interface InitializeTxPropsValidationResult {
  minimumCoinQuantities: MinimumCoinQuantityPerOutput;
}
