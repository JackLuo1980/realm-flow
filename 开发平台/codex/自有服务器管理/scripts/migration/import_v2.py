#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import sqlite3
from pathlib import Path
from typing import Any, Iterable

from common import connect_sqlite, now_ms, read_json
from mapping_rules import (
    map_chain_tunnel,
    map_forward,
    map_forward_port,
    map_node,
    map_speed_limit,
    map_statistics_flow,
    map_tunnel,
    map_user,
    map_user_quota,
)


CORE_TABLES = [
    "user",
    "user_quota",
    "node",
    "tunnel",
    "speed_limit",
    "forward",
    "forward_port",
    "chain_tunnel",
    "statistics_flow",
]


def load_snapshot(source_dir: Path) -> dict[str, Any]:
    manifest = read_json(source_dir / "manifest.json")
    tables: dict[str, Any] = {}
    for table in ["user", "node", "tunnel", "forward", "speed_limit", "statistics_flow"]:
        tables[table] = read_json(source_dir / f"{table}.json")
    return {"manifest": manifest, "tables": tables}


def ensure_tables(conn: sqlite3.Connection) -> None:
    existing = {row["name"] for row in conn.execute("select name from sqlite_master where type='table'")}
    missing = [table for table in CORE_TABLES if table not in existing]
    if missing:
        raise RuntimeError(f"target db is missing tables: {', '.join(missing)}")


def clear_tables(conn: sqlite3.Connection) -> None:
    conn.execute("pragma foreign_keys=off")
    for table in CORE_TABLES:
        conn.execute(f"delete from {table}")


def insert_rows(conn: sqlite3.Connection, table: str, rows: list[dict[str, Any]]) -> None:
    if not rows:
        return
    columns = list(rows[0].keys())
    placeholders = ", ".join(["?"] * len(columns))
    col_sql = ", ".join(columns)
    sql = f"insert into {table} ({col_sql}) values ({placeholders})"
    for row in rows:
        conn.execute(sql, [row.get(col) for col in columns])


def build_target_rows(snapshot: dict[str, Any]) -> dict[str, list[dict[str, Any]]]:
    source_tables = snapshot["tables"]
    users = source_tables["user"]["rows"]
    nodes = source_tables["node"]["rows"]
    tunnels = source_tables["tunnel"]["rows"]
    forwards = source_tables["forward"]["rows"]
    speeds = source_tables["speed_limit"]["rows"]
    stats = source_tables["statistics_flow"]["rows"]

    tunnel_by_id = {int(row["id"]): row for row in tunnels}
    speed_by_tunnel = {}
    for speed in speeds:
        tunnel_id = int(speed.get("tunnel_id") or 0)
        if tunnel_id and tunnel_id not in speed_by_tunnel:
            speed_by_tunnel[tunnel_id] = speed

    target = {table: [] for table in CORE_TABLES}

    for row in users:
        mapped = map_user(row)
        target["user"].append(mapped)
        target["user_quota"].append(map_user_quota(mapped))

    for row in nodes:
        target["node"].append(map_node(row))

    for row in tunnels:
        target["tunnel"].append(map_tunnel(row))
        target["chain_tunnel"].extend(map_chain_tunnel(row))

    for row in speeds:
        target["speed_limit"].append(map_speed_limit(row))

    for row in forwards:
        tunnel_row = tunnel_by_id.get(int(row.get("tunnel_id") or 0))
        tunnel_id = int(row.get("tunnel_id") or 0)
        speed_row = speed_by_tunnel.get(tunnel_id)
        speed_id = int(speed_row["id"]) if speed_row else None
        forward = map_forward(row, speed_id=speed_id)
        target["forward"].append(forward)
        node_id = tunnel_row.get("in_node_id") if tunnel_row else None
        in_ip = tunnel_row.get("in_ip") if tunnel_row else None
        target["forward_port"].append(
            map_forward_port(row, node_id=node_id, in_ip=in_ip)
        )

    for row in stats:
        target["statistics_flow"].append(map_statistics_flow(row))

    return target


def main() -> int:
    parser = argparse.ArgumentParser(description="Import a 1.43 snapshot into the v2 SQLite db.")
    parser.add_argument("--source", type=Path, required=True, help="Snapshot directory produced by export_143.py")
    parser.add_argument("--target", type=Path, required=True, help="Target SQLite database")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    snapshot = load_snapshot(args.source)
    target_rows = build_target_rows(snapshot)

    if args.dry_run:
        for table in CORE_TABLES:
            print(f"{table}: {len(target_rows[table])} rows")
        return 0

    conn = connect_sqlite(args.target)
    try:
        ensure_tables(conn)
        with conn:
            clear_tables(conn)
            for table in CORE_TABLES:
                insert_rows(conn, table, target_rows[table])
        print("import complete")
        for table in CORE_TABLES:
            print(f"{table}: {len(target_rows[table])} inserted")
        return 0
    finally:
        conn.close()


if __name__ == "__main__":
    raise SystemExit(main())

