import { Cardano } from '@cardano-sdk/core';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const createStubTxWithCertificates = (certificates?: Cardano.CertificateType[], certProps?: any) =>
  ({
    blockHeader: {
      slot: 37_834_496
    },
    body: {
      certificates: certificates?.map((__typename) => ({ __typename, ...certProps }))
    }
  } as Cardano.TxAlonzo);
