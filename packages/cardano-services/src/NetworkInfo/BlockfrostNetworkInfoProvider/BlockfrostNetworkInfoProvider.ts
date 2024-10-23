import { BlockfrostProvider } from '../../util/BlockfrostProvider/BlockfrostProvider';
import { BlockfrostToCore, blockfrostToProviderError } from '../../util';
import {
  Cardano,
  EraSummary,
  Milliseconds,
  NetworkInfoProvider,
  Seconds,
  StakeSummary,
  SupplySummary
} from '@cardano-sdk/core';
import { Schemas } from '@blockfrost/blockfrost-js/lib/types/open-api';
import { handleError } from '@blockfrost/blockfrost-js/lib/utils/errors';

export class BlockfrostNetworkInfoProvider extends BlockfrostProvider implements NetworkInfoProvider {
  public async stake(): Promise<StakeSummary> {
    try {
      const network = await this.blockfrost.network();
      return {
        active: BigInt(network.stake.active),
        live: BigInt(network.stake.live)
      };
    } catch (error) {
      throw blockfrostToProviderError(error);
    }
  }

  public async lovelaceSupply(): Promise<SupplySummary> {
    try {
      const { supply } = await this.blockfrost.network();
      return {
        circulating: BigInt(supply.circulating),
        total: BigInt(supply.total)
      };
    } catch (error) {
      throw blockfrostToProviderError(error);
    }
  }

  public async ledgerTip(): Promise<Cardano.Tip> {
    try {
      const block = await this.blockfrost.blocksLatest();
      return BlockfrostToCore.blockToTip(block);
    } catch (error) {
      throw blockfrostToProviderError(error);
    }
  }

  public async protocolParameters(): Promise<Cardano.ProtocolParameters> {
    try {
      const response = await this.blockfrost.epochsLatestParameters();
      return BlockfrostToCore.protocolParameters(response);
    } catch (error) {
      throw blockfrostToProviderError(error);
    }
  }

  public async genesisParameters(): Promise<Cardano.CompactGenesis> {
    return this.blockfrost
      .genesis()
      .then((response) => ({
        activeSlotsCoefficient: response.active_slots_coefficient,
        epochLength: response.epoch_length,
        maxKesEvolutions: response.max_kes_evolutions,
        maxLovelaceSupply: BigInt(response.max_lovelace_supply),
        networkId:
          response.network_magic === Cardano.NetworkMagics.Mainnet
            ? Cardano.NetworkId.Mainnet
            : Cardano.NetworkId.Testnet,
        networkMagic: response.network_magic,
        securityParameter: response.security_param,
        slotLength: Seconds(response.slot_length),
        slotsPerKesPeriod: response.slots_per_kes_period,
        systemStart: new Date(response.system_start * 1000),
        updateQuorum: response.update_quorum
      }))
      .catch((error) => {
        throw blockfrostToProviderError(error);
      });
  }

  protected async fetchEraSummaries(): Promise<Schemas['network-eras']> {
    try {
      // Although Blockfrost have the endpoint, the blockfrost-js library don't have a call for it
      // https://github.com/blockfrost/blockfrost-js/issues/294
      const response = await this.blockfrost.instance<Schemas['network-eras']>('network/eras');
      return response.body;
    } catch (error) {
      throw handleError(error);
    }
  }

  protected async parseEraSummaries(summaries: Schemas['network-eras'], systemStart: Date): Promise<EraSummary[]> {
    try {
      return summaries.map((r) => ({
        parameters: {
          epochLength: r.parameters.epoch_length,
          slotLength: Milliseconds(r.parameters.slot_length * 1000)
        },
        start: {
          slot: r.start.slot,
          time: new Date(systemStart.getTime() + r.start.time * 1000)
        }
      }));
    } catch (error) {
      throw handleError(error);
    }
  }

  public async eraSummaries(): Promise<EraSummary[]> {
    try {
      const { systemStart } = await this.genesisParameters();
      const summaries = await this.fetchEraSummaries();
      return this.parseEraSummaries(summaries, systemStart);
    } catch (error) {
      throw blockfrostToProviderError(error);
    }
  }
}
