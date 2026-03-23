#!/usr/bin/env python3
from __future__ import annotations

import json
import sqlite3
import subprocess
from pathlib import Path
from typing import Any


def ensure_dir(path: str | Path) -> Path:
    target = Path(path)
    target.mkdir(parents=True, exist_ok=True)
    return target


def read_json(path: str | Path) -> Any:
    with open(path, "r", encoding="utf-8") as fh:
        return json.load(fh)


def write_json(path: str | Path, payload: Any) -> None:
    path = Path(path)
    ensure_dir(path.parent)
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(payload, fh, ensure_ascii=True, indent=2, sort_keys=True)
        fh.write("\n")


def connect_sqlite(path: str | Path) -> sqlite3.Connection:
    conn = sqlite3.connect(str(path))
    conn.row_factory = sqlite3.Row
    return conn


def table_names(conn: sqlite3.Connection) -> list[str]:
    cur = conn.execute(
        "select name from sqlite_master where type='table' order by name"
    )
    return [row["name"] for row in cur.fetchall()]


def table_info(conn: sqlite3.Connection, table: str) -> list[dict[str, Any]]:
    cur = conn.execute(f"pragma table_info({table})")
    return [dict(row) for row in cur.fetchall()]


def sqlite_table_rows(conn: sqlite3.Connection, table: str) -> list[dict[str, Any]]:
    cur = conn.execute(f"select * from {table}")
    rows = cur.fetchall()
    return [dict(row) for row in rows]


def run_command(cmd: list[str], *, input_text: str | None = None) -> str:
    proc = subprocess.run(
        cmd,
        input=input_text,
        capture_output=True,
        text=True,
        check=False,
    )
    if proc.returncode != 0:
        raise RuntimeError(
            "command failed: {}\nstdout:\n{}\nstderr:\n{}".format(
                " ".join(cmd), proc.stdout, proc.stderr
            )
        )
    return proc.stdout


def coerce_int(value: Any, default: int = 0) -> int:
    if value is None or value == "":
        return default
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def coerce_text(value: Any, default: str = "") -> str:
    if value is None:
        return default
    return str(value)


def now_ms() -> int:
    import time

    return int(time.time() * 1000)
