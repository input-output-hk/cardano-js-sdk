import { MessengerDependencies, exposeApi } from '../../messaging';
import { SigningCoordinatorSignApi } from './types';
import { of } from 'rxjs';
import { signingCoordinatorApiChannel, signingCoordinatorApiProperties } from './util';

export interface ExposeSigningCoordinatorProps {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  signingCoordinator: SigningCoordinatorSignApi<any>;
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
