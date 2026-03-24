"""Brave Search API — https://api.search.brave.com/res/v1/web/search"""

from __future__ import annotations

import os
from typing import Any

import httpx

BRAVE_SEARCH_URL = "https://api.search.brave.com/res/v1/web/search"


def _api_key() -> str:
    key = os.environ.get("BRAVE_API_KEY", "").strip()
    if not key:
        raise RuntimeError(
            "BRAVE_API_KEY is not set — export it or add to .env before starting the Brave MCP server"
        )
    return key


async def web_search(query: str, count: int = 10, country: str = "us") -> dict[str, Any]:
    """Search the web; returns Brave JSON (trimmed by MCP layer if huge)."""
    q = query.strip()
    if not q:
        return {"error": "empty query"}

    n = max(1, min(int(count), 20))
    params = {"q": q, "count": n, "country": country}
    headers = {
        "Accept": "application/json",
        "X-Subscription-Token": _api_key(),
    }

    async with httpx.AsyncClient(timeout=30.0) as client:
        r = await client.get(BRAVE_SEARCH_URL, params=params, headers=headers)
        r.raise_for_status()
        return r.json()
