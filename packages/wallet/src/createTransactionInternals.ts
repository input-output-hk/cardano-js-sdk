// Importing types from cardano-serialization-lib-browser will cause TypeScript errors.
import CardanoSerializationLib from '@emurgo/cardano-serialization-lib-nodejs';
import { SelectionResult } from '@cardano-sdk/cip2';
import { Transaction } from '@cardano-sdk/core';

export type TxInternals = {
  hash: CardanoSerializationLib.TransactionHash;
  body: CardanoSerializationLib.TransactionBody;
};

export type CreateTxInternalsProps = {
  changeAddress: string;
  inputSelection: SelectionResult['selection'];
  validityInterval: Transaction.ValidityInterval;
};

export const createTransactionInternals = async (
  cardanoSerializationLib: typeof CardanoSerializationLib,
  props: CreateTxInternalsProps
): Promise<TxInternals> => {
  const inputs = cardanoSerializationLib.TransactionInputs.new();
  for (const utxo of props.inputSelection.inputs) {
    inputs.add(utxo.input());
  }
  const body = cardanoSerializationLib.TransactionBody.new(
    inputs,
    props.inputSelection.outputs,
    cardanoSerializationLib.BigNum.from_str(props.inputSelection.fee.toString()),
    props.validityInterval.invalidHereafter
  );
  if (props.validityInterval.invalidBefore !== undefined) {
    body.set_validity_start_interval(props.validityInterval.invalidBefore);
  }
  return {
    body,
    hash: cardanoSerializationLib.hash_transaction(body)
  };
};
