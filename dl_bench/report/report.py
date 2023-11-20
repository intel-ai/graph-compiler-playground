from sqlalchemy import create_engine, insert, Engine
from sqlalchemy import (
    MetaData,
    Table,
    Column,
    DateTime,
    String,
    Float,
    Integer,
    JSON,
    func,
)

STRING_LENGTH = 200
LARGE_STRING_LENGTH = 500


metadata_obj = MetaData()


def make_string(name, nullable=False):
    return Column(name, String(STRING_LENGTH), nullable=nullable)


results_table = Table(
    "torchmlir_benchmark",
    metadata_obj,
    # Basic data
    Column("id", Integer, primary_key=True),
    Column("date", DateTime(), nullable=False, server_default=func.now()),
    # Benchmark info
    make_string("benchmark_desc"),
    make_string("benchmark"),
    Column("benchmark_params", JSON, nullable=False),
    # Backend info
    make_string("backend_desc"),
    Column("backend_params", JSON, nullable=False),
    # Results
    Column("warmup_s", Float, nullable=False),
    Column("duration_s", Float, nullable=False),
    Column("samples_per_s", Float, nullable=False),
)


class BenchmarkDb:
    def __init__(self, engine_string):
        self.engine = create_engine(engine_string)
        metadata_obj.create_all(self.engine, checkfirst=True)

    def report(self, **value_dict):
        stmt = insert(results_table).values(**value_dict)
        with self.engine.begin() as conn:
            result = conn.execute(stmt)
