import { UtxoRepository, UtxoRepositoryEvents } from '../../src';
import { delegate, rewards, utxo } from './ProviderStub';
import Emittery from 'emittery';

export class MockUtxoRepository extends Emittery<UtxoRepositoryEvents> implements UtxoRepository {
  sync = jest.fn().mockResolvedValue(void 0);
  selectInputs = jest.fn();
  allUtxos = utxo;
  availableUtxos = utxo;
  allRewards = rewards;
  availableRewards = rewards;
  delegation = delegate;
}
