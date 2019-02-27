# backup-database-s3

This container is intended to be run as a scheduled job to perform an automated backup of a particular  database and place the resulting .sql.gz file in an S3 bucket.

# Environment variables

| Name              | Description                                         | Default     |
|-------------------|-----------------------------------------------------|-------------|
| ENGINE_VERSION    | Database numeric version (e.g. 9.6)                 |             |
| ENGINE_FAMILY     | Database family (e.g. 'postgres', 'mysql')          |             |
| S3_PREFIX         | S3 URL prefix in format s3://bucket/key/prefix      |             |
| DB_HOST           | Database host                                       |             |
| DB_PORT           | Database port                                       |             |
| DB_NAME           | Database name                                       |             |
| DB_USERNAME       | Database username                                   |             |
| DB_PASSWORD       | Database password                                   |             |
| DATE_FORMAT       | `date` format for backup files                      | +%Y%m%d%H%M |
| SLACK_WEBHOOK_URL | Slack webhook URL that backups will be announced to |             |

# Requirements and permission

The task will need `s3:PutObject` permission on the target S3 bucket and key prefix.

The host that the task is running on needs to be able to access the database host on the specified port.

Also needs access to local Docker socket, so launch with `/var/run/docker.sock` mapped into the container.

# Usage

```
docker run --rm --name backup-database-s3 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --env ENGINE_FAMILY='postgres' \
  --env ENGINE_VERSION='9.6' \
  --env S3_PREFIX='s3://my-backup-bucket/databases/this-database/' \
  --env DB_HOST='<database address>' \
  --env DB_PORT='<database port>' \
  --env DB_NAME='<database name>' \
  --env DB_USERNAME='<database username>' \
  --env DB_PASSWORD='<database password>' \
  --env DATE_FORMAT='+%Y%m%d%H%M' \
  --env SLACK_WEBHOOK_URL='https://slack.com/webhooks/id/token' \
  digirati/backup-database-s3
```

## S3_PREFIX

Backup names will be directly appended to this, for example:

| Prefix value                  | Example S3 key                                   |
|-------------------------------|--------------------------------------------------|
| s3://bucket/db/               | s3://bucket/db/201902271206.sql.gz               |
| s3://bucket/db/this_database- | s3://bucket/db/this_database-201902271206.sql.gz |

## SLACK_WEBHOOK_URL

Leave empty to skip Slack announcements.
