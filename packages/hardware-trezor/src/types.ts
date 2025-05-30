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
  /** The outputs format in the same order as they appear in the transaction. */
  outputsFormat: Array<Trezor.PROTO.CardanoTxOutputSerializationFormat>;
  /** The collateral return output format. */
  collateralReturnFormat: Trezor.PROTO.CardanoTxOutputSerializationFormat | undefined;
} & SignTransactionContext;

export type TrezorTxOutputDestination =
  | {
      addressParameters: Trezor.CardanoAddressParameters;
    }
  | {
      address: string;
    };
