import { Cardano, WalletProvider, util } from '@cardano-sdk/core';
import { WalletProviderFnProps } from './WalletProviderFnProps';

export const queryBlocksByHashesProvider =
  ({ sdk, getExactlyOneObject }: WalletProviderFnProps): WalletProvider['queryBlocksByHashes'] =>
  async (hashes) => {
    const { queryBlock } = await sdk.BlocksByHashes({ hashes: hashes as unknown as string[] });
    if (!queryBlock) return [];
    return queryBlock.filter(util.isNotNil).map(
      (block): Cardano.Block => ({
        confirmations: block.confirmations,
        date: new Date(block.slot.date),
        epoch: block.epoch.number,
        epochSlot: block.slot.slotInEpoch,
        fees: BigInt(block.totalFees),
        header: {
          blockNo: block.blockNo,
          hash: Cardano.BlockId(block.hash),
          slot: block.slot.number
        },
        nextBlock: Cardano.BlockId(block.nextBlock.hash),
        previousBlock: Cardano.BlockId(block.previousBlock.hash),
        size: Number(block.size),
        slotLeader: Cardano.PoolId(block.issuer.id),
        totalOutput: BigInt(block.totalOutput),
        txCount: block.transactionsAggregate?.count || 0,
        // TODO: test getExactlyOneObject is used here
        vrf: Cardano.VrfVkBech32(getExactlyOneObject(block.issuer.poolParameters, 'PoolParameters').vrf)
      })
    );
  };
