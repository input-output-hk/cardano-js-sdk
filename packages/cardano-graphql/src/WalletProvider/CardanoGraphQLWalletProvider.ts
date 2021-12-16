import { Cardano, ProviderError, ProviderFailure, WalletProvider, util } from '@cardano-sdk/core';
import { ProviderFromSdk, createProvider, getExactlyOneObject } from '../util';

export const createGraphQLWalletProviderFromSdk: ProviderFromSdk<WalletProvider> = (sdk) =>
  ({
    async currentWalletProtocolParameters() {
      const { queryProtocolParametersAlonzo } = await sdk.CurrentProtocolParameters();
      const protocolParams = getExactlyOneObject(queryProtocolParametersAlonzo, 'ProtocolParametersAlonzo');
      return {
        coinsPerUtxoWord: protocolParams.coinsPerUtxoWord,
        maxCollateralInputs: protocolParams.maxCollateralInputs,
        maxTxSize: protocolParams.maxTxSize,
        maxValueSize: protocolParams.maxValueSize,
        minFeeCoefficient: protocolParams.minFeeCoefficient,
        minFeeConstant: protocolParams.minFeeConstant,
        minPoolCost: protocolParams.minPoolCost,
        poolDeposit: protocolParams.poolDeposit,
        protocolVersion: protocolParams.protocolVersion,
        stakeKeyDeposit: protocolParams.stakeKeyDeposit
      };
    },
    async genesisParameters() {
      const { queryTimeSettings, queryAda, queryNetworkConstants } = await sdk.GenesisParameters();
      const timeSettings = getExactlyOneObject(queryTimeSettings, 'TimeSettings');
      const ada = getExactlyOneObject(queryAda, 'ada');
      const networkConstants = getExactlyOneObject(queryNetworkConstants, 'NetworkConstants');
      return {
        activeSlotsCoefficient: networkConstants.activeSlotsCoefficient,
        epochLength: timeSettings.epochLength,
        maxKesEvolutions: networkConstants.maxKESEvolutions,
        maxLovelaceSupply: BigInt(ada.supply.max),
        networkMagic: networkConstants.networkMagic,
        securityParameter: networkConstants.securityParameter,
        slotLength: timeSettings.slotLength,
        slotsPerKesPeriod: networkConstants.slotsPerKESPeriod,
        systemStart: new Date(networkConstants.systemStart),
        updateQuorum: networkConstants.updateQuorum
      };
    },
    async ledgerTip() {
      const { queryBlock } = await sdk.Tip();
      const tip = getExactlyOneObject(queryBlock, 'tip');
      return { blockNo: tip.blockNo, hash: Cardano.BlockId(tip.hash), slot: tip.slot.number };
    },
    async networkInfo() {
      const { queryAda, queryBlock, queryTimeSettings } = await sdk.NetworkInfo();
      const { supply } = getExactlyOneObject(queryAda, 'Ada');
      const {
        totalLiveStake,
        epoch: {
          number: currentEpochNumber,
          startedAt: { date: epochStartedAt },
          activeStakeAggregate
        }
      } = getExactlyOneObject(queryBlock, 'Block');
      const { epochLength, slotLength } = getExactlyOneObject(queryTimeSettings, 'TimeSettings');
      const activeStake = activeStakeAggregate?.quantitySum;
      if (!activeStake) {
        throw new ProviderError(
          ProviderFailure.InvalidResponse,
          null,
          'No active stake on epoch. Chain sync in progress?'
        );
      }
      const epochStartedAtDate = new Date(epochStartedAt);
      const epochEndDate = new Date(epochStartedAtDate.getTime() + epochLength * slotLength * 1000);
      return {
        currentEpoch: {
          end: { date: epochEndDate },
          number: currentEpochNumber,
          start: { date: epochStartedAtDate }
        },
        lovelaceSupply: {
          circulating: BigInt(supply.circulating),
          max: BigInt(supply.max),
          total: BigInt(supply.total)
        },
        stake: {
          active: activeStake,
          live: totalLiveStake
        }
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
          vrf: Cardano.VrfVkBech32(block.issuer.vrf)
        })
      );
    }
  } as WalletProvider);

export const createGraphQLWalletProvider = createProvider<WalletProvider>(createGraphQLWalletProviderFromSdk);
