type Metric = Record<string, number>;

export class Metrics {
  private events: Map<number, Metric>;
  private interval: NodeJS.Timer;
  private metricsInterval: number;

  constructor(metricsInterval = 60) {
    this.events = new Map();
    this.metricsInterval = metricsInterval * 1000;
    this.interval = setInterval(() => this.prune(), this.metricsInterval);
  }

  add(event: string, count = 1) {
    const now = Date.now();
    let metric = this.events.get(now);

    if (!metric) {
      metric = {};
      this.events.set(now, metric);
    }

    if (metric[event]) metric[event] += count;
    else metric[event] = count;
  }

  close() {
    clearInterval(this.interval);
  }

  get() {
    const { events } = this;
    const metrics: Metric = {};

    this.prune();

    for (const [, metric] of events)
      for (const [event, count] of Object.entries(metric))
        if (metrics[event]) metrics[event] += count;
        else metrics[event] = count;

    return metrics;
  }

  private prune() {
    const { events, metricsInterval } = this;
    const threshold = Date.now() - metricsInterval;

    for (const [when] of events) if (when < threshold) events.delete(when);
  }
}
