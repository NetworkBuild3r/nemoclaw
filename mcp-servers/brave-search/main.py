"""Streamable HTTP MCP — same transport style as mcp-aggregator backends (POST /mcp)."""

from __future__ import annotations

import contextlib
import logging
import os
import sys
from collections.abc import AsyncIterator

from mcp.server.streamable_http_manager import StreamableHTTPSessionManager
from starlette.applications import Starlette
from starlette.responses import JSONResponse
from starlette.routing import Route

from mcp_server import server

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [brave-mcp] %(levelname)s %(message)s",
    stream=sys.stdout,
)
logger = logging.getLogger("brave-mcp")

PORT = int(os.environ.get("MCP_PORT", "8770"))

# json_response=True so clients get plain JSON (mcp-call curl) without parsing SSE frames.
_session_manager = StreamableHTTPSessionManager(server, stateless=True, json_response=True)


async def health(_request):
    has_key = bool(os.environ.get("BRAVE_API_KEY", "").strip())
    return JSONResponse(
        {
            "status": "ok",
            "service": "brave-search-mcp",
            "transport": "streamable-http",
            "brave_api_key_configured": has_key,
        }
    )


class _McpAsgi:
    """ASGI 3-tuple handler for Streamable HTTP MCP."""

    async def __call__(self, scope, receive, send):
        await _session_manager.handle_request(scope, receive, send)


@contextlib.asynccontextmanager
async def lifespan(_app: Starlette) -> AsyncIterator[None]:
    async with _session_manager.run():
        yield


_mcp = _McpAsgi()

app = Starlette(
    routes=[
        Route("/health", health),
        Route("/mcp", endpoint=_mcp, methods=["GET", "POST", "DELETE"]),
    ],
    lifespan=lifespan,
)


if __name__ == "__main__":
    import uvicorn

    logger.info("Starting Brave Search MCP (streamable HTTP) on port %s", PORT)
    uvicorn.run(app, host="0.0.0.0", port=PORT)
