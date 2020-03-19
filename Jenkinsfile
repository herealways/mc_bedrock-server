pipeline {
    agent {
        label 'jenkins-host'
    }
    environment {
        PREVIOUS_VERSION = '1.14.1.4'   // used in test and staging env
        MC_VERSION = '1.14.32.1'
        MAJOR_VERSION = '1.14'
        MY_EMAIL = credentials("my_gmail")
    }
    stages {
        stage('Build') {
            when {
                branch "dev"
            }
            steps {
                sh './jenkins/build.sh'
            }
        }

        stage('Test') {
            when {
                branch "dev"
            }
            steps {
                sh './jenkins/vm_setup.sh'
                sh './ansible-galaxy install -r requirements.yml'
                withCredentials([sshUserPrivateKey(credentialsId: 'ansible_key',\
                keyFileVariable: 'ANSIBLE_KEY')]) {
                    sh 'ansible-galaxy install -r requirements.yml'
                    ansiblePlaybook(playbook: 'mc_server.yml',\
                    credentialsId: 'ANSIBLE_KEY',\
                    inventory: 'ansible_inventory/test_server',\
                    tags: 'deploy',\
                    extraVars: [MC_VERSION: "${PREVIOUS_VERSION}"],\
                    disableHostKeyChecking : true,\
                    colorized: true,\
                    extras: '-u vagrant')

                    ansiblePlaybook(playbook: 'mc_server.yml',\
                    credentialsId: 'ANSIBLE_KEY',\
                    inventory: 'ansible_inventory/test_server',\
                    tags: 'update',\
                    extraVars: [MC_VERSION: "${MC_VERSION}"],\
                    disableHostKeyChecking : true,\
                    colorized: true,\
                    extras: '-u vagrant')
                }
                input message: 'Did the test pass? Should we push the image?'
                sh './jenkins/vm_halt.sh'
            }
        }

        stage('Push') {
            when {
                branch "dev"
            }
            environment {
                DOCKER_HUB = credentials("Docker_hub_herealways")
            }
            steps {
                sh "./jenkins/push.sh ${MC_VERSION} ${MAJOR_VERSION}"
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
                    credentialsId: 'ANSIBLE_KEY',\
                    inventory: 'ansible_inventory/production_server',\
                    tags: 'update',\
                    extraVars: [MC_VERSION: "${MC_VERSION}"],\
                    disableHostKeyChecking : true,\
                    colorized: true)
                }
            }
        }
    }
    post {
        failure {
            emailext(subject: "${DEFAULT_SUBJECT}",\
                     body: "${DEFAULT_CONTENT}",\
                     to: "${MY_EMAIL}")
        }

        success {
            emailext(subject: "${DEFAULT_SUBJECT}",\
                     body: "${DEFAULT_CONTENT}",\
                     to: "${MY_EMAIL}")
        }
    }
}