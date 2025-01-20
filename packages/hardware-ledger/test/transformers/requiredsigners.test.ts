import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import {
  CONTEXT_WITHOUT_KNOWN_ADDRESSES,
  CONTEXT_WITH_KNOWN_ADDRESSES,
  paymentHash,
  stakeKeyHash as stakeCredentialHash
} from '../testData';
import { CardanoKeyConst, util } from '@cardano-sdk/key-management';
import { Ed25519KeyHashHex } from '@cardano-sdk/crypto';
import { mapRequiredSigners, toRequiredSigner } from '../../src/transformers';

const stakeKeyHash = Ed25519KeyHashHex(stakeCredentialHash);

describe('requiredSigners', () => {
  describe('mapRequiredSigners', () => {
    it('return null if given an undefined object as required signer', () => {
      const txIns = mapRequiredSigners(undefined, CONTEXT_WITH_KNOWN_ADDRESSES);
      expect(txIns).toEqual(null);
    });

    it('can map a a set of required signers', () => {
      const signers = mapRequiredSigners([stakeKeyHash, paymentHash], CONTEXT_WITH_KNOWN_ADDRESSES);

      expect(signers).not.toBeNull();
      expect(signers!.length).toEqual(2);

      expect(signers![0]).toEqual({
        path: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 2, 0],
        type: Ledger.TxRequiredSignerType.PATH
      });

      expect(signers![1]).toEqual({
        path: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 1, 0],
        type: Ledger.TxRequiredSignerType.PATH
      });
    });
  });
  describe('toRequiredSigner', () => {
    it('can map a known Ed25519KeyHashHex to a ledger required signer', async () => {
      const requiredSigner = toRequiredSigner(stakeKeyHash, CONTEXT_WITH_KNOWN_ADDRESSES);

      expect(requiredSigner).toEqual({
        path: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 2, 0],
        type: Ledger.TxRequiredSignerType.PATH
      });
    });

    it('can map a unknown Ed25519KeyHashHex to a ledger required signer', async () => {
      const requiredSigner = toRequiredSigner(stakeKeyHash, CONTEXT_WITHOUT_KNOWN_ADDRESSES);

      expect(requiredSigner).toEqual({
        hashHex: stakeKeyHash,
        type: Ledger.TxRequiredSignerType.HASH
      });
    });
  });
});
