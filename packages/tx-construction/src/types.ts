import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, HandleResolution } from '@cardano-sdk/core';
import { GroupedAddress, SignTransactionOptions } from '@cardano-sdk/key-management';
import { SelectionSkeleton } from '@cardano-sdk/input-selection';

import { CustomizeCb } from './tx-builder';
import { MinimumCoinQuantityPerOutput } from './output-validation';

export type InitializeTxResult = Cardano.TxBodyWithHash & { inputSelection: SelectionSkeleton };

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
  proposalProcedures?: Cardano.ProposalProcedure[];
  /** callback function that allows updating the transaction before input selection */
  customizeCb?: CustomizeCb;
}

export interface InitializeTxPropsValidationResult {
  minimumCoinQuantities: MinimumCoinQuantityPerOutput;
}
