import * as Crypto from '@cardano-sdk/crypto';
import { AsyncKeyAgent, GroupedAddress, SignTransactionOptions, TransactionSigner } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { InputSelector, SelectionSkeleton } from '@cardano-sdk/input-selection';
import { Logger } from 'ts-log';

import { MinimumCoinQuantityPerOutput } from './output-validation';

export type InitializeTxResult = Cardano.TxBodyWithHash & { inputSelection: SelectionSkeleton };

export interface TxBuilderProviders {
  tip: () => Promise<Cardano.Tip>;
  protocolParameters: () => Promise<Cardano.ProtocolParameters>;
  addresses: () => Promise<GroupedAddress[]>;
  changeAddress: () => Promise<Cardano.PaymentAddress>;
  genesisParameters: () => Promise<Cardano.CompactGenesis>;
  rewardAccounts: () => Promise<Omit<Cardano.RewardAccountInfo, 'delegatee'>[]>;
  utxoAvailable: () => Promise<Cardano.Utxo[]>;
}

export interface TxBuilderDependencies {
  inputSelector?: InputSelector;
  inputResolver: Cardano.InputResolver;
  keyAgent: AsyncKeyAgent;
  txBuilderProviders: TxBuilderProviders;
  logger: Logger;
}

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

export type FinalizeTxDependencies = Pick<TxBuilderDependencies, 'inputResolver' | 'keyAgent'>;

export interface InitializeTxPropsValidationResult {
  minimumCoinQuantities: MinimumCoinQuantityPerOutput;
}
