import * as Crypto from '@cardano-sdk/crypto';
import * as Trezor from '@trezor/connect';

export const mapAuxiliaryData = (auxiliaryDataHash: Crypto.Hash32ByteBase16): Trezor.CardanoAuxiliaryData => ({
  hash: auxiliaryDataHash
});
