import { PerformanceObserver, performance } from 'perf_hooks';

export interface MarkerDetail<T> {
  target: T;
  id: number;
}

export interface MeasurementData {
  /** Stats for targets added with {@link addMeasureMarker} */
  time?: {
    total: number;
    min: number;
    max: number;
    avg: number;
  }; // only for measurement markers done with `addMeasureMarker`

  /** The number of times {@link addStartMarker} was called for a target */
  calls_count: number;
}

export type MeasurementResults<T extends string> = Record<T, MeasurementData>;

/**
 * Wrapper over node perf hooks.
 * T is a user defined string union of the targets that are being
 * measured (e.g. 'wallet-initialization | input-selection').
 */
export class MeasurementUtil<T extends string> {
  #performanceObserver: PerformanceObserver;

  /**
   * Starts observing performance measurements.
   * Must be called before adding markers.
   */
  start(): void {
    this.#performanceObserver = new PerformanceObserver(() => {
      /* just an empty callback because we don't want to do anything when markers are added */
    });

    this.#performanceObserver.observe({ buffered: true, entryTypes: ['measure', 'mark'] });
  }

  /** Stops observing performance measurements and clears previous markers */
  stop(): void {
    performance.clearMarks();
    performance.clearMeasures();
    this.#performanceObserver.disconnect();
  }

  /**
   * Add a start time marker in the timeline.
   *
   * @param target target for which we are setting the marker (e.g. 'wallet-initialization').
   * @param id a unique numeric id useful when monitoring many instances. Statistics are aggregated for all ids.
   */
  addStartMarker(target: T, id: number): void {
    const detail: MarkerDetail<T> = { id, target };
    performance.mark(this.#getStartLabel(target, id), { detail });
  }

  /**
   * Add a stop time marker in the timeline.
   * Useful when the {@link addMeasureMarker} is done separately/later than the start&stop markers.
   * In that case, the measurement is done from startMarker to stopMarker, instead of startMarker to measurementMarker.
   *
   * @param target same as {@link addStartMarker}
   * @param id same as {@link addStartMarker}
   */
  addStopMarker(target: T, id: number): void {
    performance.mark(this.#getStopLabel(target, id));
  }

  /**
   * Adds a measurement marker in the timeline for {@link target} with {@link id}.
   * It measures the time since {@link addStartMarker} with the same `target` and `id` was called.
   * If {@link useStopMarker} is specified, it measures the time between {@link addStartMarker} and
   * {@link addStopMarker} called with the same `target` and `id`.
   *
   * @param target same as {@link addStartMarker}
   * @param id same as {@link addStartMarker}
   * @param useStopMarker Values:
   *   - `false | undefined`: Measure from start marker until this measure marker.
   *   - `true`: Measure from start marker until the associated stop marker.
   */
  addMeasureMarker(target: T, id: number, useStopMarker = false) {
    const detail: MarkerDetail<T> = { id, target };
    performance.measure(this.#getMeasureLabel(target, id), {
      detail,
      end: useStopMarker ? this.#getStopLabel(target, id) : undefined,
      start: this.#getStartLabel(target, id)
    });
  }

  /**
   * Calculates statistics for all {@link targets} added with {@link addMeasureMarker}.
   *
   * @param targets an array of user defined strings for which measurement markers were added.
   * @returns a record indexed with the `target` and having as value a {@link @MeasurementData} object.
   */
  getMeasurements(targets: T[]): MeasurementResults<T> {
    const measurementData: Record<T, MeasurementData> = {} as Record<T, MeasurementData>;
    const measurementCounters: Record<T, number> = {} as Record<T, number>;

    for (const target of targets) measurementData[target] = { calls_count: 0 };

    for (const measureEntry of performance
      .getEntriesByType('measure')
      .map(({ duration, detail }) => ({ duration, target: (detail as MarkerDetail<T>).target }))
      .filter(({ target }) => targets?.some((t) => t === target))) {
      const data = measurementData[measureEntry.target];
      if (!data.time) {
        measurementCounters[measureEntry.target] = 1;
        data.time = {
          avg: measureEntry.duration,
          max: measureEntry.duration,
          min: measureEntry.duration,
          total: measureEntry.duration
        };
      } else {
        measurementCounters[measureEntry.target]++;
        data.time.total += measureEntry.duration;
        data.time.min = Math.min(measureEntry.duration, data.time.min);
        data.time.max = Math.max(measureEntry.duration, data.time.max);
        data.time.avg = data.time.total / measurementCounters[measureEntry.target];
      }
    }

    // Count all the start markers. They all have the 'target' detail added. Stop markers don't have it
    for (const targetName of performance
      .getEntriesByType('mark')
      .map(({ detail }) => (detail as MarkerDetail<T>)?.target)
      .filter((target) => target && targets?.some((t) => t === target))) {
      measurementData[targetName].calls_count++;
    }

    return measurementData;
  }

  #getStopLabel(target: string, id: number): string {
    return this.#getLabel(target, id, 'stop');
  }

  #getStartLabel(target: string, id: number): string {
    return this.#getLabel(target, id, 'start');
  }

  #getLabel(target: string, id: number, type: 'start' | 'stop'): string {
    return `${target}-${type}-${id}`;
  }

  #getMeasureLabel(target: string, id: number) {
    return `${target}-${id}`;
  }
}
