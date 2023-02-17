import { EntitySubscriberInterface, EventSubscriber, InsertEvent } from 'typeorm';
import { StabilityWindowBlockEntity } from './StabilityWindowBlock.entity';

@EventSubscriber()
export class StabilityWindowBlockSubscriber implements EntitySubscriberInterface<StabilityWindowBlockEntity> {
  #tip = new BehaviorSubject<Cardano.Block | 'origin'>('origin');
  #tail = new BehaviorSubject<Cardano.Block | 'origin'>('origin');

  /**
   * Indicates that this subscriber only listen to Post events.
   */
  listenTo() {
    return StabilityWindowBlockEntity;
  }

  /**
   * Called before post insertion.
   */
  beforeInsert(event: InsertEvent<StabilityWindowBlockEntity>) {
    console.log('BEFORE POST INSERTED:', event.entity);
  }
}
