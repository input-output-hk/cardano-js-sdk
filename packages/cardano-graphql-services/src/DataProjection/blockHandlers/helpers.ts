import { Asset, BigIntMath } from '@cardano-sdk/core';
import { AssetMetadata } from '../../MetadataClient/types';
import { Schema, isAlonzoBlock, isMaryBlock } from '@cardano-ogmios/client';

export const getBlockType = (block: Schema.Block) => {
  let b: Schema.BlockMary | Schema.BlockAlonzo | undefined;
  if (isAlonzoBlock(block)) {
    b = block.alonzo as Schema.BlockAlonzo;
  } else if (isMaryBlock(block)) {
    b = block.mary as Schema.BlockMary;
  }
  return b;
};

export const mapMetadata = (serverAssetMetadata: AssetMetadata): Asset.TokenMetadata => ({
  decimals: serverAssetMetadata.decimals.value,
  desc: serverAssetMetadata.description?.value,
  icon: serverAssetMetadata.logo?.value,
  name: serverAssetMetadata.name?.value,
  ticker: serverAssetMetadata.ticker?.value,
  url: serverAssetMetadata.url?.value
  // Missing fields: sizedIcons
});

const mapAssets = (assets: { [k: string]: Schema.AssetQuantity } | undefined) =>
  // Missing: transactionOutput, asset
  assets ? Object.entries(assets).map(([name, quantity]) => ({ asset: { name }, quantity })) : [];

const mapOutput = (output: Schema.TxOut) =>
  // Missing: index, transaction, datumHash
  ({
    address: output.address,
    value: { assets: mapAssets(output.value.assets), coin: output.value.coins }
  });

const mapInput = (input: Schema.TxIn) =>
  // Missing: address:, redeemer, sourceTransaction, transaction, value
  ({ index: input.index });

const mapAuxiliaryData = (metadata: Schema.AuxiliaryData) => ({
  body: {
    blob: metadata.body.blob
      ? Object.entries(metadata.body.blob).map(([label, value]) => ({ label, metadatum: value }))
      : [],
    scripts: metadata.body.scripts
  },
  hash: metadata.hash
});

const mapTransaction = (tx: Schema.BlockBodyMary | Schema.BlockBodyAlonzo, blockHeight?: number) => ({
  auxiliaryData: tx.metadata ? mapAuxiliaryData(tx.metadata) : tx.metadata,
  blockHeight,
  fee: tx.body.fee,
  hash: tx.id,
  inputs: tx.body.inputs.map(mapInput),
  invalidBefore: tx.body.validityInterval.invalidBefore,
  invalidHereafter: tx.body.validityInterval.invalidHereafter,
  mint: mapAssets(tx.body.mint.assets),
  outputs: tx.body.outputs.map(mapOutput)
  // Missing: size, certificates, scriptIntegrityHash, requiredExtraSignatures, deposit, index, collaterals
});

export const mapBlock = (block: Schema.BlockAlonzo | Schema.BlockMary) => {
  if (block.body !== undefined) {
    const outputsAmount = block.body?.map((tx) => BigIntMath.sum(tx.body.outputs.map((output) => output.value.coins)));
    return {
      blockNo: block.header?.blockHeight,
      hash: block.header?.blockHash,
      opCert: block.header?.opCert.sigma,
      previousBlock: { hash: block.header?.prevHash },
      size: block.header?.blockSize,
      slot: block.header?.slot,
      totalFees: BigIntMath.sum(block.body.map((body) => body.body.fee)),
      totalOutput: BigIntMath.sum(outputsAmount),
      transactions: block?.body?.map((tx) => mapTransaction(tx, block?.header?.blockHeight))
      // Missing: nextBlock, nextBlockProtocolVersion, confirmations, totalLiveStake, epoch, stake pool issuer
    };
  }
};
