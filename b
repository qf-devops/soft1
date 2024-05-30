#!/bin/bash

# Set your GitLab API endpoint and credentials
API_ENDPOINT="https://your-gitlab-instance.com/api/v4"
PRIVATE_TOKEN="your-private-token"

# Set the project ID
PROJECT_ID=12345

# Set the age threshold (30 days)
AGE_THRESHOLD=30

# Set the page size
PAGE_SIZE=100

# Initialize the page number
PAGE_NUMBER=1

# Loop until there are no more pages
while true; do
  # Get the list of jobs
  RESPONSE=$(curl -s -X GET \
    $API_ENDPOINT/projects/$PROJECT_ID/jobs?page=$PAGE_NUMBER&per_page=$PAGE_SIZE \
    -H 'Authorization: Bearer '$PRIVATE_TOKEN \
    -H 'Content-Type: application/json')

  # Extract the job IDs and timestamps
  JOBS=($(jq -r '.[] |{id:.id, timestamp:.created_at}' <<< "$RESPONSE"))

  # Loop through the jobs and check if they're older than the threshold
  for JOB in "${JOBS[@]}"; do
    TIMESTAMP=$(date -d @${JOB['timestamp']} +%s)
    CURRENT_TIMESTAMP=$(date +%s)
    AGE=$((CURRENT_TIMESTAMP - TIMESTAMP))

    if [ $AGE -gt $AGE_THRESHOLD*86400 ]; then
      # Get the job artifacts
      RESPONSE=$(curl -s -X GET \
        $API_ENDPOINT/projects/$PROJECT_ID/jobs/${JOB['id']}/artifacts?per_page=100 \
        -H 'Authorization: Bearer '$PRIVATE_TOKEN \
        -H 'Content-Type: application/json')

      # Extract the artifact IDs
      ARTIFACT_IDS=($(jq -r '.[] |.id' <<< "$RESPONSE"))

      # Loop through the artifact IDs and delete the ones
      for ARTIFACT_ID in "${ARTIFACT_IDS[@]}"; do
        curl -s -X DELETE \
          $API_ENDPOINT/projects/$PROJECT_ID/jobs/${JOB['id']}/artifacts/$ARTIFACT_ID \
          -H 'Authorization: Bearer '$PRIVATE_TOKEN \
          -H 'Content-Type: application/json'

        echo "Deleted artifact ${ARTIFACT_ID} for job ${JOB['id']}"
      done
    fi
  done

  # Check if there are more pages
  if [ $(jq -r '.total_pages' <<< "$RESPONSE") -gt $PAGE_NUMBER ]; then
    # Increment the page number
    ((PAGE_NUMBER++))
  else
    # Exit the loop
    break
  fi
done
