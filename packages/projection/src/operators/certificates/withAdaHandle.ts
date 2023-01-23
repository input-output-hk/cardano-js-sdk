import { WithCertificates } from './withCertificates';
import { unifiedProjectorOperator } from '../utils';

export interface WithAdaHandle {
  address: string;
  handle: string;
}

export const withAdaHandle = unifiedProjectorOperator<WithCertificates, WithAdaHandle>((evt) =>
  // console.log('evt', evt);
  ({ ...evt, address: '', handle: '' })
);
