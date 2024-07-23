/* eslint-disable import/no-extraneous-dependencies */
import { defineConfig } from 'tsup';
import baseConfig from '../../tsup.config';
import path from 'path';

export default defineConfig({
  ...baseConfig,
  tsconfig: path.resolve(__dirname, './src/tsconfig.json')
});
