import { Cardano } from '@cardano-sdk/core';
import { GroupedAddress } from '@cardano-sdk/key-management';
import TransportNodeHid from '@ledgerhq/hw-transport-node-hid-noevents';
import TransportWebHID from '@ledgerhq/hw-transport-webhid';

export enum DeviceType {
  Ledger = 'Ledger'
}

export type LedgerTransportType = TransportWebHID | TransportNodeHid;

/**
 * The LedgerTxTransformerContext type represents the additional context necessary for
 * transforming a Core transaction into a Ledger device compatible transaction.
 *
 * @property {Cardano.ChainId} chainId - The Cardano blockchain's network identifier (e.g., mainnet or testnet).
 * @property {Cardano.InputResolver} inputResolver - A function that resolves transaction txOut from the given txIn.
 * @property {GroupedAddress[]} knownAddresses - An array of grouped known addresses by wallet.
 */
export type LedgerTxTransformerContext = {
  chainId: Cardano.ChainId;
  inputResolver: Cardano.InputResolver;
  knownAddresses: GroupedAddress[];
};
