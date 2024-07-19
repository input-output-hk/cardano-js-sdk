import { ChainSyncEventType } from "@cardano-sdk/core";
import { CredentialEntity, typeormOperator } from "../../dist/esm";
import { uniq } from "lodash";
import { Mappers } from "@cardano-sdk/projection";

export const storeCredentials = typeormOperator<Mappers.WithUtxo & Mappers.WithAddresses>(async (evt) => {
  const {
    block: { body: txs },
    eventType,
    queryRunner
  } = evt;

  // produced credentials will be automatically deleted via block cascade
  if (txs.length === 0 || eventType !== ChainSyncEventType.RollForward) return;
  
  const involvedOutputCredentials = uniq(evt.utxo.produced.map(([_, txOut]) => txOut.address).map((address) => {
    const credential = credentialsFromAddress(address);
    return {
      spendingHash: credential.spendingCredentialHash,
      stakeHash: credential.stakeCredential,
      transactions: [] // FIXME
    } as CredentialEntity;
  }))

  // TODO: compute involvedInputCredentials from HyrdratedTxIn addresses
  // TODO: compute involved credentials by merging uniq(input + output) credentials
  // TODO: reference transactions
});