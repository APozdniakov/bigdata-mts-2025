from prefect import flow, task
from onetl.connection import Hive, SparkHDFS
from onetl.file import FileDFReader
from onetl.file.format import Parquet
from onetl.db import DBReader, DBWriter
from pyspark.sql import SparkSession, functions
from pyspark.sql.functions import avg, col, lit

@task
def init_spark():
    spark = (
        SparkSession.builder.master("yarn")
        .appName("test")
        .config("spark.sql.warehouse.dir", "/user/hive/warehouse")
        .config("spark.hive.metastore.uris", "thrift://team-23-nn:9083")
        .enableHiveSupport()
        .getOrCreate()
    )
    return spark

@task
def stop_spark(spark):
    spark.stop()

@task
def extract(spark):
    hdfs = SparkHDFS(host="team-23-nn", port=9000, spark=spark, cluster="x").check()

    reader = FileDFReader(connection=hdfs, format=Parquet(), source_path="/input")
    df = reader.run(["yellow_tripdata_2025_09.parquet"])

    return df

@task
def transform(df):

    average_value = df.select(avg("passenger_count")).first()[0]
    df = df.withColumn("passenger_count_avg", lit(average_value))

    # 2. SELECT passenger_count + trip_distance AS pass_count_trip_dist FROM df;
    df = df.withColumn("pass_count_trip_dist", col("passenger_count") + col("trip_distance"))

    # 3. SELECT CAST(passenger_count AS integer) AS passenger_count FROM df;
    df = df.withColumn("passenger_count", col("passenger_count").cast("integer"))

    # 4. SELECT unix_timestamp(tpep_dropoff_datetime) - unix_timestamp(tpep_pickup_datetime) AS trip_duration_seconds FROM df;
    df = df.withColumn("trip_duration_seconds",
            (functions.unix_timestamp("tpep_dropoff_datetime") - functions.unix_timestamp("tpep_pickup_datetime")))

    # 5. SELECT AVG(tip_amount) FROM df GROUP BY passenger_count;
    df = df.groupBy("passenger_count").agg(
        avg("tip_amount").alias('average_tips'),
    )
    return df

@task
def load(df, spark):
    hive = Hive(spark=spark, cluster="x")
    print(f"{hive.check()=}")
    # writer = DBWriter(connection=hive, target="test.yellow_tripdata_2025_09_result_new", options=Hive.WriteOptions(partitionBy=["VendorID"], mode="overwrite"))
    writer = DBWriter(connection=hive, target="test.yellow_tripdata_2025_09_result_new", options=Hive.WriteOptions(partitionBy=["VendorID"]))
    writer.run(df)

@flow
def process_data():
    spark = init_spark()

    df = extract(spark)
    df = transform(df)
    load(df, spark)

    stop_spark(spark)

if __name__ == "__main__":
    process_data()