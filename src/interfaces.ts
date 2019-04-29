export interface TransactionInput {
  pointer: {
    index: number
    id: string
  }
  value: number
  addressing: {
    account: number
    change: number
    index: number
  }
}

export interface TransactionOutput {
  address: string
  value: number
  isChange?: boolean
  fullAddress?: {
    cadAmount: {
      getCCoin: number
    }
    cadId: string
    cadIsUsed: boolean
    account: number
    change: number
    index: number
  }
}