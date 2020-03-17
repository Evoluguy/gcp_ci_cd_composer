export COMPOSER_NAME=ci-cd-test
export COMPOSER_LOCATION=europe-west2
export ZONE=europe-west2-a
export ENVIRONMENT=dev

COMPOSER_GCS_BUCKET=$(gcloud composer environments describe ${COMPOSER_NAME} --location ${COMPOSER_LOCATION} | grep 'dagGcsPrefix' | grep -Eo "\S+/")

gcloud composer environments delete ${COMPOSER_NAME} \
    --location=${COMPOSER_LOCATION} \
    --zone=${ZONE} \
    --quiet

# Remove GCS bucket as it doesn't get cleaned up when the Composer instance gets deleted
gsutil -m rm -r ${COMPOSER_GCS_BUCKET}