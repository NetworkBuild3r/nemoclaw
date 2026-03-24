"""HTTP + SSE MCP transport (same path pattern as Archivist for aggregator compatibility)."""

from __future__ import annotations

import logging
import os
import sys

from mcp.server.sse import SseServerTransport
from starlette.applications import Starlette
from starlette.responses import JSONResponse
from starlette.routing import Mount, Route

from mcp_server import server

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [paloalto-mcp] %(levelname)s %(message)s",
    stream=sys.stdout,
)
logger = logging.getLogger("paloalto-mcp")

PORT = int(os.environ.get("MCP_PORT", "8765"))
sse_transport = SseServerTransport("/mcp/messages/")


async def health(_request):
    mock = os.environ.get("PANOS_MOCK", "0")
    return JSONResponse(
        {
            "status": "ok",
            "service": "paloalto-mcp",
            "panos_mock": mock,
            "panos_host": os.environ.get("PANOS_HOST", ""),
        }
    )


async def handle_sse(request):
    async with sse_transport.connect_sse(
        request.scope, request.receive, request._send
    ) as streams:
        await server.run(
            streams[0], streams[1], server.create_initialization_options()
        )


app = Starlette(
    routes=[
        Route("/health", health),
        Route("/mcp/sse", endpoint=handle_sse),
        Mount("/mcp/messages/", app=sse_transport.handle_post_message),
    ],
)


if __name__ == "__main__":
    import uvicorn

    logger.info("Starting paloalto MCP on port %s", PORT)
    uvicorn.run(app, host="0.0.0.0", port=PORT)
