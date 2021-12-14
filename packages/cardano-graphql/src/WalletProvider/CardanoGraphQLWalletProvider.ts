import { Cardano, WalletProvider, util } from '@cardano-sdk/core';
import { ProviderFromSdk, createProvider, getExactlyOneObject } from '../util';

export const createGraphQLWalletProviderFromSdk: ProviderFromSdk<WalletProvider> = (sdk) =>
  ({
    async currentWalletProtocolParameters() {
      const { queryProtocolParameters } = await sdk.ProtocolParameters();
      const protocolParams = getExactlyOneObject(queryProtocolParameters, 'protocol parameters');
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
    async genesisParameters() {
      const { queryShelleyGenesis } = await sdk.GenesisParameters();
      const genesisParameters = getExactlyOneObject(queryShelleyGenesis, 'genesis parameters');
      return {
        activeSlotsCoefficient: genesisParameters.activeSlotsCoeff,
        epochLength: genesisParameters.epochLength,
        maxKesEvolutions: genesisParameters.maxKESEvolutions,
        maxLovelaceSupply: BigInt(genesisParameters.maxLovelaceSupply),
        networkMagic: genesisParameters.networkMagic,
        securityParameter: genesisParameters.securityParam,
        slotLength: genesisParameters.slotLength,
        slotsPerKesPeriod: genesisParameters.slotsPerKESPeriod,
        systemStart: new Date(genesisParameters.systemStart),
        updateQuorum: genesisParameters.updateQuorum
      };
    },
    async ledgerTip() {
      const { queryBlock } = await sdk.Tip();
      const tip = getExactlyOneObject(queryBlock, 'tip');
      return { blockNo: tip.blockNo, hash: Cardano.BlockId(tip.hash), slot: tip.slot.number };
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
          size: Number(block.size),
          slotLeader: Cardano.PoolId(block.issuer.id),
          totalOutput: BigInt(block.totalOutput),
          txCount: block.transactionsAggregate?.count || 0,
          vrf: Cardano.VrfVkBech32(block.issuer.vrf)
        })
      );
    }
  } as WalletProvider);

export const createGraphQLWalletProvider = createProvider<WalletProvider>(createGraphQLWalletProviderFromSdk);
