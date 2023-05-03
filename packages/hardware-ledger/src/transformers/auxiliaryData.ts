import * as Crypto from '@cardano-sdk/crypto';
import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { Transform } from '@cardano-sdk/util';
import { TxAuxiliaryDataType } from '@cardano-foundation/ledgerjs-hw-app-cardano/dist/types/public';

const toAuxiliaryData: Transform<Crypto.Hash32ByteBase16, Ledger.TxAuxiliaryData> = (auxiliaryDataHash) => ({
  params: {
    hashHex: auxiliaryDataHash
  },
  type: TxAuxiliaryDataType.ARBITRARY_HASH
});

export const mapAuxiliaryData = (auxiliaryDataHash?: Crypto.Hash32ByteBase16) =>
  auxiliaryDataHash ? toAuxiliaryData(auxiliaryDataHash) : null;
