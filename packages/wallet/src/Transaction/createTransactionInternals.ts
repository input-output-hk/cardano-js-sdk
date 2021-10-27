import { SelectionResult } from '@cardano-sdk/cip2';
import { CSL, Cardano } from '@cardano-sdk/core';
import { Withdrawal } from './withdrawal';

export type TxInternals = {
  hash: CSL.TransactionHash;
  body: CSL.TransactionBody;
};

export type CreateTxInternalsProps = {
  changeAddress: string;
  inputSelection: SelectionResult['selection'];
  validityInterval: Cardano.ValidityInterval;
  certificates?: CSL.Certificate[];
  withdrawals?: Withdrawal[];
};

export const createTransactionInternals = async (props: CreateTxInternalsProps): Promise<TxInternals> => {
  const inputs = CSL.TransactionInputs.new();
  for (const utxo of props.inputSelection.inputs) {
    inputs.add(utxo.input());
  }
  const outputs = CSL.TransactionOutputs.new();
  for (const output of props.inputSelection.outputs) {
    outputs.add(output);
  }
  for (const value of props.inputSelection.change) {
    outputs.add(CSL.TransactionOutput.new(CSL.Address.from_bech32(props.changeAddress), value));
  }
  const body = CSL.TransactionBody.new(
    inputs,
    outputs,
    props.inputSelection.fee,
    props.validityInterval.invalidHereafter || undefined
  );
  if (props.validityInterval.invalidBefore) {
    body.set_validity_start_interval(props.validityInterval.invalidBefore);
  }
  if (props.certificates?.length) {
    const certs = CSL.Certificates.new();
    for (const cert of props.certificates) {
      certs.add(cert);
    }
    body.set_certs(certs);
  }
  if (props.withdrawals?.length) {
    const withdrawals = CSL.Withdrawals.new();
    for (const { address, quantity } of props.withdrawals) {
      withdrawals.insert(address, quantity);
    }
    body.set_withdrawals(withdrawals);
  }
  return {
    body,
    hash: CSL.hash_transaction(body)
  };
};
