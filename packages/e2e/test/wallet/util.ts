import { Observable, catchError, filter, firstValueFrom, throwError, timeout } from 'rxjs';
import { ObservableWallet } from '@cardano-sdk/wallet';

const SECOND = 1000;
const MINUTE = 60 * SECOND;
export const TX_TIMEOUT = 7 * MINUTE;
const SYNC_TIMEOUT = 3 * MINUTE;
export const FAST_OPERATION_TIMEOUT = 15 * SECOND;

export const firstValueFromTimed = <T>(
  observable$: Observable<T>,
  timeoutMessage = 'Timed out',
  timeoutAfter = FAST_OPERATION_TIMEOUT
) =>
  firstValueFrom(
    observable$.pipe(
      timeout(timeoutAfter),
      catchError(() => throwError(() => new Error(timeoutMessage)))
    )
  );

export const waitForWalletStateSettle = (wallet: ObservableWallet) =>
  firstValueFromTimed(
    wallet.syncStatus.isSettled$.pipe(filter((isSettled) => isSettled)),
    'Took too long to load',
    SYNC_TIMEOUT
  );
