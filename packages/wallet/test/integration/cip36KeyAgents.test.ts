import { Cardano } from '@cardano-sdk/core';
import { KeyManagement, cip36 } from '../../src';
import { testKeyAgent } from '../mocks';

describe('cip36', () => {
  // This is the KeyAgent used by the wallet, that has access to private stake key.
  // Right now it will only work with InMemoryKeyAgent because HW implementations lack `signBlob`.
  // However, it should be possible to implement `signBlob` for HW devices in the future.
  let walletKeyAgent: KeyManagement.KeyAgent;

  beforeAll(async () => {
    walletKeyAgent = await testKeyAgent();
  });

  describe('with some voting key chosen by the wallet', () => {
    let votingKeyPair: KeyManagement.Ed25519KeyPair;

    beforeAll(async () => {
      // This is the KeyAgent used to create voting key pair:
      // - it can be the same key agent that the wallet uses,
      //   then voting key would be derived from the same seedphrase.
      // - it can also be a separate key agent, then it would be using a different seedphrase,
      //   but right now it's the only way to support voting when stake key is controlled by a HW device.
      const votingKeyAgent: KeyManagement.InMemoryKeyAgent = await testKeyAgent();
      votingKeyPair = KeyManagement.util.toEd25519KeyPair(
        await votingKeyAgent.exportExtendedKeyPair([
          cip36.VotingKeyDerivationPath.PURPOSE,
          cip36.VotingKeyDerivationPath.COIN_TYPE,
          KeyManagement.util.harden(walletKeyAgent.accountIndex), // using same account index as wallet's key agent here
          0, // chain as per cip36
          0 // address_index as per cip36
        ])
      );
    });

    it('can create cip36 voting registration metadata', async () => {
      // Just ensuring we have some address. SingleAddressWallet already does this internally.
      await walletKeyAgent.deriveAddress({ index: 0, type: KeyManagement.AddressType.External });
      // SingleAddressWallet uses a single reward account, so it can be taken from any GroupedAddress
      const rewardAccount = walletKeyAgent.knownAddresses[0].rewardAccount;
      // InMemoryKeyAgent uses this derivation path for stake key.
      const stakeKey = await walletKeyAgent.derivePublicKey(KeyManagement.util.STAKE_KEY_DERIVATION_PATH);
      // "Delegating" voting power to your own voting key
      const delegations: cip36.GovernanceKeyDelegation[] = [
        {
          votingKey: votingKeyPair.vkey,
          weight: 1
        }
      ];
      const votingRegistrationMetadata: Cardano.TxMetadata = cip36.metadataBuilder.buildVotingRegistration({
        delegations,
        purpose: cip36.VotingPurpose.CATALYST,
        rewardAccount,
        stakeKey
      });
      const signedVotingRegistrationMetadata: Cardano.TxMetadata = await cip36.metadataBuilder.signVotingRegistration(
        votingRegistrationMetadata,
        {
          // signing metadata with your wallet's stake key
          signBlob: (blob) =>
            walletKeyAgent
              .signBlob(KeyManagement.util.STAKE_KEY_DERIVATION_PATH, blob)
              .then(({ signature }) => signature)
        }
      );
      expect(signedVotingRegistrationMetadata.size).toBe(2);
    });
  });
});
