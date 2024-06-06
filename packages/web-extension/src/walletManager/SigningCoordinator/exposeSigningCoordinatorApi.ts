import { exposeApi } from '../../messaging/index.js';
import { of } from 'rxjs';
import { signingCoordinatorApiChannel, signingCoordinatorApiProperties } from './util.js';
import type { MessengerDependencies } from '../../messaging/index.js';
import type { SigningCoordinatorSignApi } from './types.js';

export interface ExposeSigningCoordinatorProps {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  signingCoordinator: SigningCoordinatorSignApi<any, any>;
}

export const exposeSigningCoordinatorApi = (
  { signingCoordinator }: ExposeSigningCoordinatorProps,
  dependencies: MessengerDependencies
) =>
  exposeApi(
    {
      api$: of(signingCoordinator),
      baseChannel: signingCoordinatorApiChannel,
      properties: signingCoordinatorApiProperties
    },
    dependencies
  );
