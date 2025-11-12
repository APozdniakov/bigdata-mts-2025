#!/usr/bin/env python3

from onetl.connection import Hive, SparkHDFS
from onetl.file import FileDFReader
from onetl.file.format import Parquet
from onetl.db import DBReader, DBWriter
from pyspark.sql import SparkSession, functions
from pyspark.sql.functions import avg, col, lit

spark = (
    SparkSession.builder.master("yarn")
    .appName("test")
    .config("spark.sql.warehouse.dir", "/user/hive/warehouse")
    .config("spark.hive.metastore.uris", "thrift://team-23-nn:9083")
    .enableHiveSupport()
    .getOrCreate()
)

hdfs = SparkHDFS(host="team-23-nn", port=9000, spark=spark, cluster="x")
print(f"{hdfs.check()=}")

reader = FileDFReader(connection=hdfs, format=Parquet(), source_path="/input")
df = reader.run(["yellow_tripdata_2025_09.parquet"])
print(f"{df.count()=}")

hive = Hive(spark=spark, cluster="x")
print(f"{hive.check()=}")

writer = DBWriter(connection=hive, target="test.yellow_tripdata_2025_09", options=Hive.WriteOptions(partitionBy=["VendorID"], mode="overwrite"))
writer.run(df)
print(f"{df.rdd.getNumPartitions()=}")

# 1. SELECT (SELECT AVG(passenger_count) FROM df) AS passenger_count_avg FROM df;
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

writer = DBWriter(connection=hive, target="test.yellow_tripdata_2025_09_result", options=Hive.WriteOptions(partitionBy=["VendorID"], mode="overwrite"))
writer.run(df)
print(f"{df.rdd.getNumPartitions()=}")
