import { AssetMetadata } from '../../MetadataClient/types';
import { BigIntMath } from '@cardano-sdk/core';
import { Schema, isAlonzoBlock, isMaryBlock } from '@cardano-ogmios/client';
import { TokenMetadata } from '../../Schema';

export const getBlockType = (block: Schema.Block) => {
  let b: Schema.BlockMary | Schema.BlockAlonzo | undefined;
  if (isAlonzoBlock(block)) {
    b = block.alonzo as Schema.BlockAlonzo;
  } else if (isMaryBlock(block)) {
    b = block.mary as Schema.BlockMary;
  }
  return b;
};

export const mapAssetMetadata = (serverAssetMetadata: AssetMetadata): TokenMetadata =>
  ({
    decimals: serverAssetMetadata.decimals.value,
    desc: serverAssetMetadata.description?.value,
    icon: serverAssetMetadata.logo?.value,
    name: serverAssetMetadata.name?.value,
    ticker: serverAssetMetadata.ticker?.value,
    url: serverAssetMetadata.url?.value
    // Missing fields: sizedIcons
  } as TokenMetadata);

// TODO: need assetId to reference asset edge
// const mapTokens = (assets: { [k: string]: Schema.AssetQuantity } | undefined) =>
//   Missing: transactionOutput, asset
//   assets ? Object.entries(assets).map(([name, quantity]) => ({ asset: { name }, quantity })) : [];

const mapOutput = (output: Schema.TxOut, index: number, transactionId: string) => ({
  address: output.address,
  datumHash: output.datum,
  index,
  transaction: { uid: transactionId },
  value: {
    // assets: mapTokens(output.value.assets),
    coin: output.value.coins
  }
});

const mapInput = (input: Schema.TxIn, transactionId: string) =>
  // Missing: address, value (should be taken from query method), redeemer
  ({ index: input.index, sourceTransaction: { uid: input.txId }, transaction: { uid: transactionId } });

// TODO: Has to be adapted to Metadatum type
// const mapAuxiliaryData = (metadata: Schema.AuxiliaryData) => ({
//   body: {
//     blob: metadata.body.blob
//       ? Object.entries(metadata.body.blob).map(([label, value]) => ({ label, metadatum: value }))
//       : [],
//     scripts: metadata.body.scripts
//   },
//   hash: metadata.hash
// });

const mapTransaction = (tx: Schema.BlockBodyMary | Schema.BlockBodyAlonzo, index: number, blockHeight?: number) => ({
  blockHeight,
  fee: tx.body.fee,
  hash: tx.id,
  index,
  inputs: tx.body.inputs.map((input) => mapInput(input, tx.id)),
  invalidBefore: tx.body.validityInterval.invalidBefore,
  invalidHereafter: tx.body.validityInterval.invalidHereafter,
  // mint: mapTokens(tx.body.mint.assets),
  outputs: tx.body.outputs.map((output, i) => mapOutput(output, i, tx.id))
  // Missing: size, certificates, scriptIntegrityHash, requiredExtraSignatures, deposit, index, collaterals
});

export const mapBlock = (block: Schema.BlockAlonzo | Schema.BlockMary) => {
  if (block.body !== undefined) {
    const outputsAmount = block.body?.map((tx) => BigIntMath.sum(tx.body.outputs.map((output) => output.value.coins)));
    return {
      block: { uid: block.header?.blockHash },
      blockNo: block.header?.blockHeight,
      hash: block.header?.blockHash,
      opCert: block.header?.opCert.sigma,
      previousBlock: { hash: block.header?.prevHash },
      size: block.header?.blockSize,
      slot: block.header?.slot,
      totalFees: BigIntMath.sum(block.body.map((body) => body.body.fee)),
      totalOutput: BigIntMath.sum(outputsAmount),
      transactions: block?.body?.map((tx, index) => mapTransaction(tx, index, block?.header?.blockHeight))
      // Missing: nextBlock, nextBlockProtocolVersion, confirmations, totalLiveStake, epoch, stake pool issuer
    };
  }
};
