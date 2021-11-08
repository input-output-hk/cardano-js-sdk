import { Cardano } from '@cardano-sdk/core';

export const createStubTxWithCertificates = (certificates: Cardano.CertificateType[]) =>
  ({
    blockHeader: {
      slot: 37_834_496
    },
    body: {
      certificates: certificates.map((__typename) => ({ __typename }))
    }
  } as Cardano.TxAlonzo);
