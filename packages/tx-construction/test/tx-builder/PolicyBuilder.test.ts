import { AccountKeyDerivationPath, Bip32Account, KeyRole } from '@cardano-sdk/key-management';
import { Bip32PublicKeyHex } from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';

import { PolicyBuilder } from '../../src/tx-builder/PolicyBuilder';

describe('PolicyBuilder', () => {
  let policyBuilder: PolicyBuilder;
  const newDerivationPath: AccountKeyDerivationPath = { index: 1, role: KeyRole.External };

  beforeEach(() => {
    // help initialize the PolicyBuilder instance
    const bip32Account = new Bip32Account({
      accountIndex: 0,
      chainId: Cardano.ChainIds.Preview,
      extendedAccountPublicKey: Bip32PublicKeyHex(
        'fc5ab25e830b67c47d0a17411bf7fdabf711a597fb6cf04102734b0a2934ceaaa65ff5e7c52498d52c07b8ddfcd436fc2b4d2775e2984a49d0c79f65ceee4779'
      )
    });
    policyBuilder = new PolicyBuilder(bip32Account);
  });

  it('should update the derivation path', () => {
    policyBuilder.setDerivationPath(newDerivationPath);
    const updatedDerivationPath = policyBuilder.getDerivationPath();
    expect(updatedDerivationPath).toEqual(newDerivationPath);
  });

  it('should generate different keyHash, policy script and id when derivation path is updated', async () => {
    const initialPolicyScript = await policyBuilder.getPolicyScript();
    const initialPolicyId = await policyBuilder.getPolicyId();
    const initialKeyHash = await policyBuilder.getKeyHash();

    policyBuilder.setDerivationPath(newDerivationPath);

    const updatedPolicyScript = await policyBuilder.getPolicyScript();
    const updatedPolicyId = await policyBuilder.getPolicyId();
    const updatedKeyHash = await policyBuilder.getKeyHash();

    expect(updatedPolicyScript).not.toEqual(initialPolicyScript);
    expect(updatedPolicyId).not.toEqual(initialPolicyId);
    expect(updatedKeyHash).not.toEqual(initialKeyHash);
  });
});
