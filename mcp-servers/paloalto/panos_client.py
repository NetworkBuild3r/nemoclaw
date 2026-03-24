"""PAN-OS REST helpers — real API or mock for demos."""

from __future__ import annotations

import json
import os
import urllib.parse
from typing import Any

import httpx

MOCK_ENV = "PANOS_MOCK"


def _mock_enabled() -> bool:
    return os.environ.get(MOCK_ENV, "").lower() in ("1", "true", "yes")


def _base_url() -> str:
    host = os.environ.get("PANOS_HOST", "192.0.2.1").strip()
    if not host.startswith("http"):
        return f"https://{host}"
    return host.rstrip("/")


def _headers() -> dict[str, str]:
    key = os.environ.get("PANOS_API_KEY", "").strip()
    if key:
        return {"X-PAN-KEY": key}
    user = os.environ.get("PANOS_USER", "").strip()
    pw = os.environ.get("PANOS_PASSWORD", "").strip()
    if user and pw:
        import base64

        tok = base64.b64encode(f"{user}:{pw}".encode()).decode()
        return {"Authorization": f"Basic {tok}"}
    return {}


async def panos_request(
    params: dict[str, Any],
    *,
    timeout: float = 60.0,
) -> dict[str, Any]:
    """GET /api with query params. Returns parsed JSON or raw text wrapper."""
    if _mock_enabled():
        return _mock_response(params)

    url = f"{_base_url()}/api/"
    verify = os.environ.get("PANOS_TLS_VERIFY", "true").lower() in ("1", "true", "yes")
    async with httpx.AsyncClient(verify=verify, timeout=timeout) as client:
        r = await client.get(url, params=params, headers=_headers())
        text = r.text
    try:
        data = json.loads(text)
    except json.JSONDecodeError:
        data = {"raw": text, "status_code": r.status_code}
    return data


def _mock_response(params: dict[str, Any]) -> dict[str, Any]:
    typ = params.get("type", "")
    if typ == "op":
        return {
            "response": {
                "status": "success",
                "result": {
                    "system": {
                        "hostname": "pan-mock",
                        "model": "PA-VM",
                        "sw-version": "11.1.0",
                    }
                },
            }
        }
    if typ == "config":
        return {
            "response": {
                "status": "success",
                "result": {
                    "mock": "config",
                    "xpath": params.get("xpath", ""),
                    "entries": [
                        {"@name": "allow-dns", "action": "allow"},
                        {"@name": "deny-bad", "action": "deny"},
                    ],
                },
            }
        }
    return {"response": {"status": "success", "result": {"mock": True, "params": params}}}


async def show_system_info() -> dict[str, Any]:
    cmd = "<show><system><info></info></system></show>"
    return await panos_request({"type": "op", "cmd": cmd})


async def list_security_rules(location: str, devicegroup: str) -> dict[str, Any]:
    """List security rules for a device-group (shared or local)."""
    loc = location.strip().lower()
    dg = urllib.parse.quote(devicegroup.strip(), safe="")
    if loc == "shared":
        xpath = f"/config/shared/rulebase/security/rules"
    else:
        xpath = f"/config/devices/entry[@name='localhost']/vsys/entry[@name='vsys1']/rulebase/security/rules"
    _ = dg  # devicegroup used in real multi-vsys layouts; mock ignores
    return await panos_request(
        {
            "type": "config",
            "action": "get",
            "xpath": xpath,
        }
    )


async def config_get(xpath: str) -> dict[str, Any]:
    return await panos_request(
        {
            "type": "config",
            "action": "get",
            "xpath": xpath.strip(),
        }
    )
