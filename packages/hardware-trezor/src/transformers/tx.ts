import * as Trezor from '@trezor/connect';
import { Cardano } from '@cardano-sdk/core';
import { TrezorTxTransformerContext } from '../types';
import { util as deprecatedUtil } from '@cardano-sdk/key-management';
import { mapAdditionalWitnessRequests } from './additionalWitnessRequests';
import { mapAuxiliaryData, mapCerts, mapTxIns, mapTxOuts, mapWithdrawals } from './';
import { mapTokenMap } from './assets';

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
): Promise<Omit<Trezor.CardanoSignTransaction, 'signingMode'>> => {
  const inputs = await mapTxIns(body.inputs, context);
  return {
    additionalWitnessRequests: mapAdditionalWitnessRequests(inputs, context),
    auxiliaryData: body.auxiliaryDataHash ? mapAuxiliaryData(body.auxiliaryDataHash) : undefined,
    certificates: mapCerts(body.certificates ?? [], context),
    fee: body.fee.toString(),
    inputs,
    mint: mapTokenMap(body.mint),
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
export const txToTrezor = (props: TxToTrezorProps): Promise<Omit<Trezor.CardanoSignTransaction, 'signingMode'>> =>
  trezorTxTransformer(props.cardanoTxBody, {
    chainId: props.chainId,
    inputResolver: props.inputResolver,
    knownAddresses: props.knownAddresses
  });
