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

echo "Output filename will be $OUTPUT_FILE"

if [ $ENGINE_FAMILY == 'postgres' ]; then
  echo "Using postgres dump command"
  BACKUP_COMMAND="pg_dump postgresql://$DB_USERNAME:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME"
fi
if [ $ENGINE_FAMILY == 'mysql' ]; then
  echo "Using mysql dump command"
  BACKUP_COMMAND="mysqldump -h $DB_HOST -P $DB_PORT -u $DB_USERNAME $DB_NAME --password=$DB_PASSWORD"
fi

echo "Starting docker..."
docker run --rm ${ENGINE_FAMILY}:${ENGINE_VERSION} $BACKUP_COMMAND > $OUTPUT_FILE

if [ ! -e $OUTPUT_FILE ];
then
  announce "$DB_NAME backup: Output file is missing!"
  exit
fi

if [ -s $OUTPUT_FILE ];
then
  announce "$DB_NAME backup: Output file was zero length!"
  exit
fi

echo "GZipping output..."
gzip $OUTPUT_FILE
echo "Transfer output to S3"
aws s3 cp $OUTPUT_FILE_GZ $S3_PREFIX$FORMATTED_FILENAME.gz
announce "$DB_NAME backup: Written to $S3_PREFIX$FORMATTED_FILENAME.gz"
echo "Removing temporary file"
rm -f $OUTPUT_FILE_GZ
echo "Done"
