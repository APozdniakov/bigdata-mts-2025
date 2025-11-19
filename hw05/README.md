# hw4

## Требования

Работающий hdfs из hw1 + yarn кластер из hw2 + hive из hw3

Файл yellow_tripdata_2025-09.parquet из https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-09.parquet

## Запуск

### Запуск Hive

Запуск Apache Spark происходит через файл scripts/copy_and_run_hadoop.py (
    Он вызывает основной скрипт (используя hadoop пользователя) - run_spark_prefect.py, через который происходит запуск с помощью prefect.
)

Можно проверить локальную работу , пробрасывая порты:

```shell
ssh -L 10002:192.168.1.95:10002 -L 9870:192.168.1.95:9870 -L 8088:192.168.1.95:8088 -L 19888:192.168.1.95:19888 team@176.109.91.25
```


Должны появится данные по пути:
```code 
http://localhost:9870/explorer.html#/user/hive/warehouse
```
Новые данные - yellow_tripdata_2025_09_result_new


Трансформация данных 
    1.Добавляем новый столбец - среднее общее число пассажиров во всех поездках
    2. Складывает значения из двух столбцов passenger_count, trip_distancep pass_count_trip_dist
    3. Изменяет тип на int колонки passenger_count
    4. Получаем новый столбец - длительность поездки как разницу tpep_dropoff_datetime и tpep_pickup_datetime
    5. Группирует по passenger_count и вычисляет среднее для каждой группы