import { Asset, Cardano, Handle } from '@cardano-sdk/core';
import { CIP67Asset, CIP67Assets, WithCIP67 } from './withCIP67';
import { FilterByPolicyIds } from './types';
import { HexBlob } from '@cardano-sdk/util';
import { Logger } from 'ts-log';
import { ProjectionOperator } from '../../types';
import { assetNameToUTF8Handle } from './util';
import { map } from 'rxjs';

export interface HandleOwnership {
  handle: Handle;
  /**
   * Last effect on this handle in this block.
   * - if it's non-`null`, it means it was found in one of the transaction outputs, but it does not
   *   mean that the handle is valid - it could still have total supply >1
   * - if it's `null`, it means handle was burned, but it does not mean that the handle is invalid,
   *   as it could also be burned as a corrective action.
   */
  latestOwnerAddress: Cardano.PaymentAddress | null;
  assetId: Cardano.AssetId;
  policyId: Cardano.PolicyId;
  datum?: Cardano.PlutusData;
  parentHandle?: Handle;
}

export interface WithHandles {
  handles: HandleOwnership[];
}

const assetIdToUTF8Handle = (assetId: Cardano.AssetId, cip67Asset: CIP67Asset | undefined, logger: Logger) => {
  if (cip67Asset) {
    if (
      cip67Asset.decoded.label === Asset.AssetNameLabelNum.UserNFT ||
      cip67Asset.decoded.label === Asset.AssetNameLabelNum.VirtualHandle
    ) {
      return assetNameToUTF8Handle(cip67Asset.decoded.content, logger);
    }
    // Ignore all but UserNFT cip67 assets
    return null;
  }
  return assetNameToUTF8Handle(Cardano.AssetId.getAssetName(assetId), logger);
};

const getHandleMetadata = (handleDataFields: Cardano.PlutusList, logger: Logger) => {
  const data = handleDataFields.items[2];

  if (Cardano.util.isPlutusMap(data)) {
    return Cardano.util.tryConvertPlutusMapToUtf8Record(data, logger);
  }
};

const getVirtualSubhandleOwnerAddress = (datum: HandleOwnership['datum'], logger: Logger) => {
  if (datum && Cardano.util.isConstrPlutusData(datum)) {
    const resolvedAddressEntry = getHandleMetadata(datum.fields, logger);

    if (
      resolvedAddressEntry?.resolved_addresses &&
      Cardano.util.isPlutusMap(resolvedAddressEntry?.resolved_addresses)
    ) {
      const decodedResolvedAddresses = Cardano.util.tryConvertPlutusMapToUtf8Record(
        resolvedAddressEntry.resolved_addresses,
        logger
      );

      if (Cardano.util.isPlutusBoundedBytes(decodedResolvedAddresses.ada)) {
        return Cardano.PaymentAddress(
          Cardano.Address.fromBytes(HexBlob.fromBytes(decodedResolvedAddresses.ada)).toBech32()
        );
      }
    }
  }
};

const tryCreateHandleOwnership = (
  assetId: Cardano.AssetId,
  policyIds: Cardano.PolicyId[],
  cip67Assets: CIP67Assets,
  logger: Logger,
  txOut?: Cardano.TxOut
): HandleOwnership | undefined => {
  const policyId = Cardano.AssetId.getPolicyId(assetId);
  if (!policyIds.includes(policyId)) return;
  try {
    const cip67Asset = cip67Assets.byAssetId[assetId];

    const handle = assetIdToUTF8Handle(assetId, cip67Asset, logger);
    if (!handle) return;
    const subhandleProps: Partial<HandleOwnership> = {};
    if (handle) {
      if (handle.includes('@')) {
        subhandleProps.parentHandle = handle.split('@')[1];

        if (cip67Asset?.decoded.label === Asset.AssetNameLabelNum.VirtualHandle) {
          const virtualSubhandleOwnerAddress = getVirtualSubhandleOwnerAddress(txOut?.datum, logger);
          subhandleProps.latestOwnerAddress = virtualSubhandleOwnerAddress || null;
        }
      }

      return {
        assetId,
        datum: txOut?.datum,
        handle,
        latestOwnerAddress: txOut?.address || null,
        policyId,
        ...subhandleProps
      };
    }
  } catch (error: unknown) {
    logger.error(error);
  }
};

const getOutputHandles = (
  outputs: Cardano.TxOut[],
  policyIds: FilterByPolicyIds['policyIds'],
  cip67Assets: CIP67Assets,
  logger: Logger
) => {
  const handles: Record<Handle, HandleOwnership> = {};
  for (const txOut of outputs) {
    if (!txOut.value.assets) continue;
    for (const [assetId] of txOut.value.assets.entries()) {
      const handleData = tryCreateHandleOwnership(assetId, policyIds, cip67Assets, logger, txOut);
      if (handleData) {
        handles[handleData.handle] = handleData;
      }
    }
  }
  return handles;
};

const getBurnedHandles = (
  mint: Cardano.TokenMap | undefined,
  policyIds: FilterByPolicyIds['policyIds'],
  cip67Assets: CIP67Assets,
  logger: Logger
) => {
  if (!mint) return;
  const handles: Record<Handle, HandleOwnership> = {};
  for (const [assetId, quantity] of mint.entries()) {
    // Positive quantity mint was already accounted for in 'getOutputHandles'
    if (quantity < 0n) {
      const handleData = tryCreateHandleOwnership(assetId, policyIds, cip67Assets, logger);
      if (handleData) {
        handles[handleData.handle] = handleData;
      }
    }
  }
  return handles;
};

export const withHandles =
  <PropsIn extends WithCIP67>(
    { policyIds }: FilterByPolicyIds,
    logger: Logger
  ): ProjectionOperator<PropsIn, WithHandles> =>
  (evt$) =>
    evt$.pipe(
      map((evt) => {
        const handleMap = evt.block.body.reduce(
          (handles, { body: { outputs, mint } }) => ({
            ...handles,
            ...getBurnedHandles(mint, policyIds, evt.cip67, logger),
            ...getOutputHandles(outputs, policyIds, evt.cip67, logger)
          }),
          {} as Record<string, HandleOwnership>
        );

        return {
          ...evt,
          handles: [...Object.values(handleMap)]
        };
      })
    );
