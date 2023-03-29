// With 2023-03 mainnet protocol parameters this is good for:
// - >300 years
// - up to 100000 transactions per block

import { AllProjections } from '@cardano-sdk/projection/dist/cjs/projections';
import { CommonSinkProps, Operators, Projections, UnifiedProjectorEvent } from '@cardano-sdk/projection';
import { TypeormSink, WithTypeormContext } from '../types';
import { concatMap, from } from 'rxjs';

// - 10000 certificates per transaction
export const certificatePointerToId = ({ slot, certIndex, txIndex }: Operators.CertificatePointer) =>
  BigInt(slot) * 10_000_000_000n + BigInt(txIndex) * 10_000n + BigInt(certIndex);

export const MaxCertificatePointerIdTxIndex = 99_999;
export const MaxCertificatePointerIdCertificateIndex = 9999;

export interface TypeormSinkProps<ProjectionId extends keyof Projections.AllProjections> {
  sink: (
    evt: UnifiedProjectorEvent<CommonSinkProps<Pick<AllProjections, ProjectionId>> & WithTypeormContext>
  ) => Promise<unknown>;
  entities: Function[];
}

export const typeormSink = <ProjectionId extends keyof Projections.AllProjections>({
  entities,
  sink
}: TypeormSinkProps<ProjectionId>): TypeormSink<ProjectionId> => ({
  entities,
  sink$: (evt$) => evt$.pipe(concatMap((evt) => from(sink(evt).then(() => evt))))
});
