// Node 19+ defaults http(s).globalAgent to { keepAlive: true }. Tests that start and stop
// servers between cases can then reuse a keep-alive socket to a server that has since been
// restarted/closed, surfacing as "socket hang up" / ECONNRESET / AxiosError. Force fresh
// connections in tests (matching pre-Node-19 behaviour).
require('http').globalAgent.keepAlive = false;
require('https').globalAgent.keepAlive = false;
