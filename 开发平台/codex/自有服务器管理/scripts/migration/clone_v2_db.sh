#!/usr/bin/env sh
set -eu

if [ "$#" -ne 2 ]; then
  echo "usage: $0 SOURCE_DB TARGET_DB" >&2
  exit 1
fi

src="$1"
dst="$2"
dst_dir=$(dirname "$dst")
mkdir -p "$dst_dir"
cp "$src" "$dst"
if [ -f "${src}-wal" ]; then
  cp "${src}-wal" "${dst}-wal"
fi
if [ -f "${src}-shm" ]; then
  cp "${src}-shm" "${dst}-shm"
fi

