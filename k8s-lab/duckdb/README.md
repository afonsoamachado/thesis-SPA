# Deploy

## Image

```bash
docker build -t afonsoamachadoduckdb:1.0.0 .


```

## Set up MinIO

Allow to read data from MinIO:
```bash
INSTALL httpfs;
LOAD httpfs;
```

Set MinIo Variables:
```bash
SET s3_region='us-east-1';
SET s3_url_style='path';
SET s3_endpoint='tenant-00-hl.minio.svc.cluster.local:9000';
SET use_ssl=false;
SET s3_access_key_id='minio' ;
SET s3_secret_access_key='minio123';
```