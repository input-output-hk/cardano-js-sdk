import * as Trezor from 'trezor-connect';
import { Cardano } from '@cardano-sdk/core';
import { TrezorTxTransformerContext } from '../types';
import { util as depricated } from '@cardano-sdk/key-management';

/**
 * Temporary transformer function that returns a partial
 * trezor.CardanoSignTransaction object which can be merged
 * into the extisting implementation (later we should refactor
 * this function to the Transformer interface like in the
 * hardware-ledger package)
 */
const ledgerTxTransformer = async (
  body: Cardano.TxBody,
  _context: TrezorTxTransformerContext
): Promise<Partial<Trezor.CardanoSignTransaction>> => ({
  fee: body.fee.toString()
});

/**
 * Temporary props type extending the existing TxToTrezorProps
 * and adding the core Cardano.TxBody so we can pass it to our
 * override implementations.
 */
type TxToTrezorProps = depricated.TxToTrezorProps & {
  cardanoTxBody: Cardano.TxBody;
};

/**
 * Takes a core transaction and context data necessary to transform
 * it into a trezor.CardanoSignTransaction
 */
export const txToTrezor = async (props: TxToTrezorProps): Promise<Trezor.CardanoSignTransaction> => ({
  // First run the depricated trezor transformers
  ...(await depricated.txToTrezor(props)),
  // Then override them with our new implementations
  ...(await ledgerTxTransformer(props.cardanoTxBody, {
    chainId: props.chainId,
    inputResolver: props.inputResolver,
    knownAddresses: props.knownAddresses
  }))
});
