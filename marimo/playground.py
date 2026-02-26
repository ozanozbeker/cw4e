import marimo

__generated_with = "0.20.2"
app = marimo.App(width="full", sql_output="polars")

with app.setup:
    import marimo as mo
    import duckdb


@app.cell(hide_code=True)
async def _():
    import sys
    from pathlib import Path

    if "pyodide" in sys.modules:
        from pyodide.http import pyfetch

        _db_path = Path("/tmp/northwind.duckdb")
        if not _db_path.exists():
            _resp = await pyfetch("https://ozanozbeker.com/cw4e/data/northwind.duckdb")
            _bytes = await _resp.bytes()
            _db_path.write_bytes(_bytes)
    else:
        _db_path = Path(__file__).parent / "public" / "northwind.duckdb"

    conn = duckdb.connect(str(_db_path), read_only=True)
    return (conn,)


@app.cell(hide_code=True)
def _():
    mo.md("""
    # SQL

    Write and run SQL queries code against the
    [Northwind database](../appendices/northwind.html).
    """)
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    ## ERD

    ![Northwind ERD](https://ozanozbeker.com/cw4e/images/northwind_erd.svg)

    [Interactive version](https://dbdiagram.io/d/northwind_erd-69a0ade7a3f0aa31e13b3e83)

    ## Data Dictionary
    """)
    return


@app.cell(hide_code=True)
def _():
    _df = mo.sql(
        f"""
        SELECT * FROM data_dictionary
        """,
        engine=conn,
    )
    return


@app.cell(hide_code=True)
def _():
    mo.md(r"""
    ## SQL Editors
    """)
    return


@app.cell
def _():
    sql_editor_1 = mo.ui.code_editor(
        value="-- Write your SQL query here\nSELECT * FROM data_dictionary;",
        language="sql",
        min_height=150,
        label="**SQL**",
    )
    sql_editor_1
    return (sql_editor_1,)


@app.cell
def _(sql_editor_1):
    conn.sql(sql_editor_1.value).fetchdf()
    return


@app.cell
def _():
    sql_editor_2 = mo.ui.code_editor(
        value="-- Write your SQL query here\nSELECT * FROM data_dictionary;",
        language="sql",
        min_height=150,
        label="**SQL**",
    )
    sql_editor_2
    return (sql_editor_2,)


@app.cell
def _(sql_editor_2):
    conn.sql(sql_editor_2.value).fetchdf()
    return


if __name__ == "__main__":
    app.run()
