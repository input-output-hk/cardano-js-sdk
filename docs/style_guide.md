# Style Guide
[StandardJS](https://standardjs.com/) functional style + simple rules to keep the project structure consistent.

## Directory and file structure 
- `src/lib` contains supporting libraries generic enough to be decoupled, or are default implementations bundled with the SDK. 
- When modeling an aspect of the domain in `src`, use a directory to contain the logical boundaries of the module.
- Domain object definitions, typically interfaces, should get a file per definition.

## Name cases
- Domain related functions, files, and directories should be title case.
- Internal helper functions camel case.
- Files dealing with internal concerns should be snake case.

## Module integration
- Define the module API in `index.ts`
- Only import from the module boundary
- No `default` exports. `src/index.ts` contains the only exception. 

Browsing the `src` will provide a holistic view of these rules in action.