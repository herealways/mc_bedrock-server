pipeline {
    agent {
        label 'jenkins-host'
    }
    environment {
        PREVIOUS_VERSION = '1.14.1.4'  // Version before update
        MC_VERSION = '1.14.32.1'  // We will update server to this version
        MAJOR_VERSION = '1.14'
        MY_EMAIL = credentials("my_gmail")
        // Used in vm_setup.sh and vm_halt.sh
        // VAGRANT_PROJECT_PATH = "/root/vagrant_projects/mc_centos7"
    }
    stages {
        stage('Build') {
            when {
                branch "dev"
            }
            steps {
                retry (3) {
                    // Tag a specific version like 1.14.32.1
                    sh "./jenkins/build.sh ${MC_VERSION}"
                }
            }
        }

        // Push test image (new version of game server) to Docker Hub
        stage('Push stage 1') {
            when {
                branch "dev"
            }
            environment {
                DOCKER_HUB = credentials("Docker_hub_herealways")
            }
            steps {
                // Tag specific version, major version and latest.
                retry(3) {
                    sh "./jenkins/push_test.sh ${MC_VERSION}"
                }
            }
        }

        // Setup test environment
        stage('Test') {
            when {
                branch "dev"
            }
            steps {
                // sh './jenkins/vm_setup.sh'
                sh 'ansible-galaxy install -r requirements.yml --force'
                withCredentials([sshUserPrivateKey(credentialsId: 'ansible_key',\
                keyFileVariable: 'ANSIBLE_KEY')]) {
                    ansiblePlaybook(playbook: 'mc_server.yml',\
                    inventory: '/root/ansible-playbooks/playbooks/mc_bedrock-server/ansible_inventory/remote_test_server',\
                    //credentialsId: "${ANSIBLE_KEY}",\
                    tags: 'deploy',\
                    extraVars: [MC_VERSION: "${PREVIOUS_VERSION}"],\
                    hostKeyChecking : false,\
                    colorized: true,\
                    extras: "--private-key ${ANSIBLE_KEY}")

                    ansiblePlaybook(playbook: 'mc_server.yml',\
                    inventory: '/root/ansible-playbooks/playbooks/mc_bedrock-server/ansible_inventory/remote_test_server',\
                    //credentialsId: "${ANSIBLE_KEY}",\
                    tags: 'update',\
                    extraVars: [MC_VERSION: "${MC_VERSION}"],\
                    hostKeyChecking : false,\
                    colorized: true,\
                    extras: "--private-key ${ANSIBLE_KEY}")

                    input message: "Did the test pass? Should we continue?"
                }
            }
        }

        stage('Stop test server') {
            input {
                message '''Should we stop test server?
                (Only works on dev branch.
We can safely proceed if the branch is not master)'''
                ok "Choose"
                parameters {
                    choice(name: 'IF_STOP_TEST_SERVER', choices: [true, false], description: '')
                }
            }
            when {
                branch 'dev'
                environment name: 'IF_STOP_TEST_SERVER', value: 'true'
            }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ansible_key',\
                keyFileVariable: 'ANSIBLE_KEY')]) {
                    ansiblePlaybook(playbook: 'mc_server.yml',\
                    inventory: '/root/ansible-playbooks/playbooks/mc_bedrock-server/ansible_inventory/remote_test_server',\
                    //credentialsId: "${ANSIBLE_KEY}",\
                    tags: 'halt',\
                    extraVars: [MC_VERSION: "${MC_VERSION}"],\
                    hostKeyChecking : false,\
                    colorized: true,\
                    extras: "--private-key ${ANSIBLE_KEY}")
                }
            }
        }

        // Tag and push tested docker image to Docker Hub
        stage('Push stage 2') {
            when {
                branch "master"
            }
            input {
                message '''Should we push docker image and update production server?
                (It only works when branch is master.
We can safely proceed if the branch is not master)'''
                submitter "here"
                ok "Proceed "
            }
            environment {
                DOCKER_HUB = credentials("Docker_hub_herealways")
            }
            steps {
                retry(3) {
                    sh "./jenkins/push.sh ${MC_VERSION} ${MAJOR_VERSION}"
                }
            }
        }

        stage('Deploy') {
            when {
                branch  "master"
            }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ansible_key',\
                keyFileVariable: 'ANSIBLE_KEY')]) {
                    ansiblePlaybook(playbook: 'mc_server.yml',\
                    inventory: '/root/ansible-playbooks/playbooks/mc_bedrock-server/ansible_inventory/production_server',\
                    //credentialsId: "${ANSIBLE_KEY}",\
                    tags: 'update',\
                    extras: "--private-key ${ANSIBLE_KEY}",\
                    extraVars: [MC_VERSION: "${MC_VERSION}"],\
                    hostKeyChecking : false,\
                    colorized: true)
                }
            }
        }
    }
    post {
        always {
            // sh './jenkins/vm_halt.sh'
            emailext subject: "${env.JOB_NAME} - Branch: ${env.BRANCH_NAME} - Build # ${env.BUILD_NUMBER} - ${currentBuild.currentResult}!",
                     body: """${env.JOB_NAME} - Branch: ${env.BRANCH_NAME} - Build # ${env.BUILD_NUMBER} - ${currentBuild.currentResult}:
Check console output at ${env.BUILD_URL} to view the results.""",
                     to: "${MY_EMAIL}"
        }
    }
}