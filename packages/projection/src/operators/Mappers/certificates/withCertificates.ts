import { Cardano } from '@cardano-sdk/core';
import { unifiedProjectorOperator } from '../../utils';
import uniqWith from 'lodash/uniqWith.js';

export interface OnChainCertificate {
  pointer: Cardano.Pointer;
  certificate: Cardano.Certificate;
}

export interface WithCertificates {
  certificates: OnChainCertificate[];
  stakeCredentialsByTx: Record<Cardano.TransactionId, Cardano.Credential[]>;
}

const isNotPhase2ValidationErrorTx = (tx: Cardano.OnChainTx<Cardano.TxBody>) =>
  !Cardano.util.isPhase2ValidationErrTx(tx);

const credentialComparator = (c1: Cardano.Credential, c2: Cardano.Credential) =>
  c1.hash === c2.hash && c1.type === c2.type;

/** Adds flat array of certificates to event as well as a record of stake credentials grouped by transaction id. */
export const withCertificates = unifiedProjectorOperator<{}, WithCertificates>((evt) => {
  let blockCertificates: OnChainCertificate[] = [];
  const txToStakeCredentials = new Map<Cardano.TransactionId, Cardano.Credential[]>();

  const {
    header: { slot },
    body
  } = evt.block;
  const txs = body.filter(isNotPhase2ValidationErrorTx);

  const addCredential = (txId: Cardano.TransactionId, credential: Cardano.Credential) =>
    txToStakeCredentials.set(
      txId,
      uniqWith([...(txToStakeCredentials.get(txId) || []), credential], credentialComparator)
    );

  for (const [
    txIndex,
    {
      id: txId,
      body: { certificates = [] }
    }
  ] of txs.filter(isNotPhase2ValidationErrorTx).entries()) {
    const certs = new Array<OnChainCertificate>();

    for (const [certIndex, certificate] of certificates.entries()) {
      certs.push({
        certificate,
        pointer: {
          certIndex: Cardano.CertIndex(certIndex),
          slot: Cardano.Slot(slot),
          txIndex: Cardano.TxIndex(txIndex)
        }
      });

      if ('stakeCredential' in certificate && certificate.stakeCredential) {
        addCredential(txId, certificate.stakeCredential);
      }
    }
    blockCertificates = [...blockCertificates, ...certs];
  }

  return {
    ...evt,
    certificates: blockCertificates,
    stakeCredentialsByTx: Object.fromEntries(txToStakeCredentials)
  };
});
