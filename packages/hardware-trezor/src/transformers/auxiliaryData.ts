import * as Crypto from '@cardano-sdk/crypto';
import * as Trezor from '@trezor/connect';
import { Transform } from '@cardano-sdk/util';

export const mapAuxiliaryData: Transform<Crypto.Hash32ByteBase16, Trezor.CardanoAuxiliaryData> = (
  auxiliaryDataHash
) => ({
  cVoteRegistrationParameters: undefined, // Voting is not handled for now
  hash: auxiliaryDataHash
});
