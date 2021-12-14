import { Cardano, ProviderError, ProviderFailure, WalletProvider, util } from '@cardano-sdk/core';
import { ProviderFromSdk, createProvider } from '../util';

export const createGraphQLWalletProviderFromSdk: ProviderFromSdk<WalletProvider> = (sdk) =>
  ({
    async currentWalletProtocolParameters() {
      const { queryProtocolParameters } = await sdk.ProtocolParameters();
      if (!queryProtocolParameters || queryProtocolParameters.length === 0)
        throw new ProviderError(ProviderFailure.NotFound);
      if (queryProtocolParameters.length !== 1)
        throw new ProviderError(ProviderFailure.InvalidResponse, null, 'Expected exactly 1 protocol parameters object');
      const [protocolParams] = queryProtocolParameters;
      if (!protocolParams) throw new ProviderError(ProviderFailure.InvalidResponse);
      return {
        coinsPerUtxoWord: protocolParams.coinsPerUtxoWord,
        maxCollateralInputs: protocolParams.maxCollateralInputs,
        maxTxSize: protocolParams.maxTxSize,
        maxValueSize: protocolParams.maxValSize,
        minFeeCoefficient: protocolParams.minFeeA,
        minFeeConstant: protocolParams.minFeeB,
        minPoolCost: protocolParams.minPoolCost,
        poolDeposit: protocolParams.poolDeposit,
        protocolVersion: protocolParams.protocolVersion,
        stakeKeyDeposit: protocolParams.keyDeposit
      };
    },
    async ledgerTip() {
      const { queryBlock } = await sdk.Tip();
      if (!queryBlock || queryBlock.length === 0) throw new ProviderError(ProviderFailure.NotFound);
      if (queryBlock.length !== 1)
        throw new ProviderError(ProviderFailure.InvalidResponse, null, 'Expected exactly 1 tip');
      const [tipResponse] = queryBlock;
      if (!tipResponse) throw new ProviderError(ProviderFailure.InvalidResponse);
      return {
        blockNo: tipResponse.blockNo,
        hash: Cardano.BlockId(tipResponse.hash),
        slot: tipResponse.slot.number
      };
    },
    async queryBlocksByHashes(hashes) {
      const { queryBlock } = await sdk.BlocksByHashes({ hashes: hashes as unknown as string[] });
      if (!queryBlock) return [];
      return queryBlock.filter(util.isNotNil).map(
        (block): Cardano.Block => ({
          confirmations: block.confirmations,
          date: new Date(block.slot.date),
          epoch: block.epoch.number,
          epochSlot: block.slot.slotInEpoch,
          fees: BigInt(block.fees),
          header: {
            blockNo: block.blockNo,
            hash: Cardano.BlockId(block.hash),
            slot: block.slot.number
          },
          nextBlock: Cardano.BlockId(block.nextBlock.hash),
          previousBlock: Cardano.BlockId(block.previousBlock.hash),
          size: block.size,
          slotLeader: Cardano.PoolId(block.issuer.id),
          totalOutput: BigInt(block.totalOutput),
          txCount: block.transactionsAggregate?.count || 0,
          vrf: Cardano.VrfVkBech32(block.issuer.vrf)
        })
      );
    }
  } as WalletProvider);

export const createGraphQLWalletProvider = createProvider<WalletProvider>(createGraphQLWalletProviderFromSdk);
