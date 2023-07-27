import * as Trezor from 'trezor-connect';
import { Cardano } from '@cardano-sdk/core';
import { TrezorTxTransformerContext } from '../types';
import { util as deprecatedUtil } from '@cardano-sdk/key-management';
import { mapAuxiliaryData, mapCerts, mapTxIns, mapTxOuts, mapWithdrawals } from './';

/**
 * Temporary transformer function that returns a partial
 * trezor.CardanoSignTransaction object which can be merged
 * into the extisting implementation (later we should refactor
 * this function to the Transformer interface like in the
 * hardware-ledger package)
 */
const trezorTxTransformer = async (
  body: Cardano.TxBody,
  context: TrezorTxTransformerContext
): Promise<Partial<Trezor.CardanoSignTransaction>> => {
  const certificates = mapCerts(body.certificates ?? [], context);
  return {
    auxiliaryData: body.auxiliaryDataHash ? mapAuxiliaryData(body.auxiliaryDataHash) : undefined,
    certificates,
    fee: body.fee.toString(),
    inputs: await mapTxIns(body.inputs, context),
    networkId: context.chainId.networkId,
    outputs: mapTxOuts(body.outputs, context),
    protocolMagic: context.chainId.networkMagic,
    ttl: body.validityInterval?.invalidHereafter?.toString(),
    validityIntervalStart: body.validityInterval?.invalidBefore?.toString(),
    withdrawals: mapWithdrawals(body.withdrawals ?? [], context)
  };
};

/**
 * Temporary props type extending the existing TxToTrezorProps
 * and adding the core Cardano.TxBody so we can pass it to our
 * override implementations.
 */
type TxToTrezorProps = deprecatedUtil.TxToTrezorProps & {
  cardanoTxBody: Cardano.TxBody;
};

/**
 * Takes a core transaction and context data necessary to transform
 * it into a trezor.CardanoSignTransaction
 */
export const txToTrezor = async (props: TxToTrezorProps): Promise<Trezor.CardanoSignTransaction> => ({
  // First run the deprecated trezor transformers
  ...(await deprecatedUtil.txToTrezor(props)),
  // Then override them with our new implementations
  ...(await trezorTxTransformer(props.cardanoTxBody, {
    chainId: props.chainId,
    inputResolver: props.inputResolver,
    knownAddresses: props.knownAddresses
  }))
});
