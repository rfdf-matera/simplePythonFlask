pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                docker build -t simplePythonFlask .
            }
        }
        
        stage('Executa teste'){
            steps{
                docker run --rm -tdi --name=teste simplepythonflask

                /*Utilizaremos o sleep aqui para dar tempo de subir a app e db para depois iniciar os testes, se não tivesse, os testes iria ficar sempre com failed*/
                sleep 10

                docker exec -ti teste nosetests --with-xunit --with-coverage --cover-package=project test_users.py
                docker cp teste:/courseCatalog/nosetests.xlm .
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
            docker stop teste
        }
        unstable {
            echo 'I am unstable :/'
        }
        failure {
            echo 'I failed :('
            docker stop teste
        }
        changed {
            echo 'Things were different before...'
        }
    }
}

