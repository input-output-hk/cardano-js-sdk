import { AccountKeyDerivationPath, AsyncKeyAgent, KeyRole } from '@cardano-sdk/key-management';
import { Cardano, nativeScriptPolicyId } from '@cardano-sdk/core';
import { Ed25519KeyHashHex } from '@cardano-sdk/crypto';

export class PolicyBuilder {
  #keyAgent: AsyncKeyAgent;
  #derivationPath: AccountKeyDerivationPath;
  #derivationPathUpdated = false;
  #policyScript: Cardano.NativeScript;
  #keyHash: Ed25519KeyHashHex;

  constructor(keyAgent: AsyncKeyAgent) {
    this.#keyAgent = keyAgent;
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
    const pubKey = await this.#keyAgent.derivePublicKey(this.getDerivationPath());
    this.#keyHash = await (await this.#keyAgent.getBip32Ed25519()).getPubKeyHash(pubKey);
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
