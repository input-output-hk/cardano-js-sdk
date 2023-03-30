import { Bootstrap, projectIntoSink } from '@cardano-sdk/projection';
import { DataSource } from 'typeorm';
import { NoExtraProperties } from '@cardano-sdk/util';
import { Observable, lastValueFrom, of, takeWhile } from 'rxjs';
import { ObservableCardanoNode } from '@cardano-sdk/core';
import { SupportedProjections } from '../../src/util';
import { TypeormStabilityWindowBuffer, createSink } from '../../src';
import { logger } from '@cardano-sdk/util-dev';

export const createProjector = <P extends Partial<SupportedProjections>>(
  dataSource: DataSource,
  cardanoNode: ObservableCardanoNode,
  buffer: TypeormStabilityWindowBuffer,
  projections: P
) =>
  Bootstrap.fromCardanoNode({
    buffer,
    cardanoNode,
    logger
  }).pipe(
    projectIntoSink({
      projections: projections as NoExtraProperties<SupportedProjections, P>,
      sink: createSink({
        buffer,
        dataSource$: of(dataSource),
        logger
      })
    })
  );

export const createProjectorTilFirst =
  <T>(project: () => Observable<T>) =>
  async (filter: (evt: T) => boolean) =>
    lastValueFrom(project().pipe(takeWhile((evt) => !filter(evt), true)));
