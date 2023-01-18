import { WithCertificates } from './withCertificates';
import { WithEpochNo } from '../withEpochNo';
import { unifiedProjectorOperator } from '../utils';

export interface WithAdaHandle {
  handle: {
    address: string;
    quantity: number;
  };
}

export const withAdaHandle = unifiedProjectorOperator<WithCertificates & WithEpochNo, WithAdaHandle>((evt) =>
  // console.log('evt', evt);
  ({ ...evt, handle: { address: '', quantity: 0 } })
);
