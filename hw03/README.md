# hw3

## Требования

Работающий hdfs + yarn кластер из hw2

## Запуск

### Запуск Hive

Запуск Hive происходит через скрипт `scripts/run_hive.sh`

Можно проверить локальную работу Hive, пробрасывая порты:

```shell
ssh -L 10002:192.168.1.95:10002 -L 9870:192.168.1.95:9870 -L 8088:192.168.1.95:8088 -L 19888:192.168.1.95:19888 team@176.109.91.25
```

### Загрузка файла в Hive как таблицу

Сначала был скачан файл

```shell
wget --no-check-certificate http://rospatent.gov.ru/opendata/7730176088-tz/data-20241101-structure-20180828.csv
mv data-20241101-structure-20180828.csv data.csv
```

Потом файл был загружен в HDFS

```shell
hdfs dfs -put data.csv /input
```

Потом файл был загружен в Hive как таблицу

```shell
beeline -u jdbc:hive2://team-23-nn:5433
```

С помощью beeline были созданы база данных и таблица, в которую был переложен файл с помощью команд из [./templates/hive_init.sql](./templates/hive_init.sql)

Результат доступен в http://localhost:9870/explorer.html#/user/hive/warehouse/test.db/data после проброса портов
