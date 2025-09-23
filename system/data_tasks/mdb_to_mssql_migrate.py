import os
import sys
import subprocess
import logging
import argparse
import csv
import shutil
import pytds as tds
from pathlib import Path
from tqdm import tqdm
from concurrent.futures import ThreadPoolExecutor, as_completed
from services.dte_tools.data_task_tools import (
    DataTaskEnvironment,
    get_resolved_parameters_for_connection,
    initialise_data_task,
)

# ===============================
# MSSQL CONNECTION CONFIG
# ===============================
MSSQL_CONFIG = get_resolved_parameters_for_connection("ANA")

# Path to bundled mdb-tools under the user's home directory (dynamic per user)
MDB_TOOLS_PATH = Path.home() / "duft_resources" / "duft_config" / "system" / "utils" / "mdbtools-win-1.0.0"

MAX_WORKERS = 4
INSERT_BATCH_SIZE = 150

# =========================
# TYPE MAPPING
# =========================
TYPE_MAP = {
    "Text": lambda size: f"NVARCHAR({size})",
    "Memo": lambda _: "NVARCHAR(MAX)",
    "DateTime": lambda _: "DATETIME",
    "Single": lambda _: "REAL",
    "Double": lambda _: "FLOAT",
    "Long": lambda _: "BIGINT",
    "Integer": lambda _: "INT",
    "Byte": lambda _: "TINYINT",
    "Yes/No": lambda _: "BIT",
    "Currency": lambda _: "MONEY",
    "AutoNumber": lambda _: "INT IDENTITY(1,1)",
    "Hyperlink": lambda _: "NVARCHAR(2048)",
    "OLE Object": lambda _: "VARBINARY(MAX)",
    "Attachment": lambda _: "VARBINARY(MAX)",
    "GUID": lambda _: "UNIQUEIDENTIFIER",
}

# =========================
# LOGGER
# =========================
logging.getLogger("pytds").setLevel(logging.WARNING)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)],
)

# =========================
# ENV INITIALIZATION
# =========================
def initialize_environment():
    """
    Prepend the bundled mdb-tools directory to PATH and verify required tools exist.
    """
    mdb_tools_dir = str(MDB_TOOLS_PATH)
    os.environ["PATH"] = mdb_tools_dir + os.pathsep + os.environ.get("PATH", "")

    # Sanity check for required binaries
    for tool in ("mdb-tables", "mdb-schema", "mdb-export"):
        if shutil.which(tool) is None:
            logging.error(
                f"'{tool}' not found on PATH. Expected under: {mdb_tools_dir}\n"
                f"Current PATH: {os.environ.get('PATH', '')}\n"
                "Make sure your bundled mdb-tools are present & executable."
            )
            sys.exit(1)

# =========================
# ARGS
# =========================
def parse_args():
    parser = argparse.ArgumentParser(description="Super-fast MDB to MSSQL migration (always recreates DB).")
    parser.add_argument("--mdb", "-m", required=True, help="Path to .mdb file")
    parser.add_argument("--mssql-db-name", "-d", help="Target MSSQL database name (defaults to MDB filename)")
    parser.add_argument("--use-bcp", action="store_true", help="Use MSSQL BCP utility for faster import (experimental)")
    args = parser.parse_args()

    if not args.mssql_db_name:
        args.mssql_db_name = os.path.splitext(os.path.basename(args.mdb))[0]
        logging.info(f"--mssql-db-name not provided. Defaulting to: '{args.mssql_db_name}'")

    return args

# =========================
# CONNECTION
# =========================
def connect_mssql(database):
    return tds.connect(
        server=MSSQL_CONFIG["server"],
        database=database,
        user=MSSQL_CONFIG["user"],
        password=MSSQL_CONFIG["password"],
        port=int(MSSQL_CONFIG["port"]),
    )

# =========================
# DB UTILS (ALWAYS RECREATE)
# =========================
def ensure_database(name):
    conn = connect_mssql("master")
    conn.autocommit = True
    cursor = conn.cursor()

    # Drop if exists
    cursor.execute("SELECT name FROM sys.databases WHERE name = %s", (name,))
    exists = cursor.fetchone() is not None
    if exists:
        logging.info(f"Recreating existing database: {name}")
        cursor.execute(f"ALTER DATABASE [{name}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE")
        cursor.execute(f"DROP DATABASE [{name}]")

    # Create fresh DB
    cursor.execute(f"CREATE DATABASE [{name}]")
    logging.info(f"Created database: {name}")

    conn.commit()
    conn.close()

