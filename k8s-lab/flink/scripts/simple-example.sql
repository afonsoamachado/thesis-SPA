------ ICEBERG

SET execution.runtime-mode = streaming;

CREATE CATALOG iceberg WITH (
    'type'='iceberg',
    'catalog-type'='hive',
    'warehouse' = 's3a://warehouse',
    'hive-conf-dir' = '/opt/hive-conf'
);

create database iceberg.test;

CREATE TABLE iceberg.test.customer_simple (
  custkey INT,
  name STRING,
  internal_id BIGINT
);


------ KAFKA

--- AVRO

CREATE TABLE test_stream (
  description STRING ) WITH (
  'connector' = 'kafka',
  'topic' = 'customerstream',
  'properties.bootstrap.servers' = 'kafka.confluent.svc.cluster.local:9092',
  'properties.group.id' = 'flink-group',
  'scan.startup.mode' = 'earliest-offset',
  'value.format' = 'avro-confluent',
  'value.avro-confluent.schema-registry.url' = 'http://schemaregistry.confluent.svc.cluster.local:8081',
  'value.fields-include' = 'EXCEPT_KEY'
);

--- JSON
CREATE TABLE customer_simple_stream (
  custkey INT,
  name STRING,
  internal_id BIGINT) WITH (
  'connector' = 'kafka',
  'topic' = 'test.customerstreamjson',
  'properties.bootstrap.servers' = 'kafka.confluent.svc.cluster.local:9092',
  'properties.group.id' = 'flink-group',
  'scan.startup.mode' = 'earliest-offset',
  'value.format' = 'json',
  'value.fields-include' = 'EXCEPT_KEY'
);

INSERT INTO customer_simple_stream (custkey,name) VALUES (3,'customer#003');


INSERT INTO iceberg.test.customer_simple SELECT * FROM customer_simple_stream;

------- CLICKHOUSE
CREATE TABLE clickhouse_cust (
    customerId INT NOT NULL,
    name STRING NOT NULL,
    addressDate TIMESTAMP(3) NOT NULL,
    addressId INT,
    address STRING,
    birthday TIMESTAMP(3),
    customerStatus STRING,
    customerType STRING,
    gender STRING,
    nationality STRING,
    nif STRING,
    openDate TIMESTAMP(3),
    createdAt TIMESTAMP(3) NOT NULL
) WITH (
  'connector' = 'jdbc',
  'url' = 'jdbc:clickhouse:session-cluster-1.flink.svc.cluster.local:8123/sf1',
  'username' = 'default',
  'password' = '',
  'table-name' = 'customer'
);