import { AssetMetadata } from '../../MetadataClient/types';
import { BigIntMath } from '@cardano-sdk/core';
import {
  Schema,
  isAllegraBlock,
  isAlonzoBlock,
  isByronStandardBlock,
  isMaryBlock,
  isShelleyBlock
} from '@cardano-ogmios/client';

export type BlockType = Schema.BlockMary | Schema.BlockAlonzo | Schema.BlockAllegra | Schema.BlockShelley;
type TransactionType =
  | Schema.BlockBodyMary
  | Schema.BlockBodyAlonzo
  | Schema.BlockBodyAllegra
  | Schema.BlockBodyShelley;

interface ByronTx {
  id: Schema.TxId;
  body: Schema.Tx;
  witness: Schema.TxWitness[];
}

export const getBlockType = (block: Schema.Block) => {
  let b: BlockType | undefined;

  if (isAlonzoBlock(block)) {
    b = block.alonzo as Schema.BlockAlonzo;
  } else if (isMaryBlock(block)) {
    b = block.mary as Schema.BlockMary;
  } else if (isAllegraBlock(block)) {
    b = block.allegra as Schema.BlockAllegra;
  } else if (isShelleyBlock(block)) {
    b = block.shelley as Schema.BlockShelley;
  }
  return b;
};

export const getByronBlock = (block: Schema.Block) => {
  let b: Schema.StandardBlock | undefined;
  if (isByronStandardBlock(block)) {
    b = block.byron as Schema.StandardBlock;
  }
  return b;
};

export const mapAssetMetadata = (serverAssetMetadata: AssetMetadata) => ({
  decimals: serverAssetMetadata.decimals.value,
  desc: serverAssetMetadata.description?.value,
  icon: serverAssetMetadata.logo?.value,
  name: serverAssetMetadata.name?.value,
  ticker: serverAssetMetadata.ticker?.value,
  url: serverAssetMetadata.url?.value
  // Missing fields: sizedIcons
});

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

const mapTransaction = (tx: TransactionType, index: number, blockHeight?: number) => ({
  blockHeight,
  fee: tx.body.fee,
  hash: tx.id,
  index,
  inputs: tx.body.inputs.map((input) => mapInput(input, tx.id)),
  // invalidBefore: tx.body.validityInterval.invalidBefore,  - not available in Shelley transactions
  // invalidHereafter: tx.body.validityInterval.invalidHereafter, - not available in Shelley transactions
  // mint: mapTokens(tx.body.mint.assets),
  outputs: tx.body.outputs.map((output, i) => mapOutput(output, i, tx.id))
  // Missing: size, certificates, scriptIntegrityHash, requiredExtraSignatures, deposit, index, collaterals
});

export const mapBlock = (block: BlockType) => {
  if (block.body !== undefined) {
    const outputsAmount = block.body?.map((tx) => BigIntMath.sum(tx.body.outputs.map((output) => output.value.coins)));
    return {
      // block: { uid: block.header?.blockHash },
      blockNo: block.header?.blockHeight,
      hash: block.header?.blockHash,
      opCert: block.header?.opCert.sigma,
      previousBlock: { hash: block.header?.prevHash },
      size: block.header?.blockSize,
      slot: { number: block.header?.slot },
      totalFees: BigIntMath.sum(block.body.map((body) => body.body.fee)),
      totalOutput: BigIntMath.sum(outputsAmount),
      transactions: block?.body?.map((tx, index) => mapTransaction(tx, index, block?.header?.blockHeight))
      // Missing: nextBlock, nextBlockProtocolVersion, confirmations, totalLiveStake, epoch, stake pool issuer
    };
  }
};

const mapByronTransaction = (tx: ByronTx, index: number, blockHeight?: number) => ({
  blockHeight,
  hash: tx.id,
  index,
  inputs: tx.body.inputs.map((input) => mapInput(input, tx.id)),
  // invalidBefore: tx.body.validityInterval.invalidBefore,  - not available in Shelley transactions
  // invalidHereafter: tx.body.validityInterval.invalidHereafter, - not available in Shelley transactions
  outputs: tx.body.outputs.map((output, i) => mapOutput(output, i, tx.id))
  // Missing: size, certificates, scriptIntegrityHash, requiredExtraSignatures, deposit, index, collaterals, fee, mint
});

// eslint-disable-next-line arrow-body-style
export const mapByronBlock = (block: Schema.StandardBlock) => {
  const outputsAmount = block.body?.txPayload.map((tx) =>
    BigIntMath.sum(tx.body.outputs.map((output) => output.value.coins))
  );
  return {
    // block: { uid: block.hash },
    blockNo: block.header.blockHeight,
    hash: block.hash,
    previousBlock: { hash: block.header.prevHash },
    slot: { number: block.header?.slot },
    totalOutput: BigIntMath.sum(outputsAmount).toString(),
    transactions: block?.body?.txPayload.map((tx, index) => mapByronTransaction(tx, index, block?.header?.blockHeight))
    // Missing: nextBlock, nextBlockProtocolVersion, confirmations, totalLiveStake,
    // epoch, stake pool issuer, opCert, size, totalFees
  };
};
