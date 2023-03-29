import { EMPTY } from 'rxjs';
import { Projections } from '../src';
import { applyProjections } from '../src/applyProjections';
import { withCertificates } from '../src/operators';

jest.mock('../src/operators/certificates/withCertificates', () => {
  const actual = jest.requireActual('../src/operators/certificates/withCertificates');
  const operator = jest.fn(actual.withCertificates());
  return { withCertificates: () => operator };
});

describe('applyProjections', () => {
  it('deduplicates operators', () => {
    // Both projections are using withCertificates() internally
    applyProjections({
      stakeKeys: Projections.stakeKeys,
      stakePools: Projections.stakePools
    })(EMPTY).subscribe();
    // withCertificates() always returns the same jest.Mock
    expect(withCertificates()).toBeCalledTimes(1);
  });
});
