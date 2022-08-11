# Cardano JS SDK | util-dev

Utilities for tests in other packages

## Tests

See [code coverage report].

[code coverage report]: https://input-output-hk.github.io/cardano-js-sdk/coverage/util-dev

## TestLogger

A _unit tests_ dedicated _logger_.

```typescript
import { createLogger, logger } from '@cardano-sdk/util-dev';
import { deepStrictEqual } from 'assert';

logger.debug('Some debug data');
logger.error('Some error data');
// etc...

const newLogger = createLogger({ record: true });

newLogger.info('another message');
newLogger.debug({ test: 42 }, 'some message');
newLogger.error('error message', new Error('example error'));

deepStrictEqual(newLogger.messages, [
  { level: 'info', message: ['another message'] },
  { level: 'debug', message: [{ test: 42 }, 'some message'] },
  { level: 'error', message: ['error message', new Error('example error')] }
]);
```

This logger is expressly designed to be used in unit tests: it keeps the unit tests output as clean as possible (logging only messages with `fatal` level), but, when required, it offers a quick and easy way to increase the verbosity of the tests without the need to change any file.

It also offer the option to record **all the logged values** to perform checks on what is logged by the tested program.

### Tests development flow

While developing / maintaining / reviewing unit tests we often run the unit test command from our shell:

```
yarn test
```

As long as all the tests pass, we don't even need `TestLogger`.

But sometimes it may happen that some tests fail... sometimes...

In order to investigate the reason of the failure of a test, may be useful to access the logs.

If the test was written using `TestLogger`, the latter allows us to access and / or customize the logs through simple environment variables.

To increase the log level, just use the `TL_LEVEL` environment variable:

```
TL_LEVEL=info yarn test
```

By default, `TestLogger` uses [util.inspect](https://nodejs.org/api/util.html#utilinspectobject-options) and its `options` object can be customized with following environment variables:

- `TL_ARRAY` maps to `maxArrayLength`. Defaults to `100`. `0` maps to `Infinity`.
- `TL_BREAK` maps to `breakLength`. Defaults to tty width on a tty or `90` otherwise. `0` maps to `Infinity`.
- `TL_COLOR` maps to `colors`. Defaults to `true` on a tty `false` otherwise.
- `TL_COMPACT` maps to `compact`. Defaults to `3`. `0` maps to `false`.
- `TL_DEPTH` maps to `depth`. Defaults to `2`. `0` maps to `Infinity`.
- `TL_HIDDEN` maps to `showHidden`. Defaults to `false`.
- `TL_PROXY` maps to `showProxy`. Defaults to `false`.
- `TL_STRING` maps to `maxStringLength`. Defaults to `1000` (not `10000` as `util.inspect` does). `0` maps to `Infinity`.

so if (for example) we need to log full nested objects and `Proxy`s we could run our test command with:

```
TL_PROXY=true TL_DEPTH=0 TL_LEVEL=info yarn test
```

Even if `util.inspect` can be deeply customized (letting us to customize our log as well), it has the drawback that its output can't be cut and pasted on a source file or to perform a POST etc.
If we need to cut paste something from our log we can instruct `TestLogger` to use `JSONBig.stringify` instead; this will obviously make `TestLogger` to ignore environment variables which customize `util.inspect`.

```
TL_LEVEL=info TL_JSON=true yarn test
```
