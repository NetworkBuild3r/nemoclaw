"""Brave Search MCP — web search for agents."""

from __future__ import annotations

import json

from mcp.server import Server
from mcp.types import TextContent, Tool

import brave_client

server = Server("brave-search")


@server.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="brave_web_search",
            description="Search the public web via Brave Search API. Args: query (required), count 1-20 (default 10), country (default us).",
            inputSchema={
                "type": "object",
                "properties": {
                    "query": {"type": "string", "description": "Search query"},
                    "count": {
                        "type": "integer",
                        "description": "Number of results (1-20)",
                        "default": 10,
                    },
                    "country": {
                        "type": "string",
                        "description": "Country code for search region",
                        "default": "us",
                    },
                },
                "required": ["query"],
            },
        ),
    ]


@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    if name != "brave_web_search":
        return [
            TextContent(
                type="text", text=json.dumps({"error": f"unknown tool: {name}"})
            )
        ]
    query = arguments.get("query", "")
    count = int(arguments.get("count", 10))
    country = str(arguments.get("country", "us"))
    try:
        data = await brave_client.web_search(query, count=count, country=country)
    except Exception as e:
        return [TextContent(type="text", text=json.dumps({"error": str(e)}))]
    text = json.dumps(data, indent=2)
    if len(text) > 200_000:
        text = text[:200_000] + "\n... [truncated]"
    return [TextContent(type="text", text=text)]
