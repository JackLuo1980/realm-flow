#!/usr/bin/env python3
from __future__ import annotations

from typing import Any

from common import coerce_int, coerce_text, now_ms


def map_user(source: dict[str, Any]) -> dict[str, Any]:
    updated = source.get("updated_time")
    if updated in (None, ""):
        updated = source.get("created_time")
    return {
        "id": coerce_int(source.get("id")),
        "user": coerce_text(source.get("user")),
        "pwd": coerce_text(source.get("pwd")),
        "role_id": coerce_int(source.get("role_id")),
        "exp_time": coerce_int(source.get("exp_time")),
        "flow": coerce_int(source.get("flow")),
        "in_flow": coerce_int(source.get("in_flow")),
        "out_flow": coerce_int(source.get("out_flow")),
        "flow_reset_time": coerce_int(source.get("flow_reset_time")),
        "num": coerce_int(source.get("num")),
        "created_time": coerce_int(source.get("created_time"), now_ms()),
        "updated_time": coerce_int(updated, now_ms()),
        "status": coerce_int(source.get("status"), 1),
    }


def map_user_quota(user_row: dict[str, Any]) -> dict[str, Any]:
    stamp = coerce_int(user_row.get("updated_time"), coerce_int(user_row.get("created_time"), now_ms()))
    return {
        "user_id": coerce_int(user_row.get("id")),
        "daily_limit_gb": 0,
        "monthly_limit_gb": 0,
        "daily_used_bytes": 0,
        "monthly_used_bytes": 0,
        "day_key": 0,
        "month_key": 0,
        "disabled_by_quota": 0,
        "disabled_at": 0,
        "paused_forward_ids": "",
        "created_time": coerce_int(user_row.get("created_time"), now_ms()),
        "updated_time": stamp,
    }


def map_node(source: dict[str, Any]) -> dict[str, Any]:
    port_sta = coerce_int(source.get("port_sta"))
    port_end = coerce_int(source.get("port_end"), port_sta)
    port = str(port_sta) if port_sta == port_end else f"{port_sta}-{port_end}"
    return {
        "id": coerce_int(source.get("id")),
        "name": coerce_text(source.get("name")),
        "remark": "",
        "expiry_time": None,
        "renewal_cycle": None,
        "secret": coerce_text(source.get("secret")),
        "server_ip": coerce_text(source.get("server_ip")),
        "server_ip_v4": coerce_text(source.get("server_ip")),
        "server_ip_v6": "",
        "extra_ips": coerce_text(source.get("ip")),
        "port": port,
        "interface_name": None,
        "version": coerce_text(source.get("version")),
        "http": coerce_int(source.get("http")),
        "tls": coerce_int(source.get("tls")),
        "socks": coerce_int(source.get("socks")),
        "created_time": coerce_int(source.get("created_time"), now_ms()),
        "updated_time": source.get("updated_time"),
        "status": coerce_int(source.get("status"), 1),
        "tcp_listen_addr": "[::]",
        "udp_listen_addr": "[::]",
        "inx": coerce_int(source.get("inx"), 0),
        "is_remote": 0,
        "remote_url": None,
        "remote_token": None,
        "remote_config": None,
        "expiry_reminder_dismissed": 0,
    }


def map_tunnel(source: dict[str, Any]) -> dict[str, Any]:
    return {
        "id": coerce_int(source.get("id")),
        "name": coerce_text(source.get("name")),
        "traffic_ratio": float(source.get("traffic_ratio") or 1.0),
        "type": coerce_int(source.get("type")),
        "protocol": coerce_text(source.get("protocol"), "tls"),
        "flow": coerce_int(source.get("flow")),
        "created_time": coerce_int(source.get("created_time"), now_ms()),
        "updated_time": coerce_int(source.get("updated_time"), now_ms()),
        "status": coerce_int(source.get("status"), 1),
        "in_ip": coerce_text(source.get("in_ip")),
        "inx": coerce_int(source.get("inx"), 0),
        "ip_preference": "",
    }


def map_chain_tunnel(source: dict[str, Any]) -> list[dict[str, Any]]:
    tunnel_id = coerce_int(source.get("id"))
    created = coerce_int(source.get("created_time"), now_ms())
    updated = coerce_int(source.get("updated_time"), created)
    protocol = coerce_text(source.get("protocol"), "tls")
    return [
        {
            "id": tunnel_id * 10 + 1,
            "tunnel_id": tunnel_id,
            "chain_type": "in",
            "node_id": coerce_int(source.get("in_node_id")),
            "port": None,
            "strategy": "round",
            "inx": 0,
            "protocol": protocol,
            "connect_ip": coerce_text(source.get("in_ip")),
        },
        {
            "id": tunnel_id * 10 + 2,
            "tunnel_id": tunnel_id,
            "chain_type": "out",
            "node_id": coerce_int(source.get("out_node_id")),
            "port": None,
            "strategy": "round",
            "inx": 1,
            "protocol": protocol,
            "connect_ip": coerce_text(source.get("out_ip")),
        },
    ]


def map_speed_limit(source: dict[str, Any]) -> dict[str, Any]:
    return {
        "id": coerce_int(source.get("id")),
        "name": coerce_text(source.get("name")),
        "speed": coerce_int(source.get("speed")),
        "tunnel_id": coerce_int(source.get("tunnel_id")),
        "tunnel_name": coerce_text(source.get("tunnel_name")),
        "created_time": coerce_int(source.get("created_time"), now_ms()),
        "updated_time": coerce_int(source.get("updated_time"), now_ms()),
        "status": coerce_int(source.get("status"), 1),
    }


def map_forward(
    source: dict[str, Any], *, speed_id: int | None = None
) -> dict[str, Any]:
    return {
        "id": coerce_int(source.get("id")),
        "user_id": coerce_int(source.get("user_id")),
        "user_name": coerce_text(source.get("user_name")),
        "name": coerce_text(source.get("name")),
        "tunnel_id": coerce_int(source.get("tunnel_id")),
        "remote_addr": coerce_text(source.get("remote_addr")),
        "strategy": coerce_text(source.get("strategy"), "fifo"),
        "in_flow": coerce_int(source.get("in_flow")),
        "out_flow": coerce_int(source.get("out_flow")),
        "created_time": coerce_int(source.get("created_time"), now_ms()),
        "updated_time": coerce_int(source.get("updated_time"), now_ms()),
        "status": coerce_int(source.get("status"), 1),
        "inx": coerce_int(source.get("inx"), 0),
        "speed_id": speed_id,
    }


def map_forward_port(
    source: dict[str, Any], *, node_id: int | None, in_ip: str | None
) -> dict[str, Any]:
    return {
        "id": coerce_int(source.get("id")),
        "forward_id": coerce_int(source.get("id")),
        "node_id": coerce_int(node_id),
        "port": coerce_int(source.get("in_port")),
        "in_ip": coerce_text(in_ip),
    }


def map_statistics_flow(source: dict[str, Any]) -> dict[str, Any]:
    return {
        "id": coerce_int(source.get("id")),
        "user_id": coerce_int(source.get("user_id")),
        "flow": coerce_int(source.get("flow")),
        "total_flow": coerce_int(source.get("total_flow")),
        "time": coerce_text(source.get("time")),
        "created_time": coerce_int(source.get("created_time"), now_ms()),
    }

