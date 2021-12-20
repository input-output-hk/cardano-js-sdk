import { Cardano, WalletProvider, util } from '@cardano-sdk/core';
import { TransactionsByHashesQuery } from '../sdk';
import { WalletProviderFnProps } from './WalletProviderFnProps';

export type Await<T> = T extends Promise<infer U> ? U : T;
type GraphQlScript = NonNullable<
  NonNullable<NonNullable<TransactionsByHashesQuery['queryTransaction']>[0]>['witness']['scripts']
>[0]['script'];

const scriptToCore = (script: GraphQlScript): Cardano.Script => {
  // if (script.__typename === 'NativeScript') {
  //   if (script.all) return {native: {all: script.all.filter(util.isNotNil).map(toCoreScript)}};
  // }
  script;
  throw new Error('s');
};

type GraphQlInputs = NonNullable<NonNullable<TransactionsByHashesQuery['queryTransaction']>[0]>['inputs'];
const inputsToCore = (inputs: GraphQlInputs, txId: Cardano.TransactionId) =>
  inputs.map(
    ({ address: { address }, index }): Cardano.TxIn => ({
      address: Cardano.Address(address),
      index,
      txId
    })
  );

export const queryTransactionsByHashesProvider =
  ({ sdk, getExactlyOneObject }: WalletProviderFnProps): WalletProvider['queryTransactionsByHashes'] =>
  async (hashes) => {
    const { queryProtocolParametersAlonzo, queryTransaction } = await sdk.TransactionsByHashes({
      hashes: hashes as unknown as string[]
    });
    if (!queryTransaction) return [];
    getExactlyOneObject;
    queryProtocolParametersAlonzo;
    // TODO: refactor moving out functions converting to core types
    return queryTransaction
      .filter(util.isNotNil)
      .map(util.replaceNullsWithUndefineds)
      .map((tx): Cardano.TxAlonzo => {
        const txId = Cardano.TransactionId(tx.hash);
        return {
          blockHeader: {
            blockNo: tx.block.blockNo,
            hash: Cardano.BlockId(tx.block.hash),
            slot: tx.block.slot.number
          },
          body: {
            collaterals: tx.collateral ? inputsToCore(tx.collateral, txId) : undefined,
            fee: tx.fee,
            inputs: inputsToCore(tx.inputs, txId),
            outputs: tx.outputs.map(
              ({ address: { address }, value: { coin, assets }, datumHash }): Cardano.TxOut => ({
                address: Cardano.Address(address),
                datum: datumHash ? Cardano.Hash32ByteBase16(datumHash) : undefined,
                value: {
                  assets: new Map(
                    assets?.map(({ asset, quantity }) => [Cardano.AssetId(asset.assetId), BigInt(quantity)])
                  ),
                  coins: coin
                }
              })
            ),
            validityInterval: {
              invalidBefore: tx.invalidBefore?.slotNo,
              invalidHereafter: tx.invalidHereafter?.slotNo
            }
          },
          id: Cardano.TransactionId(tx.hash),
          implicitCoin: {}, // TODO: move util from wallet to core and compute it
          index: tx.index,
          txSize: Number(tx.size),
          witness: {
            bootstrap: tx.witness.bootstrap?.map((bootstrap) => ({
              addressAttributes: bootstrap.addressAttributes,
              chainCode: bootstrap.chainCode,
              key: bootstrap.key?.key,
              signature: bootstrap.signature
            })),
            datums: tx.witness.datums?.reduce(
              (datums, { datum, hash }) => ({
                ...datums,
                [hash]: datum
              }),
              {} as Record<string, string>
            ),
            redeemers: tx.witness.redeemers?.map((redeemer) => ({
              executionUnits: redeemer.executionUnits,
              index: redeemer.index,
              purpose: redeemer.purpose as Cardano.Redeemer['purpose'],
              scriptHash: Cardano.Hash28ByteBase16(redeemer.scriptHash)
            })),
            scripts: tx.witness.scripts?.reduce(
              (scripts, { key, script }) => ({
                ...scripts,
                // eslint-disable-next-line sonarjs/no-use-of-empty-return-value
                [key]: scriptToCore(script)
              }),
              {} as Cardano.Script
              // eslint-disable-next-line @typescript-eslint/no-explicit-any
            ) as any,
            signatures: new Map(
              tx.witness.signatures.map(({ publicKey: { key }, signature }) => [
                Cardano.Ed25519PublicKey(key),
                Cardano.Ed25519Signature(signature)
              ])
            )
          }
        };
      });
  };
