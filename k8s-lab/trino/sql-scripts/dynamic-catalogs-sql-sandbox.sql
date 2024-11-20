DROP CATALOG gateway_db;

CREATE CATALOG gateway_db USING postgresql
WITH (
  "connection-url" = 'jdbc:postgresql://postgres.postgres.svc.cluster.local:5432/gateway',
  "connection-user" = 'postgres',
  "connection-password" = 'postgres',
  "case-insensitive-name-matching" = 'true'
);

----------------------------------------

DROP CATALOG iceberg;

CREATE CATALOG iceberg USING iceberg
WITH (
    "iceberg.catalog.type"='hive_metastore',
    "iceberg.file-format"='PARQUET',
    "iceberg.security"='ALLOW_ALL',
    "hive.metastore.uri"='thrift://hive.trino.svc.cluster.local:9083',
    "fs.native-s3.enabled"='true',
    "s3.endpoint"='http://tenant-00-hl.minio.svc.cluster.local:9000',
    "s3.region"='us-east-1',
    "s3.path-style-access"='true',
    "s3.aws-access-key"='minio',
    "s3.aws-secret-key"='minio123',
    "s3.socket-connect-timeout"='30s',
    "s3.socket-read-timeout"='30s',
    "fs.cache.enabled"='true',
    "fs.cache.directories"='/tmp/trino-cache',
    "fs.cache.max-sizes"='20GB',
    "fs.cache.ttl"='30s',
    "fs.cache.preferred-hosts-count"='2'
);

----------------------------------------

DROP CATALOG singlestore;

CREATE CATALOG singlestore USING singlestore
WITH (
    "connection-url"='jdbc:singlestore://svc-sdb-cluster-ddl.sdb.svc.cluster.local:3306',
    "connection-user"='superadmin',
    "connection-password"='superadmin123',
    "metadata.cache-ttl"='60m',
    "metadata.cache-missing"='true'
);

----------------------------------------

DROP CATALOG tpch;

CREATE CATALOG tpch USING tpch;

----------------------------------------

DROP CATALOG clickhouse;

CREATE CATALOG clickhouse USING clickhouse
WITH (
  "connection-url"='jdbc:clickhouse://clickhouse-clickhouse-cluster.clickhouse.svc.cluster.local:8123/',
  "connection-user"='default',
  "connection-password"=''
);

----------------------------------------

DROP CATALOG kafka;

CREATE CATALOG kafka USING kafka
WITH (
  "kafka.nodes"='kafka.confluent.svc.cluster.local:9092',
  "kafka.table-names"='test.customerstreamjson',
  "kafka.hide-internal-columns"='true',
  "kafka.table-description-supplier"='file',
  "kafka.table-description-dir"='/etc/kafka'
);

-----------------------------------------

DROP CATALOG cockroack;

CREATE CATALOG cockroack USING postgresql
WITH (
  "connection-url" = 'jdbc:postgresql://cockroachdb.cockroach-operator-system.svc.cluster.local:26257/default',
  "connection-user" = 'roach',
  "connection-password" = 'roach'
);
