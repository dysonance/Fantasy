import pandas as pd
import psycopg2 as psql


def dbconnect() -> psql.extensions.connection:
    uri = "host=localhost user=nfldb password=nfldb dbname=nfldb"
    return psql.connect(uri)


def dbquery(query: str, params: list = None) -> pd.DataFrame:
    # convert from data grip parameter syntax if necessary
    query = query.replace("?", "%s")
    params = [] if params is None else params
    result = {"cols": None, "rows": None}
    with dbconnect() as db:
        with db.cursor() as cursor:
            cursor.execute(query, params)
            db.commit()
            if cursor.description is not None:
                result["cols"] = [col.name for col in cursor.description]
                result["rows"] = cursor.fetchall()
        return pd.DataFrame(result["rows"], columns=result["cols"])
