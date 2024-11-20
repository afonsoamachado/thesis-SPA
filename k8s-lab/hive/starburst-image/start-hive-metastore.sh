#!/usr/bin/env bash

################################################################################
# Copyright (c) 2020 Starburst Data, Inc. All rights reserved.
#
# All information herein is owned by Starburst Data Inc. and its licensors
# ("Starburst"), if any.  This software and the concepts it embodies are
# proprietary to Starburst, are protected by trade secret and copyright law,
# and may be covered by patents in the U.S. and abroad.  Distribution,
# reproduction, and relicensing are strictly forbidden without Starburst's prior
# written permission.
#
# THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED.  THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
# AND NONINFRINGEMENT ARE EXPRESSLY DISCLAIMED. IN NO EVENT SHALL STARBURST BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR ITS USE
# EVEN IF STARBURST HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Please refer to your agreement(s) with Starburst for further information.
################################################################################

set -xeuo pipefail

cd "$(dirname "$0")"

SERVICE=metastore
while getopts ":hs:" opt; do
    case $opt in
        s)
            SERVICE="${OPTARG}"
            ;;
        h | *)
            echo "Start hive service."
            echo "Usage: $(basename $0) [-s metastore | hiveserver2 ]"
            exit 1
            ;;
    esac
done

test -v HIVE_METASTORE_JDBC_URL
test -v HIVE_METASTORE_DRIVER
test -v HIVE_METASTORE_USER
test -v HIVE_METASTORE_PASSWORD
test -v S3_ENDPOINT
test -v S3_ACCESS_KEY
test -v S3_SECRET_KEY
test -v S3_PATH_STYLE_ACCESS
test -v REGION
test -v GOOGLE_CLOUD_KEY_FILE_PATH
test -v AZURE_ADL_CLIENT_ID
test -v AZURE_ADL_CREDENTIAL
test -v AZURE_ADL_REFRESH_URL
test -v AZURE_ABFS_STORAGE_ACCOUNT
test -v AZURE_ABFS_ACCESS_KEY
test -v AZURE_WASB_STORAGE_ACCOUNT
test -v AZURE_ABFS_OAUTH
test -v AZURE_ABFS_OAUTH_TOKEN_PROVIDER
test -v AZURE_ABFS_OAUTH_CLIENT_ID
test -v AZURE_ABFS_OAUTH_SECRET
test -v AZURE_ABFS_OAUTH_ENDPOINT
test -v AZURE_WASB_ACCESS_KEY
test -v HIVE_HOME

TMP_DIR="/tmp"
JDBC_DRIVERS_DIR="${HIVE_HOME}/lib/"

MYSQL_DRIVER_DOWNLOAD_URL=${MYSQL_DRIVER_DOWNLOAD_URL:-"https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.20.tar.gz"}

set +x
S3_ACCESS_KEY=$(echo ${S3_ACCESS_KEY} | tr -d '\n ')
S3_SECRET_KEY=$(echo ${S3_SECRET_KEY} | tr -d '\n ')
S3_PATH_STYLE_ACCESS=$(echo ${S3_PATH_STYLE_ACCESS} | tr -d '\n ')

AZURE_ADL_CLIENT_ID=$(echo ${AZURE_ADL_CLIENT_ID} | tr -d '\n ')
AZURE_ADL_CREDENTIAL=$(echo ${AZURE_ADL_CREDENTIAL} | tr -d '\n ')
AZURE_ADL_REFRESH_URL=$(echo ${AZURE_ADL_REFRESH_URL} | tr -d '\n ')

AZURE_ABFS_STORAGE_ACCOUNT=$(echo ${AZURE_ABFS_STORAGE_ACCOUNT} | tr -d '\n ')
AZURE_ABFS_ACCESS_KEY=$(echo ${AZURE_ABFS_ACCESS_KEY} | tr -d '\n ')

AZURE_ABFS_OAUTH=$(echo ${AZURE_ABFS_OAUTH} | tr -d '\n ')
AZURE_ABFS_OAUTH_TOKEN_PROVIDER=$(echo ${AZURE_ABFS_OAUTH_TOKEN_PROVIDER} | tr -d '\n ')
AZURE_ABFS_OAUTH_CLIENT_ID=$(echo ${AZURE_ABFS_OAUTH_CLIENT_ID} | tr -d '\n ')
AZURE_ABFS_OAUTH_SECRET=$(echo ${AZURE_ABFS_OAUTH_SECRET} | tr -d '\n ')
AZURE_ABFS_OAUTH_ENDPOINT=$(echo ${AZURE_ABFS_OAUTH_ENDPOINT} | tr -d '\n ')

