import { BigIntMath } from '@cardano-sdk/core';
import { Schema, isAllegraBlock, isAlonzoBlock, isMaryBlock, isShelleyBlock } from '@cardano-ogmios/client';

// Different eras than Byron
export type BlockType = Schema.BlockMary | Schema.BlockAlonzo | Schema.BlockShelley | Schema.BlockAllegra;
// type TransactionType = Schema.BlockBodyMary | Schema.BlockBodyAlonzo;

// interface ByronTx {
//   id: Schema.TxId;
//   body: Schema.Tx;
//   witness: Schema.TxWitness[];
// }

export const getBlockType = (block: Schema.Block) => {
  let b: BlockType | undefined;

  if (isAlonzoBlock(block)) {
    b = block.alonzo as Schema.BlockAlonzo;
  } else if (isMaryBlock(block)) {
    b = block.mary as Schema.BlockMary;
  } else if (isShelleyBlock(block)) {
    b = block.shelley as Schema.BlockShelley;
  } else if (isAllegraBlock(block)) {
    b = block.allegra as Schema.BlockAllegra;
  }
  return b;
};

// const mapOutput = (
//   output: Schema.TxOut,
//   index: number
//   // , transactionId: string
// ) => ({
//   address: output.address,
//   datumHash: output.datum,
//   index,
//   // transaction: { uid: transactionId },
//   value: {
//     // assets: mapTokens(output.value.assets),
//     coin: BigInt(output.value.coins).toString()
//   }
// });

// const mapInput = (
//   input: Schema.TxIn
//   // , transactionId: string
// ) =>
//   // Missing: address, value (should be taken from query method), redeemer
//   ({
//     index: input.index
//     // sourceTransaction: { uid: input.txId }
//     // transaction: { uid: transactionId }
//   });

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

// const mapTransaction = (tx: TransactionType, index: number, blockHeight?: number) => ({
//   blockHeight,
//   fee: BigInt(tx.body.fee).toString(),
//   hash: tx.id,
//   index,
//   inputs: tx.body.inputs.map((input) => mapInput(input)),
//   invalidBefore: tx.body.validityInterval.invalidBefore,
//   invalidHereafter: tx.body.validityInterval.invalidHereafter,
//   // mint: tx.body?.mint.assets,
//   outputs: tx.body.outputs.map((output, i) => mapOutput(output, i))
//   // Missing: size, certificates, scriptIntegrityHash, requiredExtraSignatures, deposit, index, collaterals
// });

// const mapAllegraTransaction = (tx: Schema.BlockBodyAllegra, index: number, blockHeight?: number) => ({
//   blockHeight,
//   fee: BigInt(tx.body.fee).toString(),
//   hash: tx.id,
//   index,
//   inputs: tx.body.inputs.map((input) => mapInput(input)),
//   // invalidBefore: tx.body.validityInterval.invalidBefore,  - not available in Shelley transactions
//   // invalidHereafter: tx.body.validityInterval.invalidHereafter, - not available in Shelley transactions
//   outputs: tx.body.outputs.map((output, i) => mapOutput(output, i))
//   // Missing: size, certificates, scriptIntegrityHash, requiredExtraSignatures, deposit, index, collaterals
// });

// const mapShelleyTransaction = (tx: Schema.BlockBodyShelley, index: number, blockHeight?: number) => ({
//   blockHeight,
//   fee: BigInt(tx.body.fee).toString(),
//   hash: tx.id,
//   index,
//   inputs: tx.body.inputs.map((input) => mapInput(input)),
//   outputs: tx.body.outputs.map((output, i) => mapOutput(output, i))
//   // Missing: size, certificates, scriptIntegrityHash, requiredExtraSignatures, deposit, index, collaterals
// });

export const mapBlock = (block: BlockType) => {
  if (block.body !== undefined) {
    const outputsAmount = block.body?.map((tx) =>
      BigIntMath.sum(tx.body.outputs.map((output) => BigInt(output.value.coins)))
    );
    return {
      // block: { uid: block.header?.blockHash },
      'Block.blockNo': block.header?.blockHeight,
      'Block.hash': block.header?.blockHash,
      'Block.opCert': block.header?.opCert.sigma,
      'Block.previousBlock': { hash: block.header?.prevHash },
      'Block.size': block.header?.blockSize,
      'Block.slot': { number: block.header?.slot },
      'Block.totalFees': BigIntMath.sum(block.body.map((body) => BigInt(body.body.fee))).toString(),
      'Block.totalOutput': BigIntMath.sum(outputsAmount).toString()
      // TODO: blocks have to be discriminated between allegra, shelley and (alonzo, mary)
      // since they have different transaction structures
      // 'Block.transactions': block?.body?.map((tx, index) => mapTransaction(tx, index, block?.header?.blockHeight))
      // Missing: nextBlock, nextBlockProtocolVersion, confirmations, totalLiveStake, epoch, stake pool issuer
    };
  }
};

// const mapByronTransaction = (tx: ByronTx, index: number, blockHeight?: number) => ({
//   blockHeight,
//   'dgraph.type': 'Transaction',
//   hash: tx.id,
//   index,
//   inputs: tx.body.inputs.map((input) => mapInput(input)),
//   outputs: tx.body.outputs.map((output, i) => mapOutput(output, i))
//   // Missing: size, certificates, scriptIntegrityHash, requiredExtraSignatures,
//   // deposit, index, collaterals, fee, mint
// });

export const mapByronBlock = (block: Schema.StandardBlock) => {
  const outputsAmount = block.body?.txPayload.map((tx) =>
    BigIntMath.sum(tx.body.outputs.map((output) => BigInt(output.value.coins)))
  );
  return {
    // block: { uid: block.hash },
    'Block.blockNo': block.header.blockHeight,
    'Block.hash': block.hash,
    'Block.previousBlock': { hash: block.header.prevHash },
    'Block.slot': { number: block.header?.slot },
    'Block.totalOutput': BigIntMath.sum(outputsAmount).toString()
    // transactions:
    // block?.body?.txPayload.map((tx, index) => mapByronTransaction(tx, index, block?.header?.blockHeight))
    // Missing: nextBlock, nextBlockProtocolVersion, confirmations, totalLiveStake,
    // epoch, stake pool issuer, opCert, size, totalFees
  };
};

export const mapByronEpochBoundaryBlock = (block: Schema.EpochBoundaryBlock) => ({
  'Block.blockNo': block.header.blockHeight,
  'Block.hash': block.hash,
  'Block.previousBlock': { hash: block.header.prevHash }
});
