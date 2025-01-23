import { Asset, Cardano, HandleProvider, HandleResolution, ResolveHandlesArgs, util } from '@cardano-sdk/core';
import { BlockfrostClient } from '../blockfrost/BlockfrostClient';
import { BlockfrostProvider } from '../blockfrost/BlockfrostProvider';
import { Logger } from 'ts-log';
import type { Responses } from '@blockfrost/blockfrost-js';

// https://docs.adahandle.com/official-policy-ids
// https://public.koralabs.io/documentation/HandleResolution.pdf
export const adaHandlePolicyId = Cardano.PolicyId('f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a');

export class BlockfrostHandleProvider extends BlockfrostProvider implements HandleProvider {
  constructor(client: BlockfrostClient, logger: Logger) {
    super(client, logger);
  }

  private async resolveVirtualSubHandleAddress(datumHash: string): Promise<Cardano.PaymentAddress> {
    const res = await this.request<Responses['script_datum']>(`scripts/datum/${datumHash}`);
    const addresses = res.json_value.resolved_addresses as { ada: string };
    return Cardano.PaymentAddress(addresses.ada);
  }

  private async resolveHandle(handle: string): Promise<HandleResolution | null> {
    if (!Asset.util.isValidHandle(handle)) {
      this.logger.warn(`Invalid handle: '${handle}'`);
      return null;
    }
    try {
      const assetName = Cardano.AssetName(util.utf8ToHex(handle));
      const assetId = Cardano.AssetId.fromParts(adaHandlePolicyId, assetName);
      const res = await this.request<Responses['asset_addresses']>(`assets/${assetId.toString()}/addresses`);
      if (res.length === 0) return null;
      const assetOwnerAddress = Cardano.PaymentAddress(res[0].address);
      const [{ data_hash: datumHash, inline_datum: inlineDatum }] = await this.request<
        Responses['address_utxo_content']
      >(`addresses/${assetOwnerAddress.toString()}/utxos/${assetId.toString()}`);

      let resolvingAddress: Cardano.PaymentAddress;
      if (handle.includes('@') && datumHash) {
        this.logger.debug(`Resolving SubHandle address for: ${handle.split('@')[1]}`);
        resolvingAddress = await this.resolveVirtualSubHandleAddress(datumHash);
      } else {
        resolvingAddress = assetOwnerAddress;
      }
      return {
        cardanoAddress: resolvingAddress,
        handle,
        hasDatum: !!inlineDatum,
        policyId: adaHandlePolicyId
      };
    } catch (error) {
      this.logger.error('resolveHandles failed', handle);
      throw this.toProviderError(error);
    }
  }

  getPolicyIds(): Promise<Cardano.PolicyId[]> {
    return Promise.all([Cardano.PolicyId(adaHandlePolicyId)]);
  }

  resolveHandles({ handles }: ResolveHandlesArgs): Promise<Array<HandleResolution | null>> {
    return Promise.all(handles.map((handle) => this.resolveHandle(handle)));
  }
}
