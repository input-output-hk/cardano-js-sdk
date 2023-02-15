module.exports = {
  root: true,
  extends: '@react-native-community',
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint', 'detox'],
  rules: {
    'no-shadow': 'off',
    '@typescript-eslint/no-shadow': ['error'],
  },
};
