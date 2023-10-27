podTemplate(containers: [
    containerTemplate(
    name: 'docker',
    image: 'docker:dind',
    command: 'sleep',
    ttyEnabled: true,
    privileged: true,
    args: '30d',
    envVars: [
      containerEnvVar(key: 'IMAGE_NAME', value: 'course_catalog' ),
      containerEnvVar(key: 'NEXUS_REPOSITORY', value: '192.168.0.12:8082'),
      containerEnvVar(key: 'HTTP_PROTOCOL', value: 'http://'),
      containerEnvVar(key: 'REGISTRY_URL', value: 'http://192.168.0.12:8082')
      ]
    ),
    containerTemplate(
    name: 'openjdk',
    image: 'openjdk:11',
    privileged: true,
    hostNetwork: true,
    command: 'sleep', args: '99d'),
    containerTemplate(
    name: 'kubectl',
    image: 'alpine:3.7',
    command: 'sleep', args: '99d',
    envVars: [
      containerEnvVar(key: 'IMAGE_NAME', value: 'course_catalog' ),
      containerEnvVar(key: 'NEXUS_REPOSITORY', value: '192.168.0.12:8082'),
      containerEnvVar(key: 'HTTP_PROTOCOL', value: 'http://'),
      containerEnvVar(key: 'REGISTRY_URL', value: 'http://192.168.0.12:8082')
      ]
      )
    ],
   volumes: [
   hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock')]
   ){
node(POD_LABEL) {
 
    environment {
      IMAGE_NAME="course_catalog"
      IMAGE_TAG="0.${BUILD_ID}"
      CONTAINER_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"
      HTTP_PROTOCOL="http://"
      NEXUS_REPOSITORY="192.168.0.12:8082"
      DOCKER_REGISTRY="${HTTP_PROTOCOL}${NEXUS_REPOSITORY}"
    }
 
    container('docker'){
 
    stage('Clone do repositorio') {
        git 'http://192.168.0.12:3000/root/simplePythonFlask.git'
   
    }
    stage('Dockerbuild') {
        sh 'docker build -t "$IMAGE_NAME:$BUILD_ID" .'
        sh 'docker tag "$IMAGE_NAME:$BUILD_ID" "$NEXUS_REPOSITORY/$IMAGE_NAME:$BUILD_ID"'
    }
   stage('Unit Testing'){
          sh 'docker run --rm -tdi --name unit "$NEXUS_REPOSITORY/$IMAGE_NAME:$BUILD_ID"'
    sh 'sleep 5'
    sh 'docker exec -t unit nosetests --with-xunit --with-coverage --cover-package=project test_users.py'
          sh 'docker cp unit:/courseCatalog/nosetests.xml .'
          sh 'docker stop unit'
   }
  stage('Gather test'){
  junit 'nosetests.xml'
  }
}
 
    container('openjdk'){
    stage('SonarQube Analysis'){
    script{
        def sonarScannerPath = tool 'SonarScanner'
        withSonarQubeEnv('SonarQube'){
        sh "${sonarScannerPath}/bin/sonar-scanner \
        -Dsonar.projectKey=courseCatalog -Dsonar.sources=. \
        -Dsonar.host.url=http://192.168.122.7:9000 \
                  -Dsonar.login=sqp_7ebbb592245a4163418696212e9ef773a33c99c5"
    }
    }
    }
    }
  container('docker'){
  stage('Nexus - Saving Artifact'){
         script{
          docker.withRegistry('http://192.168.0.12:8082', '447eab02-93ae-40cd-96ca-c57f72a567ff'){
          sh 'docker push "$NEXUS_REPOSITORY/$IMAGE_NAME:$BUILD_ID"'
        }
      }
   }
  }
    container('kubectl'){
    stage('Realizar deploy no Kubernetes') {
      sh 'apk update  && apk add --no-cache curl'
      sh 'curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl'
      sh 'chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl'
      sh 'kubectl set image deployment/web simplepythonflask=$NEXUS_REPOSITORY/$IMAGE_NAME:$BUILD_ID -n homolog '
      sh 'sleep 10'
      sh 'kubectl get pods -n homolog'
 
    }
    }
}
  post {
    always {
      echo "Pipeline finalizado."
      sh   'rm -rf simplePythonFlask'
    }
    success {
      echo "Pipeline finalizado com Sucesso"
    }
    failure {
      echo "Pipeline finalizado com Falha"
      sh   "docker image rm unit"
    }
  }
}