import { performance } from 'perf_hooks';
import type { PerformanceEntry } from 'perf_hooks';

import { MeasurementUtil } from '../../src/index.js';

const mockPerformanceObserver = {
  disconnect: jest.fn(),
  observe: jest.fn()
};

jest.mock('perf_hooks', () => ({
  PerformanceObserver: jest.fn().mockImplementation(() => mockPerformanceObserver),
  performance: {
    clearMarks: () => jest.fn(),
    clearMeasures: () => jest.fn(),
    getEntriesByType: () => jest.fn()
  }
}));

type measureTargets = 't1' | 't2';
describe('MeasurementUtil', () => {
  let measurementUtil: MeasurementUtil<measureTargets>;
  let mockData: Partial<PerformanceEntry>[];

  beforeEach(() => {
    measurementUtil = new MeasurementUtil<measureTargets>();

    mockData = [
      { detail: { id: 0, target: 't1' }, duration: 5 },
      { detail: { id: 1, target: 't1' }, duration: 7 },
      { detail: { id: 2, target: 't1' }, duration: 9 },
      { detail: { id: 0, target: 't2' }, duration: 80 },
      { detail: { id: 1, target: 't2' }, duration: 40 }
    ];

    performance.getEntriesByType = jest.fn().mockReturnValue(mockData);
  });

  afterEach(() => {
    mockPerformanceObserver.observe.mockClear();
    mockPerformanceObserver.disconnect.mockClear();
  });

  it('on start creates PerformanceObserver and starts observing it', () => {
    measurementUtil.start();
    expect(mockPerformanceObserver.observe).toHaveBeenCalled();
  });

  it('returns number of calls to addStartMarker', () => {
    const measuredData = measurementUtil.getMeasurements(['t1', 't2']);
    expect(performance.getEntriesByType).toHaveBeenCalled();
    expect(measuredData.t1.calls_count).toBe(3);
    expect(measuredData.t2.calls_count).toBe(2);
  });

  it('calculates times correctly', () => {
    const measuredData = measurementUtil.getMeasurements(['t1', 't2']);
    expect(performance.getEntriesByType).toHaveBeenCalled();
    expect(measuredData.t1.time).toEqual({ avg: 7, max: 9, min: 5, total: 21 });
    expect(measuredData.t2.time).toEqual({ avg: 60, max: 80, min: 40, total: 120 });
  });

  it('returns measurements only requested targets', () => {
    expect(measurementUtil.getMeasurements(['t1']).t2).toBeUndefined();
    expect(measurementUtil.getMeasurements(['t2']).t1).toBeUndefined();
  });

  it('identifies stop markers by missing "details" property and does not count them', () => {
    performance.getEntriesByType = jest.fn(
      (type) =>
        (type === 'measure'
          ? mockData
          : [...mockData, { name: 't1-stop-0' }, { name: 't1-stop-1' }]) as PerformanceEntry[]
    );
    expect(measurementUtil.getMeasurements(['t1']).t1.calls_count).toBe(3);
  });

  it('builds correct labels and details object based on target name', () => {
    const mockMarkFn = jest.fn();
    performance.mark = mockMarkFn;

    measurementUtil.addStartMarker('t1', 22);
    expect(performance.mark).toHaveBeenCalledWith('t1-start-22', { detail: { id: 22, target: 't1' } });

    mockMarkFn.mockClear();
    measurementUtil.addStopMarker('t1', 22);
    expect(performance.mark).toHaveBeenCalledWith('t1-stop-22');

    performance.measure = jest.fn();
    measurementUtil.addMeasureMarker('t1', 22, true);
    expect(performance.measure).toHaveBeenCalledWith('t1-22', {
      detail: { id: 22, target: 't1' },
      end: 't1-stop-22',
      start: 't1-start-22'
    });
  });
});
