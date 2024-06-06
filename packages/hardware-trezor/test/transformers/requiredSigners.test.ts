import { CardanoKeyConst, util } from '@cardano-sdk/key-management';
import { contextWithKnownAddresses, contextWithoutKnownAddresses, paymentHash, stakeKeyHash } from '../testData.js';
import { mapRequiredSigners, toRequiredSigner } from '../../src/transformers/index.js';

describe('requiredSigners', () => {
  describe('mapRequiredSigners', () => {
    it('can map a a set of required signers', async () => {
      const signers = await mapRequiredSigners([stakeKeyHash, paymentHash], contextWithKnownAddresses);

      expect(signers).not.toBeNull();
      expect(signers!.length).toEqual(2);

      expect(signers![0]).toEqual({
        keyPath: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 2, 0]
      });

      expect(signers![1]).toEqual({
        keyPath: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 1, 0]
      });
    });
  });

  describe('toRequiredSigner', () => {
    it('can map a known Ed25519KeyHashHex to a trezor required signer', async () => {
      const requiredSigner = toRequiredSigner(stakeKeyHash, contextWithKnownAddresses);

      expect(requiredSigner).toEqual({
        keyPath: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 2, 0]
      });
    });

    it('can map a unknown Ed25519KeyHashHex to a trezor required signer', async () => {
      const requiredSigner = toRequiredSigner(stakeKeyHash, contextWithoutKnownAddresses);

      expect(requiredSigner).toEqual({
        keyHash: stakeKeyHash
      });
    });
  });
});
