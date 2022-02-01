// This is a little hacky, it would be better to set up ESM builds instead
const Module = require('module');
const originalRequire = Module.prototype.require;
Module.prototype.require = function () {
  return originalRequire.apply(this, arguments[0] === 'lodash-es' ? ['lodash'] : arguments);
};
