/* eslint-disable import/no-extraneous-dependencies */
const dotenv = require('dotenv');
const path = require('path');

const pathToE2ePackage = path.join(__dirname, '../../../e2e/');
dotenv.config({ path: path.join(pathToE2ePackage, '.env') });

const { getEnv, walletVariables } = require('@cardano-sdk/e2e');

const env = getEnv(walletVariables);

module.exports = { env, pathToE2ePackage };
