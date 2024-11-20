FROM flink:1.17.2

## Flink - Plugins
RUN curl -L https://repo1.maven.org/maven2/org/apache/flink/flink-s3-fs-hadoop/1.17.2/flink-s3-fs-hadoop-1.17.2.jar -o /opt/flink/plugins/flink-s3-fs-hadoop-1.17.2.jar

## Flink Core
RUN curl -L  https://repo1.maven.org/maven2/org/apache/flink/flink-core/1.17.2/flink-core-1.17.2.jar -o /opt/flink/lib/flink-core-1.17.2.jar
RUN curl -L https://repo1.maven.org/maven2/org/apache/flink/flink-connector-base/1.17.2/flink-connector-base-1.17.2.jar -o /opt/flink/plugins/flink-connector-base-1.17.2.jar

## Kafka Flink Library
RUN curl -L  https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kafka/1.17.2/flink-connector-kafka-1.17.2.jar -o /opt/flink/lib/flink-connector-kafka-1.17.2.jar
RUN curl -L  https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka/1.17.2/flink-sql-connector-kafka-1.17.2.jar -o /opt/flink/lib/flink-sql-connector-kafka-1.17.2.jar
RUN curl -L  https://repo1.maven.org/maven2/org/apache/flink/flink-shaded-force-shading/15.0/flink-shaded-force-shading-15.0.jar -o /opt/flink/lib/flink-shaded-force-shading-15.0.jar

## Kafka & Avro
RUN curl -L  https://packages.confluent.io/maven/io/confluent/kafka-schema-registry-client/6.2.2/kafka-schema-registry-client-6.2.2.jar -o /opt/flink/lib/kafka-schema-registry-client-6.2.2.jar
RUN curl -L  https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.2.3/kafka-clients-3.2.3.jar -o /opt/flink/lib/kafka-clients-3.2.3.jar
RUN curl -L https://repo1.maven.org/maven2/org/apache/avro/avro/1.11.1/avro-1.11.1.jar -o /opt/flink/lib/avro-1.11.1.jar 
RUN curl -L  https://repo1.maven.org/maven2/org/apache/flink/flink-avro/1.17.2/flink-avro-1.17.2.jar -o /opt/flink/lib/flink-avro-1.17.2.jar
RUN curl -L  https://repo1.maven.org/maven2/org/apache/flink/flink-avro-confluent-registry/1.17.2/flink-avro-confluent-registry-1.17.2.jar -o /opt/flink/lib/flink-avro-confluent-registry-1.17.2.jar

## Iceberg Flink Library
RUN curl -L  https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-flink-runtime-1.17/1.4.3/iceberg-flink-runtime-1.17-1.4.3.jar -o /opt/flink/lib/iceberg-flink-runtime-1.17-1.4.3.jar

## Hive Flink Library
RUN curl https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-hive-3.1.3_2.12/1.17.2/flink-sql-connector-hive-3.1.3_2.12-1.17.2.jar -o /opt/flink/lib/flink-sql-connector-hive-3.1.3_2.12-1.17.2.jar


##  AWS / Hadoop S3
RUN curl -L https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-common/3.3.1/hadoop-common-3.3.1.jar -o /opt/flink/lib/hadoop-common-3.3.1.jar
RUN curl -L https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-hdfs/3.3.1/hadoop-hdfs-3.3.1.jar -o /opt/flink/lib/hadoop-hdfs-3.3.1.jar

RUN mkdir -p /opt/flink/lib/aws && \
    curl https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.1/hadoop-aws-3.3.1.jar -o /opt/flink/lib/aws/hadoop-aws-3.3.1.jar && \
    curl https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.648/aws-java-sdk-bundle-1.12.648.jar -o /opt/flink/lib/aws/aws-java-sdk-bundle-1.12.648.jar
 
RUN mkdir -p /opt/flink/lib/hadoop && \
    curl https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-auth/3.3.1/hadoop-auth-3.3.1.jar -o /opt/flink/lib/hadoop/hadoop-auth-3.3.1.jar && \
    curl https://repo1.maven.org/maven2/org/apache/hadoop/thirdparty/hadoop-shaded-guava/1.1.1/hadoop-shaded-guava-1.1.1.jar -o /opt/flink/lib/hadoop/hadoop-shaded-guava-1.1.1.jar && \
    curl https://repo1.maven.org/maven2/org/codehaus/woodstox/stax2-api/4.2.1/stax2-api-4.2.1.jar -o /opt/flink/lib/hadoop/stax2-api-4.2.1.jar && \
    curl https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-hdfs-client/3.3.1/hadoop-hdfs-client-3.3.1.jar -o /opt/flink/lib/hadoop/hadoop-hdfs-client-3.3.1.jar && \
    curl https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-mapreduce-client-core/3.3.1/hadoop-mapreduce-client-core-3.3.1.jar -o /opt/flink/lib/hadoop/hadoop-mapreduce-client-core-3.3.1.jar

## Others
RUN curl https://repo1.maven.org/maven2/commons-logging/commons-logging/1.1.3/commons-logging-1.1.3.jar -o /opt/flink/lib/commons-logging-1.1.3.jar
RUN curl https://repo1.maven.org/maven2/com/fasterxml/woodstox/woodstox-core/5.3.0/woodstox-core-5.3.0.jar -o /opt/flink/lib/hadoop/woodstox-core-5.3.0.jar
RUN curl https://repo1.maven.org/maven2/org/apache/commons/commons-configuration2/2.1.1/commons-configuration2-2.1.1.jar -o /opt/flink/lib/commons-configuration2-2.1.1.jar
RUN curl -L https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/2.13.3/jackson-databind-2.13.3.jar -o /opt/flink/lib/jackson-databind-2.13.3.jar
RUN curl -L https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-core/2.13.3/jackson-core-2.13.3.jar -o /opt/flink/lib/jackson-core-2.13.3.jar
RUN curl -L https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-annotations/2.13.3/jackson-annotations-2.13.3.jar -o /opt/flink/lib/jackson-annotations-2.13.3.jar
RUN curl -L https://repo1.maven.org/maven2/org/apache/htrace/htrace-core4/4.2.0-incubating/htrace-core4-4.2.0-incubating.jar -o /opt/flink/lib/htrace-core4-4.2.0-incubating.jar

## Flink JDBC
RUN curl https://repo1.maven.org/maven2/org/apache/flink/flink-connector-jdbc/3.1.2-1.17/flink-connector-jdbc-3.1.2-1.17.jar -o /opt/flink/lib/flink-connector-jdbc-3.1.2-1.17.jar

## Clickhouse
RUN curl https://repo1.maven.org/maven2/com/alibaba/ververica/ververica-connector-clickhouse/1.15-vvr-6.0.2-3/ververica-connector-clickhouse-1.15-vvr-6.0.2-3.jar -o /opt/flink/lib/ververica-connector-clickhouse-1.15-vvr-6.0.2-3.jar
RUN curl https://repo1.maven.org/maven2/com/clickhouse/clickhouse-jdbc/0.6.3/clickhouse-jdbc-0.6.3.jar -o /opt/flink/lib/clickhouse-jdbc-0.6.3.jar

## Singlestore
RUN curl https://repo1.maven.org/maven2/com/singlestore/singlestore-jdbc-client/1.2.3/singlestore-jdbc-client-1.2.3.jar -o /opt/flink/lib/singlestore-jdbc-client-1.2.3.jar

## Set CLASSPATH
ENV CLASSPATH="/opt/flink/lib/*"

CMD ["./bin/start-cluster.sh"]