#!/bin/bash
# Outputs a list of DAGs that need to be started and stopped based on
# the current running DAGs on the Cloud Composer environment and the 
# dags_to_deploy.txt file.
ENVIRONMENT='ci-cd-test'
REGION='europe-west2'

function get-dags-status() {
    DAGNAME_REGEX=".+_dag_v[0-9]_[0-9]_[0-9]$"
   
    RUNNING_DAGS=$(gcloud -q composer environments run "$ENVIRONMENT" \
        --location "$REGION" list_dags 2>&1 | sed -e '1,/DAGS/d' | \
        tail -n +2 | sed '/^[[:space:]]*$/d'| grep -iE "$DAGNAME_REGEX" )

    DAGS_TO_RUN=$(cat ../conf/dags_to_deploy.txt | grep -iE "$DAGNAME_REGEX" )

    DAGS_TO_STOP=$(arrayDiff "${RUNNING_DAGS[@]}" "${DAGS_TO_RUN[@]}")
    DAGS_TO_START=$(arrayDiff "${DAGS_TO_RUN[@]}" "${RUNNING_DAGS[@]}")

    echo "DAGS_TO_STOP=${DAGS_TO_STOP// /,}"
    echo "DAGS_TO_START=${DAGS_TO_START// /,}"
}

# Perform a sequence of steps to delete a DAG.
# $1 dag_id (string)
function delete_dag() {
    # Pause DAG
    gcloud -q composer environments run "$ENVIRONMENT" pause \
        -- "$DAG_ID"

    # Delete DAG from GCS
    gcloud -q composer environments storage dags delete \
        --environment="$ENVIRONMENT" \
        -- "$FILENAME"

    # Delete DAG from Airflow UI
    gcloud -q composer environments run "$ENVIRONMENT" delete_dag \
        -- "$DAG_ID"
}

get-dags-status

# delete_dag