import { Cardano } from '@cardano-sdk/core';
import { isNil } from 'lodash-es';

// TODO: hoist to core. Duplicated in cardano-graphql package.
export const isNotNil = <T>(item: T | null | undefined): item is T => !isNil(item);

export interface TxWithEpoch {
  tx: Cardano.TxAlonzo;
  epoch: Cardano.Epoch;
}

export const transactionHasAnyCertificate = (
  { body: { certificates } }: Cardano.TxAlonzo,
  certificateTypes: Cardano.CertificateType[]
) => certificates?.some(({ __typename }) => certificateTypes.includes(__typename)) || false;
