#!/usr/bin/env bash
# Runs the example server over real pipes, the way an MCP client does.
set -euo pipefail

project_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
compiler=${ABLAC:-$project_root/../ablac/build/ablac}
cd "$project_root"
mkdir -p build
"$compiler" build examples/echo.ab -o build/echo --fast --no-cache

initialize='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18"}}'
initialized='{"jsonrpc":"2.0","method":"notifications/initialized"}'
call='{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"echo","arguments":{"text":"olá"}}}'

output=$(printf '%s\n%s\n%s\n' "$initialize" "$initialized" "$call" | build/echo)
[[ $(wc -l <<<"$output") == 2 ]] || { echo "FAIL expected two replies: $output"; exit 1; }
grep -q '"protocolVersion":"2025-06-18"' <<<"$output" || { echo "FAIL initialize: $output"; exit 1; }
grep -q '"text":"olá"' <<<"$output" || { echo "FAIL tool call: $output"; exit 1; }

# A message split across writes, then stdin closing, must end the server.
output=$( { printf '{"jsonrpc":"2.0","id":3,'; sleep 0.2; printf '"method":"ping"}\n'; } | timeout 5 build/echo)
grep -q '"id":3' <<<"$output" || { echo "FAIL split message: $output"; exit 1; }
echo "stdio tests passed"
