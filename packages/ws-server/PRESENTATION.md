# WebSocket based connection

## Introduction

This is not the presentation of a POC, the propose here is actually the initial implementation of a WebSocket based
connection between SDK server and client, i.e. between Lace extension and its back-end.

## Target

The target of this proposal is to introduce two new features in the SDK:

- the WebSocket connection
- the hot reload feature

## WebSocket connection

We already had a lot of discussions about the improvements from events against polling... we'll not go deeper on this
topic.

## Hot reload

One of the main advantages of using high level programming languages is they offer several tools to save the developers
from the _build time_.

The SDK takes no advantage from any of them: for each single comma we change in our source code, we need to shut down
the program, rebuild it ad restart it.

**The introduction of this feature may increase our development speed of about 30 - 50 % !**

## Scope

Being only an initial implementation the only functionality is _following the tip in an event based way_.

## Implementation details

### Run the server through tsx both in dev and in prod

Using [tsx](https://www.npmjs.com/package/tsx) (or [ts-node](https://www.npmjs.com/package/ts-node)) in development
environment is mandatory to have the hot reload feature.

Why using it in production environment as well?

Running a **node.js** process through `tsx` means the TypeScript is transplitted at load time rather than at build
time: the code running at run time will be exactly the same;

**disadvantages:**

- the start up may take something like 1" (machine time) more;

**advantages:**

- shorter docker image build time;
- thrown `Error`s have a TypeScript stack trace rather than in transplitted JavaScript;

reading a transplitted stake trace often requires the developer to open the built version of the source code to
translate back to TypeScript in order to clearly understand what happened; and this is human time, not machine time.

**The time saved during even only the first investigation will repay years of 1" delay while starting the back-end.**

## Two new SDK packages

The easiest fastest and cheapest way to nest this implementation into what we have today is to add it to the SDK.

### Server package

Applying the required changes to `cardano-services` and all its dependency packages to let them run with `tsx` may be a
quite long task: lots of packages are involved and some unexpected problem may raise. A new server package requires a
well determined time effort.

### Client package

Being this a completely new feature, it could be well scoped in a self dedicated package.

## Client side interface

The client package will expose its own native interface object exposing the `Observable` serving the tip.

To easily nest it into what we have today it will expose a `NetworkInfoProvider` as well. So the initial change
required on Lace side is restricted to:

1. import the new client package;
2. calling the init function providing the WebSocket URL;
3. using the exposed `NetworkInfoProvider` instead of the current one.

### NetworkInfoProvider implementation details

Actually the only event based info from this provider will be the tip. All other functions of the provider will use a
request / answer model as we have today, they will anyway take advantage from the WebSocket, i.e. these requests will
be performed through the persistent connection saving TCP-IP and SSL handshakes time and resources.

The `ledgerTip` implementation will be just a `firstValueFrom` call on the `Observable` exposed by the native object.

## DB needs to take part to the events

Even if this unavoidably means adding a few ms delay, as long as all other requests (from this provider and from all
the other ones) are based on the DB, this also completely prevent from possible cases where the wallet is aware af a
new block but no of the data it contains.

Switching from a polling model to an events based one (even if with a short delay) should be a noticeable improvement
anyway.

## SDK projector Vs db-sync

Since

1. we currently have no projectors able to serve the data required for a `NetworkInfoProvider` implementation,
2. the path to get rid from db-sync is yet quite long,

db-sync is a natural choice not impacting our plans: switching to another DB in a later stage, can be done in a snap.

## Roll-backward chain-sync events

As long as we serve only the tip, they can be just ignored. A roll-backward event can't live alone, it will be followed
for sure by at least one roll-forward event: propagating it to the client will overwrite anyway the changes the
roll-backward produced.

## Next step

As a first implementation both Lace and the SDK will continue to use their polling logics. As part of the first
implementation we could just (significantly) decrease the polling interval as:

- we know this will have impact only on CPU and RAM but not on network traffic;
- this is more a configuration change than an actual change.

Once done this implementation we can propagate the `Observable` exposed by the native object to any upper layer which
requires it to:

- remove any delays;
- save the local resources which a too short interval polling strategy may cost;
- simplify the code removing currently implemented polling and retry strategies.

## Costs

### Development time

Two man weeks in the best case, three man weeks in the worst case.

Some time from SRE will be required as well to:

- deploy the new micro service,
- correctly expose a public WebSocket server;

An approximated estimation could be another couple of man weeks, but better to ask SRE team directly.

### Resources

The impact on resources cost should be negligible, it should be a save more than an additional cost... but negligible.

There will no longer be the `ledgerTip` DB query... but it is a very light and well cached query...
There will be some (maybe several) less network handshakes... how much can they cost?

As stated above: negligible.

## Next next steps

- We can use it (directly or as PoC) for Lace Backend v2.
- We can implement other providers, starting from the ones Lace will benefit more from an events based connection.
  - The `ChainSyncProvider` is a great candidate to drastically reduce back-end work load.
