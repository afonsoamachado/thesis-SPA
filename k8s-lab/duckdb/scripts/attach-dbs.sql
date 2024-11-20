SET memory_limit = '1GB';
SELECT * FROM duckdb_settings();

---- SingleStore

INSTALL mysql;
LOAD mysql;

CREATE OR REPLACE SECRET (
    TYPE MYSQL,
    HOST '10.0.0.10',
    PORT 31770,
    DATABASE sf1,
    USER 'superadmin',
    PASSWORD 'superadmin123'
);

ATTACH '' AS S2 (TYPE MYSQL);

USE S2;

SELECT * FROM transaction t WHERE  t.transactionDateTime>=date'2024-06-01' AND t.transactionDateTime<=date '2024-06-01' + interval '60' day

---- S3

INSTALL httpfs;
LOAD httpfs;

SET s3_region='us-east-1';
SET s3_url_style='path';
SET s3_endpoint='tenant-00-hl.minio.svc.cluster.local:9000';
SET s3_use_ssl=false;
SET s3_access_key_id='minio' ;
SET s3_secret_access_key='minio123';


CREATE SECRET minio (
    TYPE S3,
    KEY_ID 'minio',
    SECRET 'minio123',
    REGION 'us-east-1',
    ENDPOINT 'tenant-00-hl.minio.svc.cluster.local:9000',
    USE_SSL false
);

SELECT * FROM read_parquet('s3://warehouse/bcp/sf1/cust-a60a90d84264460d8182ea75aa3cf528/data/20240826_154130_06067_uc6yp-d0c326bd-cce0-48f1-b891-af730203f486.parquet');


SELECT * FROM read_parquet('s3://warehouse/bcp/sf1/cust-a60a90d84264460d8182ea75aa3cf528/data/*.parquet', hive_partitioning = true);
