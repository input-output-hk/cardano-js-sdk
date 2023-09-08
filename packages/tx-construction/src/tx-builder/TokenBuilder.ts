import { Cardano } from '@cardano-sdk/core';

export class TxTokenBuilder {
  #assets: Cardano.TokenMap;
  #policyId: Cardano.PolicyId;

  constructor(policyId: Cardano.PolicyId) {
    this.#policyId = policyId;
    this.#assets = new Map();
  }

  #toHex = (value: string) =>
    value
      .split('')
      .map((s) => s.charCodeAt(0).toString(16))
      .join('');

  addAsset(tokenName: string, quantity: bigint): TxTokenBuilder {
    this.#assets.set(Cardano.AssetId(`${this.#policyId}${this.#toHex(tokenName)}`), quantity);
    return this;
  }

  build(): Cardano.TokenMap {
    return this.#assets ? this.#assets : new Map();
  }
}
