# Automated Jenkins Installation using Docker for Testing with Kubernetes Integration

## Prerequisites

- You must have Docker installed.
- You must also have Kubernetes installed.

## Installation

1. Start by copying the contents of `.env.template` into a new file named `.env`. In this newly created file, provide your GitHub Token. This token is necessary to access the Git repository where the "wizard" application is installed.

2. To set up a fresh Jenkins instance, execute the following command:
```bash
./test/jenkins/install.sh
```

3. During this process:
- A new Jenkins instance will be initialized.
- Configuration for a Kubernetes Cloud will be set up.
- A test pipeline job will be created.
- Credentials for both Kubernetes and GitHub pipeline code will be generated.

## Testing

To verify the integration with Kubernetes, follow these steps:

1. Run the pipeline named `test-kubernetes-agent`.
2. This action will deploy a bash agent into the Kubernetes cluster.
3. The pipeline is expected to complete successfully.

## References

- [Tutorial: Simplifying Jenkins Setup using Docker and Jenkins Configuration as Code](https://www.digitalocean.com/community/tutorials/how-to-automate-jenkins-setup-with-docker-and-jenkins-configuration-as-code)
- [GitHub Repository: Examples for Jenkins Configuration as Code Plugin](https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos)
- [YouTube Video: Efficient Jenkins Setup using Docker and Configuration as Code](https://www.youtube.com/watch?v=ZXaorni-icg)
- [GitHub Gist: Command to Retrieve Information about the Kubernetes Cluster](https://gist.github.com/darinpope/67c297b3ccc04c17991b22e1422df45a)
- [Job DSL Plugin](https://plugins.jenkins.io/job-dsl/)

## Useful Commands

- `kubectl cluster-info`: Obtain comprehensive details about the Kubernetes cluster, including the address of the Kubernetes control plane (e.g., https://kubernetes.docker.internal:6443).