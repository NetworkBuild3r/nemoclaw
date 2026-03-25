"""ServiceNow Table API client (REST)."""

from __future__ import annotations

import base64
import os
from typing import Any

import httpx

INSTANCE = os.environ.get("SNOW_INSTANCE", "").rstrip("/")
USER = os.environ.get("SNOW_USER", "")
PASSWORD = os.environ.get("SNOW_PASSWORD", "")
MOCK = os.environ.get("SNOW_MOCK", "0").lower() in ("1", "true", "yes")


def _auth_header() -> dict[str, str]:
    raw = f"{USER}:{PASSWORD}".encode()
    return {"Authorization": f"Basic {base64.b64encode(raw).decode()}"}


async def _post_table(table: str, body: dict[str, Any]) -> dict[str, Any]:
    if MOCK:
        return {
            "mock": True,
            "table": table,
            "payload": body,
            "result": {"sys_id": "mock-sys-id", "number": "MOCK0001"},
        }
    if not INSTANCE or not USER:
        return {"error": "SNOW_INSTANCE and SNOW_USER (and SNOW_PASSWORD unless MOCK) required"}
    url = f"{INSTANCE}/api/now/table/{table}"
    async with httpx.AsyncClient(timeout=60.0) as client:
        r = await client.post(
            url,
            json=body,
            headers={**_auth_header(), "Accept": "application/json", "Content-Type": "application/json"},
        )
        try:
            data = r.json()
        except Exception:
            data = {"raw": r.text[:2000]}
        if r.status_code >= 400:
            return {"error": "snow_api_error", "status": r.status_code, "body": data}
        return data


async def create_incident(short_description: str, description: str, urgency: str = "2") -> dict[str, Any]:
    body = {
        "short_description": short_description[:200],
        "description": description[:8000] if description else "",
        "urgency": urgency,
    }
    return await _post_table("incident", body)


async def create_change_request(
    short_description: str,
    description: str,
    change_type: str = "normal",
) -> dict[str, Any]:
    body = {
        "short_description": short_description[:200],
        "description": description[:8000] if description else "",
        "type": change_type,
    }
    return await _post_table("change_request", body)
