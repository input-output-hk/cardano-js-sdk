/* eslint-disable max-len */
import { CML, Cardano, coreToCml } from '@cardano-sdk/core';
import { cip36 } from '../src';
import { usingAutoFree } from '@cardano-sdk/util';
import delay from 'delay';

describe('cip36', () => {
  describe('metadataBuilder', () => {
    it('uses timestamp as nonce by default', async () => {
      const props: cip36.BuildVotingRegistrationProps = {
        delegations: [
          {
            votingKey: Cardano.Ed25519PublicKey('0036ef3e1f0d3f5989e2d155ea54bdb2a72c4c456ccb959af4c94868f473f5a0'),
            weight: 1
          }
        ],
        purpose: cip36.VotingPurpose.CATALYST,
        rewardAddress: Cardano.Address('addr_test1qprhw4s70k0vzyhvxp6h97hvrtlkrlcvlmtgmaxdtjz87xrjkctk27ypuv9dzlzxusqse89naweygpjn5dxnygvus05sdq9h07'),
        stakeKey: Cardano.Ed25519PublicKey('e3cd2404c84de65f96918f18d5b445bcb933a7cda18eeded7945dd191e432369')
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
            votingKey: Cardano.Ed25519PublicKey('0036ef3e1f0d3f5989e2d155ea54bdb2a72c4c456ccb959af4c94868f473f5a0'),
            weight: 1
          },
          {
            votingKey: Cardano.Ed25519PublicKey('00588e8e1d18cba576a4d35758069fe94e53f638b6faf7c07b8abd2bc5c5cdee'),
            weight: 3
          }
        ],
        nonce: 1234,
        purpose: cip36.VotingPurpose.CATALYST,
        rewardAddress: Cardano.Address('addr_test1qprhw4s70k0vzyhvxp6h97hvrtlkrlcvlmtgmaxdtjz87xrjkctk27ypuv9dzlzxusqse89naweygpjn5dxnygvus05sdq9h07'),
        stakeKey: Cardano.Ed25519PublicKey('e3cd2404c84de65f96918f18d5b445bcb933a7cda18eeded7945dd191e432369')
      });
      expect(
        Buffer.from(
          usingAutoFree((scope) => coreToCml.txMetadata(scope, votingRegistrationMetadata).to_bytes())
        ).toString('hex')
      ).toEqual(
        'a119ef64a501828258200036ef3e1f0d3f5989e2d155ea54bdb2a72c4c456ccb959af4c94868f473f5a00182582000588e8e1d18cba576a4d35758069fe94e53f638b6faf7c07b8abd2bc5c5cdee03025820e3cd2404c84de65f96918f18d5b445bcb933a7cda18eeded7945dd191e432369035839004777561e7d9ec112ec307572faec1aff61ff0cfed68df4cd5c847f1872b617657881e30ad17c46e4010c9cb3ebb2440653a34d32219c83e9041904d20500'
      );
      const signedCip36Metadata = await cip36.metadataBuilder.signVotingRegistration(votingRegistrationMetadata, {
        signBlob: async (blob) => {
          const privateStakeKey = CML.PrivateKey.from_normal_bytes(
            Buffer.from('852fa5d17df3efdfdcd6dac53ec9fe5593f3c0bd7cadb3c2af76c7e15dfa8a5c', 'hex')
          );
          return Cardano.Ed25519Signature(privateStakeKey.sign(Buffer.from(blob, 'hex')).to_hex());
        }
      });
      expect((signedCip36Metadata.get(61_285n) as Cardano.MetadatumMap).get(1n)).toEqual(
        Buffer.from(
          'c6f5d88690b9bf52d41feb7e5c0c867895a7b90014d497d9994063cbc21883f75bf6c7a63ac6cfda5a17a4c30f199890d3a0a2be7d8327f79dc50f94644d2401',
          'hex'
        )
      );
    });
  });
});
