pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                sh 'docker build -t simplepythonflask .'
            }
        }
        
        stage('Executa teste'){
            steps{
                sh 'docker run --rm -tdi --name=teste simplepythonflask'

                /*Utilizaremos o sleep aqui para dar tempo de subir a app e db para depois iniciar os testes, se não tivesse, os testes iria ficar sempre com failed*/
                sh 'sleep 10'

                sh 'docker exec -i teste nosetests --with-xunit --with-coverage --cover-package=project test_users.py'
                sh 'docker cp teste:/courseCatalog/nosetests.xml .'
                junit 'nosetests.xml'
            }
        }
    }
    post {
        always {
            echo 'One way or another, I have finished'
            deleteDir() /* clean up our workspace */
        }
        success {
            echo 'I succeeded!'
            sh 'docker stop teste'
        }
        unstable {
            echo 'I am unstable :/'
        }
        failure {
            echo 'I failed :('
            sh 'docker stop teste'
        }
        changed {
            echo 'Things were different before...'
        }
    }
}

