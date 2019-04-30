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
