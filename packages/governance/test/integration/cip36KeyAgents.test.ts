import { AddressType, Ed25519KeyPair, InMemoryKeyAgent, KeyAgent, util } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { cip36 } from '../../src';
import { testKeyAgent } from '../../../key-management/test/mocks';

describe('cip36', () => {
  // This is the KeyAgent used by the wallet, that has access to private stake key.
  // Right now it will only work with InMemoryKeyAgent because HW implementations lack `signBlob`.
  // However, it should be possible to implement `signBlob` for HW devices in the future.
  let walletKeyAgent: KeyAgent;

  beforeAll(async () => {
    walletKeyAgent = await testKeyAgent();
  });

  describe('with some vote key chosen by the wallet', () => {
    let cip36VoteKeyPair: Ed25519KeyPair;

    beforeAll(async () => {
      // This is the KeyAgent used to create vote key pair:
      // - it can be the same key agent that the wallet uses,
      //   then vote key would be derived from the same seedphrase.
      // - it can also be a separate key agent, then it would be using a different seedphrase,
      //   but right now it's the only way to support vote when stake key is controlled by a HW device.
      const cip36VoteKeyAgent: InMemoryKeyAgent = (await testKeyAgent()) as unknown as InMemoryKeyAgent;
      cip36VoteKeyPair = await util.toEd25519KeyPair(
        await cip36VoteKeyAgent.exportExtendedKeyPair([
          cip36.CIP36VoteKeyDerivationPath.PURPOSE,
          cip36.CIP36VoteKeyDerivationPath.COIN_TYPE,
          walletKeyAgent.accountIndex, // using same account index as wallet's key agent here
          0, // chain as per cip36
          0 // address_index as per cip36
        ]),
        cip36VoteKeyAgent.bip32Ed25519
      );
    });

    it('can create cip36 voting registration metadata', async () => {
      // Just ensuring we have some address. BaseWallet already does this internally.
      const groupedAddress = await walletKeyAgent.deriveAddress({ index: 0, type: AddressType.External }, 0);
      const paymentAddress = groupedAddress.address;
      // InMemoryKeyAgent uses this derivation path for stake key.
      const stakeKey = await walletKeyAgent.derivePublicKey(util.STAKE_KEY_DERIVATION_PATH);
      // "Delegating" voting power to your own vote key
      const delegations: cip36.VoteKeyDelegation[] = [
        {
          cip36VoteKey: cip36VoteKeyPair.vkey,
          weight: 1
        }
      ];
      const votingRegistrationMetadata: Cardano.TxMetadata = cip36.metadataBuilder.buildVotingRegistration({
        delegations,
        paymentAddress,
        purpose: cip36.VotingPurpose.CATALYST,
        stakeKey
      });
      const signedVotingRegistrationMetadata: Cardano.TxMetadata = await cip36.metadataBuilder.signVotingRegistration(
        votingRegistrationMetadata,
        {
          // signing metadata with your wallet's stake key
          signBlob: (blob) =>
            walletKeyAgent.signBlob(util.STAKE_KEY_DERIVATION_PATH, blob).then(({ signature }) => signature)
        }
      );
      expect(signedVotingRegistrationMetadata.size).toBe(2);
    });
  });
});
