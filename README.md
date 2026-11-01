# Abla MCP

A [Model Context Protocol](https://modelcontextprotocol.io) server library
written in [Abla](https://github.com/AndreBaltazar8/ablac).

## Features

- tools (text, image and structured results), resources and prompts;
- logging with `logging/setLevel`, and list-changed notifications;
- custom notifications, requests to the client, and Claude Code channels;
- negotiation of protocol revisions 2025-06-18, 2025-03-26 and 2024-11-05; and
- newline-delimited stdio that can be polled next to other descriptors.

The core, `McpServer.handle`, turns one message into its reply and does no I/O,
so other transports can drive it.

## Import

```abla
import github("AndreBaltazar8/abla-mcp")
```

For sibling-checkout development:

```abla
import "../../abla-mcp/src/mcp.ab"
```

## Example

```abla
fun main: int {
    val server = mcpServer("echo", "0.1.0", "Echoes text back.")
    server.tool(
        "echo",
        "Returns the text it is given",
        mcpSchema(["text"], [mcpProperty("string", "What to echo")], ["text"]),
        { arguments: Json -> mcpText(arguments.getString("text")) }
    )
    mcpStdio(server).run()
}
```

Handlers are stored, so a lambda can't reassign a captured variable. Change an
array or a class field it captures instead.

## Alongside other work

To serve MCP while waiting on something else, watch the stdio descriptor:

```abla
val stdio = mcpStdio(server)
val poller = socketPoller()
poller.watchDescriptor(stdio.descriptor)
poller.watchDescriptor(other.descriptor)
// When stdin is readable call stdio.pump(); it returns false once the client
// has gone. Call server.notify(...) or server.channel(...) at any time.
```

## Tests

`make check` runs the protocol tests. `make test` also drives the example server
over real pipes.

## License

Mozilla Public License 2.0.
