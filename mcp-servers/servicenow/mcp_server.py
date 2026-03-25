"""ServiceNow MCP — incidents + change requests via Table API."""

from __future__ import annotations

import json

from mcp.server import Server
from mcp.types import TextContent, Tool

import snow_client

server = Server("servicenow")


@server.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="snow_create_incident",
            description="Create a ServiceNow incident (ticket). Uses SNOW_INSTANCE, SNOW_USER, SNOW_PASSWORD or SNOW_MOCK=1.",
            inputSchema={
                "type": "object",
                "properties": {
                    "short_description": {"type": "string"},
                    "description": {"type": "string"},
                    "urgency": {
                        "type": "string",
                        "description": "1=high, 2=medium, 3=low",
                        "default": "2",
                    },
                },
                "required": ["short_description"],
            },
        ),
        Tool(
            name="snow_create_change",
            description="Create a ServiceNow change_request (CAB track). type: normal|standard|emergency.",
            inputSchema={
                "type": "object",
                "properties": {
                    "short_description": {"type": "string"},
                    "description": {"type": "string"},
                    "change_type": {
                        "type": "string",
                        "default": "normal",
                    },
                },
                "required": ["short_description"],
            },
        ),
    ]


@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    if name == "snow_create_incident":
        data = await snow_client.create_incident(
            arguments.get("short_description", ""),
            arguments.get("description", ""),
            arguments.get("urgency", "2"),
        )
    elif name == "snow_create_change":
        data = await snow_client.create_change_request(
            arguments.get("short_description", ""),
            arguments.get("description", ""),
            arguments.get("change_type", "normal"),
        )
    else:
        return [TextContent(type="text", text=json.dumps({"error": f"unknown tool {name}"}))]
    return [TextContent(type="text", text=json.dumps(data, indent=2)[:200000])]
