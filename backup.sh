#!/bin/sh

function announce() {
  echo "$*"
  if [ $SLACK_WEBHOOK_URL != "" ];
  then
    ANNOUNCETEXT='{"text": "'$*'", "link_names": 1}'
    curl -X POST -d ''"${ANNOUNCETEXT}"'' $SLACK_WEBHOOK_URL
  fi
}

OUTPUT_FOLDER="/tmp"
FORMATTED_FILENAME=`date $DATE_FORMAT`.sql
OUTPUT_FILE=$OUTPUT_FOLDER/$FORMATTED_FILENAME
OUTPUT_FILE_GZ=$OUTPUT_FILE.gz

if [ $ENGINE_FAMILY == 'postgres' ]; then
  BACKUP_COMMAND="pg_dump postgresql://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME"
fi
if [ $ENGINE_FAMILY == 'mysql' ]; then
  BACKUP_COMMAND="mysqldump -h $DB_HOST -P $DB_PORT -u $DB_USERNAME $DB_NAME --password=$DB_PASSWORD"
fi

echo "Starting docker..."
docker run --rm ${ENGINE_FAMILY}:${ENGINE_VERSION} $BACKUP_COMMAND > $OUTPUT_FILE
echo "GZipping output..."
gzip $OUTPUT_FILE
echo "Transfer output to S3"
aws s3 cp $OUTPUT_FILE_GZ $S3_PREFIX$FORMATTED_FILENAME.gz
announce "$DB_NAME backup written to $S3_PREFIX$FORMATTED_FILENAME.gz"
rm -f $OUTPUT_FILE_GZ
