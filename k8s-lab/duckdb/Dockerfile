FROM ubuntu:24.10 AS base
ARG DUCKDB_VERSION=v1.0.0

RUN apt-get update  \
    && apt-get install -y curl unzip \
    && curl -L -o duckdb_cli.zip "https://github.com/duckdb/duckdb/releases/download/${DUCKDB_VERSION}/duckdb_cli-linux-amd64.zip" \
    && unzip duckdb_cli.zip

ENTRYPOINT [ "./duckdb" ]