import { RemoteUnit } from './RemoteUnit'

export interface RemoteWallet {
  id: string
  balance: {
    available: {
      quantity: number
      unit: RemoteUnit
    }
    total: {
      quantity: number
      unit: RemoteUnit
    }
  }
  name: string
  state: {
    status: string
  }
  delegation: {
    status: string
    target: string
  }
}
