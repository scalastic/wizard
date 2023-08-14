# Automated Jenkins Installation on Docker for Testing with Kubernetes Integration

## Prerequisites

- Docker must be installed.
- Kubernetes must be installed.

## Installation

To set up a new Jenkins instance, execute the following command:
```bash
./test/jenkins/install.sh
```

## Testing

Follow these steps to test the Kubernetes integration:

1. Create a pipeline named `test-kubernetes-agent`.
2. Insert the provided pipeline definition script:

```groovy
pipeline {
    agent {
        kubernetes {
            yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: maven
            image: maven:alpine
            command:
            - cat
            tty: true
          - name: node
            image: node:16-alpine3.12
            command:
            - cat
            tty: true
        '''
        }
    }
    stages {
        stage('Run maven') {
            steps {
                container('maven') {
                    sh 'mvn -version'
                }
                container('node') {
                    sh 'npm version'
                }
            }
        }
    }
}
```

3. Execute the pipeline; two agents should be deployed on the Kubernetes cluster.

## References

- [Automating Jenkins Setup with Docker and Jenkins Configuration as Code](https://www.digitalocean.com/community/tutorials/how-to-automate-jenkins-setup-with-docker-and-jenkins-configuration-as-code)
- [GitHub - Jenkins Configuration as Code Plugin Demos](https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos)
- [YouTube - Automated Jenkins Setup using Docker and Configuration as Code](https://www.youtube.com/watch?v=ZXaorni-icg)
- [GitHub Gist - Kubernetes Cluster Info Command](https://gist.github.com/darinpope/67c297b3ccc04c17991b22e1422df45a)

## Useful Commands

- `kubectl cluster-info`: Retrieve information about the Kubernetes cluster, including the Kubernetes control plane address (e.g., https://kubernetes.docker.internal:6443).