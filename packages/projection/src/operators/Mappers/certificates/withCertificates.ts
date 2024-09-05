import { Cardano } from '@cardano-sdk/core';
import { WithBlock } from '../../../types';
import { unifiedProjectorOperator } from '../../utils';

export interface OnChainCertificate {
  pointer: Cardano.Pointer;
  certificate: Cardano.Certificate;
}

export interface WithCertificates {
  certificates: OnChainCertificate[];
}

const blockCertificates = ({
  block: {
    header: { slot },
    body
  }
}: WithBlock) =>
  body
    .filter((tx) => !Cardano.util.isPhase2ValidationErrTx(tx))
    .flatMap(({ body: { certificates = [] } }, txIndex) =>
      certificates.map((certificate, certIndex) => ({
        certificate,
        pointer: {
          certIndex: Cardano.CertIndex(certIndex),
          slot: BigInt(slot),
          txIndex: Cardano.TxIndex(txIndex)
        }
      }))
    );

/** Map ChainSyncEvents to a flat array of certificates. */
export const withCertificates = unifiedProjectorOperator<{}, WithCertificates>((evt) => ({
  ...evt,
  certificates: blockCertificates(evt)
}));