AZURE_WASB_STORAGE_ACCOUNT=$(echo ${AZURE_WASB_STORAGE_ACCOUNT} | tr -d '\n ')
AZURE_WASB_ACCESS_KEY=$(echo ${AZURE_WASB_ACCESS_KEY} | tr -d '\n ')

# S3_AWS_CREDENTIALS_PROVIDER may be not set, we expect hive to use default settings then
S3_AWS_CREDENTIALS_PROVIDER=$(echo ${S3_AWS_CREDENTIALS_PROVIDER:="default"} | tr -d '\n ')
set -x

# If MariaDB driver used
if [[ "${HIVE_METASTORE_DRIVER}" == "org.mariadb.jdbc.Driver" ]]; then
    # If JDBC connection string parameter section does not exits add it.
    if [[ "${HIVE_METASTORE_JDBC_URL}" != *"?"* ]]; then
        export HIVE_METASTORE_JDBC_URL="${HIVE_METASTORE_JDBC_URL}?"
    fi
    # If sessionVariable JDBC parameter not defined.
    # Add sql_mode session variable to handle '"' properly.
    # Hive uses direct SQL and '"' for schema elements names.
    if [[ "${HIVE_METASTORE_JDBC_URL}" != *"sessionVariables="* ]]; then
        export HIVE_METASTORE_JDBC_URL="${HIVE_METASTORE_JDBC_URL}&sessionVariables=sql_mode=ANSI_QUOTES"
    fi
fi

# Change ampersand '&' to XML representation to not corrupt Hive XML configuration.
# Also escape it as '&' is SED special character.
export HIVE_METASTORE_JDBC_URL=$(echo "${HIVE_METASTORE_JDBC_URL}" | sed -e "s|&|\\\&amp;|g")

export HIVE_METASTORE_WAREHOUSE_DIR=${HIVE_METASTORE_WAREHOUSE_DIR:-"file:///no/default/location/defined/please/create/new/schema/with/location/explicitly/set/"}
export HIVE_METASTORE_STORAGE_AUTHORIZATION=${HIVE_METASTORE_STORAGE_AUTHORIZATION:-"true"}
export HIVE_METASTORE_USERS_IN_ADMIN_ROLE=${HIVE_METASTORE_USERS_IN_ADMIN_ROLE:-""}

### Replace predefined placeholders
set +x
sed -i \
    -e "s|%HIVE_METASTORE_JDBC_URL%|${HIVE_METASTORE_JDBC_URL}|g" \
    -e "s|%HIVE_METASTORE_DRIVER%|${HIVE_METASTORE_DRIVER}|g" \
    -e "s|%HIVE_METASTORE_USER%|${HIVE_METASTORE_USER}|g" \
    -e "s|%HIVE_METASTORE_PASSWORD%|${HIVE_METASTORE_PASSWORD}|g" \
    -e "s|%HIVE_METASTORE_WAREHOUSE_DIR%|${HIVE_METASTORE_WAREHOUSE_DIR}|g" \
    -e "s|%S3_ENDPOINT%|${S3_ENDPOINT}|g" \
    -e "s|%S3_ACCESS_KEY%|${S3_ACCESS_KEY}|g" \
    -e "s|%S3_SECRET_KEY%|${S3_SECRET_KEY}|g" \
    -e "s|%S3_PATH_STYLE_ACCESS%|${S3_PATH_STYLE_ACCESS}|g" \
    -e "s|%REGION%|${REGION}|g" \
    -e "s|%GOOGLE_CLOUD_KEY_FILE_PATH%|${GOOGLE_CLOUD_KEY_FILE_PATH}|g" \
    -e "s|%AZURE_ADL_CLIENT_ID%|${AZURE_ADL_CLIENT_ID}|g" \
    -e "s|%AZURE_ADL_CREDENTIAL%|${AZURE_ADL_CREDENTIAL}|g" \
    -e "s|%AZURE_ADL_REFRESH_URL%|${AZURE_ADL_REFRESH_URL}|g" \
    -e "s|%AZURE_ABFS_STORAGE_ACCOUNT%|${AZURE_ABFS_STORAGE_ACCOUNT}|g" \
    -e "s|%AZURE_ABFS_ACCESS_KEY%|${AZURE_ABFS_ACCESS_KEY}|g" \
    -e "s|%AZURE_ABFS_OAUTH%|${AZURE_ABFS_OAUTH}|g" \
    -e "s|%AZURE_ABFS_OAUTH_TOKEN_PROVIDER%|${AZURE_ABFS_OAUTH_TOKEN_PROVIDER}|g" \
    -e "s|%AZURE_ABFS_OAUTH_CLIENT_ID%|${AZURE_ABFS_OAUTH_CLIENT_ID}|g" \
    -e "s|%AZURE_ABFS_OAUTH_SECRET%|${AZURE_ABFS_OAUTH_SECRET}|g" \
    -e "s|%AZURE_ABFS_OAUTH_ENDPOINT%|${AZURE_ABFS_OAUTH_ENDPOINT}|g" \
    -e "s|%AZURE_WASB_STORAGE_ACCOUNT%|${AZURE_WASB_STORAGE_ACCOUNT}|g" \
    -e "s|%AZURE_WASB_ACCESS_KEY%|${AZURE_WASB_ACCESS_KEY}|g" \
    -e "s|%HIVE_METASTORE_STORAGE_AUTHORIZATION%|${HIVE_METASTORE_STORAGE_AUTHORIZATION}|g" \
    -e "s|%HIVE_METASTORE_USERS_IN_ADMIN_ROLE%|${HIVE_METASTORE_USERS_IN_ADMIN_ROLE}|g" \
    ../apache-hive-3.1.3-bin/conf/hive-site.xml
