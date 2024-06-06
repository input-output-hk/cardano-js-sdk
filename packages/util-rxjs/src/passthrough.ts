import type { Observable } from 'rxjs';

/**
 * RxJS operator that returns source observable without any changes.
 * Intended to be used for conditionally applying an operator. For example:
 * - as a default argument value in a function
 * - with ternary operator
 */
export const passthrough =
  <T>() =>
  (evt$: Observable<T>) =>
    evt$;
