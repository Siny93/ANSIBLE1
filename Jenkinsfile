pipeline {
 agent { label 'WORKSTATION' }
  options {
  ansiColor('xterm')
  }

  parameters {
    choice(name: 'env', choices: ['dev', 'prod'], description: 'choose env')
    string(name: 'COMPONENT', defaultValue: '',description: 'which app content')
  }

  environment {
  SSH = credentials('CENTOS')
  }

   stages {
     stage('create server') {
       steps {
         sh 'bash ec2launch.sh ${COMPONENT} ${env}'
       }

     }
     stage('ansible playbook run') {
       steps {
         script {
           env.ANSIBLE_TAG=COMPONENT
         }
         sh 'sleep 60'
         sh 'ansible-playbook -i roboshop.inv roboshop.yml -e ENV=${env} -t ${ANSIBLE_TAG} -e ansible_password=${SSH_PSW} -u ${SSH_USR}'
       }
     }

   }
}