set -x

### Add conditionally needed properties
if [[ "${S3_AWS_CREDENTIALS_PROVIDER}" != "default" ]]; then
    CONTENT="<property>\n<name>fs.s3a.aws.credentials.provider</name>\n<value>${S3_AWS_CREDENTIALS_PROVIDER}</value>\n</property>"
    C=$(echo $CONTENT | sed 's/\//\\\//g')
    sed -i "/<\/configuration>/ s/.*/${C}\n&/" ../apache-hive-3.1.3-bin/conf/hive-site.xml
fi

### Format xmlfile with Ubi builtin tool
xmllint --format ../apache-hive-3.1.3-bin/conf/hive-site.xml -o ../apache-hive-3.1.3-bin/conf/hive-site.xml

retry() {
    wait_timeout="$1"
    retry_delay="$2"
    shift 2

    END=$(($(date +%s) + ${wait_timeout}))

    while (($(date +%s) < $END)); do
        "$@" && return
        sleep "${retry_delay}"
    done

    echo "$0: retrying [$*] timed out" >&2
}

function downloadMysqlDriver() {
    local driverFileName=$(echo ${MYSQL_DRIVER_DOWNLOAD_URL} | rev | cut -d "/" -f 1 | rev)
    local downloadLocation="${TMP_DIR}/${driverFileName}"
    local unpackDirectory="${TMP_DIR}/mysql-driver"
    mkdir -p "${unpackDirectory}"

    echo "Downloading MySql driver from: ${MYSQL_DRIVER_DOWNLOAD_URL}"
    curl -SsL "${MYSQL_DRIVER_DOWNLOAD_URL}" -o "${downloadLocation}"

    if [[ "${driverFileName}" == *".tar"* ]]; then
        echo "Unpack MySql driver TAR archive: ${downloadLocation}"
        tar -xf "${downloadLocation}" -C ${unpackDirectory}
        mv "${unpackDirectory}"/**/mysql-*.jar "${JDBC_DRIVERS_DIR}"
    elif [[ "${driverFileName}" == *".zip" ]]; then
        echo "Unpack MySql driver ZIP archive: ${downloadLocation}"
        unzip -q -o "${downloadLocation}" -d "${unpackDirectory}"
        mv "${unpackDirectory}"/**/mysql-*.jar "${JDBC_DRIVERS_DIR}"
    elif [[ "${driverFileName}" == *".jar" ]]; then
        mv "${downloadLocation}" "${JDBC_DRIVERS_DIR}"
    else
        echo "Unsupported MySql driver download file format. Only various tar packages or directly jar is supported."
    fi

    echo -e "Installed MySql driver files:\n$(ls "${JDBC_DRIVERS_DIR}"/mysql-*.jar)"
    rm -rf "${downloadLocation}" "${unpackDirectory}"
}

export HIVE_METASTORE_DB_HOST="$(echo "$HIVE_METASTORE_JDBC_URL" | cut -d / -f 3 | cut -d : -f 1)"
export HIVE_METASTORE_DB_PORT="$(echo "$HIVE_METASTORE_JDBC_URL" | cut -d / -f 3 | cut -d : -f 2)"
export HIVE_METASTORE_DB_NAME="$(echo "$HIVE_METASTORE_JDBC_URL" | cut -d / -f 4 | cut -d '?' -f 1)"
if [[ "$HIVE_METASTORE_DRIVER" == "org.mariadb.jdbc.Driver" || "$HIVE_METASTORE_DRIVER" == "com.mysql.jdbc.Driver" ]]; then
    function sql() {
        mysql --host="$HIVE_METASTORE_DB_HOST" --port="$HIVE_METASTORE_DB_PORT" --user="$HIVE_METASTORE_USER" --password="$HIVE_METASTORE_PASSWORD" "$HIVE_METASTORE_DB_NAME" "$@"
    }
    declare -fxr sql

    # Download MYSQL Driver
    downloadMysqlDriver

    # Make sure that mysql is accessible
    set +x
    echo "Making sure that MySQL is accessible..."
    retry 300 1 timeout 5 bash -ce "sql -e 'SELECT 1'"
    if ! sql -e 'SELECT 1 FROM DBS LIMIT 1'; then
        schematool -dbType mysql -initSchema
    fi
    set -x
