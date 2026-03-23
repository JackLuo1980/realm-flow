#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path

from common import connect_sqlite, table_info, table_names


def snapshot(db_path: Path) -> dict:
    conn = connect_sqlite(db_path)
    try:
        tables = table_names(conn)
        schema_version = None
        if "schema_version" in tables:
            row = conn.execute("select version from schema_version limit 1").fetchone()
            if row is not None:
                schema_version = row["version"]
        payload = {
            "db_path": str(db_path),
            "schema_version": schema_version,
            "tables": {},
        }
        for table in tables:
            payload["tables"][table] = {
                "columns": table_info(conn, table),
                "count": conn.execute(f"select count(*) as c from {table}").fetchone()["c"],
            }
        return payload
    finally:
        conn.close()


def main() -> int:
    parser = argparse.ArgumentParser(description="Print a SQLite schema snapshot.")
    parser.add_argument("db_path", type=Path)
    parser.add_argument("--json", action="store_true", help="Emit JSON only")
    args = parser.parse_args()
    payload = snapshot(args.db_path)
    if args.json:
        print(json.dumps(payload, ensure_ascii=True, indent=2, sort_keys=True))
    else:
        print(f"db: {payload['db_path']}")
        print(f"schema_version: {payload['schema_version']}")
        for table, meta in payload["tables"].items():
            print(f"{table}: {meta['count']} rows")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

