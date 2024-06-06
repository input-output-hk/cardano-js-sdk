import type * as Crypto from '@cardano-sdk/crypto';
import type { Cardano, HandleResolution } from '@cardano-sdk/core';
import type { GroupedAddress, SignTransactionOptions } from '@cardano-sdk/key-management';
import type { SelectionSkeleton } from '@cardano-sdk/input-selection';

import type { CustomizeCb, TxEvaluator } from './tx-builder/index.js';
import type { MinimumCoinQuantityPerOutput } from './output-validation/index.js';
import type { RedeemersByType } from './input-selection/index.js';

export type InitializeTxResult = Cardano.TxBodyWithHash & {
  inputSelection: SelectionSkeleton;
  redeemers?: Array<Cardano.Redeemer>;
};

export type RewardAccountWithPoolId = Omit<Cardano.RewardAccountInfo, 'delegatee'> & {
  delegatee?: { nextNextEpoch?: { id: Cardano.PoolId } };
};

export interface AddressesProvider {
  get: () => Promise<GroupedAddress[]>;
  /**
   * When TxBuilder derives new addresses, it notifies the wallet via this method.
   *
   * @returns Updated wallet addresses (including old ones)
   */
  add: (...addresses: GroupedAddress[]) => Promise<GroupedAddress[]>;
}

export interface TxBuilderProviders {
  tip: () => Promise<Cardano.Tip>;
  protocolParameters: () => Promise<Cardano.ProtocolParameters>;
  genesisParameters: () => Promise<Cardano.CompactGenesis>;
  rewardAccounts: () => Promise<RewardAccountWithPoolId[]>;
  utxoAvailable: () => Promise<Cardano.Utxo[]>;
  addresses: AddressesProvider;
}

export type InitializeTxWitness = Partial<Cardano.Witness>;
export type TxBodyPreInputSelection = Omit<Cardano.TxBody, 'inputs' | 'fee'>;

export interface InitializeTxProps {
  // Inputs specified at this stage will be included in the transaction regardless of the input selection result.
  inputs?: Set<Cardano.Utxo>;
  referenceInputs?: Set<Cardano.TxIn>;
  outputs?: Set<Cardano.TxOut>;
  certificates?: Cardano.Certificate[];
  options?: {
    validityInterval?: Cardano.ValidityInterval;
  };
  collaterals?: Set<Cardano.TxIn>;
  collateralReturn?: Cardano.TxOut;
  mint?: Cardano.TokenMap;
  scriptIntegrityHash?: Crypto.Hash32ByteBase16;
  requiredExtraSignatures?: Crypto.Ed25519KeyHashHex[];
  auxiliaryData?: Cardano.AuxiliaryData;
  witness?: InitializeTxWitness;
  signingOptions?: SignTransactionOptions;
  handleResolutions?: HandleResolution[];
  proposalProcedures?: Cardano.ProposalProcedure[];
  /** callback function that allows updating the transaction before input selection */
  customizeCb?: CustomizeCb;
  txEvaluator?: TxEvaluator;
  redeemersByType?: RedeemersByType;
  scriptVersions?: Set<Cardano.PlutusLanguageVersion>;
}

export interface InitializeTxPropsValidationResult {
  minimumCoinQuantities: MinimumCoinQuantityPerOutput;
}
