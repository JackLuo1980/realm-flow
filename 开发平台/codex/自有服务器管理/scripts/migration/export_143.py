#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import shlex
from pathlib import Path
from typing import Any

from common import ensure_dir, run_command, write_json


TABLES = ["user", "node", "tunnel", "forward", "speed_limit", "statistics_flow"]


def build_remote_mysql_cmd(args: argparse.Namespace, query: str) -> list[str]:
    if args.ssh_host:
        remote_cmd = (
            "docker exec "
            + shlex.quote(args.docker_container)
            + " mysql -u "
            + shlex.quote(args.mysql_user)
            + " "
            + shlex.quote(f"-p{args.mysql_password}")
            + " -D "
            + shlex.quote(args.mysql_db)
            + " -N -B -e "
            + shlex.quote(query)
        )
        return [
            "sshpass",
            "-p",
            args.ssh_password,
            "ssh",
            "-p",
            str(args.ssh_port),
            "-o",
            "StrictHostKeyChecking=no",
            f"{args.ssh_user}@{args.ssh_host}",
            remote_cmd,
        ]
    return [
        "mysql",
        "-u",
        args.mysql_user,
        f"-p{args.mysql_password}",
        "-h",
        args.mysql_host,
        "-P",
        str(args.mysql_port),
        "-D",
        args.mysql_db,
        "-N",
        "-B",
        "-e",
        query,
    ]


def remote_query(args: argparse.Namespace, query: str) -> str:
    return run_command(build_remote_mysql_cmd(args, query))


def load_columns(args: argparse.Namespace, table: str) -> list[str]:
    output = remote_query(args, f"show columns from `{table}`;")
    columns: list[str] = []
    for line in output.splitlines():
        if not line.strip():
            continue
        columns.append(line.split("\t", 1)[0])
    return columns


def load_rows(args: argparse.Namespace, table: str, columns: list[str]) -> list[dict[str, Any]]:
    if not columns:
        return []
    exprs = []
    for col in columns:
        exprs.append(f"'{col}'")
        exprs.append(f"`{col}`")
    order_clause = " order by `id`" if "id" in columns else ""
    query = f"select json_object({', '.join(exprs)}) as row_json from `{table}`{order_clause};"
    output = remote_query(args, query)
    rows = []
    for line in output.splitlines():
        line = line.strip()
        if not line:
            continue
        rows.append(json.loads(line))
    return rows


def export_snapshot(args: argparse.Namespace) -> dict[str, Any]:
    payload: dict[str, Any] = {
        "source": {
            "mysql_host": args.mysql_host,
            "mysql_port": args.mysql_port,
            "mysql_db": args.mysql_db,
            "ssh_host": args.ssh_host,
            "ssh_user": args.ssh_user,
            "docker_container": args.docker_container,
        },
        "tables": {},
    }
    for table in TABLES:
        columns = load_columns(args, table)
        rows = load_rows(args, table, columns)
        payload["tables"][table] = {
            "columns": columns,
            "row_count": len(rows),
            "rows": rows,
        }
    return payload


def main() -> int:
    parser = argparse.ArgumentParser(description="Export the 1.43 MySQL data to JSON.")
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--mysql-host", default="127.0.0.1")
    parser.add_argument("--mysql-port", type=int, default=3306)
    parser.add_argument("--mysql-user", required=True)
    parser.add_argument("--mysql-password", required=True)
    parser.add_argument("--mysql-db", required=True)
    parser.add_argument("--ssh-host")
    parser.add_argument("--ssh-port", type=int, default=22)
    parser.add_argument("--ssh-user", default="root")
    parser.add_argument("--ssh-password")
    parser.add_argument("--docker-container", default="gost-mysql")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    if args.ssh_host and not args.ssh_password:
        parser.error("--ssh-password is required when --ssh-host is set")

    if args.dry_run:
        print("dry-run: no files written")
        for table in TABLES:
            print(f"- would export {table}")
        return 0

    ensure_dir(args.output_dir)
    snapshot = export_snapshot(args)
    snapshot["manifest"] = {
        "tables": {k: v["row_count"] for k, v in snapshot["tables"].items()}
    }
    for table, meta in snapshot["tables"].items():
        write_json(args.output_dir / f"{table}.json", meta)
    write_json(args.output_dir / "manifest.json", snapshot["manifest"] | snapshot["source"])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
