/* eslint-disable prettier/prettier */
import { Schema } from '@cardano-ogmios/client';
import { BigIntMath } from '@cardano-sdk/core';

const throwIfNegative = (value: bigint | number): void => {
  if (value < 0) {
    throw new Error('The value provided cannot be applied as it will result in a negative balance');
  }
};

// eslint-disable-next-line sonarjs/cognitive-complexity
export const applyValue = (balance: Schema.Value, value: Schema.Value, spending = false): Schema.Value => {
  const coins = balance.coins + (spending ? -Math.abs(value.coins) : value.coins);
  throwIfNegative(coins);
  const balanceToApply: Schema.Value = { coins };
  if (balance.assets !== undefined || value.assets !== undefined) {
    balanceToApply.assets = { ...balance.assets } ?? {};
  }
  const assets = Object.entries(value.assets ?? {});
  if (assets.length > 0) {
    for (const [assetId, qty] of assets) {
      balanceToApply.assets![assetId] =
        balance.assets![assetId] !== undefined
          ? balance.assets![assetId] + (spending ? -BigIntMath.abs(qty) : qty)
          : (spending ? -BigIntMath.abs(qty) : qty);
      throwIfNegative(balanceToApply.assets![assetId]);
    }
  }

  return balanceToApply;
};
