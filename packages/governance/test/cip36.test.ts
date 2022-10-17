/* eslint-disable max-len */
import { CSL, Cardano, coreToCsl } from '@cardano-sdk/core';
import { cip36 } from '../src';
import { usingAutoFree } from '@cardano-sdk/util';
import delay from 'delay';

describe('cip36', () => {
  describe('metadataBuilder', () => {
    it('uses timestamp as nonce by default', async () => {
      const props: cip36.BuildVotingRegistrationProps = {
        delegations: [
          {
            votingKey: Cardano.Ed25519PublicKey('a6a3c0447aeb9cc54cf6422ba32b294e5e1c3ef6d782f2acff4a70694c4d1663'),
            weight: 1
          }
        ],
        purpose: cip36.VotingPurpose.CATALYST,
        rewardAccount: Cardano.RewardAccount('stake_test1uzhr5zn6akj2affzua8ylcm8t872spuf5cf6tzjrvnmwemcehgcjm'),
        stakeKey: Cardano.Ed25519PublicKey('86870efc99c453a873a16492ce87738ec79a0ebd064379a62e2c9cf4e119219e')
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
            votingKey: Cardano.Ed25519PublicKey('a6a3c0447aeb9cc54cf6422ba32b294e5e1c3ef6d782f2acff4a70694c4d1663'),
            weight: 1
          },
          {
            votingKey: Cardano.Ed25519PublicKey('00588e8e1d18cba576a4d35758069fe94e53f638b6faf7c07b8abd2bc5c5cdee'),
            weight: 3
          }
        ],
        nonce: 1234,
        purpose: cip36.VotingPurpose.CATALYST,
        rewardAccount: Cardano.RewardAccount('stake_test1uzhr5zn6akj2affzua8ylcm8t872spuf5cf6tzjrvnmwemcehgcjm'),
        stakeKey: Cardano.Ed25519PublicKey('86870efc99c453a873a16492ce87738ec79a0ebd064379a62e2c9cf4e119219e')
      });
      expect(
        Buffer.from(
          usingAutoFree((scope) => coreToCsl.txMetadata(scope, votingRegistrationMetadata).to_bytes())
        ).toString('hex')
      ).toEqual(
        'a119ef64a50182825820a6a3c0447aeb9cc54cf6422ba32b294e5e1c3ef6d782f2acff4a70694c4d16630182582000588e8e1d18cba576a4d35758069fe94e53f638b6faf7c07b8abd2bc5c5cdee0302582086870efc99c453a873a16492ce87738ec79a0ebd064379a62e2c9cf4e119219e03581de0ae3a0a7aeda4aea522e74e4fe36759fca80789a613a58a4364f6ecef041904d20500'
      );
      const signedCip36Metadata = await cip36.metadataBuilder.signVotingRegistration(votingRegistrationMetadata, {
        signBlob: async (blob) => {
          const privateStakeKey = CSL.PrivateKey.from_normal_bytes(
            Buffer.from('f5beaeff7932a4164d270afde7716067582412e8977e67986cd9b456fc082e3a', 'hex')
          );
          return Cardano.Ed25519Signature(privateStakeKey.sign(Buffer.from(blob, 'hex')).to_hex());
        }
      });
      expect((signedCip36Metadata.get(61_285n) as Cardano.MetadatumMap).get(1n)).toEqual(
        Buffer.from(
          '3aaa2e6b43c0a96e880a7d70df84dffb2a1a17b19d7a99a6ed27b91d499b32027c43acfbf6dff097af7634b2ee38c8039af259b0b6a64316f02b4ffee28a0608',
          'hex'
        )
      );
    });
  });
});
