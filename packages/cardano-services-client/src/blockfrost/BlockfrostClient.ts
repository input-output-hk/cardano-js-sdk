import { CustomError } from 'ts-custom-error';
import { catchError, firstValueFrom, switchMap, throwError } from 'rxjs';
import { fromFetch } from 'rxjs/fetch';

export type BlockfrostClientConfig = {
  projectId?: string;
  baseUrl: string;
  apiVersion?: string;
};

export type RateLimiter = {
  schedule: <T>(task: () => Promise<T>) => Promise<T>;
};

export type BlockfrostClientDependencies = {
  /**
   * Rate limiter from npm: https://www.npmjs.com/package/bottleneck
   *
   * new Bottleneck({
   *   reservoir: DEFAULT_BLOCKFROST_RATE_LIMIT_CONFIG.size,
   *   reservoirIncreaseAmount: DEFAULT_BLOCKFROST_RATE_LIMIT_CONFIG.increaseAmount,
   *   reservoirIncreaseInterval: DEFAULT_BLOCKFROST_RATE_LIMIT_CONFIG.increaseInterval,
   *   reservoirIncreaseMaximum: DEFAULT_BLOCKFROST_RATE_LIMIT_CONFIG.size
   * })
   */
  rateLimiter: RateLimiter;
};

export class BlockfrostError extends CustomError {
  constructor(public status?: number, public body?: string, public innerError?: unknown) {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const message: string | null = body || (innerError as any)?.message;
    super(`Blockfrost error with status '${status}': ${message}`);
  }
}

export class BlockfrostClient {
  private rateLimiter: RateLimiter;
  private baseUrl: string;
  private requestInit: RequestInit;

  constructor(
    { apiVersion, projectId, baseUrl }: BlockfrostClientConfig,
    { rateLimiter }: BlockfrostClientDependencies
  ) {
    this.rateLimiter = rateLimiter;
    this.requestInit = projectId ? { headers: { project_id: projectId } } : {};
    this.baseUrl = apiVersion ? `${baseUrl}/api/${apiVersion}` : `${baseUrl}`;
  }

  /**
   * @param endpoint e.g. 'blocks/latest'
   * @param requestInit request options
   * @throws {BlockfrostError}
   */
  public request<T>(endpoint: string, requestInit?: RequestInit): Promise<T> {
    return this.rateLimiter.schedule(() =>
      firstValueFrom(
        fromFetch(`${this.baseUrl}/${endpoint}`, {
          ...this.requestInit,
          ...requestInit,
          headers: requestInit?.headers
            ? { ...this.requestInit.headers, ...requestInit.headers }
            : this.requestInit.headers
        }).pipe(
          switchMap(async (response): Promise<T> => {
            if (response.ok) {
              try {
                return await response.json();
              } catch {
                throw new BlockfrostError(response.status, 'Failed to parse json');
              }
            }
            try {
              const responseBody = await response.text();
              throw new BlockfrostError(response.status, responseBody);
            } catch {
              throw new BlockfrostError(response.status);
            }
          }),
          catchError((err) => {
            if (err instanceof BlockfrostError) {
              return throwError(() => err);
            }
            return throwError(() => new BlockfrostError(undefined, undefined, err));
          })
        )
      )
    );
  }
}
