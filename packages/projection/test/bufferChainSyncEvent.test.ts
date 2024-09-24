/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano } from '@cardano-sdk/core';
import { ChainSyncEvent, ChainSyncEventType, RequestNext } from '../src';
import { Observable, Subject, Subscription } from 'rxjs';
import { bufferChainSyncEvent } from '../src/bufferChainSyncEvent';

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

class ChainSyncEventTestConsumer {
  private interval: NodeJS.Timer;
  private subscription: Subscription;

  private consumeUpTo = 0;
  private current: number;

  private requestNext: RequestNext | undefined;

  public constructor(public events: string[], observable$: Observable<ChainSyncEvent>) {
    this.subscription = observable$.subscribe({
      complete: () => this.events.push('Consumer completed'),
      error: (error) => this.events.push(`Consumer error: ${error}`),
      next: (value) => {
        this.current = (value.tip as Cardano.Tip).blockNo;
        this.events.push(`Got ${this.current}`);
        this.requestNext = value.requestNext;
      }
    });

    let prevRequestNext = this.requestNext;
    let prevCurrent = this.current;
    let prevConsumeUpTo = this.consumeUpTo;

    this.interval = setInterval(() => {
      if (
        prevRequestNext !== this.requestNext ||
        prevCurrent !== this.current ||
        prevConsumeUpTo !== this.consumeUpTo
      ) {
        prevRequestNext = this.requestNext;
        prevCurrent = this.current;
        prevConsumeUpTo = this.consumeUpTo;
      }

      if (!this.requestNext || this.current > this.consumeUpTo) return;

      this.events.push(`Consumed ${this.current}`);

      const { requestNext } = this;

      this.requestNext = undefined;
      requestNext();
    }, 1);
  }

  public consumeTill(till: number) {
    this.consumeUpTo = till;
  }

  public stop() {
    clearInterval(this.interval);
    this.subscription.unsubscribe();
  }
}

class ChainSyncEventTestProducer {
  public observable$ = new Subject<ChainSyncEvent>();

  private interval: NodeJS.Timer;

  private canProduce = true;
  private produceUpTo = 1;
  private producedTill = 0;

  private requestedComplete = false;
  private requestedError: unknown | undefined;

  private completed = false;
  private error = false;

  public constructor(public events: string[]) {
    this.interval = setInterval(() => {
      if (!this.canProduce || this.completed || this.error) return;

      if (this.producedTill === this.produceUpTo) {
        if (this.requestedComplete) {
          this.completed = true;
          this.events.push('Producer completed');
          this.observable$.complete();
        }
        if (this.requestedError) {
          this.error = true;
          this.events.push(`Producer error: ${this.requestedError}`);
          this.observable$.error(this.requestedError);
        }

        return;
      }

      const count = ++this.producedTill;

      this.canProduce = false;
      this.events.push(`Produced ${count}`);
      this.observable$.next({
        eventType: ChainSyncEventType.RollBackward,
        point: 'origin',
        requestNext: () => {
          this.canProduce = true;
        },
        tip: { blockNo: Cardano.BlockNo(count), hash: '' as Cardano.BlockId, slot: Cardano.Slot(count) }
      });
    }, 1);
  }

  public produceTill(till: number) {
    this.produceUpTo = till;
  }

  public requestComplete() {
    this.requestedComplete = true;
  }

  public requestError(error: unknown) {
    this.requestedError = error;
  }

  public stop() {
    clearInterval(this.interval);
  }
}

describe('bufferChainSyncEvent', () => {
  const events: string[] = [];
  let consumer: ChainSyncEventTestConsumer;
  let producer: ChainSyncEventTestProducer;

  beforeEach(() => {
    events.length = 0;
    producer = new ChainSyncEventTestProducer(events);
  });

  afterEach(() => {
    producer.stop();
    consumer.stop();
  });

  const produceAndConsume = async () => {
    await sleep(50);
    producer.produceTill(2);
    await sleep(50);
    consumer.consumeTill(1);
    await sleep(50);
    producer.produceTill(4);
    await sleep(50);
    consumer.consumeTill(2);
    await sleep(50);
    producer.produceTill(8);
    await sleep(50);
    consumer.consumeTill(3);
    await sleep(50);
    producer.produceTill(16);
    await sleep(50);
    consumer.consumeTill(4);
    await sleep(50);
  };

  describe('without buffer', () => {
    it('the chain works sequentially', async () => {
      consumer = new ChainSyncEventTestConsumer(events, producer.observable$);
      await produceAndConsume();
      expect(events).toEqual([
        'Produced 1',
        'Got 1',
        'Consumed 1',
        'Produced 2',
        'Got 2',
        'Consumed 2',
        'Produced 3',
        'Got 3',
        'Consumed 3',
        'Produced 4',
        'Got 4',
        'Consumed 4',
        'Produced 5',
        'Got 5'
      ]);
    });
  });

  describe('with buffer', () => {
    beforeEach(
      () => (consumer = new ChainSyncEventTestConsumer(events, producer.observable$.pipe(bufferChainSyncEvent(10))))
    );

    it('producer events are buffered up to the configured number', async () => {
      await produceAndConsume();
      expect(events).toEqual([
        'Produced 1',
        'Got 1',
        'Produced 2',
        'Consumed 1',
        'Got 2',
        'Produced 3',
        'Produced 4',
        'Consumed 2',
        'Got 3',
        'Produced 5',
        'Produced 6',
        'Produced 7',
        'Produced 8',
        'Consumed 3',
        'Got 4',
        'Produced 9',
        'Produced 10',
        'Produced 11',
        'Produced 12',
        'Produced 13',
        'Produced 14',
        'Consumed 4',
        'Got 5'
      ]);
    });

    it('producer complete is correctly propagated with buffer empty', async () => {
      await sleep(50);
      producer.produceTill(2);
      await sleep(50);
      consumer.consumeTill(2);
      await sleep(50);
      producer.requestComplete();
      await sleep(50);
      expect(events).toEqual([
        'Produced 1',
        'Got 1',
        'Produced 2',
        'Consumed 1',
        'Got 2',
        'Consumed 2',
        'Producer completed',
        'Consumer completed'
      ]);
    });

    it('producer complete is correctly propagated with buffer not empty', async () => {
      await sleep(50);
      producer.produceTill(2);
      producer.requestComplete();
      await sleep(50);
      consumer.consumeTill(2);
      await sleep(50);
      expect(events).toEqual([
        'Produced 1',
        'Got 1',
        'Produced 2',
        'Producer completed',
        'Consumed 1',
        'Got 2',
        'Consumed 2',
        'Consumer completed'
      ]);
    });

    it('producer error is correctly propagated with buffer empty', async () => {
      await sleep(50);
      producer.produceTill(2);
      await sleep(50);
      consumer.consumeTill(2);
      await sleep(50);
      producer.requestError('test error');
      await sleep(50);
      expect(events).toEqual([
        'Produced 1',
        'Got 1',
        'Produced 2',
        'Consumed 1',
        'Got 2',
        'Consumed 2',
        'Producer error: test error',
        'Consumer error: test error'
      ]);
    });

    it('producer error is correctly propagated with buffer not empty', async () => {
      await sleep(50);
      producer.produceTill(2);
      producer.requestError('test error');
      await sleep(50);
      consumer.consumeTill(2);
      await sleep(50);
      expect(events).toEqual([
        'Produced 1',
        'Got 1',
        'Produced 2',
        'Producer error: test error',
        'Consumed 1',
        'Got 2',
        'Consumed 2',
        'Consumer error: test error'
      ]);
    });
  });
});
