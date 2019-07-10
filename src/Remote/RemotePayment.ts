import { RemoteUnit } from './RemoteUnit'

export interface RemotePayment {
  address: string
  amount: {
    quantity: number
    unit: RemoteUnit
  }
}