elif [[ "$HIVE_METASTORE_DRIVER" == org.postgresql.Driver ]]; then
    function sql() {
        export PGPASSWORD="$HIVE_METASTORE_PASSWORD"
        psql --host="$HIVE_METASTORE_DB_HOST" --port="$HIVE_METASTORE_DB_PORT" --username="$HIVE_METASTORE_USER" "$HIVE_METASTORE_DB_NAME" "$@"
    }
    declare -fxr sql

    # Make sure that postgres is accessible
    set +x
    echo "Making sure that Postgres is accessible..."
    retry 300 1 timeout 5 bash -ce "sql -c 'SELECT 1'"
    if ! sql -c 'SELECT 1 FROM "DBS" LIMIT 1'; then
        schematool -dbType postgres -initSchema
    fi
    set -x
elif [[ "$HIVE_METASTORE_DRIVER" == com.microsoft.sqlserver.jdbc.SQLServerDriver ]]; then
    # extract hostname, port and DB name specifically for MS SQL Server
    export HIVE_METASTORE_DB_HOST="$(echo "$HIVE_METASTORE_JDBC_URL" | cut -d / -f 3 | cut -d : -f 1)"
    export HIVE_METASTORE_DB_PORT="$(echo "$HIVE_METASTORE_JDBC_URL" | cut -d / -f 3 | cut -d : -f 2 | cut -d ";" -f 1)"
    export HIVE_METASTORE_DB_NAME="$(echo ${HIVE_METASTORE_JDBC_URL##*DatabaseName=} | cut -d ";" -f 1)"
    function sql() {
        export SQLCMDPASSWORD="$HIVE_METASTORE_PASSWORD"
        sqlcmd -b -C -S "$HIVE_METASTORE_DB_HOST,$HIVE_METASTORE_DB_PORT" -U "$HIVE_METASTORE_USER" -d "$HIVE_METASTORE_DB_NAME" "$@"
    }
    declare -fxr sql

    # Make sure that MS SQL Server is accessible
    set +x
    echo "Making sure that MS SQL Server is accessible..."
    retry 300 1 timeout 5 bash -ce "sql -Q 'SELECT 1'"
    if ! sql -Q 'SELECT TOP 1 * FROM DBS'; then
        schematool -dbType mssql -initSchema
    fi
    set -x
elif [[ "$HIVE_METASTORE_DRIVER" == oracle.jdbc.OracleDriver ]]; then
    function sql() {
        sqlplus -s "$HIVE_METASTORE_USER/$HIVE_METASTORE_PASSWORD@$HIVE_METASTORE_DB_HOST:$HIVE_METASTORE_DB_PORT/$HIVE_METASTORE_DB_NAME" <<EOF
        whenever sqlerror exit sql.sqlcode;
        $@;
EOF
    }
    declare -fxr sql

    # Make sure that Oracle is accessible
    set +x
    echo "Making sure that Oracle is accessible..."
    retry 300 1 timeout 5 bash -ce "sql 'SELECT 1 FROM dual'"
    if ! sql 'SELECT 1 FROM DBS'; then
        schematool -dbType oracle -initSchema
    fi
    set -x
else
    echo "Unsupported driver: ${HIVE_METASTORE_DRIVER}" >&2
    exit 1
fi

if [[ -n ${USE_OPENJSSE+x} ]]; then
  echo "Adding an OpenJSSE provider to java.security file..."
  cp /opt/java/openjdk/lib/security/java.security /tmp/java.security
  sed -i "s/security.provider.4=com.sun.net.ssl.internal.ssl.Provider/security.provider.10=com.sun.net.ssl.internal.ssl.Provider/g" /tmp/java.security
  sed -i "/security.provider.3=/asecurity.provider.4=org.openjsse.net.ssl.OpenJSSE" /tmp/java.security
  cat /tmp/java.security > /opt/java/openjdk/lib/security/java.security
fi

# log threshold is set to INFO to avoid log pollution from Datanucleus
exec hive --service "$SERVICE" --hiveconf hive.root.logger=INFO,console --hiveconf hive.log.threshold=INFO
