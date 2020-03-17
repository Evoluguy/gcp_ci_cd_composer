export COMPOSER_NAME=ci-cd-test
export COMPOSER_LOCATION=europe-west2
export ZONE=europe-west2-a
export ENVIRONMENT=dev

gcloud beta composer environments create ${COMPOSER_NAME} \
    --location=${COMPOSER_LOCATION} \
    --zone=${ZONE}
    --airflow-configs=core-dags_are_paused_at_creation=True \
    --image-version=composer-1.9.2-airflow-1.10.6 \
    --disk-size=20GB \
    --python-version=3 \
    --node-count=3 \
    --labels env=${ENVIRONMENT}

COMPOSER_GCS_BUCKET=$(gcloud composer environments describe ${COMPOSER_NAME} --location ${COMPOSER_LOCATION} | grep 'dagGcsPrefix' | grep -Eo "\S+/")   

gcloud beta builds triggers create github \
      --repo-owner="Evoluguy" \
      --repo-name="gcp_ci_cd_composer" --pull-request-pattern="^master$" \
      --build-config="../cloudbuild.yaml" \
      --substitutions _COMPOSER_BUCKET_URL=${COMPOSER_GCS_BUCKET}