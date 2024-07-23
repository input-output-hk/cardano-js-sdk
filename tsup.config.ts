/* eslint-disable import/no-extraneous-dependencies */
import { defineConfig } from 'tsup';

export default defineConfig({
  bundle: true,
  clean: true,
  // Skip until .d.ts.map is also supported https://github.com/egoist/tsup/issues/564
  dts: false,
  entry: ['src/index.ts'],
  esbuildOptions(options) {
    options.platform = 'node';
    options.target = ['es2020'];
    options.resolveExtensions = ['.js', '.ts'];
  },
  format: ['cjs', 'esm'],
  legacyOutput: true,
  outDir: 'dist',
  silent: false,
  skipNodeModulesBundle: true,
  sourcemap: true,
  splitting: false
});
