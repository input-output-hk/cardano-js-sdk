import { AccountKeyDerivationPath, Bip32Account, KeyRole } from '@cardano-sdk/key-management';
import { Cardano, nativeScriptPolicyId } from '@cardano-sdk/core';
import { Ed25519KeyHashHex } from '@cardano-sdk/crypto';

/**
 * `PolicyBuilder` is a class for building minting/burning policies be used by TxBuilder.
 * The signer keyHash is defined by the configurable derivation path.
 *
 * By default it uses a single issuer native script policy, but it can be overridden with a custom policy,
 * using the `setPolicyScript` method.
 */
export class PolicyBuilder {
  #bip32Account: Bip32Account;
  #derivationPath: AccountKeyDerivationPath;
  #derivationPathUpdated = false;
  #policyScript: Cardano.NativeScript;
  #keyHash: Ed25519KeyHashHex;

  constructor(bip32Account: Bip32Account) {
    this.#bip32Account = bip32Account;
    this.#derivationPath = {
      index: 0,
      role: KeyRole.External
    };
  }

  setDerivationPath(derivationPath: AccountKeyDerivationPath) {
    this.#derivationPath = derivationPath;
    this.#derivationPathUpdated = true;
  }

  getDerivationPath() {
    return this.#derivationPath;
  }

  setPolicyScript(script: Cardano.NativeScript) {
    this.#policyScript = script;
    return this;
  }

  async getPolicyScript() {
    if (!this.#policyScript || this.#derivationPathUpdated) {
      this.#policyScript = await this.#getDefaultPolicyScript();
    }
    return this.#policyScript;
  }

  async getKeyHash(): Promise<Ed25519KeyHashHex> {
    if (this.#keyHash && !this.#derivationPathUpdated) {
      return this.#keyHash;
    }
    const pubKey = await this.#bip32Account.derivePublicKey(this.getDerivationPath());
    this.#keyHash = (await pubKey.hash()).hex();
    this.#derivationPathUpdated = false;
    return this.#keyHash;
  }

  async #getDefaultPolicyScript(): Promise<Cardano.NativeScript> {
    return {
      __type: Cardano.ScriptType.Native,
      keyHash: await this.getKeyHash(),
      kind: Cardano.NativeScriptKind.RequireSignature
    };
  }

  async getPolicyId() {
    const policyScript = await this.getPolicyScript();
    return nativeScriptPolicyId(policyScript);
  }
}
