import { MessengerDependencies, exposeApi } from '../../messaging';
import { SignerManagerSignApi } from './types';
import { of } from 'rxjs';
import { signerManagerApiChannel, signerManagerApiProperties } from './util';

export interface ExposeSignerManagerProps {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  signerManager: SignerManagerSignApi<any>;
}

export const exposeSignerManagerApi = (
  { signerManager }: ExposeSignerManagerProps,
  dependencies: MessengerDependencies
) =>
  exposeApi(
    {
      api$: of(signerManager),
      baseChannel: signerManagerApiChannel,
      properties: signerManagerApiProperties
    },
    dependencies
  );
