import gitlab
import datetime

gl = gitlab.Gitlab('https://your-gitlab-instance.com', private_token='your-private-token')

jobs = gl.jobs.list(all=True)

older_than_30_days = [j for j in jobs if j.created_at < datetime.datetime.now() - datetime.timedelta(days=30)]

for job in older_than_30_days:
    artifacts = gl.artifacts.list(job_id=job.id)
    for artifact in artifacts:
        gl.artifacts.delete(artifact.id)
