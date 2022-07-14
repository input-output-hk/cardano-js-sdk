module.exports = (path, options) => {
    // Call the defaultResolver, so we leverage its cache, error handling, etc.
    return options.defaultResolver(path, {
        ...options,
        // Use packageFilter to process parsed `package.json` before the resolution (see https://www.npmjs.com/package/resolve#resolveid-opts-cb)
        packageFilter: pkg => {
            // jest-environment-jsdom 28+ tries to use browser exports instead of default exports,
            // but nanoid only offers an ESM browser export and not a CommonJS one. Jest does not yet
            // support ESM modules natively, so this causes a Jest error related to trying to parse
            // "export" syntax.
            //
            // This workaround prevents Jest from considering nanoid's module-based exports at all;
            // it falls back to uuid's CommonJS+node "main" property.
            //
            // Once we're able to migrate our Jest config to ESM and a browser crypto
            // implementation is available for the browser+ESM version of nanoid to use, this can go away.
            if (pkg.name === 'nanoid') {
                delete pkg['exports'];
                delete pkg['module'];
            }
            return pkg;
        },
    });
};