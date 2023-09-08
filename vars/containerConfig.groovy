
    def getContainerConfig(appConfig, selectedContainerNames = null) {
        //def appConfig = readYaml(file: "./wizard-workdir/config/containers-config.yaml")

        if (selectedContainerNames) {
            appConfig.container = appConfig.container.findAll { container ->
                selectedContainerNames.contains(container.name)
            }
        }

        return appConfig
    }

    def generateContainerTemplate(Map appConfig) {
        def containerTemplates = appConfig.container.collect { container ->
            def envVars = container.envVars.collect { envVar ->
                """
                - name: ${envVar.name}
                  value: "${envVar.value}"
                """
            }.join('\n')

            def volumeMounts = container.volumeMounts.collect { volumeMount ->
                """
                - name: ${volumeMount.name}
                  mountPath: ${volumeMount.mountPath}
                  readOnly: ${volumeMount.readOnly}
                """
            }.join('\n')

            def volumes = container.volumes.collect { volume ->
                """
                - name: ${volume.name}
                  persistentVolumeClaim:
                    claimName: ${volume.claimName}
                """
            }.join('\n')

            """
            - name: ${container.name}
              image: ${container.image}
              command:
                - "${container.command}"
              tty: ${container.tty}
              ${envVars ? "env:\n${envVars}" : ''}
              resources:
                limits:
                  cpu: ${container.resources.cpu.limit}
                  memory: ${container.resources.memory.limit}
                requests:
                  cpu: ${container.resources.cpu.request}
                  memory: ${container.resources.memory.request}
              securityContext:
                runAsNonRoot: true
                runAsUser: ${container.securityContext.runAsUser}
              ${volumeMounts ? "volumeMounts:\n${volumeMounts}" : ''}
            ${volumes ? "volumes:\n${volumes}" : ''}
            """
        }

        def containerTemplate = """
apiVersion: v1
kind: Pod
spec:
  containers:
${containerTemplates.join('\n')}
"""

        return containerTemplate
    }
