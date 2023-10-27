   pipeline{
    agent any
    tools{
        jdk 'jdk11'
        gradle 'gradle'
    }
    stages{
        stage('Cleanws'){
            steps{
                cleanWs()
            }
        }
        stage('checkout from scm'){
            steps{
                git branch: 'main', url: 'https://github.com/paraspahwa/Java-Gradle-Website.git'
            }
        }
        stage('Gradle compile'){
            steps{
                sh 'chmod +x gradlew'
                sh './gradlew compileJava'
            }
        }
        stage('Test Gradle'){
            steps{
                sh 'chmod +x gradlew'
                sh './gradlew test'
            }
        }
        stage('sonarqube Analysis'){
            steps{
                script{
                      withSonarQubeEnv(credentialsId: 'sonar-token') {
                        sh 'chmod +x gradlew'
                        sh './gradlew sonarqube'
                    }
                    //quality gate
                    timeout(time: 10, unit: 'MINUTES'){
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK'){
                            error "pipeline is aborted due to qualitygate failure: ${qg.status}"
                        }
                    }
                }
            }
        }
        stage('build Gradle'){
            steps{
                sh 'chmod +x gradlew'
                sh './gradlew build'
            }
        }
        stage("OWASP Dependency Check"){
            steps{
                dependencyCheck additionalArguments: '--scan ./ --format XML ', odcInstallation: 'dp-check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('build and push to nexus'){
            steps{
                script{
                    withCredentials([string(credentialsId: 'docker_pass', variable: 'docker_password')]) {
                        sh '''
                         docker build -t 43.205.139.161:8083/gradle1:latest .
                         docker login -u admin -p $docker_password 43.205.139.161:8083
                         docker push 43.205.139.161:8083/gradle1:latest
                         '''
                    }
                }
            }
        }
        stage('deploy to container'){
            steps{
                script{
                    withCredentials([string(credentialsId: 'docker_pass', variable: 'docker_password')]) {
                        sh 'docker run -d --name g1 -p 8082:8080 43.205.139.161:8083/gradle1:latest'
                    }
                }
            }
        }
    }
}
