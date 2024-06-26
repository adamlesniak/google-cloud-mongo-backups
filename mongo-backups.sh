#!/bin/sh

DATE=`date +%F`
GCLOUD_CONFIG_FILE_PATH="/root/.config/gcloud/configurations/config_default"
GCLOUD_KEY_FILE_PATH="key_file.json"

if ! `grep -Fxq project $GCLOUD_CONFIG_FILE_PATH`;then
  echo "Configuring Google Cloud SDK"
  echo -n $GCLOUD_KEY_FILE | base64 -d > $GCLOUD_KEY_FILE_PATH
  gcloud auth activate-service-account --key-file=$GCLOUD_KEY_FILE_PATH
  gcloud config set project $GCLOUD_PROJECT_ID
#  rm $GCLOUD_KEY_FILE_PATH
fi

for MONGO_URI in $(echo $MONGO_URIS | tr ";" "\n")
do
  MONGO_DB_NAME=$(echo $MONGO_URI | tr "@" "\n" | tail -1)
  BACKUP=$(echo $MONGO_DB_NAME | tr "/" "\n" | head -n 1)

  echo "Performing backup of $MONGO_DB_NAME"

  # Backup variables
  BACKUP_NAME="$BACKUP-$DATE"
  BACKUP_ARCHIVE_NAME=$BACKUP_NAME.tar.gz

  # Create dump
  mongodump --uri="${MONGO_URI}"

  # Rename dump
  mv dump $BACKUP_NAME

  # Compress backup
  tar -czvf $BACKUP_ARCHIVE_NAME $BACKUP_NAME

  # Upload archive to Google Cloud
  echo "Uploading gs://$GCLOUD_BUCKET_NAME/$BACKUP_ARCHIVE_NAME"
  gsutil cp $BACKUP_ARCHIVE_NAME gs://$GCLOUD_BUCKET_NAME

  echo "Database backup of $MONGO_DB_NAME complete!"
done
