// Polyfill for Array.prototype.findLast on unit tests
if (!Array.prototype.findLast) {
  // eslint-disable-next-line no-extend-native
  Array.prototype.findLast = function (predicate, thisArg) {
    if (!Array.isArray(this)) {
      throw new TypeError('Array.prototype.findLast called on non-array object');
    }
    if (typeof predicate !== 'function') {
      throw new TypeError('predicate must be a function');
    }

    for (let i = this.length - 1; i >= 0; i--) {
      if (predicate.call(thisArg, this[i], i, this)) {
        return this[i];
      }
    }
  };
}
