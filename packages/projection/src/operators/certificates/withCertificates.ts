import { Cardano } from '@cardano-sdk/core';
import { RollForwardEvent } from '../../types';
import { WithRolledBackEvents } from '../withRolledBackEvents';
import { projectorOperator } from '../utils';

export interface CertificatePointer {
  slot: Cardano.Slot;
  txIndex: number;
  certIndex: number;
}

export interface OnChainCertificate {
  pointer: CertificatePointer;
  certificate: Cardano.Certificate;
}

export interface WithCertificates {
  /**
   * Order of certificates on rolled back transactions is reversed.
   */
  certificates: OnChainCertificate[];
}

const blockCertificates = ({
  block: {
    header: { slot },
    body
  }
}: RollForwardEvent) =>
  body.flatMap(({ body: { certificates = [] } }, txIndex) =>
    certificates.map((certificate, certIndex) => ({
      certificate,
      pointer: {
        certIndex,
        slot,
        txIndex
      }
    }))
  );

/**
 * Map ChainSyncEvents to a flat array of certificates.
 * Order of certificates on rolled back transactions is reversed.
 */
export const withCertificates = projectorOperator<{}, WithRolledBackEvents, WithCertificates, WithCertificates>({
  rollBackward: (evt) => ({
    ...evt,
    certificates: evt.rolledBackEvents.flatMap((rolledBackEvt) => blockCertificates(rolledBackEvt).reverse())
  }),
  rollForward: (evt) => ({
    ...evt,
    certificates: blockCertificates(evt)
  })
});
