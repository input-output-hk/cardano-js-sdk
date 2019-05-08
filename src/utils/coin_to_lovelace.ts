import { Coin } from 'cardano-wallet'

export function convertCoinToLovelace (coin: Coin): string {
  const ada = coin.ada()
  const lovelace = coin.lovelace()
  return String((ada * 1000000) + lovelace)
}
