module.exports = {
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "project": "./tsconfig.json",
    "tsconfigRootDir": __dirname
  },
  "extends": [
      "@atixlabs/eslint-config/configurations/node",
      "plugin:@typescript-eslint/recommended",
      "plugin:jsdoc/recommended"
  ],
  "plugins": ["jsdoc", "sort-keys-fix", "sort-imports-es6-autofix"],
  "settings": {
    "import/resolver": {
      "typescript": {}
    }
  },
  "rules": {
    "jsdoc/require-param": 0,
    "jsdoc/require-returns": 0,
    "no-unused-vars": 0,
    "linebreak-style": [
      2,
      "unix"
    ],
    "no-restricted-imports": ["error", {
      "patterns": ["@cardano-sdk/*/src/*"]
    }],
    "new-cap": 0,
    'jsdoc/require-returns-type': 0,
    "no-unused-expressions": 0,
    "no-useless-constructor": 0,
    "quotes": ["error", "single", { "avoidEscape": true }],
    "sort-keys-fix/sort-keys-fix": ["warn", "asc", {"natural": true}],
    "sort-imports-es6-autofix/sort-imports-es6": "warn",
    "sort-imports": ["warn", {ignoreDeclarationSort: true}],
    "unicorn/filename-case": 0,
    "unicorn/prevent-abbreviations": 0,
    "unicorn/no-null": 0,
    "unicorn/no-array-reduce": 0,
    "unicorn/prefer-node-protocol": 0,
    "unicorn/prefer-module": 0,
    "unicorn/no-array-callback-reference": 0, // needed for inference from type guards
    "@typescript-eslint/no-floating-promises": ["error"],
    '@typescript-eslint/no-var-requires': 0, // covered by unicorn/prefer-module
    '@typescript-eslint/explicit-module-boundary-types': 0,
    "@typescript-eslint/ban-types": 0,
    '@typescript-eslint/no-non-null-assertion': 0,
    "@typescript-eslint/no-shadow": ["error"],
    "@typescript-eslint/no-unused-vars": ['warn', { argsIgnorePattern: '^_', varsIgnorePattern: '^_' }],
    "template-tag-spacing": 0,
    "no-magic-numbers": 0,
    'promise/avoid-new': 0,
    'consistent-return': 0, // typescript checks return types
    "camelcase": 0,
    "no-shadow": "off", // eslint compains about TS enums hence disable here and enable @typescript-eslint/no-shadow
    "import/no-unresolved": 0
  }
}
