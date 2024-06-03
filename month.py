import requests
import datetime

# Set your GitLab API token and the name of your GitLab instance
api_token = 'your_api_token'
gitlab_instance = 'https://your-gitlab-instance.com'

# Set the start and end dates for the month
start_date = datetime.date.today().replace(day=1)
end_date = start_date.replace(day=28) + datetime.timedelta(days=4)

# Get the list of artifacts for the month
url = f'{gitlab_instance}/api/v4/projects/{project_id}/jobs/artifacts'
params = {'per_page': 100, 'page': 1, 'ort': 'created_at'}
response = requests.get(url, headers={'Private-Token': api_token}, params=params)

artifacts = []
while response.json():
    for artifact in response.json():
        if artifact['created_at'] >= start_date and artifact['created_at'] <= end_date:
            artifacts.append(artifact)
    params['page'] += 1
    response = requests.get(url, headers={'Private-Token': api_token}, params=params)

# Delete the artifacts
for artifact in artifacts:
    url = f'{gitlab_instance}/api/v4/projects/{project_id}/jobs/artifacts/{artifact["id"]}'
    response = requests.delete(url, headers={'Private-Token': api_token})
    print(f'Deleted artifact {artifact["name"]}')
