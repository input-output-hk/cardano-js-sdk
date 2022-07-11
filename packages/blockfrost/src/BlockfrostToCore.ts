import { Cardano, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';
import { Responses } from '@blockfrost/blockfrost-js';

type Unpacked<T> = T extends (infer U)[] ? U : T;
type BlockfrostAddressUtxoContent = Responses['address_utxo_content'];
type BlockfrostInputs = Responses['tx_content_utxo']['inputs'];
type BlockfrostInput = Pick<Unpacked<BlockfrostInputs>, 'address' | 'amount' | 'output_index' | 'tx_hash'>;
type BlockfrostOutputs = Responses['tx_content_utxo']['outputs'];
type BlockfrostOutput = Unpacked<BlockfrostOutputs>;
export type BlockfrostTransactionContent = Unpacked<Responses['address_transactions_content']>;
export type BlockfrostUtxo = Unpacked<BlockfrostAddressUtxoContent>;

export const BlockfrostToCore = {
  addressUtxoContent: (address: string, blockfrost: Responses['address_utxo_content']): Cardano.Utxo[] =>
    blockfrost.map((utxo) => [
      BlockfrostToCore.txIn(BlockfrostToCore.inputFromUtxo(address, utxo)),
      BlockfrostToCore.txOut(BlockfrostToCore.outputFromUtxo(address, utxo))
    ]) as Cardano.Utxo[],

  blockToTip: (block: Responses['block_content']): Cardano.Tip => ({
    blockNo: block.height!,
    hash: Cardano.BlockId(block.hash),
    slot: block.slot!
  }),

  currentWalletProtocolParameters: (
    blockfrost: Responses['epoch_param_content']
  ): ProtocolParametersRequiredByWallet => ({
    coinsPerUtxoByte: Number(blockfrost.coins_per_utxo_word),
    maxCollateralInputs: Number(blockfrost.max_collateral_inputs),
    maxTxSize: Number(blockfrost.max_tx_size),
    maxValueSize: Number(blockfrost.max_val_size),
    minFeeCoefficient: blockfrost.min_fee_a,
    minFeeConstant: blockfrost.min_fee_b,
    minPoolCost: Number(blockfrost.min_pool_cost),
    poolDeposit: Number(blockfrost.pool_deposit),
    protocolVersion: { major: blockfrost.protocol_major_ver, minor: blockfrost.protocol_minor_ver },
    stakeKeyDeposit: Number(blockfrost.key_deposit)
  }),

  inputFromUtxo: (address: string, utxo: BlockfrostUtxo): BlockfrostInput => ({
    address,
    amount: utxo.amount,
    output_index: utxo.output_index,
    tx_hash: utxo.tx_hash
  }),

  inputs: (inputs: BlockfrostInputs): Cardano.TxIn[] => inputs.map((input) => BlockfrostToCore.txIn(input)),

  outputFromUtxo: (address: string, utxo: BlockfrostUtxo): BlockfrostOutput => ({
    address,
    amount: utxo.amount
  }),

  outputs: (outputs: BlockfrostOutputs): Cardano.TxOut[] => outputs.map((output) => BlockfrostToCore.txOut(output)),

  transactionUtxos: (utxoResponse: Responses['tx_content_utxo']) => ({
    collaterals: utxoResponse.inputs.filter((input) => input.collateral).map(BlockfrostToCore.txIn),
    inputs: utxoResponse.inputs.filter((input) => !input.collateral).map(BlockfrostToCore.txIn),
    outputs: utxoResponse.outputs.map(BlockfrostToCore.txOut)
  }),

  txContentUtxo: (blockfrost: Responses['tx_content_utxo']) => ({
    hash: blockfrost.hash,
    inputs: BlockfrostToCore.inputs(blockfrost.inputs),
    outputs: BlockfrostToCore.outputs(blockfrost.outputs)
  }),

  txIn: (blockfrost: BlockfrostInput): Cardano.TxIn => ({
    address: Cardano.Address(blockfrost.address),
    index: blockfrost.output_index,
    txId: Cardano.TransactionId(blockfrost.tx_hash)
  }),

  txOut: (blockfrost: BlockfrostOutput): Cardano.TxOut => {
    const assets: Cardano.TokenMap = new Map();
    for (const { quantity, unit } of blockfrost.amount) {
      if (unit === 'lovelace') continue;
      assets.set(Cardano.AssetId(unit), BigInt(quantity));
    }
    return {
      address: Cardano.Address(blockfrost.address),
      value: {
        assets,
        coins: BigInt(blockfrost.amount.find(({ unit }) => unit === 'lovelace')!.quantity)
      }
    };
  }
};
