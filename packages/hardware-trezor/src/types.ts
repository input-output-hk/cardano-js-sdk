import * as Trezor from '@trezor/connect';
import { Cardano } from '@cardano-sdk/core';
import { GroupedAddress } from '@cardano-sdk/key-management';

/**
 * The TrezorTxTransformerContext type represents the additional context necessary for
 * transforming a core transaction into a Trezor device compatible transaction.
 *
 * @property {Cardano.ChainId} chainId - The Cardano blockchain's network identifier (e.g., mainnet or testnet).
 * @property {Cardano.InputResolver} inputResolver - A function that resolves transaction txOut from the given txIn.
 * @property {GroupedAddress[]} knownAddresses - An array of grouped known addresses by wallet.
 */
export type TrezorTxTransformerContext = {
  chainId: Cardano.ChainId;
  inputResolver: Cardano.InputResolver;
  knownAddresses: GroupedAddress[];
};

export type TrezorTxOutputDestination =
  | {
      addressParameters: Trezor.CardanoAddressParameters;
    }
  | {
      address: string;
    };
