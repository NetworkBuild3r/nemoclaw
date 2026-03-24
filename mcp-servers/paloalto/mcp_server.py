"""Palo Alto PAN-OS MCP — thin tool surface over REST."""

from __future__ import annotations

import json

from mcp.server import Server
from mcp.types import TextContent, Tool

import panos_client

server = Server("paloalto")


@server.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="panos_show_system_info",
            description="PAN-OS operational: show system info (hostname, version, model). Uses mock if PANOS_MOCK=1.",
            inputSchema={"type": "object", "properties": {}, "additionalProperties": False},
        ),
        Tool(
            name="panos_list_security_rules",
            description="Config get security rulebase (simplified xpath). Args: location ('shared'|'local'), devicegroup (label for future use).",
            inputSchema={
                "type": "object",
                "properties": {
                    "location": {"type": "string", "description": "shared or local"},
                    "devicegroup": {"type": "string", "description": "Device group name"},
                },
                "required": ["location", "devicegroup"],
            },
        ),
        Tool(
            name="panos_config_get",
            description="Generic config get for an XPath (read-only).",
            inputSchema={
                "type": "object",
                "properties": {"xpath": {"type": "string"}},
                "required": ["xpath"],
            },
        ),
    ]


@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    if name == "panos_show_system_info":
        data = await panos_client.show_system_info()
    elif name == "panos_list_security_rules":
        loc = arguments.get("location", "shared")
        dg = arguments.get("devicegroup", "default")
        data = await panos_client.list_security_rules(loc, dg)
    elif name == "panos_config_get":
        data = await panos_client.config_get(arguments.get("xpath", ""))
    else:
        return [TextContent(type="text", text=json.dumps({"error": f"unknown tool {name}"}))]
    return [TextContent(type="text", text=json.dumps(data, indent=2)[:200000])]
