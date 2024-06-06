/* eslint-disable complexity */
/* eslint-disable unicorn/no-nested-ternary */
import { BigIntMath } from '@cardano-sdk/util';
import type { Ogmios } from '@cardano-sdk/ogmios';

const throwIfNegative = (value: bigint | number): void => {
  if (value < 0) {
    throw new Error('The value provided cannot be applied as it will result in a negative balance');
  }
};

export const applyValue = (
  balance: Ogmios.Schema.Value,
  value: Ogmios.Schema.Value,
  spending = false
  // eslint-disable-next-line sonarjs/cognitive-complexity
): Ogmios.Schema.Value => {
  // This is a workaround. coins is typed as a bigint,
  // but it's sometimes being parsed from the raw response as a number.
  const valueCoins: bigint = typeof value.coins === 'bigint' ? value.coins : BigInt(value.coins);
  const balanceCoins: bigint = typeof balance.coins === 'bigint' ? balance.coins : BigInt(balance.coins);
  const coins = balanceCoins + (spending ? -BigIntMath.abs(valueCoins) : valueCoins);
  throwIfNegative(coins);
  const balanceToApply: Ogmios.Schema.Value = { coins };
  if (balance.assets !== undefined || value.assets !== undefined) {
    balanceToApply.assets = { ...balance.assets } ?? {};
  }
  const assets = Object.entries(value.assets ?? {});
  if (assets.length > 0) {
    for (const [assetId, qty] of assets) {
      balanceToApply.assets![assetId] =
        balance.assets![assetId] !== undefined
          ? balance.assets![assetId] + (spending ? -BigIntMath.abs(qty) : qty)
          : spending
          ? -BigIntMath.abs(qty)
          : qty;
      throwIfNegative(balanceToApply.assets![assetId]);
    }
  }

  return balanceToApply;
};