# =========================
# SHELL TOOLS
# =========================
def run_cmd(args):
    result = subprocess.run(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if result.returncode != 0:
        logging.error(f"Command failed: {' '.join(args)}\n{result.stderr}")
        sys.exit(1)
    return result.stdout

def get_tables(mdb_path):
    return run_cmd(["mdb-tables", "-1", mdb_path]).strip().splitlines()

def get_schema(mdb_path):
    return run_cmd(["mdb-schema", mdb_path])

def export_table_data(mdb_path, table):
    # Dates: -D for date, -T for timestamp
    return run_cmd(["mdb-export", "-D", "%Y-%m-%d", "-T", "%Y-%m-%d %H:%M:%S", mdb_path, table])

# =========================
# SCHEMA CONVERSION
# =========================
def extract_create_stmt(schema_sql, table):
    lines = schema_sql.splitlines()
    collecting, buffer = False, []
    target = f"CREATE TABLE [{table}]".upper()
    for line in lines:
        if line.strip().upper().startswith(target):
            collecting = True
        if collecting:
            buffer.append(line)
            if line.strip().endswith(";"):
                break
    return "\n".join(buffer)

def convert_schema_to_mssql(create_stmt):
    lines = create_stmt.strip().splitlines()
    if not lines:
        return None, None, None

    table_line = lines[0]
    col_lines = lines[1:-1]

    new_col_lines = []
    column_types = {}

    for col in col_lines:
        if "--" in col:
            col = col.split("--")[0]
        col = col.strip().rstrip(",")
        if not col:
            continue

        parts = col.split(None, 1)
        if len(parts) != 2:
            continue
        name, rest = parts

        if name.startswith("[") and name.endswith("]"):
            name = name[1:-1]

        type_part = rest.split()[0]
        size = None

        if type_part.startswith("Text"):
            try:
                size = int(type_part.split("(")[1].rstrip(")"))
            except Exception:
                size = 255
            sql_type = TYPE_MAP["Text"](size)
            column_types[name] = "Text"
        else:
            base_type = type_part.strip()
            type_func = TYPE_MAP.get(base_type, lambda s=None: "NVARCHAR(255)")
            sql_type = type_func(size)
            column_types[name] = base_type

        new_col_lines.append(f"    [{name}] {sql_type},")

    # Extract table name safely
    parts = table_line.split()
    table_name = parts[2].strip("[]") if len(parts) >= 3 else None
    if not table_name:
        return None, None, None

    mssql_schema = f"CREATE TABLE [{table_name}] (\n" + "\n".join(new_col_lines).rstrip(",") + "\n);"
    return mssql_schema, table_name, column_types

# =========================
# DATA INSERTION
# =========================
def parse_csv_rows(csv_data):
    lines = csv_data.strip().splitlines()
    reader = csv.reader(lines)
    rows = list(reader)
    return (rows[0], rows[1:]) if rows else ([], [])

def insert_batch(cursor, table, columns, rows):
    placeholders = ",".join(["%s"] * len(columns))
    cols_joined = ",".join(columns)
    insert_sql = f"INSERT INTO [{table}] ({cols_joined}) VALUES ({placeholders})"
    try:
        cursor.executemany(insert_sql, rows)
    except Exception as e:
        logging.error(f"Batch insert failed for {table}: {e}")

def migrate_table(mdb_path, schema_sql, table, dbname, use_bcp):
    try:
        conn = connect_mssql(dbname)
        cursor = conn.cursor()

        create_stmt = extract_create_stmt(schema_sql, table)
        if not create_stmt:
            logging.warning(f"No schema for: {table}")
            return

        mssql_schema, mssql_table, column_types = convert_schema_to_mssql(create_stmt)
        if not mssql_schema:
            logging.warning(f"Failed to convert schema: {table}")
            return

        # Safety check (should not exist in a freshly recreated DB)
        cursor.execute("SELECT OBJECT_ID(%s, 'U')", (f"dbo.{mssql_table}",))
        if cursor.fetchone()[0] is not None:
            logging.info(f"Table already exists unexpectedly, skipping: {mssql_table}")
            return

        cursor.execute(mssql_schema)
        conn.commit()  # <-- fixed indentation

        # Export data
        csv_data = export_table_data(mdb_path, table)
        header, rows = parse_csv_rows(csv_data)
        if not rows:
            logging.info(f"No data in table: {table}")
            return

        columns = [f"[{col}]" for col in header]
        for i in range(0, len(rows), INSERT_BATCH_SIZE):
            batch = rows[i:i + INSERT_BATCH_SIZE]
            clean_batch = [
                [None if (v is None or str(v).upper() == "NULL") else v for v in row]
                for row in batch
            ]
            insert_batch(cursor, mssql_table, columns, clean_batch)

        conn.commit()
        logging.info(f"Migrated table: {table}")
    except Exception as e:
        logging.error(f"Error migrating table {table}: {e}")
    finally:
        try:
            conn.close()
        except Exception:
            pass

# =========================
# MAIN
# =========================
def main():
    initialize_environment()
    args = parse_args()

    if not os.path.isfile(args.mdb):
        logging.error(f"File not found: {args.mdb}")
        sys.exit(1)

    # Always recreate DB each run
    ensure_database(args.mssql_db_name)

    schema_sql = get_schema(args.mdb)
    tables = get_tables(args.mdb)

    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        futures = [
            executor.submit(
                migrate_table, args.mdb, schema_sql, table, args.mssql_db_name, args.use_bcp
            )
            for table in tables
        ]
        for f in tqdm(as_completed(futures), total=len(futures), desc="Migrating tables", unit="table"):
            f.result()

    logging.info("✅ Migration completed successfully!")


main()
