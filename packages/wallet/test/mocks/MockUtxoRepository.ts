import Emittery from 'emittery';
import { delegate, rewards, utxo } from './ProviderStub';
import { UtxoRepository, UtxoRepositoryEvents } from '../../src';

export class MockUtxoRepository extends Emittery<UtxoRepositoryEvents> implements UtxoRepository {
  sync = jest.fn().mockResolvedValue(void 0);
  selectInputs = jest.fn();
  allUtxos = utxo;
  availableUtxos = utxo;
  allRewards = rewards;
  availableRewards = rewards;
  delegation = delegate;
}
