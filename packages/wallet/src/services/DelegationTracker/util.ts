import { Cardano } from '@cardano-sdk/core';

export interface TxWithEpoch {
  tx: Cardano.TxAlonzo;
  epoch: Cardano.Epoch;
}

export const transactionHasAnyCertificate = (
  { body: { certificates } }: Cardano.TxAlonzo,
  certificateTypes: Cardano.CertificateType[]
) => certificates?.some(({ __typename }) => certificateTypes.includes(__typename)) || false;
