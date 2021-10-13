## Logging into the Container Registry
The Elastic Container registry requires authentication in order to use it. Logging in can be done by retrieving the `Access Keys` from the resource, assuming the dev has permissions to read it, otherwise see your administrator for this information. getting and passing the keys can by done by using the AWS CLI.  Be aware that they do expire after a time, so this process may need to be repeated.

```bash
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 716701816433.dkr.ecr.us-west-2.amazonaws.com
```

Once authenticated, docker will store these crednetials until they are invalid or replaced.

[Back to workspace setup](./devops_workspace.md)