import { Cardano } from '@cardano-sdk/core';
import type { TxWithEpoch } from '../../../src/services/DelegationTracker/types.js';

export const createStubTxWithCertificates = (
  certificates?: Cardano.Certificate[],
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  commonCertProps?: any,
  auxData?: Cardano.AuxiliaryData
) =>
  ({
    auxiliaryData: auxData,
    blockHeader: {
      slot: Cardano.Slot(37_834_496)
    },
    body: {
      certificates: certificates?.map((cert) => ({ ...cert, ...commonCertProps }))
    }
  } as Cardano.HydratedTx);

export const createStubTxWithEpoch = (
  epoch: number,
  certificates?: Cardano.Certificate[],
  auxData?: Cardano.AuxiliaryData
) =>
  ({
    epoch: Cardano.EpochNo(epoch),
    tx: {
      auxiliaryData: auxData,
      blockHeader: {
        slot: Cardano.Slot(37_834_496)
      },
      body: {
        certificates: certificates?.map((cert) => ({ ...cert }))
      }
    } as Cardano.HydratedTx
  } as TxWithEpoch);

export const createStubTxWithSlot = (
  slot: number,
  certificates?: Cardano.Certificate[],
  auxData?: Cardano.AuxiliaryData
) =>
  ({
    auxiliaryData: auxData,
    blockHeader: {
      slot: Cardano.Slot(slot)
    },
    body: {
      certificates: certificates?.map((cert) => ({ ...cert }))
    }
  } as Cardano.HydratedTx);
