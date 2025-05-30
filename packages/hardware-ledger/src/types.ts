import { Cardano } from '@cardano-sdk/core';
import { HID } from 'node-hid';
import { SignTransactionContext } from '@cardano-sdk/key-management';
import { TxOutputFormat } from '@cardano-foundation/ledgerjs-hw-app-cardano';
import TransportNodeHid from '@ledgerhq/hw-transport-node-hid-noevents';
import TransportWebUSB from '@ledgerhq/hw-transport-webusb';

export enum DeviceType {
  Ledger = 'Ledger'
}

export type LedgerTransportType = TransportWebUSB | TransportNodeHid;

export type LedgerDevice = USBDevice | HID;

/**
 * The LedgerTxTransformerContext type represents the additional context necessary for
 * transforming a Core transaction into a Ledger device compatible transaction.
 */
export type LedgerTxTransformerContext = {
  /** The Cardano blockchain's network identifier (e.g., mainnet or testnet). */
  chainId: Cardano.ChainId;
  /** Non-hardened account in cip1852 */
  accountIndex: number;
  /** The outputs format in the same order as they appear in the transaction. */
  outputsFormat: Array<TxOutputFormat>;
  /** The collateral return output format. */
  collateralReturnFormat: TxOutputFormat | undefined;
} & SignTransactionContext;
