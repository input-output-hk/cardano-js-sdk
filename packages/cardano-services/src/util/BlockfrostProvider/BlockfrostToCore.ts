import { Cardano } from '@cardano-sdk/core';
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
      BlockfrostToCore.hydratedTxIn(BlockfrostToCore.inputFromUtxo(address, utxo)),
      BlockfrostToCore.txOut(BlockfrostToCore.outputFromUtxo(address, utxo))
    ]) as Cardano.Utxo[],

  blockToTip: (block: Responses['block_content']): Cardano.Tip => ({
    blockNo: Cardano.BlockNo(block.height!),
    hash: Cardano.BlockId(block.hash),
    slot: Cardano.Slot(block.slot!)
  }),

  hydratedTxIn: (blockfrost: BlockfrostInput): Cardano.HydratedTxIn => ({
    address: Cardano.PaymentAddress(blockfrost.address),
    index: blockfrost.output_index,
    txId: Cardano.TransactionId(blockfrost.tx_hash)
  }),

  inputFromUtxo: (address: string, utxo: BlockfrostUtxo): BlockfrostInput => ({
    address,
    amount: utxo.amount,
    output_index: utxo.output_index,
    tx_hash: utxo.tx_hash
  }),

  inputs: (inputs: BlockfrostInputs): Cardano.TxIn[] => inputs.map((input) => BlockfrostToCore.hydratedTxIn(input)),

  outputFromUtxo: (address: string, utxo: BlockfrostUtxo): BlockfrostOutput => ({
    ...utxo,
    address,
    collateral: false
  }),

  outputs: (outputs: BlockfrostOutputs): Cardano.TxOut[] => outputs.map((output) => BlockfrostToCore.txOut(output)),

  // @todo Blockfrost library does not provide NewProtocolParamsInConway parameters yet
  protocolParameters: (blockfrost: Responses['epoch_param_content']): Cardano.ProtocolParameters => ({
    coinsPerUtxoByte: Number(blockfrost.coins_per_utxo_word),
    collateralPercentage: blockfrost.collateral_percent!,
    committeeTermLimit: Cardano.EpochNo(0),
    costModels: new Map<Cardano.PlutusLanguageVersion, Cardano.CostModel>([
      [Cardano.PlutusLanguageVersion.V1, Object.values(blockfrost.cost_models!.PlutusV1 as { [key: string]: number })],
      [Cardano.PlutusLanguageVersion.V2, Object.values(blockfrost.cost_models!.PlutusV2 as { [key: string]: number })]
    ]),
    dRepDeposit: 0,
    dRepInactivityPeriod: Cardano.EpochNo(0),
    dRepVotingThresholds: null as unknown as Cardano.DelegateRepresentativeThresholds,
    desiredNumberOfPools: blockfrost.n_opt,
    governanceActionDeposit: 0,
    governanceActionValidityPeriod: Cardano.EpochNo(0),
    maxBlockBodySize: blockfrost.max_block_size,
    maxBlockHeaderSize: blockfrost.max_block_header_size,
    maxCollateralInputs: Number(blockfrost.max_collateral_inputs),
    maxExecutionUnitsPerBlock: {
      memory: Number.parseInt(blockfrost.max_block_ex_mem!),
      steps: Number.parseInt(blockfrost.max_block_ex_steps!)
    },
    maxExecutionUnitsPerTransaction: {
      memory: Number.parseInt(blockfrost.max_tx_ex_mem!),
      steps: Number.parseInt(blockfrost.max_tx_ex_steps!)
    },
    maxTxSize: Number(blockfrost.max_tx_size),
    maxValueSize: Number(blockfrost.max_val_size),
    minCommitteeSize: 0,
    minFeeCoefficient: blockfrost.min_fee_a,
    minFeeConstant: blockfrost.min_fee_b,
    minPoolCost: Number(blockfrost.min_pool_cost),
    monetaryExpansion: blockfrost.rho.toString(),
    poolDeposit: Number(blockfrost.pool_deposit),
    poolInfluence: blockfrost.a0.toString(),
    poolRetirementEpochBound: blockfrost.e_max,
    poolVotingThresholds: null as unknown as Cardano.PoolVotingThresholds,
    prices: {
      memory: blockfrost.price_mem!,
      steps: blockfrost.price_step!
    },
    protocolVersion: { major: blockfrost.protocol_major_ver, minor: blockfrost.protocol_minor_ver },
    stakeKeyDeposit: Number(blockfrost.key_deposit),
    treasuryExpansion: blockfrost.tau.toString()
  }),

  transactionUtxos: (utxoResponse: Responses['tx_content_utxo']) => ({
    collaterals: utxoResponse.inputs.filter((input) => input.collateral).map(BlockfrostToCore.hydratedTxIn),
    inputs: utxoResponse.inputs.filter((input) => !input.collateral).map(BlockfrostToCore.hydratedTxIn),
    outputs: utxoResponse.outputs.map(BlockfrostToCore.txOut)
  }),

  txContentUtxo: (blockfrost: Responses['tx_content_utxo']) => ({
    hash: blockfrost.hash,
    inputs: BlockfrostToCore.inputs(blockfrost.inputs),
    outputs: BlockfrostToCore.outputs(blockfrost.outputs)
  }),

  txOut: (blockfrost: BlockfrostOutput): Cardano.TxOut => {
    const assets: Cardano.TokenMap = new Map();
    for (const { quantity, unit } of blockfrost.amount) {
      if (unit === 'lovelace') continue;
      assets.set(Cardano.AssetId(unit), BigInt(quantity));
    }
    return {
      address: Cardano.PaymentAddress(blockfrost.address),
      value: {
        assets,
        coins: BigInt(blockfrost.amount.find(({ unit }) => unit === 'lovelace')!.quantity)
      }
    };
  }
};
