#!/usr/bin/env node

import chalk from 'chalk'
import { Command } from 'commander'
import { addressBalancesCommand } from './AddressBalance'

const clear = require('clear')
const packageJson = require('../package.json')

clear()
console.log(
  chalk.blue('Cardano Golden Test Generator')
)

const program = new Command('cardano-golden-test-generator')

program
  .addCommand(addressBalancesCommand())

program.version(packageJson.version)
if (!process.argv.slice(2).length) {
  program.outputHelp()
  process.exit(1)
} else {
  program.parseAsync(process.argv).catch(error => {
    console.error(error)
    process.exit(0)
  })
}
