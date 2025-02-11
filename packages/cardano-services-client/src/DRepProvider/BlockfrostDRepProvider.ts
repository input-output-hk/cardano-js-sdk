import { BlockfrostClient } from '../blockfrost/BlockfrostClient';
import { BlockfrostProvider } from '../blockfrost/BlockfrostProvider';
import { Cardano, DRepInfo, DRepProvider, GetDRepInfoArgs, GetDRepsInfoArgs } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import type { Responses } from '@blockfrost/blockfrost-js';

export class BlockfrostDRepProvider extends BlockfrostProvider implements DRepProvider {
  constructor(client: BlockfrostClient, logger: Logger) {
    super(client, logger);
  }

  async getDRepInfo({ id }: GetDRepInfoArgs): Promise<DRepInfo> {
    try {
      const cip129DRepId = Cardano.DRepID.toCip129DRepID(id).toString();
      const response = await this.request<Responses['drep']>(`governance/dreps/${cip129DRepId}`);
      const amount = BigInt(response.amount);
      const activeEpoch = response.active_epoch ? Cardano.EpochNo(response.active_epoch) : undefined;
      const active = response.active;
      const hasScript = response.has_script;

      return {
        active,
        activeEpoch,
        amount,
        hasScript,
        id
      };
    } catch (error) {
      this.logger.error('getDRep failed', id);
      throw this.toProviderError(error);
    }
  }

  getDRepsInfo({ ids }: GetDRepsInfoArgs): Promise<DRepInfo[]> {
    return Promise.all(ids.map((id) => this.getDRepInfo({ id })));
  }
}
