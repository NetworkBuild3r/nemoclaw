"""Brave Search API — https://api.search.brave.com/res/v1/web/search"""

from __future__ import annotations

import os
from typing import Any

import httpx

BRAVE_SEARCH_URL = "https://api.search.brave.com/res/v1/web/search"
# Brave docs use 2-letter ISO country; examples show uppercase (e.g. DE). Very long q can 422.
_MAX_Q_LEN = 400


def _api_key() -> str:
    key = os.environ.get("BRAVE_API_KEY", "").strip()
    if not key:
        raise RuntimeError(
            "BRAVE_API_KEY is not set — export it or add to .env before starting the Brave MCP server"
        )
    return key


def _headers() -> dict[str, str]:
    # Brave Search API docs require these exact header names (see authentication guide).
    return {
        "Accept": "application/json",
        "Accept-Encoding": "gzip",
        "X-Subscription-Token": _api_key(),
    }


async def web_search(query: str, count: int = 10, country: str = "us") -> dict[str, Any]:
    """Search the web; returns Brave JSON (trimmed by MCP layer if huge)."""
    q = " ".join(query.split()).strip()
    if not q:
        return {"error": "empty query"}
    if len(q) > _MAX_Q_LEN:
        q = q[:_MAX_Q_LEN]

    n = max(1, min(int(count), 20))
    cc = (country or "us").strip().upper()
    if len(cc) != 2 or not cc.isalpha():
        cc = "US"

    params: dict[str, Any] = {"q": q, "count": n, "country": cc}

    async with httpx.AsyncClient(timeout=30.0) as client:
        r = await client.get(BRAVE_SEARCH_URL, params=params, headers=_headers())
        if r.status_code >= 400:
            body = (r.text or "")[:4000]
            try:
                err_json = r.json()
                body = str(err_json)[:4000]
            except Exception:
                pass
            raise RuntimeError(
                f"Brave API HTTP {r.status_code}: {body}. "
                "Check BRAVE_API_KEY (Search API key from https://api-dashboard.search.brave.com/), "
                "plan includes Web Search, and query is plain text (no huge JSON blobs)."
            ) from None
        return r.json()
