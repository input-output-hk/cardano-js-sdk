import { RemoteUnit } from './RemoteUnit'
import { RemoteTransactionDirection } from './RemoteTransactionDirection'
import { RemotePayment } from './RemotePayment'

export interface RemoteTransaction {
  id: string
  amount: {
    quantity: number
    unit: RemoteUnit
  }
  /* eslint-disable */
  inserted_at: {
    time: string
    block: {
      slot_number: number
      epoch_number: number
    }
  }
  /* eslint-enable */
  depth: {
    quantity: 1337
    unit: string
  }
  direction: RemoteTransactionDirection
  inputs: RemotePayment[]
  outputs: RemotePayment[],
  status: string
}
