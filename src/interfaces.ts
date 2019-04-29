export interface TransactionInput {
  pointer: {
    index: number
    id: string
  }
  value: string
  addressing?: {
    account: number
    change: number
    index: number
  }
}

export interface TransactionOutput {
  address: string
  value: string
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
