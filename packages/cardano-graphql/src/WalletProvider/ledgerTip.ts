import { Cardano, WalletProvider } from '@cardano-sdk/core';
import { WalletProviderFnProps } from './WalletProviderFnProps';

export const ledgerTipProvider =
  ({ getExactlyOneObject, sdk }: WalletProviderFnProps): WalletProvider['ledgerTip'] =>
  async () => {
    const { queryBlock } = await sdk.Tip();
    const tip = getExactlyOneObject(queryBlock, 'tip');
    return { blockNo: tip.blockNo, hash: Cardano.BlockId(tip.hash), slot: tip.slot.number };
  };
