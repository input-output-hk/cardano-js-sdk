import { Cardano, util } from '@cardano-sdk/core';

/** `TxTokenBuilder` is a class for creating a token bundle, for the given policyId. */
export class TxTokenBuilder {
  #assets: Cardano.TokenMap;
  #policyId: Cardano.PolicyId;

  constructor(policyId: Cardano.PolicyId) {
    this.#policyId = policyId;
    this.#assets = new Map();
  }

  addAsset(tokenName: string, quantity: bigint): TxTokenBuilder {
    this.#assets.set(Cardano.AssetId.fromParts(this.#policyId, Cardano.AssetName(util.utf8ToHex(tokenName))), quantity);
    return this;
  }

  build(): Cardano.TokenMap {
    return this.#assets ? new Map(this.#assets) : new Map();
  }
}
