def call() {

    string pod_init_label = "wild-init-1"
    string pod_run_label = "wild-run-1"
    def k8s_containers_init = libraryResource('config/k8s/containers-init.yaml')
    def k8s_containers_run

    def colored_xterm = isColoredXterm()
    def env_variables_list = [
        "wild_path=./wild-workdir",
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

            logger.bannerLogo(libraryResource('config/banner/wild.txt'))

            stage('init') {

                withEnv(env_variables_list) {

                    logger.bannerStage('init')

                    //logger.info("This is an informational message.")
                    //logger.warn("This is a warning message.")
                    //logger.err("This is an error message.")
                    //logger.success("This is a success message.")
                    //logger.debug("This is a debug message.")
                    //logger.bannerLogo("Banner Logo")
                    //logger.bannerStage("My Stage")

                    sh(script: "git config --global http.sslverify false")
                    checkout scm

                    checkout([
                        $class                           : 'GitSCM',
                        branches                         : [[name: env."library.wild.version"]],
                        doGenerateSubmoduleConfigurations: false,
                        extensions                       : [
                            [$class: 'CleanBeforeCheckout'],
                            [$class: 'RelativeTargetDirectory', relativeTargetDir: './wild-workdir']
                        ],
                        submoduleCfg                     : [],
                        userRemoteConfigs                : [
                            [credentialsId: 'wild-github-token',
                             url          : 'https://github.com/scalastic/wild.git']
                        ]
                    ])

                    def config_containers = readYaml(file: "${wild_path}/config/k8s/containers-config.yaml")
                    def names_containers_run = []
                    container('wild') {
                        names_containers_run = sh(
                            script: '''
                            export JQ=$(which jq)
                            export WILD_CWD=${wild_path}
                            export LOG_PATH=${log_path}
                            bash --version
                            source ${wild_path}/src/lib/workflow.sh
                            workflow_get_workflows_containers_names ${wild_path}/test/config/workflow-default.json
                            ''',
                            returnStdout: true)
                    }
                    logger.info("workflow executed!")
                    def config_containers_run = containerConfig.getContainerConfig(config_containers, names_containers_run)
                    k8s_containers_run = containerConfig.generateContainerTemplate(config_containers_run)

                    logger.info("${k8s_containers_run}")

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

                def workflow = readJSON(file: "${wild_path}/config/workflow-default.json")
                logger.info("Processing workflow '${workflow.name}' version '${workflow.version}'...")

                workflow.actions.each { action ->
                    stage(action.name) {
                        logger.bannerStage(action.name)
                        container(action.container) {
                            sh "chmod +x ${action.script}"
                            sh "./${action.script}"
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