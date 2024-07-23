/* eslint-disable import/no-extraneous-dependencies */
import { defineConfig } from 'tsup';
import baseConfig from '../../tsup.config';

export default defineConfig({
  ...baseConfig,
  noExternal: ['libsodium-wrappers-sumo']
});
