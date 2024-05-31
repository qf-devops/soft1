import requests
import datetime
import sys

# Configuration
GITLAB_URL = 'https://gitlab.example.com'  # Replace with your GitLab instance URL
PRIVATE_TOKEN = 'your_private_token'  # Replace with your GitLab personal access token
PROJECT_ID = 'your_project_id'  # Replace with your GitLab project ID
DAYS_THRESHOLD = 30  # Artifacts older than this number of days will be deleted

def delete_old_artifacts(gitlab_url, private_token, project_id, days_threshold):
    headers = {
        'PRIVATE-TOKEN': private_token
    }
    today = datetime.datetime.now()
    threshold_date = today - datetime.timedelta(days=days_threshold)

    # Get all jobs
    jobs_url = f'{gitlab_url}/api/v4/projects/{project_id}/jobs'
    response = requests.get(jobs_url, headers=headers)
    if response.status_code != 200:
        print(f'Failed to fetch jobs: {response.status_code}, {response.text}')
        sys.exit(1)

    jobs = response.json()

    # Filter jobs with artifacts older than the threshold date
    for job in jobs:
        if job['artifacts_file']:
            job_date = datetime.datetime.strptime(job['created_at'], '%Y-%m-%dT%H:%M:%S.%fZ')
            if job_date < threshold_date:
                job_id = job['id']
                delete_url = f'{gitlab_url}/api/v4/projects/{project_id}/jobs/{job_id}/artifacts'
                del_response = requests.delete(delete_url, headers=headers)
                if del_response.status_code == 204:
                    print(f'Successfully deleted artifacts for job {job_id}')
                else:
                    print(f'Failed to delete artifacts for job {job_id}: {del_response.status_code}, {del_response.text}')

if __name__ == "__main__":
    delete_old_artifacts(GITLAB_URL, PRIVATE_TOKEN, PROJECT_ID, DAYS_THRESHOLD)
