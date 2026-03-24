#!/usr/bin/env python3

import sqlite3
import re

def is_chinese(text):
    return any('\u4e00' <= char <= '\u9fff' for char in text)

def sort_key(name):
    if is_chinese(name):
        return (1, name)
    else:
        return (0, name)

def main():
    db_path = '/opt/dstatus/data/db.db'
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    cursor.execute('SELECT sid, name FROM servers WHERE deleted_at IS NULL')
    servers = cursor.fetchall()

    servers.sort(key=lambda x: sort_key(x[1]))

    for index, (sid, name) in enumerate(servers):
        cursor.execute('UPDATE servers SET display_index = ? WHERE sid = ?', (index, sid))
        print(f'{index}: {name}')

    conn.commit()
    conn.close()
    print('\n排序完成！')

if __name__ == '__main__':
    main()
