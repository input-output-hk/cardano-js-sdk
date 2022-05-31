module.exports = {
  extends: ['../../../test/.eslintrc.js'],
  parserOptions: {
    project: ['./tsconfig.json', '../../../tsconfig.eslint.json'],
    tsconfigRootDir: __dirname
  }
};
