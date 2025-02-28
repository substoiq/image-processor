A GitHub Actions workflow file for building and pushing your Docker image to both Docker Hub and GitHub Container Registry:

This GitHub Actions workflow will build your Docker image and push it to both Docker Hub and GitHub Container Registry when you push to the main branch or create tags starting with 'v'.

## Where to put the workflow file

Save this file at `.github/workflows/docker-build-push.yml` in your repository:

```bash
mkdir -p .github/workflows
cp docker-build-push.yml .github/workflows/
```

## Setting up GitHub Secrets

You need to configure the following secrets in your GitHub repository:

1. Go to your GitHub repository
2. Click on "Settings" tab
3. Click on "Secrets and variables" → "Actions" in the left sidebar
4. Click on "New repository secret" to add each of these:

| Secret Name | Description |
|-------------|-------------|
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | Your Docker Hub access token (not your password) |

The `GITHUB_TOKEN` is automatically provided by GitHub Actions, so you don't need to add it manually.

## How to create a Docker Hub access token

1. Log in to [Docker Hub](https://hub.docker.com/)
2. Click on your username → "Account Settings" → "Security"
3. Click on "New Access Token"
4. Give it a name (e.g., "GitHub Actions") and select appropriate permissions
5. Copy the token immediately (you won't be able to see it again)
6. Use this token as your `DOCKERHUB_TOKEN` secret in GitHub

## How the workflow works

This workflow:

1. Runs on pushes to your main branch, tag creations starting with 'v', and pull requests to main
2. Logs in to both Docker Hub and GitHub Container Registry
3. Generates appropriate tags based on the event (branch, PR, tag, etc.)
4. Builds the Docker image using BuildX for better caching
5. Pushes the image to both registries (except on pull requests)

When you push to the main branch, it will create and push images tagged with 'latest' and the short commit SHA. When you create a tag like 'v1.2.3', it will create images tagged with '1.2.3', '1.2', and the tag name.

---

The `pull_request` trigger in the GitHub Actions workflow makes the workflow run when a pull request targeting the main branch is created or updated, but with a key difference - it will only build the Docker image without pushing it to any registry.

Reasons:

1. **Validation**: It ensures that the Docker build process itself succeeds on pull requests before they're merged to main. This catches build errors early in the development cycle.

2. **Security**: For external contributors or pull requests from forks, you don't want to allow pushes to your registries until the code has been reviewed and merged.

3. **Preview**: Maintainers can see if the Docker image builds correctly without having to push potentially untested or insecure images to your public registries.

In the workflow, this behavior is controlled by the condition:
```yaml
push: ${{ github.event_name != 'pull_request' }}
```

This line ensures that the image is only pushed to registries when the event is NOT a pull request. During pull requests, the image is built but not pushed anywhere.

You can safely remove the pull request trigger if you prefer not to run Docker builds on PRs at all, but having it there provides an extra layer of verification before changes get merged to your main branch.
