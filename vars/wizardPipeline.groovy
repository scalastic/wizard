def call() {

    string pod_init_label = "wizard-init-1"
    string pod_run_label = "wizard-run-1"
    def k8s_containers_init = libraryResource('config/k8s/containers-init.yaml')
    def k8s_containers_run

    def colored_xterm = isColoredXterm()
    def env_variables_list = [
        "wizard_path=./wizard-workdir",
        "log_path=${env.WORKSPACE}/log",
        "current_git_branch=${env.BRANCH_NAME}",
        "colored_xterm=${colored_xterm}",
    ]

    podTemplate(
        label: pod_init_label,
        yaml: k8s_containers_init,
        yamlMergeStrategy: merge()
    ) {
        node(pod_init_label) {

            logger.bannerLogo(libraryResource('config/banner/wizard.txt'))

            stage('init') {

                withEnv(env_variables_list) {

                    logger.bannerStage('init')

                    sh(script: "git config --global http.sslverify false")
                    checkout scm

                    checkout([
                        $class                           : 'GitSCM',
                        branches                         : [[name: env."library.wizard.version"]],
                        doGenerateSubmoduleConfigurations: false,
                        extensions                       : [
                            [$class: 'CleanBeforeCheckout'],
                            [$class: 'RelativeTargetDirectory', relativeTargetDir: './wizard-workdir']
                        ],
                        submoduleCfg                     : [],
                        userRemoteConfigs                : [
                            [credentialsId: 'wizard-github-token',
                             url          : 'https://github.com/scalastic/wizard.git']
                        ]
                    ])

                    def config_containers = readYaml(file: "${wizard_path}/config/k8s/containers-config.yaml")
                    def names_containers_run = []
                    container('wizard') {
                        names_containers_run = sh(
                            script: '''
                            export JQ=$(which jq)
                            export WIZARD_CWD=${wizard_path}
                            export LOG_PATH=${log_path}
                            bash --version
                            source ${wizard_path}/src/lib/workflow.sh
                            workflow_get_workflows_containers_names ${wizard_path}/config/workflow-default.json
                            ''',
                            returnStdout: true)
                    }
                    logger.info("Workflow pipeline is initialized!")
                    def config_containers_run = containerConfig.getContainerConfig(config_containers, names_containers_run)
                    k8s_containers_run = containerConfig.generateContainerTemplate(config_containers_run)

                    stash name: "init", useDefaultExcludes: false
                }
            }
        }
    }

    podTemplate(
        label: pod_run_label,
        yaml: k8s_containers_run,
        yamlMergeStrategy: merge()
    ) {
        node(pod_run_label) {

            withEnv(env_variables_list) {

                unstash "init"

                def workflow = readJSON(file: "${wizard_path}/config/workflow-default.json")
                logger.info("Processing workflow '${workflow.name}', version '${workflow.version}'...")

                workflow.actions.each { action ->
                    stage(action.name) {
                        logger.bannerStage(action.name)
                        container(action.container) {
                            if (action.pre_script?.trim()) {
                                logger.info("Processing PRE action script ${action.pre_script}...")
                                sh "chmod +x ${action.pre_script}"
                                sh "./${action.pre_script}"
                            }
                            logger.info("Processing MAIN action script ${action.script}...")
                            sh "chmod +x ${action.script}"
                            sh "./${action.script}"
                            if (action.post_script?.trim()) {
                                logger.info("Processing POST action script ${action.post_script}...")
                                sh "chmod +x ${action.post_script}"
                                sh "./${action.post_script}"
                            }
                        }
                    }
                }
            }
        }
    }
}

private Boolean isColoredXterm() {
    try {
        ansiColor('xterm') {
            return true
        }
    } catch (Throwable ex) {
        return false
    }
}