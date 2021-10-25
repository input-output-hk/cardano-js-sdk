import { Transaction } from '@emurgo/cardano-serialization-lib-nodejs';
import { Tx, TxDetails } from '../Transaction';

// TODO: probably move stuff over from cslToOgmios;
export const tx = (_input: Transaction): Tx & { details: TxDetails } => {
  throw new Error('Not implemented');
};
