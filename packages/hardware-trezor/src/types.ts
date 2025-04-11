import * as Trezor from '@trezor/connect';
import { Cardano } from '@cardano-sdk/core';
import { SignTransactionContext } from '@cardano-sdk/key-management';

/**
 * The TrezorTxTransformerContext type represents the additional context necessary for
 * transforming a core transaction into a Trezor device compatible transaction.
 */
export type TrezorTxTransformerContext = {
  /** The Cardano blockchain's network identifier (e.g., mainnet or testnet). */
  chainId: Cardano.ChainId;
  /** Non-hardened account in cip1852 */
  accountIndex: number;
  /** Whether sets should be encoded as tagged set in CBOR */
  tagCborSets: boolean;
  /** Whether to use Babbage output format or not. */
  useBabbageOutputs: boolean;
} & SignTransactionContext;

export type TrezorTxOutputDestination =
  | {
      addressParameters: Trezor.CardanoAddressParameters;
    }
  | {
      address: string;
    };
