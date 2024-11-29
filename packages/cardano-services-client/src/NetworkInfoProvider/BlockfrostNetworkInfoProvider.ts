import { BlockfrostClient } from '../blockfrost/BlockfrostClient';
import { BlockfrostProvider } from '../blockfrost/BlockfrostProvider';
import { BlockfrostToCore } from '../blockfrost';
import {
  Cardano,
  EraSummary,
  Milliseconds,
  NetworkInfoProvider,
  Seconds,
  StakeSummary,
  SupplySummary
} from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import type { Responses } from '@blockfrost/blockfrost-js';
import type { Schemas } from '@blockfrost/blockfrost-js/lib/types/open-api';

export class BlockfrostNetworkInfoProvider extends BlockfrostProvider implements NetworkInfoProvider {
  constructor(client: BlockfrostClient, logger: Logger) {
    super(client, logger);
  }

  public async stake(): Promise<StakeSummary> {
    try {
      const { stake } = await this.request<Responses['network']>('network');
      return {
        active: BigInt(stake.active),
        live: BigInt(stake.live)
      };
    } catch (error) {
      throw this.toProviderError(error);
    }
  }

  public async lovelaceSupply(): Promise<SupplySummary> {
    try {
      const { supply } = await this.request<Responses['network']>('network');
      return {
        circulating: BigInt(supply.circulating),
        total: BigInt(supply.total)
      };
    } catch (error) {
      throw this.toProviderError(error);
    }
  }

  public async ledgerTip(): Promise<Cardano.Tip> {
    try {
      const block = await this.request<Responses['block_content']>('blocks/latest');
      return BlockfrostToCore.blockToTip(block);
    } catch (error) {
      throw this.toProviderError(error);
    }
  }

  public async protocolParameters(): Promise<Cardano.ProtocolParameters> {
    try {
      const response = await this.request<Responses['epoch_param_content']>('epochs/latest/parameters');
      return BlockfrostToCore.protocolParameters(response);
    } catch (error) {
      throw this.toProviderError(error);
    }
  }

  public async genesisParameters(): Promise<Cardano.CompactGenesis> {
    return this.request<Responses['genesis_content']>('genesis')
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
        // Blockfrost currently returns '0' for our local network
        // https://github.com/blockfrost/openapi/pull/389
        slotLength: Seconds(response.slot_length || 0.2),
        slotsPerKesPeriod: response.slots_per_kes_period,
        systemStart: new Date(response.system_start * 1000),
        updateQuorum: response.update_quorum
      }))
      .catch((error) => {
        throw this.toProviderError(error);
      });
  }

  protected async fetchEraSummaries(): Promise<Schemas['network-eras']> {
    try {
      return await this.request<Responses['network-eras']>('network/eras');
    } catch (error) {
      throw this.toProviderError(error);
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
      throw this.toProviderError(error);
    }
  }

  public async eraSummaries(): Promise<EraSummary[]> {
    try {
      const { systemStart } = await this.genesisParameters();
      const summaries = await this.fetchEraSummaries();
      return this.parseEraSummaries(summaries, systemStart);
    } catch (error) {
      throw this.toProviderError(error);
    }
  }
}
