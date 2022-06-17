module.exports = {
  extends: ['./.eslintrc.js'],
  parserOptions: {
    project: 'eslint.tsconfig.json',
    tsconfigRootDir: __dirname
  },
  rules: {
    '@typescript-eslint/no-floating-promises': ['error']
  }
};
