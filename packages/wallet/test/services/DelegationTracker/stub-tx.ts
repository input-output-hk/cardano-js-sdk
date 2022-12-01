import { Cardano } from '@cardano-sdk/core';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const createStubTxWithCertificates = (certificates?: Cardano.Certificate[], commonCertProps?: any) =>
  ({
    blockHeader: {
      slot: 37_834_496
    },
    body: {
      certificates: certificates?.map((cert) => ({ ...cert, ...commonCertProps }))
    }
  } as Cardano.HydratedTx);
