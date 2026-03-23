#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path

from common import connect_sqlite, read_json


TABLES = [
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


def main() -> int:
    parser = argparse.ArgumentParser(description="Verify a migrated snapshot against a target SQLite db.")
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--target", type=Path, required=True)
    args = parser.parse_args()

    snapshot = read_json(args.source / "manifest.json")
    conn = connect_sqlite(args.target)
    try:
        print("counts:")
        for table in TABLES:
            source_meta = snapshot["tables"].get(table)
            source_count = source_meta["row_count"] if source_meta else "n/a"
            target_count = conn.execute(f"select count(*) as c from {table}").fetchone()["c"]
            print(f"- {table}: source={source_count} target={target_count}")
        print("sample forwards:")
        for row in conn.execute(
            "select id,user_id,user_name,name,tunnel_id,remote_addr,strategy,status from forward order by id limit 5"
        ).fetchall():
            print(dict(row))
        return 0
    finally:
        conn.close()


if __name__ == "__main__":
    raise SystemExit(main())
