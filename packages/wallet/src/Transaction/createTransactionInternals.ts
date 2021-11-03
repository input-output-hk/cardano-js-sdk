import { CSL, Cardano, coreToCsl, cslToCore } from '@cardano-sdk/core';
import { Hash16 } from '@cardano-ogmios/schema';
import { SelectionResult } from '@cardano-sdk/cip2';

export type TxInternals = {
  hash: Hash16;
  body: Cardano.TxBodyAlonzo;
};

export type CreateTxInternalsProps = {
  changeAddress: string;
  inputSelection: SelectionResult['selection'];
  validityInterval: Cardano.ValidityInterval;
  certificates?: Cardano.Certificate[];
  withdrawals?: Cardano.Withdrawal[];
};

export const createTransactionInternals = async ({
  changeAddress,
  withdrawals,
  certificates,
  validityInterval,
  inputSelection
}: CreateTxInternalsProps): Promise<TxInternals> => {
  const outputs = [...inputSelection.outputs].map(cslToCore.txOut);
  for (const cslValue of inputSelection.change) {
    const value = cslToCore.value(cslValue);
    outputs.push({
      address: changeAddress,
      value
    });
  }
  const body = {
    // TODO: return more fields. Also add support in coreToCsl.txBody:
    // collaterals, mint, requiredExtraSignatures, scriptIntegrityHash
    certificates,
    fee: BigInt(inputSelection.fee.to_str()),
    inputs: [...inputSelection.inputs].map((cslInput) =>
      cslToCore.txIn(cslInput.input(), cslInput.output().address().to_bech32('addr'))
    ),
    outputs,
    validityInterval,
    withdrawals
  };
  return {
    body,
    hash: Buffer.from(CSL.hash_transaction(coreToCsl.txBody(body)).to_bytes()).toString('hex')
  };
};
