import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, Serialization } from '@cardano-sdk/core';
import { cip36 } from '../src/index.js';

import delay from 'delay';

describe('cip36', () => {
  describe('metadataBuilder', () => {
    it('uses timestamp as nonce by default', async () => {
      const props: cip36.BuildVotingRegistrationProps = {
        delegations: [
          {
            cip36VoteKey: Crypto.Ed25519PublicKeyHex(
              '0036ef3e1f0d3f5989e2d155ea54bdb2a72c4c456ccb959af4c94868f473f5a0'
            ),
            weight: 1
          }
        ],
        paymentAddress: Cardano.PaymentAddress(
          'addr_test1qprhw4s70k0vzyhvxp6h97hvrtlkrlcvlmtgmaxdtjz87xrjkctk27ypuv9dzlzxusqse89naweygpjn5dxnygvus05sdq9h07'
        ),
        purpose: cip36.VotingPurpose.CATALYST,
        stakeKey: Crypto.Ed25519PublicKeyHex('e3cd2404c84de65f96918f18d5b445bcb933a7cda18eeded7945dd191e432369')
      };
      const getNonce = (metadata: Cardano.TxMetadata) =>
        (metadata.get(61_284n) as Cardano.MetadatumMap).get(4n) as bigint;
      const nonce1 = getNonce(cip36.metadataBuilder.buildVotingRegistration(props));
      await delay(2);
      const nonce2 = getNonce(cip36.metadataBuilder.buildVotingRegistration(props));
      expect(nonce2).toBeGreaterThan(nonce1);
    });

    test('vectors specified in the cip', async () => {
      const votingRegistrationMetadata = cip36.metadataBuilder.buildVotingRegistration({
        delegations: [
          {
            cip36VoteKey: Crypto.Ed25519PublicKeyHex(
              '0036ef3e1f0d3f5989e2d155ea54bdb2a72c4c456ccb959af4c94868f473f5a0'
            ),
            weight: 1
          }
        ],
        nonce: 1234,
        paymentAddress: Cardano.PaymentAddress(
          'addr_test1qprhw4s70k0vzyhvxp6h97hvrtlkrlcvlmtgmaxdtjz87xrjkctk27ypuv9dzlzxusqse89naweygpjn5dxnygvus05sdq9h07'
        ),
        purpose: cip36.VotingPurpose.CATALYST,
        stakeKey: Crypto.Ed25519PublicKeyHex('e3cd2404c84de65f96918f18d5b445bcb933a7cda18eeded7945dd191e432369')
      });
      expect(Serialization.GeneralTransactionMetadata.fromCore(votingRegistrationMetadata).toCbor()).toEqual(
        'a119ef64a501818258200036ef3e1f0d3f5989e2d155ea54bdb2a72c4c456ccb959af4c94868f473f5a001025820e3cd2404c84de65f96918f18d5b445bcb933a7cda18eeded7945dd191e432369035839004777561e7d9ec112ec307572faec1aff61ff0cfed68df4cd5c847f1872b617657881e30ad17c46e4010c9cb3ebb2440653a34d32219c83e9041904d20500'
      );
      const signedCip36Metadata = await cip36.metadataBuilder.signVotingRegistration(votingRegistrationMetadata, {
        signBlob: async (blob) => {
          const bip32Ed25519 = new Crypto.SodiumBip32Ed25519();
          const privateStakeKey = Crypto.Ed25519PrivateNormalKeyHex(
            '852fa5d17df3efdfdcd6dac53ec9fe5593f3c0bd7cadb3c2af76c7e15dfa8a5c'
          );
          return bip32Ed25519.sign(privateStakeKey, blob);
        }
      });
      expect((signedCip36Metadata.get(61_285n) as Cardano.MetadatumMap).get(1n)).toEqual(
        Buffer.from(
          'cbb96ba1596fafc18eec84e306feea3067ba1c6ace95b11af820bcbd53837ef32bdcf28176749061e1f2a1300d4df98c80582722786e40cf330072d0b78a7408',
          'hex'
        )
      );
    });
  });
});
