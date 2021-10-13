// TODO: jest environment is not happy with 'lodash-es' exports.
// I think using non-es-module 'lodash' in 'dependencies' is too heavy.
// eslint-disable-next-line unicorn/prefer-module
jest.mock('lodash-es', () => require('lodash'));
