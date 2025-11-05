import { Cardano } from '@cardano-sdk/core';
import { cip19TestVectors } from '@cardano-sdk/util-dev';
import { createPaymentCredentialFilter, extractCredentials, minimizeCredentialSet } from '../src/credentialUtils';

describe('credentialUtils', () => {
  describe('extractCredentials', () => {
    describe('BaseAddress with different credential type combinations', () => {
      it('extracts payment KeyHash + stake KeyHash credentials', () => {
        const addresses = [cip19TestVectors.basePaymentKeyStakeKey];
        const result = extractCredentials(addresses);

        // Should extract one payment credential and one reward account (stake address)
        expect(result.paymentCredentials.size).toBe(1);
        expect(result.rewardAccounts.size).toBe(1);

        // Payment credential should be addr_vkh (key hash)
        const paymentCred = [...result.paymentCredentials.keys()][0];
        expect(paymentCred).toMatch(/^addr_vkh1/);

        // RewardAccount (stake address) should have stake/stake_test prefix
        const rewardAccount = [...result.rewardAccounts.keys()][0];
        expect(rewardAccount).toMatch(/^stake1/);

        // Both should reference the same address
        expect(result.paymentCredentials.get(paymentCred)).toEqual([cip19TestVectors.basePaymentKeyStakeKey]);
        expect(result.rewardAccounts.get(rewardAccount)).toEqual([cip19TestVectors.basePaymentKeyStakeKey]);

        // No skipped addresses
        expect(result.skippedAddresses.byron).toEqual([]);
        expect(result.skippedAddresses.pointer).toEqual([]);
      });

      it('extracts payment ScriptHash + stake KeyHash credentials', () => {
        const addresses = [cip19TestVectors.basePaymentScriptStakeKey];
        const result = extractCredentials(addresses);

        expect(result.paymentCredentials.size).toBe(1);
        expect(result.rewardAccounts.size).toBe(1);

        // Payment credential should be script (script hash)
        const paymentCred = [...result.paymentCredentials.keys()][0];
        expect(paymentCred).toMatch(/^script1/);

        // Stake credential should be RewardAccount
        const stakeCred = [...result.rewardAccounts.keys()][0];
        expect(stakeCred).toMatch(/^stake1/);

        expect(result.skippedAddresses.byron).toEqual([]);
        expect(result.skippedAddresses.pointer).toEqual([]);
      });

      it('extracts payment KeyHash + stake ScriptHash credentials', () => {
        const addresses = [cip19TestVectors.basePaymentKeyStakeScript];
        const result = extractCredentials(addresses);

        expect(result.paymentCredentials.size).toBe(1);
        expect(result.rewardAccounts.size).toBe(1);

        // Payment credential should be addr_vkh (key hash)
        const paymentCred = [...result.paymentCredentials.keys()][0];
        expect(paymentCred).toMatch(/^addr_vkh1/);

        // Stake credential should be RewardAccount with stake prefix
        const stakeCred = [...result.rewardAccounts.keys()][0];
        expect(stakeCred).toMatch(/^stake1/);

        expect(result.skippedAddresses.byron).toEqual([]);
        expect(result.skippedAddresses.pointer).toEqual([]);
      });

      it('extracts payment ScriptHash + stake ScriptHash credentials', () => {
        const addresses = [cip19TestVectors.basePaymentScriptStakeScript];
        const result = extractCredentials(addresses);

        expect(result.paymentCredentials.size).toBe(1);
        expect(result.rewardAccounts.size).toBe(1);

        // Payment credential should be script
        const paymentCred = [...result.paymentCredentials.keys()][0];
        expect(paymentCred).toMatch(/^script1/);

        // Stake credential should be RewardAccount
        const stakeCred = [...result.rewardAccounts.keys()][0];
        expect(stakeCred).toMatch(/^stake1/);

        expect(result.skippedAddresses.byron).toEqual([]);
        expect(result.skippedAddresses.pointer).toEqual([]);
      });
    });

    describe('EnterpriseAddress with different credential types', () => {
      it('extracts payment KeyHash only (no stake credential)', () => {
        const addresses = [cip19TestVectors.enterpriseKey];
        const result = extractCredentials(addresses);

        // Should extract only payment credential
        expect(result.paymentCredentials.size).toBe(1);
        expect(result.rewardAccounts.size).toBe(0);

        // Payment credential should be addr_vkh (key hash)
        const paymentCred = [...result.paymentCredentials.keys()][0];
        expect(paymentCred).toMatch(/^addr_vkh1/);

        expect(result.paymentCredentials.get(paymentCred)).toEqual([cip19TestVectors.enterpriseKey]);

        expect(result.skippedAddresses.byron).toEqual([]);
        expect(result.skippedAddresses.pointer).toEqual([]);
      });

      it('extracts payment ScriptHash only (no stake credential)', () => {
        const addresses = [cip19TestVectors.enterpriseScript];
        const result = extractCredentials(addresses);

        // Should extract only payment credential
        expect(result.paymentCredentials.size).toBe(1);
        expect(result.rewardAccounts.size).toBe(0);

        // Payment credential should be script
        const paymentCred = [...result.paymentCredentials.keys()][0];
        expect(paymentCred).toMatch(/^script1/);

        expect(result.paymentCredentials.get(paymentCred)).toEqual([cip19TestVectors.enterpriseScript]);

        expect(result.skippedAddresses.byron).toEqual([]);
        expect(result.skippedAddresses.pointer).toEqual([]);
      });
    });

    describe('Special address types', () => {
      it('collects Byron addresses in skippedAddresses.byron', () => {
        const addresses = [cip19TestVectors.byronMainnetYoroi, cip19TestVectors.byronTestnetDaedalus];
        const result = extractCredentials(addresses);

        // No credentials extracted
        expect(result.paymentCredentials.size).toBe(0);
        expect(result.rewardAccounts.size).toBe(0);

        // Byron addresses should be in skipped list
        expect(result.skippedAddresses.byron).toEqual(addresses);
        expect(result.skippedAddresses.pointer).toEqual([]);
      });

      it('collects Pointer addresses in skippedAddresses.pointer', () => {
        const addresses = [cip19TestVectors.pointerKey, cip19TestVectors.pointerScript];
        const result = extractCredentials(addresses);

        // No credentials extracted
        expect(result.paymentCredentials.size).toBe(0);
        expect(result.rewardAccounts.size).toBe(0);

        // Pointer addresses should be in skipped list
        expect(result.skippedAddresses.byron).toEqual([]);
        expect(result.skippedAddresses.pointer).toEqual(addresses);
      });
    });

    describe('Grouping behavior', () => {
      it('groups multiple addresses with same payment credential', () => {
        // Create two different BaseAddresses that happen to share the same payment credential
        // but have different stake credentials (this is a realistic scenario)
        const addr1 = cip19TestVectors.basePaymentKeyStakeKey;
        const addr2 = cip19TestVectors.basePaymentKeyStakeScript;

        const addresses = [addr1, addr2];
        const result = extractCredentials(addresses);

        // Should have one payment credential (shared)
        expect(result.paymentCredentials.size).toBe(1);

        // Should have two stake credentials (different)
        expect(result.rewardAccounts.size).toBe(2);

        // Payment credential should reference both addresses
        const paymentCred = [...result.paymentCredentials.keys()][0];
        expect(result.paymentCredentials.get(paymentCred)).toHaveLength(2);
        expect(result.paymentCredentials.get(paymentCred)).toContain(addr1);
        expect(result.paymentCredentials.get(paymentCred)).toContain(addr2);
      });

      it('groups multiple addresses with same stake credential', () => {
        // basePaymentKeyStakeKey and basePaymentScriptStakeKey share the same stake credential
        const addr1 = cip19TestVectors.basePaymentKeyStakeKey;
        const addr2 = cip19TestVectors.basePaymentScriptStakeKey;

        const addresses = [addr1, addr2];
        const result = extractCredentials(addresses);

        // Should have two payment credentials (different)
        expect(result.paymentCredentials.size).toBe(2);

        // Should have one stake credential (shared)
        expect(result.rewardAccounts.size).toBe(1);

        // Stake credential should reference both addresses
        const stakeCred = [...result.rewardAccounts.keys()][0];
        expect(result.rewardAccounts.get(stakeCred)).toHaveLength(2);
        expect(result.rewardAccounts.get(stakeCred)).toContain(addr1);
        expect(result.rewardAccounts.get(stakeCred)).toContain(addr2);
      });

      it('handles mixed BaseAddress and EnterpriseAddress', () => {
        const addresses = [cip19TestVectors.basePaymentKeyStakeKey, cip19TestVectors.enterpriseKey];
        const result = extractCredentials(addresses);

        // Both addresses share the same payment key hash, so only one payment credential
        expect(result.paymentCredentials.size).toBe(1);

        // Should have one stake credential (only from BaseAddress)
        expect(result.rewardAccounts.size).toBe(1);

        // Both addresses should be grouped under the same payment credential
        const paymentCred = [...result.paymentCredentials.keys()][0];
        expect(result.paymentCredentials.get(paymentCred)).toHaveLength(2);

        expect(result.skippedAddresses.byron).toEqual([]);
        expect(result.skippedAddresses.pointer).toEqual([]);
      });
    });

    describe('Bech32 encoding verification', () => {
      it('encodes payment KeyHash credentials as addr_vkh', () => {
        const addresses = [cip19TestVectors.basePaymentKeyStakeKey];
        const result = extractCredentials(addresses);

        const paymentCred = [...result.paymentCredentials.keys()][0];
        expect(paymentCred).toMatch(/^addr_vkh1/);

        // Verify it's valid PaymentCredential
        expect(() => Cardano.PaymentCredential(paymentCred)).not.toThrow();
      });

      it('encodes payment ScriptHash credentials as script', () => {
        const addresses = [cip19TestVectors.basePaymentScriptStakeKey];
        const result = extractCredentials(addresses);

        const paymentCred = [...result.paymentCredentials.keys()][0];
        expect(paymentCred).toMatch(/^script1/);

        // Verify it's valid PaymentCredential
        expect(() => Cardano.PaymentCredential(paymentCred)).not.toThrow();
      });

      it('encodes reward accounts (stake addresses) with stake prefix for KeyHash', () => {
        const addresses = [cip19TestVectors.basePaymentKeyStakeKey];
        const result = extractCredentials(addresses);

        const rewardAccount = [...result.rewardAccounts.keys()][0];
        expect(rewardAccount).toMatch(/^stake1/);

        // Verify it's valid RewardAccount
        expect(() => Cardano.RewardAccount(rewardAccount)).not.toThrow();
      });

      it('encodes reward accounts (stake addresses) with stake prefix for ScriptHash', () => {
        const addresses = [cip19TestVectors.basePaymentKeyStakeScript];
        const result = extractCredentials(addresses);

        const rewardAccount = [...result.rewardAccounts.keys()][0];
        expect(rewardAccount).toMatch(/^stake1/);

        // Verify it's valid RewardAccount
        expect(() => Cardano.RewardAccount(rewardAccount)).not.toThrow();
      });

      it('encodes mainnet reward accounts with "stake" prefix', () => {
        const addresses = [cip19TestVectors.basePaymentKeyStakeKey];
        const result = extractCredentials(addresses);

        const rewardAccount = [...result.rewardAccounts.keys()][0];
        expect(rewardAccount).toMatch(/^stake1/);
        expect(rewardAccount).not.toMatch(/^stake_test/);

        // Verify it's valid RewardAccount
        expect(() => Cardano.RewardAccount(rewardAccount)).not.toThrow();
      });

      it('encodes testnet reward accounts with "stake_test" prefix', () => {
        const addresses = [cip19TestVectors.testnetBasePaymentKeyStakeKey];
        const result = extractCredentials(addresses);

        const rewardAccount = [...result.rewardAccounts.keys()][0];
        expect(rewardAccount).toMatch(/^stake_test1/);

        // Verify it's valid RewardAccount
        expect(() => Cardano.RewardAccount(rewardAccount)).not.toThrow();
      });
    });

    describe('Edge cases', () => {
      it('handles empty address array', () => {
        const result = extractCredentials([]);

        expect(result.paymentCredentials.size).toBe(0);
        expect(result.rewardAccounts.size).toBe(0);
        expect(result.skippedAddresses.byron).toEqual([]);
        expect(result.skippedAddresses.pointer).toEqual([]);
      });

      it('handles duplicate addresses', () => {
        const addresses = [cip19TestVectors.basePaymentKeyStakeKey, cip19TestVectors.basePaymentKeyStakeKey];
        const result = extractCredentials(addresses);

        // Should still have one of each credential
        expect(result.paymentCredentials.size).toBe(1);
        expect(result.rewardAccounts.size).toBe(1);

        // Address should appear once in the list (deduplicated)
        const paymentCred = [...result.paymentCredentials.keys()][0];
        expect(result.paymentCredentials.get(paymentCred)).toHaveLength(1);
      });
    });
  });

  describe('minimizeCredentialSet', () => {
    it('Scenario 1: Single address (BaseAddress) - prefer payment credential', () => {
      // Single BaseAddress has both payment and stake credentials
      // Should prefer payment credential over stake when both cover the same address
      const addr1 = cip19TestVectors.basePaymentKeyStakeKey;
      const addressGroups = extractCredentials([addr1]);

      const result = minimizeCredentialSet({
        paymentCredentials: addressGroups.paymentCredentials,
        rewardAccounts: addressGroups.rewardAccounts
      });

      // Should keep payment credential, remove stake credential
      expect(result.paymentCredentials.size).toBe(1);
      expect(result.rewardAccounts.size).toBe(0);
    });

    it('Scenario 2: Single address (EnterpriseAddress) - only payment credential', () => {
      // EnterpriseAddress has only payment credential
      const addr1 = cip19TestVectors.enterpriseKey;
      const addressGroups = extractCredentials([addr1]);

      const result = minimizeCredentialSet({
        paymentCredentials: addressGroups.paymentCredentials,
        rewardAccounts: addressGroups.rewardAccounts
      });

      // Should keep payment credential (only option)
      expect(result.paymentCredentials.size).toBe(1);
      expect(result.rewardAccounts.size).toBe(0);
    });

    it('Scenario 3: 2 addresses with same stake credential, different payment credentials', () => {
      // Two addresses share stake credential but have different payment credentials
      const addr1 = cip19TestVectors.basePaymentKeyStakeKey;
      const addr2 = cip19TestVectors.basePaymentScriptStakeKey;
      const addressGroups = extractCredentials([addr1, addr2]);

      const result = minimizeCredentialSet({
        paymentCredentials: addressGroups.paymentCredentials,
        rewardAccounts: addressGroups.rewardAccounts
      });

      // Stake credential covers both addresses, so it should be preferred
      expect(result.paymentCredentials.size).toBe(0);
      expect(result.rewardAccounts.size).toBe(1);
    });

    it('Scenario 4: prefers payment credentials when coverage is equal (3 addresses, overlapping credentials)', () => {
      // Three addresses:
      // addr1 = payment KEY + stake KEY
      // addr2 = payment SCRIPT + stake KEY (shares stake with addr1)
      // addr3 = payment KEY + stake SCRIPT (shares payment with addr1)
      const addr1 = cip19TestVectors.basePaymentKeyStakeKey;
      const addr2 = cip19TestVectors.basePaymentScriptStakeKey;
      const addr3 = cip19TestVectors.basePaymentKeyStakeScript;

      const addressGroups = extractCredentials([addr1, addr2, addr3]);

      const result = minimizeCredentialSet({
        paymentCredentials: addressGroups.paymentCredentials,
        rewardAccounts: addressGroups.rewardAccounts
      });

      // Payment KEY covers addr1 and addr3 (2 addresses)
      // Payment SCRIPT covers addr2 (1 address)
      // Stake KEY covers addr1 and addr2 (2 addresses)
      // Stake SCRIPT covers addr3 (1 address)
      // Both approaches need 2 credentials, but greedy algorithm prefers payment credentials
      expect(result.paymentCredentials.size).toBe(2);
      expect(result.rewardAccounts.size).toBe(0);
    });

    it('Scenario 5: All EnterpriseAddresses with different payment credentials', () => {
      // All addresses are EnterpriseAddress
      // Note: enterpriseKey and testnetEnterpriseKey share the same key hash
      // Payment credentials don't include network ID (per CIP-5), so they have the same credential
      const addr1 = cip19TestVectors.enterpriseKey;
      const addr2 = cip19TestVectors.enterpriseScript;
      const addr3 = cip19TestVectors.testnetEnterpriseScript;

      const addressGroups = extractCredentials([addr1, addr2, addr3]);

      const result = minimizeCredentialSet({
        paymentCredentials: addressGroups.paymentCredentials,
        rewardAccounts: addressGroups.rewardAccounts
      });

      // Should keep all payment credentials (no stake credentials to optimize)
      // addr1 uses key hash, addr2 uses script hash (mainnet), addr3 uses script hash (testnet)
      // Since payment credentials don't include network, addr2 and addr3 share the same credential
      expect(result.paymentCredentials.size).toBe(2);
      expect(result.rewardAccounts.size).toBe(0);
    });

    it('Scenario 6: Mixed BaseAddress and EnterpriseAddress', () => {
      // Mix of BaseAddress and EnterpriseAddress with different payment credentials
      const addr1 = cip19TestVectors.enterpriseKey; // Enterprise (payment1)
      const addr2 = cip19TestVectors.basePaymentScriptStakeKey; // Base (paymentScript + stake1)
      const addr3 = cip19TestVectors.basePaymentScriptStakeScript; // Base (paymentScript + stake2)
      // addr2 and addr3 share the same payment credential (script hash)

      const addressGroups = extractCredentials([addr1, addr2, addr3]);

      const result = minimizeCredentialSet({
        paymentCredentials: addressGroups.paymentCredentials,
        rewardAccounts: addressGroups.rewardAccounts
      });

      // payment1 covers addr1 (1 address)
      // paymentScript covers addr2 + addr3 (2 addresses) - prefer over stake1+stake2
      expect(result.paymentCredentials.size).toBe(2);
      expect(result.rewardAccounts.size).toBe(0);
    });

    it('handles empty credential maps', () => {
      const result = minimizeCredentialSet({
        paymentCredentials: new Map(),
        rewardAccounts: new Map()
      });

      expect(result.paymentCredentials.size).toBe(0);
      expect(result.rewardAccounts.size).toBe(0);
    });

    it('handles credentials with no addresses', () => {
      const result = minimizeCredentialSet({
        paymentCredentials: new Map(),
        rewardAccounts: new Map([[Cardano.RewardAccount(cip19TestVectors.rewardKey), []]])
      });

      // Credential with no addresses should be removed
      expect(result.paymentCredentials.size).toBe(0);
      expect(result.rewardAccounts.size).toBe(0);
    });
  });

  describe('createPaymentCredentialFilter', () => {
    // Constants for commonly used test inputs
    const BASE_KEY_STAKE_KEY_INPUT = [cip19TestVectors.basePaymentKeyStakeKey];
    const BASE_SCRIPT_STAKE_KEY_INPUT = [cip19TestVectors.basePaymentScriptStakeKey];
    const ENTERPRISE_KEY_INPUT = [cip19TestVectors.enterpriseKey];
    const ENTERPRISE_SCRIPT_INPUT = [cip19TestVectors.enterpriseScript];
    const POINTER_KEY_INPUT = [cip19TestVectors.pointerKey];
    const POINTER_SCRIPT_INPUT = [cip19TestVectors.pointerScript];

    // Constants for test description strings
    const WITH_KEY_HASH = 'with KeyHash payment credential';
    const WITH_SCRIPT_HASH = 'with ScriptHash payment credential';
    const EXACT_MATCH_TEST = 'passes filter for address with controlled payment credential (exact match)';

    describe('BaseAddress filtering', () => {
      describe(WITH_KEY_HASH, () => {
        const filter = createPaymentCredentialFilter(BASE_KEY_STAKE_KEY_INPUT);

        it(EXACT_MATCH_TEST, () => {
          // Same address should pass (fast path - exact match)
          expect(filter(cip19TestVectors.basePaymentKeyStakeKey)).toBe(true);
        });

        it('passes filter for address with same payment credential but different stake credential', () => {
          // Different address with same payment credential should pass
          // basePaymentKeyStakeKey has payment key hash, basePaymentKeyStakeScript has same payment key hash but different stake
          expect(filter(cip19TestVectors.basePaymentKeyStakeScript)).toBe(true);
        });

        it('rejects addresses with uncontrolled payment credentials', () => {
          // basePaymentScriptStakeKey has different payment credential (script vs key hash)
          expect(filter(cip19TestVectors.basePaymentScriptStakeKey)).toBe(false);
          // Address with same stake credential but different payment credential should also be rejected
          expect(filter(cip19TestVectors.basePaymentScriptStakeScript)).toBe(false);
        });
      });

      describe(WITH_SCRIPT_HASH, () => {
        const filter = createPaymentCredentialFilter(BASE_SCRIPT_STAKE_KEY_INPUT);

        it('passes filter for addresses with same payment credential', () => {
          // Same payment credential (script) should pass
          expect(filter(cip19TestVectors.basePaymentScriptStakeKey)).toBe(true);
          // Different stake but same payment credential (script) should pass
          expect(filter(cip19TestVectors.basePaymentScriptStakeScript)).toBe(true);
        });
      });
    });

    describe('EnterpriseAddress filtering', () => {
      describe(WITH_KEY_HASH, () => {
        const filter = createPaymentCredentialFilter(ENTERPRISE_KEY_INPUT);

        it(EXACT_MATCH_TEST, () => {
          expect(filter(cip19TestVectors.enterpriseKey)).toBe(true);
        });

        it('rejects address with uncontrolled payment credential', () => {
          // enterpriseScript has different payment credential
          expect(filter(cip19TestVectors.enterpriseScript)).toBe(false);
        });
      });

      describe(WITH_SCRIPT_HASH, () => {
        const filter = createPaymentCredentialFilter(ENTERPRISE_SCRIPT_INPUT);

        it('passes filter for script payment credential', () => {
          expect(filter(cip19TestVectors.enterpriseScript)).toBe(true);
        });
      });

      it('passes filter when EnterpriseAddress matches payment credential from BaseAddress', () => {
        const filter = createPaymentCredentialFilter(BASE_KEY_STAKE_KEY_INPUT);

        // enterpriseKey should have the same payment credential as basePaymentKeyStakeKey
        expect(filter(cip19TestVectors.enterpriseKey)).toBe(true);
      });
    });

    describe('PointerAddress filtering', () => {
      describe(WITH_KEY_HASH, () => {
        const filter = createPaymentCredentialFilter(POINTER_KEY_INPUT);

        it(EXACT_MATCH_TEST, () => {
          expect(filter(cip19TestVectors.pointerKey)).toBe(true);
        });

        it('rejects address with uncontrolled payment credential', () => {
          // pointerScript has different payment credential
          expect(filter(cip19TestVectors.pointerScript)).toBe(false);
        });
      });

      describe(WITH_SCRIPT_HASH, () => {
        const filter = createPaymentCredentialFilter(POINTER_SCRIPT_INPUT);

        it('passes filter for script payment credential', () => {
          expect(filter(cip19TestVectors.pointerScript)).toBe(true);
        });
      });

      it('passes filter when PointerAddress matches payment credential from BaseAddress', () => {
        const filter = createPaymentCredentialFilter(BASE_KEY_STAKE_KEY_INPUT);

        // pointerKey should have the same payment credential as basePaymentKeyStakeKey
        expect(filter(cip19TestVectors.pointerKey)).toBe(true);
      });
    });

    describe('Mixed credential types', () => {
      it('correctly filters KeyHash payment credentials', () => {
        const inputAddresses = [
          cip19TestVectors.basePaymentKeyStakeKey,
          cip19TestVectors.enterpriseKey,
          cip19TestVectors.pointerKey
        ];
        const filter = createPaymentCredentialFilter(inputAddresses);

        // All addresses with same key hash should pass
        expect(filter(cip19TestVectors.basePaymentKeyStakeKey)).toBe(true);
        expect(filter(cip19TestVectors.basePaymentKeyStakeScript)).toBe(true);
        expect(filter(cip19TestVectors.enterpriseKey)).toBe(true);
        expect(filter(cip19TestVectors.pointerKey)).toBe(true);

        // Addresses with script hash should not pass
        expect(filter(cip19TestVectors.basePaymentScriptStakeKey)).toBe(false);
        expect(filter(cip19TestVectors.enterpriseScript)).toBe(false);
        expect(filter(cip19TestVectors.pointerScript)).toBe(false);
      });

      it('correctly filters ScriptHash payment credentials', () => {
        const inputAddresses = [
          cip19TestVectors.basePaymentScriptStakeKey,
          cip19TestVectors.enterpriseScript,
          cip19TestVectors.pointerScript
        ];
        const filter = createPaymentCredentialFilter(inputAddresses);

        // All addresses with same script hash should pass
        expect(filter(cip19TestVectors.basePaymentScriptStakeKey)).toBe(true);
        expect(filter(cip19TestVectors.basePaymentScriptStakeScript)).toBe(true);
        expect(filter(cip19TestVectors.enterpriseScript)).toBe(true);
        expect(filter(cip19TestVectors.pointerScript)).toBe(true);

        // Addresses with key hash should not pass
        expect(filter(cip19TestVectors.basePaymentKeyStakeKey)).toBe(false);
        expect(filter(cip19TestVectors.enterpriseKey)).toBe(false);
        expect(filter(cip19TestVectors.pointerKey)).toBe(false);
      });

      it('correctly filters mixed KeyHash and ScriptHash credentials', () => {
        const inputAddresses = [
          cip19TestVectors.basePaymentKeyStakeKey, // key hash payment
          cip19TestVectors.basePaymentScriptStakeKey // script hash payment
        ];
        const filter = createPaymentCredentialFilter(inputAddresses);

        // Addresses with either controlled payment credential should pass
        expect(filter(cip19TestVectors.basePaymentKeyStakeKey)).toBe(true);
        expect(filter(cip19TestVectors.enterpriseKey)).toBe(true);
        expect(filter(cip19TestVectors.basePaymentScriptStakeKey)).toBe(true);
        expect(filter(cip19TestVectors.enterpriseScript)).toBe(true);
      });
    });

    describe('Edge cases', () => {
      it('rejects all addresses when input is empty', () => {
        const filter = createPaymentCredentialFilter([]);

        expect(filter(cip19TestVectors.basePaymentKeyStakeKey)).toBe(false);
        expect(filter(cip19TestVectors.enterpriseKey)).toBe(false);
        expect(filter(cip19TestVectors.pointerKey)).toBe(false);
      });

      it('skips Byron addresses in filter input (cannot extract payment credential)', () => {
        const inputAddresses = [cip19TestVectors.byronMainnetYoroi, cip19TestVectors.basePaymentKeyStakeKey];
        const filter = createPaymentCredentialFilter(inputAddresses);

        // Byron address itself should pass (exact match)
        expect(filter(cip19TestVectors.byronMainnetYoroi)).toBe(true);
        // Other addresses with key hash should still work
        expect(filter(cip19TestVectors.basePaymentKeyStakeKey)).toBe(true);
        expect(filter(cip19TestVectors.enterpriseKey)).toBe(true);
      });

      it('rejects Byron address when checking if it matches payment credentials', () => {
        const inputAddresses = [cip19TestVectors.basePaymentKeyStakeKey];
        const filter = createPaymentCredentialFilter(inputAddresses);

        // Byron address should not pass (cannot extract payment credential, no exact match)
        expect(filter(cip19TestVectors.byronMainnetYoroi)).toBe(false);
      });

      it('handles duplicate addresses in input', () => {
        const inputAddresses = [
          cip19TestVectors.basePaymentKeyStakeKey,
          cip19TestVectors.basePaymentKeyStakeKey,
          cip19TestVectors.enterpriseKey
        ];
        const filter = createPaymentCredentialFilter(inputAddresses);

        // Should work correctly despite duplicates
        expect(filter(cip19TestVectors.basePaymentKeyStakeKey)).toBe(true);
        expect(filter(cip19TestVectors.enterpriseKey)).toBe(true);
      });

      it('handles testnet addresses correctly', () => {
        const inputAddresses = [cip19TestVectors.testnetBasePaymentKeyStakeKey];
        const filter = createPaymentCredentialFilter(inputAddresses);

        // Same payment credential on testnet should pass
        expect(filter(cip19TestVectors.testnetBasePaymentKeyStakeKey)).toBe(true);
        expect(filter(cip19TestVectors.testnetEnterpriseKey)).toBe(true);
        expect(filter(cip19TestVectors.testnetPointerKey)).toBe(true);

        // Different payment credential should not pass
        expect(filter(cip19TestVectors.testnetBasePaymentScriptStakeKey)).toBe(false);
      });
    });

    describe('Performance optimization - exact address match', () => {
      it('uses fast path for exact address matches', () => {
        const inputAddresses = [cip19TestVectors.basePaymentKeyStakeKey, cip19TestVectors.enterpriseKey];
        const filter = createPaymentCredentialFilter(inputAddresses);

        // These should use the fast path (exact match in Set)
        expect(filter(cip19TestVectors.basePaymentKeyStakeKey)).toBe(true);
        expect(filter(cip19TestVectors.enterpriseKey)).toBe(true);

        // This should use the credential extraction path (not in exact match Set)
        expect(filter(cip19TestVectors.basePaymentKeyStakeScript)).toBe(true);
      });
    });
  });
});
